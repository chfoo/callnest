package callnest.impl;

import callnest.CompletionStatus;
import callnest.Exception;
import haxe.CallStack;
import haxe.ds.Option;


class BuiltinFuture<T> implements Future<T> {
    public var result(get, never):Option<T>;
    public var exception(get, never):Option<Any>;
    public var exceptionCallStack(get, never):Option<Array<StackItem>>;
    public var status(get, never):CompletionStatus;
    public var isComplete(get, never):Bool;
    public var isCanceled(get, never):Bool;
    public var hasResult(get, never):Bool;
    public var hasException(get, never):Bool;

    var _result:Option<T> = None;
    var _exception:Option<Any> = None;
    var _exceptionCallStack:Option<Array<StackItem>> = None;
    var _status:CompletionStatus = Created;
    var _completeCallbacks:Array<Future<T>->Void>;
    var _exceptionHandler:ExceptionInfo->Void;

    public function new() {
        _completeCallbacks = [];
    }

    function get_result():Option<T> {
        return _result;
    }

    function get_exception():Option<Any> {
        return _exception;
    }

    function get_exceptionCallStack():Option<Array<StackItem>> {
        return _exceptionCallStack;
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

    public function cancel():Bool {
        if (!isComplete) {
            _status = Canceled;
            runCallbacks();

            return true;
        } else {
            return false;
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

    public function handleException(handler:ExceptionInfo->Void):Future<T> {
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
            var info:ExceptionInfo = {
                exception: exception,
                callStack: Some(CallStack.exceptionStack())
            };

            if (_exceptionHandler == null) {
                TaskDefaults.handleException(info);
            } else {
                _exceptionHandler(info);
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
    function setException(exception:Any, ?callStack:Array<StackItem>) {
        throwIfCanceledOrComplete();
        _exception = Some(exception);

        if (callStack != null) {
            _exceptionCallStack = Some(callStack);
        }

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
