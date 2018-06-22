package callnest.test;

import haxe.Timer;
import utest.Assert;


class TestTask {
    public function new() {
    }

    public function testContinueWith() {
        var source:TaskSource<Int> = TaskDefaults.newTaskSource();
        var task = source.task;
        var done = Assert.createAsync();

        task.continueWith(function (task:Task<Int>):Task<Int> {
                var value = task.getResult();
                return TaskTools.fromResult(value + 1);
            })
            .continueWith(function (task:Task<Int>):Task<Int> {
                var value = task.getResult();
                return TaskTools.fromResult(value * 2);
            })
            .continueWith(function (task:Task<Int>):Task<Bool> {
                var value = task.getResult();
                return TaskTools.fromResult(value == 10);
            })
            .onComplete(function (task:Task<Bool>) {
                Assert.isTrue(task.getResult());
                done();
            });

        source.setResult(4);
    }

    public function testExceptionInContinueWith() {
        var source:TaskSource<Int> = TaskDefaults.newTaskSource();
        var task = source.task;
        var done = Assert.createAsync();

        task.continueWith(function (task:Task<Int>):Task<Int> {
                var value = task.getResult();
                return TaskTools.fromResult(value + 1);
            })
            .continueWith(function (task:Task<Int>):Task<Int> {
                throw "my exception";
            })
            .continueWith(function (task:Task<Int>):Task<Bool> {
                var value = task.getResult();
                return TaskTools.fromResult(value == 10);
            })
            .onComplete(function (task:Task<Bool>) {
                Assert.isTrue(task.hasException);
                done();
            });

        source.setResult(4);
    }

    public function testRun() {
        var source:TaskSource<Int> = TaskDefaults.newTaskSource();
        var task = source.task;
        var done = Assert.createAsync(function () {
            Assert.equals(10, task.getResult());
        });

        source.run(function () {
            return 10;
        });

        task.onComplete(function (task:Task<Int>) {
            done();
        });
    }

    public function testRunException() {
        var source:TaskSource<Int> = TaskDefaults.newTaskSource();
        var task = source.task;
        var done = Assert.createAsync(function () {
            Assert.isTrue(task.hasException);
        });

        source.run(function () {
            throw "my exception";
        });

        task.onComplete(function (task:Task<Int>) {
            done();
        });
    }

    public function testWithTimer() {
        var source:TaskSource<Int> = TaskDefaults.newTaskSource();
        var task = source.task;
        var done = Assert.createAsync(function () {
            Assert.isTrue(task.isComplete);
            Assert.isTrue(task.hasResult);
        });

        task.onComplete(function (task) {
            done();
        });

        Timer.delay(source.setResult.bind(123), 20);
    }
}
