2. Create a Task
-----
A Task represents an asynchronous operation that is created and started by the means of the TaskFactory class.

The TaskFactory class implement the following methods:

*  **`startSync`:** *Starts a Task synchronously*
*  **`startAsync`:** *Starts a Task asynchronously*
*  **`startAfter`:** *Starts a Task asynchronously after the input number of milliseconds.*

```swift
TaskFactory.startAsync(TaskScheduler.background()) {
    return "Hello World!"
}
```

A continuation that executes asynchronously when the Task completes can be defined to the created Task.

```swift
let task = TaskFactory.startAsync(TaskScheduler.background()) {
    return "Hello World!"
}

task.continueWith(TaskScheduler.ui()) {
    [unowned self] task in
    println(task.result ?? "NO RESULT")
}

```
