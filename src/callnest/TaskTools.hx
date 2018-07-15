package callnest;

import haxe.CallStack;

/**
    Task manipulation methods.
**/
class TaskTools {
    /**
        Returns a completed Task with the given result.
    **/
    public static function fromResult<T>(result:T):Task<T> {
        var source = TaskDefaults.newTaskSource();
        source.setResult(result);
        return source.task;
    }

    /**
        Returns a completed Task with the given exception.
    **/
    public static function fromException<T>(exception:Any,
            ?callStack:Array<StackItem>):Task<T> {
        var source = TaskDefaults.newTaskSource();
        source.setException(exception, callStack);
        return source.task;
    }

    /**
        Returns an aggregated task that completes when all of the given
        tasks complete.
    **/
    public static function whenAll<T>(tasks:Iterable<Task<T>>)
            :Task<Iterable<Task<T>>> {
        var allTasks = [];
        var remainingCount = 0;
        var remainingTasks = new Map<Task<T>,Bool>();
        var taskSource:TaskSource<Iterable<Task<T>>> = TaskDefaults.newTaskSource();

        for (task in tasks) {
            allTasks.push(task);
            remainingTasks.set(task, true);
            remainingCount += 1;
        }

        if (allTasks.length == 0) {
            taskSource.setResult([]);
            return taskSource.task;
        }

        function callback(task:Task<T>) {
            if (remainingTasks.remove(task)) {
                remainingCount -= 1;
            }

            if (remainingCount == 0) {
                taskSource.setResult(allTasks);
            }
        }

        for (task in allTasks) {
            task.onComplete(callback);
        }

        return taskSource.task;
    }

    /**
        Returns an aggregated task that completes when any of the given
        tasks complete.
    **/
    public static function whenAny<T>(tasks:Iterable<Task<T>>):Task<Task<T>> {
        var taskSource = TaskDefaults.newTaskSource();
        var count = 0;

        function callback(task:Task<T>) {
            if (!taskSource.task.isComplete) {
                taskSource.setResult(task);
            }
        }

        for (task in tasks) {
            task.onComplete(callback);
            count += 1;
        }

        if (count == 0) {
            throw new Exception("tasks cannot be empty");
        }

        return taskSource.task;
    }

    /**
        Chains and returns a task using the given callback that returns a
        task.

        This is a convenience method to `Task.continueWith` that:

        1. Calls `Task.getResult`
        2. Discards the result (but still propagates exceptions)
        3. Returns a task returned by the callback
    **/
    public static function continueNext<T,TNext>(task:Task<T>,
            callback:Void->Task<TNext>):Task<TNext> {
        return task.continueWith(function (task) {
            task.getResult();
            return callback();
        });
    }

    /**
        Chains and returns a task using the given callback that accepts and
        returns a result.

        This is a convenience method to `Task.continueWith` that:

        1. Calls `Task.getResult`
        2. Passes the result to the given callback
        3. Creates a new task with the result set to the given callback's
            return value
    **/
    public static function thenContinue<T,TNext>(task:Task<T>,
            callback:T->TNext):Task<TNext> {
        return task.continueWith(function (task) {
            var result = task.getResult();
            return fromResult(callback(result));
        });
    }

    /**
        Chains and returns a task using the given callback that returns a
        result.

        This is a convenience method to `Task.continueWith` that:

        1. Calls `Task.getResult`
        2. Discards the result (but still propagates exceptions)
        3. Creates a new task with the result set to the given callback's
            return value
    **/
    public static function thenNext<T,TNext>(task:Task<T>,
            callback:Void->TNext):Task<TNext> {
        return task.continueWith(function (task) {
            task.getResult();
            return fromResult(callback());
        });
    }

    /**
        Chains and returns a task with the given result.

        This is a convenience method to `Task.continueWith` that:

        1. Calls `Task.getResult`
        2. Discards the result (but still propagates exceptions)
        3. Creates a new task with the result set to the given value
    **/
    public static function thenResult<T,TNext>(task:Task<T>,
            result:TNext):Task<TNext> {
        return task.continueWith(function (task) {
            task.getResult();
            return fromResult(result);
        });
    }
}
