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
}
