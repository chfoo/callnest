package callnest.impl;


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
        var innerSource = new BuiltinTaskSource<R>();

        function completeCallback(task:Task<T>) {
            try {
                callback(task).onComplete(function (innerTask) {
                    if (innerTask.isCanceled) {
                        innerSource.task.cancel();
                    } else if (innerTask.hasResult) {
                        innerSource.setResult(innerTask.getResult());
                    } else {
                        innerSource.setException(innerTask.exception);
                    }
                });

            } catch (exception:Any) {
                innerSource.setException(exception);
            }
        }

        onComplete(completeCallback);

        return innerSource.task;
    }
}
