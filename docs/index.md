What is SwiftTaskLibrary
-----

It is a `Swift` porting of the .net `TPL`. The purpose of the `TPL` is to make
developers more productive by simplifying the process of adding parallelism
and concurrency to applications.

Create a `Task`
-----
A ``Task`` represents an asynchronous operation that is created and started by the means of the ```TaskFactory``` class.

The `TaskFactory`class implement the following methods:

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
Separation of the concerns reduce coupling and increase cohesion of the application.

An example of separation of concerns is the `DAL` (Data Access Layer).
The `DAL` is a layer which provided simplified access to data stored in persistent storage.

The `DAL` performs IO operations because of that `Api` must be asynchronous.

Below and exmaple of how an `Api` may look like.

**Sample 1 - DataAccessLayer Protocol**
```Swift
public protocol DataAccessLayer {
    func getOrders(success:([Order]) -> Void, failure:(NSError) -> Void))    
}
``` 

In order to use the DataAccessLayer two closures have to passed in input.

Below an exmaple of code which uses the `DAL` and perform an action on the UI thread once the asynchronous operation is completed.

**Sample 2 - Usage of the DataAccessLayer**
```Swift
let dal = OrdersDataAccessLayer()
dal.getOrders({
    orders in 
        dispatch_sync(dispatch_get_main_queue(), { 
            () -> Void in
            update(orders)
        })
    },
    failure: {
        error in 
        dispatch_sync(dispatch_get_main_queue(), { 
            () -> Void in
            log(error)
        })
    },
``` 

Using SwiftTaskLibrary the `DAL` code would be implemented as following.

**Sample 3 - DataAccessLayer Protocol**
```Swift
public protocol DataAccessLayer {
    func getOrdersAsync() -> Task<[Order]>    
}
``` 

**Sample 3 - Usage of the DataAccessLayer**
```Swift
let dal = OrdersDataAccessLayer()
dal.getOrdersAsync()
    .continueWith(TaskScheduler.ui()) { 
        task in
        if (task.isFaulted) {
            log(task.error)
            return
        }
        update(task.result)
}
``` 