package callnest;


/**
    General purpose exception for this library.
**/
class Exception extends haxe.Exception {
    override function toString():String {
        return '[${Type.getClassName(Type.getClass(this))} ${message}]';
    }
}

/**
    Thrown when an operation is called on an instance with mismatching state.

    For example, attempting to access the result of a future in a status
    that is not complete will throw this exception.
**/
class InvalidStateException extends Exception {
}


/**
    Thrown when an operation is called on a future that is canceled.
**/
class CanceledStatusException extends InvalidStateException {
}
