package callnest.test;


import utest.Assert;

class TestTaskTools {
    public function new() {
    }

    public function testFromResult() {
        var task = TaskTools.fromResult(123);

        Assert.equals(123, task.getResult());
    }

    public function testFromException() {
        var task = TaskTools.fromException("my exception");

        Assert.raises(task.getResult, String);
    }

    public function testWhenAll() {
        var taskSources = [];
        var tasks = [];

        for (index in 0...10) {
            var taskSource = TaskDefaults.newTaskSource();

            taskSources.push(taskSource);
            tasks.push(taskSource.task);
        }

        var allTask = TaskTools.whenAll(tasks);

        for (index in 0...10) {
            Assert.isFalse(allTask.isComplete);
            taskSources[index].setResult(true);
        }

        Assert.isTrue(allTask.isComplete);

        var result = Lambda.array(allTask.getResult());

        Assert.same(tasks, result);
    }

    public function testWhenAllEmpty() {
        var allTask = TaskTools.whenAll([]);
        Assert.isTrue(allTask.isComplete);
    }

    public function testWhenAny() {
        var taskSources = [];
        var tasks = [];

        for (index in 0...10) {
            var taskSource = TaskDefaults.newTaskSource();

            taskSources.push(taskSource);
            tasks.push(taskSource.task);
        }

        var anyTask = TaskTools.whenAny(tasks);

        Assert.isFalse(anyTask.isComplete);
        taskSources[3].setResult(true);

        Assert.isTrue(anyTask.isComplete);

        var result = anyTask.getResult();

        Assert.same(tasks[3], result);
    }

    public function testWhenAnyEmpty() {
        Assert.raises(TaskTools.whenAny.bind([]), Exception);
    }
}
