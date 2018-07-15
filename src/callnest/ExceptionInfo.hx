package callnest;

import haxe.CallStack;
import haxe.ds.Option;


/**
    Exception information provided to exception handlers.
**/
@:structInit
class ExceptionInfo {
    /**
        Exception instance.
    **/
    public var exception(default, null):Any;

    /**
        Call stack of the exception.

        This may not be available even if there is an exception.
    **/
    public var callStack(default, null):Option<Array<StackItem>>;
}
