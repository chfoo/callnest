package callnest;


/**
    Source of a `Task` instance.

    See also `FutureSource`.
**/
interface TaskSource<T> extends FutureSource<T> {
    /**
        The `Task` instance associated with this source.
    **/
    var task(get, never):Task<T>;

    /**
        Runs synchronous code as a task.

        When an appropriate implementation is provided, this method runs
        synchronous code in the background. By default, the callback
        is run synchronously.

        @param callback A function returning the result for the task.
        @param scheduler Optional scheduler to override the default scheduler.
    **/
    function run(callback:Void->T, ?scheduler:Scheduler):Void;
}
