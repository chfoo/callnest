package callnest;

/**
    Type for representing a task that does not return a computed value for
    a result.

    The task may be declared as `Task<VoidReturn>` and the value is `Nothing`.

    This is used in replacement for misusing `Void` or returning `Bool` or
    `null`.
**/
enum VoidReturn {
    /**
        An alternative for `null`.
    **/
    Nothing;
}
