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
}
