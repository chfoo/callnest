package callnest;

import haxe.CallStack;


/**
    Asynchronous producer.

    A `FutureSource` is the write interface to the future & promise pattern.
    It represents a method ("promise") of resolving a result to a `Future`.
**/
interface FutureSource<T> {
    /**
        The future instance associated with this source.
    **/
    var future(get, never):Future<T>;

    /**
        Resolve the future with the given result.
    **/
    function setResult(result:T):Void;

    /**
        Resolve the future with an exception instance.

        @param exception Any instance representing an exception.
        @param callStack Optional call stack of the exception. It is typically
            obtained using `CallStack.exceptionStack()` when catching a thrown
            exception. Use `CallStack.callStack()` otherwise.
    **/
    function setException(exception:Any, ?callStack:Array<StackItem>):Void;
}
