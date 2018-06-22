package callnest.impl;


class BuiltinFutureSource<T> implements FutureSource<T> {
    public var future(get, never):Future<T>;

    var _future:BuiltinFuture<T>;

    public function new() {
        initFuture();
    }

    function initFuture() {
        _future = new BuiltinFuture();
    }

    function get_future():Future<T> {
        return _future;
    }

    public function setResult(result:T) {
        _future.setResult(result);
    }

    public function setException(exception:Any) {
        _future.setException(exception);
    }
}
