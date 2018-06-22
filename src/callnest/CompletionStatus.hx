package callnest;


/**
    States of a future or task.
**/
enum CompletionStatus {
    /**
        A result is not yet been computed.
    **/
    Created;

    /**
        Future or task is canceled.
    **/
    Canceled;

    /**
        Future or task has an exception.
    **/
    Faulted;

    /**
        A result has been computed successfully.
    **/
    Done;
}
