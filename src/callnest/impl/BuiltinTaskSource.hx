package callnest.impl;


class BuiltinTaskSource<T> extends BuiltinFutureSource<T> implements TaskSource<T> {
    public var task(get, never):Task<T>;

    var _task:BuiltinTask<T>;

    function get_task():Task<T> {
        return _task;
    }

    override function initFuture() {
        _task = new BuiltinTask<T>();
        _future = _task;
    }

    public function run(callback:Void->T, ?scheduler:Scheduler) {
        scheduler = scheduler != null ? scheduler : TaskDefaults.scheduler;

        scheduler.addCallback(callback).onComplete(function (schedulerFuture) {
            if (schedulerFuture.isCanceled) {
                _task.cancel();
            } else if (schedulerFuture.hasResult) {
                _task.setResult(schedulerFuture.getResult());
            } else {
                switch (schedulerFuture.exception) {
                    case Some(exception):
                        _task.setException(exception);
                    default:
                        throw "Shouldn't reach here";
                }
            }
        });
    }
}
