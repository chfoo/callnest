package callnest.test;

import callnest.VoidReturn;
import utest.Assert;


class TestVoidReturn {
    public function new() {
    }

    public function test() {
        var source:TaskSource<VoidReturn> = TaskDefaults.newTaskSource();
        source.setResult(Nothing);

        Assert.equals(Nothing, source.task.getResult());
    }
}
