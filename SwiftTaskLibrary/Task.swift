//
// Task.swift
// SwiftTaskLibrary
//
// Created by Nicola Gallo on 19/06/2016.
// Copyright © 2016 Nicola Gallo. All rights reserved.
//

import Foundation

/// Represents an operation.
public class Task<T> : Taskable {
    
    //#MARK: Fields
    
    private var _cancellationToken:CancellationToken?
    private var _isCompletionSource = false
    private var _taskAction:((TaskContext<T>) -> Void)?
    private var _taskContinuationsSyncRoot = NSObject()
    private var _taskContinuations = [TaskContinuation]()
    
    //#MARK: Constructors & Destructors
    
    private init() {
        id = NSUUID().UUIDString
        _cancellationToken = nil
        status = TaskStatus.Created
    }
   
    internal convenience init(task:() throws -> T) {
        self.init()
        let taskAction: ((TaskContext<T>) -> Void) = { context in
            do {
                let retVal = try task()
                context.setResult(retVal)
            }
            catch let error as NSError {
                context.setError(error, errorMessage: "")
            }
        }
        _taskAction = taskAction
    }
    
    internal convenience init(taskCompletion:TaskCompletionSource<T> ) {
        self.init()
    }

    //#MARK: Properties
    
    /// Gets an ID for this Task instance.
    public let id:String
    
    /// Gets the error that caused the Task to end prematurely.
    public private(set) var error:NSError? = nil
    
    /// Gets the error message.
    public private(set) var errorMessage:String = ""
    
    /// Gets the TaskStatus of this task.
    public private(set) var status:TaskStatus

    /// Gets whether this Task has a result.
    public var hasResult:Bool {
        return result != nil
    }
    
    /// Gets the result value of this Task<T>.
    public private(set) var result:T? = nil

    //#MARK: Methods
    
    internal func addContinuationTask(taskContinuation:TaskContinuation) {
        task_lock(_taskContinuationsSyncRoot) {
            self._taskContinuations.append(taskContinuation)
            if (self.isTerminated == true)  {
                self.processContinuations()
            }
        }
    }
    
    private func processContinuations() {
        task_lock(_taskContinuationsSyncRoot) {
            for taskContnuation in self._taskContinuations {
                if taskContnuation.isStarted == true {
                    continue
                }
                var hasToRun = false
                var isAsync = false
                taskContnuation.isStarted = true
                switch taskContnuation.taskContinuationOption {
                    case .None:
                        hasToRun = true
                        isAsync = true
                    case .ExecuteSynchronously:
                        hasToRun = true
                        isAsync = false
                    case .NotOnCanceled:
                        hasToRun = (self.isCanceled == false)
                        isAsync = true
                    case .NotOnFaulted:
                        hasToRun = (self.isFaulted == false)
                        isAsync = true
                    case .NotOnRanToCompletion:
                        hasToRun = (self.isCompleted == false)
                        isAsync = true
                    case .OnlyOnCanceled:
                        hasToRun = (self.isCanceled == true)
                        isAsync = true
                    case .OnlyOnFaulted:
                        hasToRun = (self.isFaulted == true)
                        isAsync = true
                    case .OnlyOnRanToCompletion:
                        hasToRun = (self.isCompleted == true)
                        isAsync = true
                    case .RunContinuationsAsynchronously:
                        hasToRun = true
                        isAsync = true
                }
                if hasToRun == false {
                    taskContnuation.taskable.cancelSync()
                }
                else if isAsync == true {
                    taskContnuation.taskable.startSync(taskContnuation.taskScheduler, cancellationToken: taskContnuation.cancellationToken, numberOfRetries: taskContnuation.numberOfRetries)
                }
                else {
                    taskContnuation.taskable.startAsync(taskContnuation.taskScheduler, cancellationToken: taskContnuation.cancellationToken, numberOfRetries: taskContnuation.numberOfRetries)
                }
            }
        }
    }
    
    public func wait() {
        fatalError("Not implemented yet")
    }
    
    //#MARK: Methods - Cancel
    
    /// Cancel the current task
    internal func cancelSync() {
        status = .Canceled
        self.processContinuations()
    }
    
    //#MARK: Methods - Start
    
    private func setResult(result:T) {
        self.result = result
        self.status = TaskStatus.RanToCompletion
        self.processContinuations()
    }
    
    private func setError(error:NSError, errorMessage:String) {
        self.error = error
        self.errorMessage = errorMessage
        self.status = TaskStatus.Faulted(error)
        self.processContinuations()
    }
   
    private func startOperation(retryCounter:Int, numberOfRetries:Int) {
        if retryCounter < 1 || numberOfRetries < 1 || retryCounter > numberOfRetries {
            fatalError("Invalid number of retries")
        }
        startSync()
        guard let taskAction = _taskAction else {
            return
        }
        //Start task
        let context = TaskContext<T>(retryCounter: retryCounter, onSuccess: { [unowned self] result in
            if let token = self._cancellationToken where token.isCancellationRequested {
                self.cancelSync()
            }
            else {
                self.setResult(result)
            }
            }, onFailure: { [unowned self] error, errorMessage in
                if let token = self._cancellationToken where token.isCancellationRequested {
                    self.cancelSync()
                }
                else if (retryCounter < numberOfRetries) {
                    self.startOperation(retryCounter + 1, numberOfRetries:numberOfRetries)
                }
                else {
                    if let token = self._cancellationToken where token.isCancellationRequested {
                        self.cancelSync()
                    }
                    else {
                        self.setError(error, errorMessage: errorMessage)
                    }
                }
            })
        taskAction(context)
    }
    
    /// Set the task in started state
    internal func startSync() -> (setResult:(T)->Void, setError:(error:NSError, errorMessage:String) -> Void) {
        status = TaskStatus.Running
        return (self.setResult, self.setError)
    }
    
    /// Starts the input task synchronously with a number of retries in case of error.
    internal func startSync(taskScheduler:TaskScheduler, cancellationToken:CancellationToken?, numberOfRetries:Int) {
        if let taskQueue = taskScheduler.getTaskQueue() {
            dispatch_sync(taskQueue) {
                self.startOperation(1, numberOfRetries: numberOfRetries)
            }
        } else {
            startOperation(1, numberOfRetries: numberOfRetries)
        }
    }
    
    /// Starts the input task asynchronously with a number of retries in case of error.
    internal func startAsync(taskScheduler:TaskScheduler, cancellationToken:CancellationToken?, numberOfRetries:Int) {
        let taskQueue = taskScheduler.getTaskQueueOrDefault()
        dispatch_async(taskQueue) {
            self.startOperation(1, numberOfRetries: numberOfRetries)
        }
    }
    
    /// Starts the input task asynchronously after the input number of milliseconds with a number of retries in case of error.
    internal func startAfter(numberMs:Double, taskScheduler:TaskScheduler, cancellationToken:CancellationToken?, numberOfRetries:Int) {
        let taskQueue = taskScheduler.getTaskQueueOrDefault()
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(numberMs * Double(NSEC_PER_MSEC)))
        dispatch_after(delayTime, taskQueue) {
            self.startOperation(1, numberOfRetries: numberOfRetries)
        }
    }

}
