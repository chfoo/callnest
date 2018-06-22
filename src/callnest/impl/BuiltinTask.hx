package callnest.impl;

import callnest.Exception.CanceledStatusException;


class BuiltinTask<T> extends BuiltinFuture<T> implements Task<T> {
    override public function onComplete(callback:Task<T>->Void):Task<T> {
        super.onComplete(cast callback);
        return this;
    }

    override public function handleException(callback:Any->Void):Task<T> {
        super.handleException(callback);
        return this;
    }

    public function continueWith<R>(callback:Task<T>->Task<R>):Task<R> {
        var continueSource = new BuiltinTaskSource<R>();

        function innerCompleteCallback(innerTask:Task<R>) {
            if (innerTask.isCanceled) {
                continueSource.task.cancel();
            } else if (innerTask.hasResult) {
                continueSource.setResult(innerTask.getResult());
            } else {
                switch (innerTask.exception) {
                    case Some(exception):
                        continueSource.setException(exception);
                    case None:
                        throw "Shouldn't reach here";
                }
            }
        }

        function completeCallback(task:Task<T>) {
            try {
                callback(task).onComplete(innerCompleteCallback);

            } catch (exception:CanceledStatusException) {
                continueSource.task.cancel();
            } catch (exception:Any) {
                continueSource.setException(exception);
            }
        }

        onComplete(completeCallback);

        return continueSource.task;
    }
}
