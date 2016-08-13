Create a TaskCompletionSource
-----
A TaskCompletionSource represents the producer side of a Task unbound to a delegate, providing access to the consumer side through the Task property.

It is a source for creating a task, and the source for that task’s completion. In essence, a TaskCompletionSource acts as the producer for a Task<TResult> and its completion.

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
