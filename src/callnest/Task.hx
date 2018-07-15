package callnest;


/**
    Asynchronous result and management.

    A `Task` extends `Future` to provide methods that allow tasks to chain
    and propagate results between tasks automatically. It also encapsulates
    the pattern of an asynchronous unit of work.
**/
interface Task<T> extends Future<T> {
    /**
        See `Future.onComplete`.
    **/
    function onComplete(callback:Task<T>->Void):Task<T>;

    /**
        See `Future.handleException`.
    **/
    function handleException(handler:ExceptionInfo->Void):Task<T>;

    /**
        Chains a given task to be executed when this task completes.

        This method allows a sequence of tasks to be run without nesting
        callbacks nor using boilerplate code to propagate results. When
        this task completes, the callback is executed. The callback
        is free to process the result or throw an exception which will
        be handled automatically.

        Exceptions and cancellations are propagated depending on the
        implementation. The builtin way passes a completed task to each
        callback in the chain which allows each callback to react to
        exceptional cases. A consequence is that an exception may be thrown
        on each step of the chain.

        An alternate way is to short-circuit the chain when there is an
        exception or cancellation. This may have unintended side-effects if
        not used correctly.

        @param callback A callback that is called when the task completes and
            returns a task representing more tasks or a final result.
    **/
    function continueWith<R>(callback:Task<T>->Task<R>):Task<R>;
}
