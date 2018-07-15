Change Log
==========

Unreleased
----------

* Added `TaskTools.continueNext()`, `TaskTools.thenContinue()`, `TaskTools.thenNext()`, `TaskTools.thenResult()`.
* Added `VoidReturn`.
* Added `Future.exceptionCallStack`.
* Changed `FutureSource.setException()` to accept an optional call stack parameter.
* Changed `handleException()` to accept an instance of `ExceptionResult`.


0.2.0 (2018-07-12)
------------------

* Added `TaskTools.whenAny()` and `TaskTools.whenAll()`.
* Changed default exception handler to trace out call stacks instead of just the exception.


0.1.0 (2018-06-22)
------------------

* Initial release.
