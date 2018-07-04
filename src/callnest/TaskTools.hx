package callnest;


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
    public static function fromException<T>(exception:Any):Task<T> {
        var source = TaskDefaults.newTaskSource();
        source.setException(exception);
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
        var taskSource = TaskDefaults.newTaskSource();

        for (task in tasks) {
            allTasks.push(task);
            remainingTasks.set(task, true);
            remainingCount += 1;
        }

        function callback(task:Task<T>) {
            if (remainingTasks.remove(task)) {
                remainingCount -= 1;
            }

            if (remainingCount == 0) {
                taskSource.setResult((allTasks:Iterable<Task<T>>));
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

        function callback(task:Task<T>) {
            if (!taskSource.task.isComplete) {
                taskSource.setResult(task);
            }
        }

        for (task in tasks) {
            task.onComplete(callback);
        }

        return taskSource.task;
    }
}
