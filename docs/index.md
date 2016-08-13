What is SwiftTaskLibrary
-----

It is a `Swift` porting of the .net `TPL`. The purpose of the `TPL` is to make
developers more productive by simplifying the process of adding parallelism
and concurrency to applications.

Create a `Task`
-----
A ``Task`` represents an asynchronous operation that is created and started by the means of the ```TaskFactory``` class.

The `Factory`class implement the following methods:

*  **`startSync`:** *Starts a `Task` synchronously*
*  **`startAsync`:** *Starts a `Task` asynchronously*
*  **`startAfter`:** *Starts a `Task` asynchronously after the input number of milliseconds.*

```swift
TaskFactory.startAsync(TaskScheduler.background()) {
    return "Hello World!"
}
```

A continuation that executes asynchronously when the `Task` completes can be defined to the created `Task`.

```swift
let task = TaskFactory.startAsync(TaskScheduler.background()) {
    return "Hello World!"
}

task.continueWith(TaskScheduler.ui()) {
    [unowned self] task in
    println(task.result ?? "NO RESULT")
}

```

Create a TaskCompletionSource
-----
A TaskCompletionSource represents the producer side of a `Task` unbound to a delegate, providing access to the consumer side through the `Task` property.

It is a source for creating a task, and the source for that task’s completion. In essence, a TaskCompletionSource acts as the producer for a `Task` and its completion.

Using a TaskCompletionSource is quite handy when you don't have control of the asynchronus operation (for instance the operation is started by a third party library).

```Swift
//Creates  a new CancellationTokenSource
let cTokenSource = CancellationTokenSource()

//Defines a task continuation on the task created by the CancellationTokenSource
cTokenSource.task.continueWith(TaskScheduler.ui()) {
    [unowned self] task in
    println(task.result ?? "NO RESULT")
}

dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {
    println("TaskCompletionSource - Running")
    sleep(5)
    // Complete the task created by the CancellationTokenSource
    tcs.setResult(self.getResult("TaskCompletionSource - Completed"))
}

```

Create asynchronous methods
-----
