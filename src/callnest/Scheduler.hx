package callnest;


/**
    Schedules routines to be executed.

    The scheduler is used to schedule synchronous code (such as blocking IO
    or intensive computations) to execute in the background. Some
    implementation examples include executing one or a few task each frame,
    queuing them to `haxe.MainLoop`, or submitting them to a thread pool
    executor.

    If the target does not support facilities to allow this, the scheduler
    may simply execute them synchronously. Synchronous execution is the
    default behavior.
**/
interface Scheduler {
    /**
        Schedule the callback to be executed.
    **/
    function addCallback<T>(callback:Void->T):Future<T>;
}
