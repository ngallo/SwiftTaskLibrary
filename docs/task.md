Create a Task
-----
A task represents an asynchronous operation.

A task can be created and started by the means of the TaskFactory class.

The TaskFactory class implement the following methods:

*  **`startSync`:** *Starts a task synchronously*
*  **`startAsync`:** *Starts a task asynchronously*
*  **`startAfter`:** *Starts the input task asynchronously after the input number of milliseconds.*

```swift
TaskFactory.startAsync(TaskScheduler.background()) {
    return "Hello World!"
}
```

A continuation that executes asynchronously when the task completes can be defined to the created task.

```swift
let task = TaskFactory.startAsync(TaskScheduler.background()) {
    return "Hello World!"
}

task.continueWith(TaskScheduler.ui()) {
    [unowned self] task in
    println(task.result ?? "NO RESULT")
}

```
