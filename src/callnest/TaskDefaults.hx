package callnest;

import callnest.impl.BuiltinFutureSource;
import callnest.impl.BuiltinTaskSource;
import callnest.impl.SynchronousScheduler;
import haxe.CallStack;


/**
    Global, default implementation configuration.
**/
class TaskDefaults {
    /**
        Default scheduler.
    **/
    public static var scheduler(get, set):Scheduler;

    static var _scheduler:Scheduler;

    static function get_scheduler():Scheduler {
        if (_scheduler == null) {
            _scheduler = new SynchronousScheduler();
        }

        return _scheduler;
    }

    static function set_scheduler(value:Scheduler) {
        return _scheduler = value;
    }

    /**
        Returns a new `FutureSource`.

        This function can be reassigned to provide your own implementation.
    **/
    public dynamic static function newFutureSource<T>():FutureSource<T> {
        return new BuiltinFutureSource<T>();
    }

    /**
        Returns a new `TaskSource`.

        This function can be reassigned to provide your own implementation.
    **/
    public dynamic static function newTaskSource<T>():TaskSource<T> {
        return new BuiltinTaskSource<T>();
    }

    /**
        Handles uncaught exceptions.

        By default, it is passed to `trace()` and rethrown.

        This function can be reassigned to provide your own global error
        handling.
    **/
    public dynamic static function handleException(info:ExceptionInfo) {
        trace('Unhandled exception: ${info.exception}');

        var callStack;

        switch info.callStack {
            case Some(callStack_):
                callStack = callStack_;
            case None:
                callStack = CallStack.exceptionStack();
        }

        trace('Exception stack: ${CallStack.toString(callStack)}');

        #if debug
        trace('Call stack: ${CallStack.toString(CallStack.callStack())}');
        #end

        throw info.exception;
    }
}
