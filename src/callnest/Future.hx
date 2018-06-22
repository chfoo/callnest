package callnest;

import haxe.ds.Option;

/**
    Asynchronous result.

    A `Future` is the read interface to the future & promise pattern. It
    represents a result that may not be available until later. A future is
    resolved by the source promise which puts the future in the completed
    status.

    An instance can be obtained by creating an instance of `FutureSource`.
**/
interface Future<T> {
    /**
        Result from the source when completed.
    **/
    var result(get, never):Option<T>;

    /**
        Exception from the source when completed.
    **/
    var exception(get, never):Option<Any>;

    /**
        State of the future.
    **/
    var status(get, never):CompletionStatus;

    /**
        Whether the future is resolved by the source promise.

        This is true when the future has a result, has an exception, or is
        canceled.
    **/
    var isComplete(get, never):Bool;

    /**
        Whether the future is canceled.
    **/
    var isCanceled(get, never):Bool;

    /**
        Whether the future has a result.
    **/
    var hasResult(get, never):Bool;

    /**
        Whether the future is faulted due to an error.
    **/
    var hasException(get, never):Bool;

    /**
        Checks the status of the future and returns the result.

        If the future has an exception, it will be thrown. If the future
        is not yet completed, `InvalidStateException` will be thrown.
    **/
    function getResult():T;

    /**
        Cancels the future.

        Returns `true` if the future was canceled. Returns `false` if
        the future was already complete.
    **/
    function cancel():Bool;

    /**
        Calls the callback when the future enters the completed status.

        This method can be called multiple times. If it is called
        after the future is complete, it is called immediately.
    **/
    function onComplete(callback:Future<T>->Void):Future<T>;

    /**
        Sets an error handler for the `onComplete` method.

        By default, the global error handler is used.
    **/
    function handleException(handler:Any->Void):Future<T>;
}
