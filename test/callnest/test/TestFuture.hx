package callnest.test;

import callnest.Exception.InvalidStateException;
import haxe.ds.Option;
import utest.Assert;


class TestFuture {
    public function new() {
    }

    public function testSetResult() {
        var source = TaskDefaults.newFutureSource();
        var future = source.future;

        Assert.isFalse(future.hasException);
        Assert.isFalse(future.hasResult);
        Assert.isFalse(future.isCanceled);
        Assert.isFalse(future.isComplete);
        Assert.equals(None, future.result);
        Assert.equals(None, future.exception);

        source.setResult(3);

        Assert.isFalse(future.hasException);
        Assert.isTrue(future.hasResult);
        Assert.isFalse(future.isCanceled);
        Assert.isTrue(future.isComplete);

        Assert.equals(3, future.getResult());
        Assert.isTrue(Some(3).equals(future.result));
        Assert.equals(None, future.exception);

        Assert.raises(source.setResult.bind(4), InvalidStateException);
        Assert.raises(source.setException.bind("a"), InvalidStateException);
    }

    public function testSetException() {
        var source:FutureSource<Int> = TaskDefaults.newFutureSource();
        var future = source.future;

        Assert.isFalse(future.hasException);
        Assert.isFalse(future.hasResult);
        Assert.isFalse(future.isCanceled);
        Assert.isFalse(future.isComplete);
        Assert.equals(None, future.result);
        Assert.equals(None, future.exception);

        source.setException("my exception");

        Assert.isTrue(future.hasException);
        Assert.isFalse(future.hasResult);
        Assert.isFalse(future.isCanceled);
        Assert.isTrue(future.isComplete);
        Assert.equals(None, future.result);
        Assert.isTrue(Some(("my exception":Any)).equals(future.exception));

        Assert.raises(future.getResult, String);
        Assert.raises(source.setResult.bind(4), InvalidStateException);
        Assert.raises(source.setException.bind("a"), InvalidStateException);
    }

    public function testCancel() {
        var source = TaskDefaults.newFutureSource();
        var future = source.future;

        Assert.isFalse(future.hasException);
        Assert.isFalse(future.hasResult);
        Assert.isFalse(future.isCanceled);
        Assert.isFalse(future.isComplete);
        Assert.equals(None, future.result);
        Assert.equals(None, future.exception);

        Assert.isTrue(future.cancel());

        Assert.isFalse(future.hasException);
        Assert.isFalse(future.hasResult);
        Assert.isTrue(future.isCanceled);
        Assert.isTrue(future.isComplete);
        Assert.equals(None, future.result);
        Assert.equals(None, future.exception);

        Assert.raises(source.setResult.bind(4), InvalidStateException);
        Assert.raises(source.setException.bind("a"), InvalidStateException);

        Assert.isFalse(future.cancel());
    }

    public function testOnCompleteResult() {
        var source = TaskDefaults.newFutureSource();
        var future = source.future;
        var called1 = false;
        var called2 = false;

        future.onComplete(function (future) {
            called1 = true;
        });

        source.setResult(3);

        future.onComplete(function (future) {
            called2 = true;
        });

        Assert.isTrue(called1);
        Assert.isTrue(called2);
    }

    public function testOnCompleteException() {
        var source = TaskDefaults.newFutureSource();
        var future = source.future;
        var called1 = false;
        var called2 = false;

        future.onComplete(function (future) {
            called1 = true;
        });

        source.setException("my exception");

        future.onComplete(function (future) {
            called2 = true;
        });

        Assert.isTrue(called1);
        Assert.isTrue(called2);
    }

    public function testOnCompleteCancel() {
        var source = TaskDefaults.newFutureSource();
        var future = source.future;
        var called1 = false;
        var called2 = false;

        future.onComplete(function (future) {
            called1 = true;
        });

        future.cancel();

        future.onComplete(function (future) {
            called2 = true;
        });

        Assert.isTrue(called1);
        Assert.isTrue(called2);
    }

    public function testHandleException() {
        var source = TaskDefaults.newFutureSource();
        var future = source.future;
        var caughtException:Any = null;
        var done = Assert.createAsync(function () {
            Assert.equals("my exception", caughtException);
        });

        future
            .onComplete(function (future) {
                throw "my exception";
            })
            .handleException(function (exception:Any) {
                caughtException = exception;
                done();
            });

        source.setResult(123);
    }
}
