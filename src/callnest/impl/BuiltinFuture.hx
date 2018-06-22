package callnest.impl;

import callnest.CompletionStatus;
import callnest.Exception;
import haxe.ds.Option;


class BuiltinFuture<T> implements Future<T> {
    public var result(get, never):Option<T>;
    public var exception(get, never):Option<Any>;
    public var status(get, never):CompletionStatus;
    public var isComplete(get, never):Bool;
    public var isCanceled(get, never):Bool;
    public var hasResult(get, never):Bool;
    public var hasException(get, never):Bool;

    var _result:Option<T> = None;
    var _exception:Option<Any> = None;
    var _status:CompletionStatus = Created;
    var _completeCallbacks:Array<Future<T>->Void>;
    var _exceptionHandler:Any->Void;

    public function new() {
        _completeCallbacks = [];
    }

    function get_result():Option<T> {
        return _result;
    }

    function get_exception():Option<Any> {
        return _exception;
    }

    function get_status():CompletionStatus {
        return _status;
    }

    function get_isComplete():Bool {
        switch (_status) {
            case Canceled | Faulted | Done:
                return true;
            default:
                return false;
        }
    }

    function get_isCanceled():Bool {
        return _status == Canceled;
    }

    function get_hasResult():Bool {
        switch (_result) {
            case Some(result):
                return true;
            case None:
                return false;
        }
    }

    function get_hasException():Bool {
        switch (_exception) {
            case Some(exception):
                return true;
            case None:
                return false;
        }
    }

    public function getResult():T {
        if (isCanceled) {
            throw new CanceledStatusException("Cannot get result on canceled future.");
        }

        switch (_exception) {
            case Some(exception):
                throw exception;
            case None:
                // empty
        }

        switch (_result) {
            case Some(result):
                return result;
            case None:
                throw new InvalidStateException("Future has no result yet.");
        }
    }

    public function cancel():Void {
        if (!isComplete) {
            _status = Canceled;
            runCallbacks();
        }
    }

    public function onComplete(callback:Future<T>->Void):Future<T> {
        if (isComplete) {
            runCallbackWithHandler(callback);
        } else {
            _completeCallbacks.push(callback);
        }

        return this;
    }

    public function handleException(handler:Any->Void):Future<T> {
        if (_exceptionHandler != null) {
            throw new InvalidStateException("Exception handler already set.");
        }

        _exceptionHandler = handler;

        return this;
    }

    function runCallbacks() {
        for (callback in _completeCallbacks) {
            runCallbackWithHandler(callback);
        }
    }

    function runCallbackWithHandler(callback:Future<T>->Void) {
        try {
            callback(this);
        } catch (exception:Any) {
            if (_exceptionHandler == null) {
                TaskDefaults.handleException(exception);
            } else {
                _exceptionHandler(exception);
            }
        }
    }

    @:allow(callnest.impl)
    function setResult(result:T) {
        throwIfCanceledOrComplete();
        _result = Some(result);
        _status = Done;
        runCallbacks();
    }

    @:allow(callnest.impl)
    function setException(exception:Any) {
        throwIfCanceledOrComplete();
        _exception = Some(exception);
        _status = Faulted;
        runCallbacks();
    }

    function throwIfCanceledOrComplete() {
        if (isCanceled) {
            throw new CanceledStatusException("Cannot get result on canceled future.");
        } else if (isComplete) {
            throw new InvalidStateException("Future is already in completed status.");
        }
    }
}
