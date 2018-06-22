package callnest.impl;


class SynchronousScheduler implements Scheduler {
    public function new() {
    }

    public function addCallback<T>(callback:Void->T):Future<T> {
        var source = TaskDefaults.newFutureSource();

        try {
            source.setResult(callback());
        } catch (exception:Any) {
            source.setException(exception);
        }

        return source.future;
    }
}
