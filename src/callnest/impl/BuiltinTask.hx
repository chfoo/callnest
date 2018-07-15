package callnest.impl;

import callnest.Exception.CanceledStatusException;
import haxe.CallStack;


class BuiltinTask<T> extends BuiltinFuture<T> implements Task<T> {
    override public function onComplete(callback:Task<T>->Void):Task<T> {
        super.onComplete(cast callback);
        return this;
    }

    override public function handleException(callback:ExceptionInfo->Void):Task<T> {
        super.handleException(callback);
        return this;
    }

    public function continueWith<R>(callback:Task<T>->Task<R>):Task<R> {
        var continueSource = new BuiltinTaskSource<R>();

        function completeCallback(task:Task<T>) {
            try {
                callback(task).onComplete(innerCompleteCallback.bind(continueSource));

            } catch (exception:CanceledStatusException) {
                continueSource.task.cancel();
            } catch (exception:Any) {
                var callStack = CallStack.exceptionStack();
                continueSource.setException(exception, callStack);
            }
        }

        onComplete(completeCallback);

        return continueSource.task;
    }

    function innerCompleteCallback<R>(continueSource:TaskSource<R>, innerTask:Task<R>) {
        if (innerTask.isCanceled) {
            continueSource.task.cancel();
        } else if (innerTask.hasResult) {
            continueSource.setResult(innerTask.getResult());
        } else {
            switch innerTask.exception {
                case Some(exception):
                    switch innerTask.exceptionCallStack {
                        case Some(callStack):
                            continueSource.setException(exception, callStack);
                        case None:
                            continueSource.setException(exception);
                    }
                case None:
                    throw "Shouldn't reach here";
            }
        }
    }
}
