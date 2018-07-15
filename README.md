Callnest
========

Callnest is, yet another, future/promise/task/asynchronous library for Haxe. However, the goal is to provide a consistent and unified interface for bringing your own async implementations and building on top of them.


Why
---

There are (too) many async Haxe libraries, such as [Promhx](https://github.com/jdonaldson/promhx), [thx.promise](https://github.com/fponticelli/thx.promise), [tink_core](https://github.com/haxetink/tink_core), and [hxbolts](https://github.com/restorer/hxbolts), which provide implementations of an asynchronous pattern to various degrees. Some provide event loop and background execution support, while some provide exception handling. A good starting read is [this blog post series](https://blog.zame-dev.org/why-hxbolts/).

They function well, but it becomes apparent that they can be lacking when once you have used a more powerful language supporting coroutines with `async` and `await` keywords (as known as the ["Blub paradox"](https://en.wikipedia.org/wiki/Paul_Graham_(programmer)#The_Blub_paradox)).

`async` and `await` isn't in Haxe, but that does not mean it should stop us from incorporating good async design and patterns.


Using the library
-----------------

Install using haxelib:

        haxelib install callnest

The library deals with two concerns: an interface to asynchronous results and scheduling the execution of asynchronous routines.

### Future

The `Future` interface provides an API to asynchronous results.

To create a `Future`, create an instance which implements `FutureSource`. `FutureSource` is the write API ("promise") to the read API of `Future`. This pattern allows us to separate the producer and consumer concerns within a function:

```haxe
function download(url:String):Future<Bytes> {
    var source:FutureSource<Bytes> = TaskDefaults.newFutureSource();

    var httpClient = new HTTPClient();
    httpClient.onFinish = function (event:Event) {
        source.setResult(event.data);
    };
    httpClient.onError = function (event:Event) {
        source.setException(new DownloadException("Failed to download"));
    }
    httpClient.get(url);

    return source.future;
}
```

In the above example, we attach our callbacks to the hypothetical async HTTP client which either sets the result or an exception to the future. The future from the future source is returned.

Now, we call our function and process the result:

```haxe
download("http://example.com/data.png").onComplete(function (future:Future)) {
    var data:Bytes;

    try {
        data = future.getResult();
    } catch (exception:DownloadException) {
        reportDownloadFailure();
        return;
    }

    saveDownload(data);
});
```

The `Future.onComplete()` method allows us to attach our callback when the future has been resolved with a promise. `Future.getResult()` either returns the result or throws an exception. We don't have separate callback methods for success or exception to discourage implicit branching.

You can also access the result or exception on the `Future.result` or `Future.exception` property. The state of future can be checked by its `isCompleted`, `hasResult`, and `hasException` properties.

Before we continue, what happens if our callback to `onComplete()` throws an exception? That is up to the implementation to decide. It may let it propagate to the main thread, log the error and continue on, or crash silently. If we want to catch this error, we can wrap our code in a try-catch block, or better yet, add an error handling callback with `handleException()`.

```haxe
download()
    .onComplete(function (future) {
        1 / 0; // oops!
    })
    .handleException(function (info:ExceptionInfo) {
        trace('Internal error! Something has gone wrong: ${info.exception}');
        shutdown();
    });
```

In the example above, we add our handler which logs it and then quits the program gracefully with the hypothetical `shutdown()` method. If this becomes boilerplate, you can set the global error handler on `TaskDefaults.handleException`.

While it's simple to process a single `Future`, further processing of `Future`s will get messy as in the following example:

```haxe
// Avoid doing this!

download("http://example.com/data.png").onComplete(function (future:Future)) {
    var data:Bytes;

    try {
        data = future.getResult();
    } catch (exception:DownloadException) {
        reportDownloadFailure();
        return;
    }

    reupload(data).onComplete(function (future) {
        var shareLink;

        try {
            shareLink = future.getResult();
        } catch (exception:DownloadException) {
            reportDownloadFailure();
            return;
        }

        sendLink(shareLink).onComplete(
            // [...]

            everythingIsDone();
        )
    });
});
```

We can avoid this callback hell by rewriting the anonymous functions into named functions, but there are still issues of result and exception propagation.

For example, we could wrap all the code into a single function and change `everythingIsDone()` to set a result to `FutureSource`:

```haxe
// Avoid doing this!

function doAllTheThings():Future<Bool> {
    var futureSource<Bool> = TaskDefaults.newFutureSource();

    download("http://example.com/data.png").onComplete(
        // [...]
        try {
            // [...]
        } catch (exception:Dynamic) {
            futureSource.setException(exception);
            return;
        }

        // [...]

            try {
                // [...]
            } catch (exception:Dynamic) {
                futureSource.setException(exception);
                return;
            }

            futureSource.setResult(true);
        // [...]
    );

    return futureSource.future;
}
```

Ouch, that looks awful! There's a lot of boilerplate code just to ensure the result and exceptions are propagated to the `FutureSource` in `doAllTheThings()`. This can be very error prone. Let's look at using `Tasks` which will make propagation automatic.


### Task

The `Task` interface extends from `Future` and provides an API to schedule the task and chain additional tasks.

The usage of `Task` is similar to a `Future`:

```haxe
function download(url:String):Task<Bytes> {
    var source:TaskSource<Bytes> = TaskDefaults.newTaskSource();

    var httpClient = new HTTPClient();
    httpClient.onFinish = function (event:Event) {
        source.setResult(event.data);
    };
    // [...]

    return source.task;
}

download("http://example.com/data.png").onComplete(function (task:Task)) {
    var data:Bytes;

    try {
        data = task.getResult();
    } catch (exception:DownloadException) {
        reportDownloadFailure();
        return;
    }

    // [...]
});
```

However, `doAllTheThings()` can be written such that `Task`s are chained together:

```haxe
function doAllTheThings():Task<Bool> {
    return download("http://example.com/data.png")
        .continueWith(function (task:Task<Bytes>):Task<String> {
            var data = task.getResult();
            return reupload(data);
        })
        .continueWith(function (task:Task<String>):Task<Bool> {
            var shareLink = task.getResult();
            return sendLink(shareLink);
        });
}

doAllTheThings()
    .onComplete(function (task:Task<Bool>)) {
        var success;

        try {
            success = task.getResult();
        } catch (exception:DownloadException) {
            trace('Error downloading: $exception');
            return;
        }

        trace('Image shared success: $success');
    });
```

In the example above, `Task.continueWith()` accepts a callback that will process the task and return another task to be processed. The chain continues on until a final `onComplete()`.

If an exception is thrown within `continueWith()`, the exception will be caught and a new `Task` with the exception will be passed along to a subsequent `continueWith()` or `onSuccess()` method calls.


### Unused results

If you need to use tasks that don't have a useful return, you can use the `VoidReturn` enum:

```haxe
import callnest.VoidReturn;

function doSomething():Task<VoidReturn> {
    // Do work
    source.setResult(Nothing);
}

doSomething()
    .onComplete(doFinishingWork);
```

Note that using `Void` may be allowed in some instances, but it may be a bug in Haxe and is not supported in some targets.


### Convenience methods for chaining tasks

If you chain tasks that don't use the prior result in this processing, then `TaskTools.continueNext` may be used:

```haxe
using callnest.TaskTools;

function doSomething():Task<VoidReturn> {
    // Do work
    source.setResult(VoidReturn);
}

function doSomethingElse():Task<VoidReturn> {
    // Do work
    source.setResult(VoidReturn);
}

doSomething()
    .continueNext(doSomethingElse)
    .onComplete(doFinishingWork);
```

Additionally, if you chain tasks that don't need fine grain control or exception handling, `TaskTools` provides "then" methods that skip task boilerplate code:

```haxe
using callnest.TaskTools;

function doSomething():Task<Int> {
    // Do work
    source.setResult(123);
}


doSomething()
    .thenContinue(function (result:Int) { return result + 1; })
    .thenNext(function () { return 100; })
    .thenResult(200)
    .onComplete(function (task:Task<Int>) {
        trace(task.getResult()); // => 200
    });
```


### Cancellation

Both `Future` and `Task` support cancellation. When the `cancel()` method is called, the instance goes into the cancelled state and further changes to result and exception values will throw an exception.

The source can check whether the task is cancelled before setting the result:

```haxe
function download(url:String):Future<Bytes> {
    var source:FutureSource<Bytes> = TaskDefaults.newFutureSource();

    var httpClient = new HTTPClient();
    httpClient.onFinish = function (event:Event) {
        if (source.task.isCanceled) {
            return;
        }
        source.setResult(event.data);
    };
    httpClient.onError = function (event:Event) {
        if (source.task.isCanceled) {
            return;
        }
        source.setException(new DownloadException("Failed to download"));
    }
    httpClient.get(url);

    return source.future;
}
```

The consumer can check when the task completes:

```haxe
var task = download().onComplete(function (task) {
    if (task.isCanceled) {
        // Skip doing extra work
        return;
    }

    // Do things..
});

task.cancel();
```

Within `Task.completeWith()`, implementations can propagate cancellation by two ways:

The first way is catching the exception and passing a canceled task. Each part of the chain can either handle the canceled task or let the exception be thrown again. The builtin implementation uses this way.

The second way is short-circuiting by skipping the execution of the callbacks and only returning a cancelled task. This may perform better, but may cause unintended side-effects if not used correctly.


### Running Synchronous Code Asynchronously

Up until now, we have only been wrapping asynchronous routines that are natively supported on the target. If the target supports running synchronous routines (such as blocking IO or intensive computations) in the background (such as in a thread pool), then it would be useful to use the task pattern for this case.

Instead of calling `TaskSource.setResult`, call `TaskSource.run` with a callback that returns a value or throws an exception:

```haxe
function intensiveCalculation():Task<Float> {
    var taskSource = TaskDefaults.newTaskSource();

    taskSource.run(function () {
        // Long running computation here
        // [...]

        return 123.456;
    });

    taskSource.task;
}
```

In the example above, we do our computation in the `run()` method. This method will schedule the callback for execution. If we return a value or throw an exception, it will automatically set the result or exception on the task source.


### Scheduling Tasks

An implication of running synchronous routines within `TaskSource.run` is the need to schedule the running of them. When a task contains asynchronous routines, it will use the underling scheduler. When executing `TaskSource.run`, the library does not know how to execute it asynchronously.

This library aims to be flexible by allowing to specify a scheduler per task or globally.

A `Scheduler` will do the appropriate action to run the task. Running one or a few tasks on a frame in OpenFL, queueing them to `haxe.MainLoop`, or submitting to a thread pool executor are such examples.

By default, it will use a scheduler specified on the `TaskDefaults` class. The builtin default runs everything synchronously. You can change the scheduler described in the section below, or by providing a scheduler instance for methods that accept a scheduler argument.


Bringing your own implementation
--------------------------------

You can bring your implementation by implementing the interfaces, using helper classes, or by using static method extensions. Implementing interfaces is suggested for wrapping an existing library or providing an optimized implementation. Helper classes and static extension is suggested for providing additional features not included in this library's API.

To change the scheduler, set the static property `TaskDefaults.scheduler` with an instance implementing `Scheduler`. Likewise, the `TaskDefaults.newTaskSource()` and `TaskDefaults.newFutureSource()` can be changed.


### Extending

If you find that writing boilerplate, it may be useful to rewrite it as a static extension.

```haxe
class CustomTaskTools {
    public static function trySetResult<T>(taskSource:TaskSource, result:T):Bool {
        if (!taskSource.task.hasResult) {
            taskSource.setResult(result);
            return true;
        } else {
            return false;
        }
    }

    public static function sum(taskTools:Class<TaskTools>, tasks:Array<Float>):Task<Float> {
        var currentSum = 0;
        var callback;

        callback = function (task:Task<Float>) {
            currentSum += task.getResult();

            if (tasks.length == 0) {
                return TaskTools.fromResult(currentSum);
            } else {
                return tasks.pop().continueWith(callback);
            }
        }

        return tasks.pop().continueWith(callback);
    }
}
```

Then, you can use it with the `using` keyword:

```haxe
using CustomTaskTools;

// Static extension over TaskSource instance:
var taskSource = TaskDefaults.newTaskSource();
taskSource.trySetResult(123);

// Static extension over TaskTools class:
TaskTools.sum([task1, task2, task3])
    .onComplete(function (task) {
        var sum = task.getResult();
        trace('The result is $sum');
    });
```


Thread Safety
-------------

The builtin implementations are not thread-safe. That is, futures/tasks and their sources must not be mutated in different threads. Alternatively, you may bring your own thread-safe implementations.


Further reading
---------------

For details, see the API documentation at https://chfoo.github.io/callnest/api/


Development
-----------

Running tests:

        haxelib haxe hxml/test.neko.hxml && neko out/neko/test.n
        haxelib haxe hxml/test.cpp.hxml && ./out/cpp/TestAll-debug
