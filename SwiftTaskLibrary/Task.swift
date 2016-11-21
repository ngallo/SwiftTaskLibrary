//
// Task.swift
// SwiftTaskLibrary
//
// Created by Nicola Gallo on 19/06/2016.
// Copyright © 2016 Nicola Gallo. All rights reserved.
//

import Foundation

/// Represents an operation.
public final class Task<T> : Taskable {
    
    //#MARK: Fields
    
    fileprivate var _cancellationToken:CancellationToken?
    fileprivate var _isCompletionSource = false
    fileprivate var _taskAction:((TaskContext<T>) -> Void)?
    fileprivate var _taskContinuationsSyncRoot = NSObject()
    fileprivate var _taskContinuations = [TaskContinuation]()
    fileprivate var _taskCompletedCondition: NSCondition = NSCondition()
    
    //#MARK: Constructors & Destructors
    
    fileprivate init() {
        id = UUID().uuidString
        _cancellationToken = nil
        status = TaskStatus.created
    }
   
    internal convenience init(task:@escaping () throws -> T) {
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
    public fileprivate(set) var error:NSError? = nil
    
    /// Gets the error message.
    public fileprivate(set) var errorMessage:String = ""
    
    /// Gets the TaskStatus of this task.
    public fileprivate(set) var status:TaskStatus

    /// Gets whether this Task has a result.
    public var hasResult:Bool {
        return result != nil
    }
    
    /// Gets the result value of this Task<T>.
    public fileprivate(set) var result:T? = nil

    //#MARK: Methods
    
    fileprivate func signalTaskCompletedCondition() {
        _taskCompletedCondition.lock()
        self._taskCompletedCondition.signal()
        self._taskCompletedCondition.broadcast()
        _taskCompletedCondition.unlock()
    }
    
    internal func addContinuationTask(_ taskContinuation:TaskContinuation) {
        task_lock(_taskContinuationsSyncRoot) {
            self._taskContinuations.append(taskContinuation)
            if (self.isTerminated == true)  {
                self.processContinuations()
            }
        }
    }
    
    fileprivate func processContinuations() {
        task_lock(_taskContinuationsSyncRoot) {
            for taskContnuation in self._taskContinuations {
                if taskContnuation.isStarted == true {
                    continue
                }
                var hasToRun = false
                var isAsync = false
                taskContnuation.isStarted = true
                switch taskContnuation.taskContinuationOption {
                    case .none:
                        hasToRun = true
                        isAsync = true
                    case .executeSynchronously:
                        hasToRun = true
                        isAsync = false
                    case .notOnCanceled:
                        hasToRun = (self.isCanceled == false)
                        isAsync = true
                    case .notOnFaulted:
                        hasToRun = (self.isFaulted == false)
                        isAsync = true
                    case .notOnRanToCompletion:
                        hasToRun = (self.isCompleted == false)
                        isAsync = true
                    case .onlyOnCanceled:
                        hasToRun = (self.isCanceled == true)
                        isAsync = true
                    case .onlyOnFaulted:
                        hasToRun = (self.isFaulted == true)
                        isAsync = true
                    case .onlyOnRanToCompletion:
                        hasToRun = (self.isCompleted == true)
                        isAsync = true
                    case .runContinuationsAsynchronously:
                        hasToRun = true
                        isAsync = true
                }
                if hasToRun == false {
                    taskContnuation.taskable.cancelSync()
                }
                else if isAsync == false {
                    taskContnuation.taskable.startSync(taskContnuation.taskScheduler, cancellationToken: taskContnuation.cancellationToken, numberOfRetries: taskContnuation.numberOfRetries)
                }
                else {
                    taskContnuation.taskable.startAsync(taskContnuation.taskScheduler, cancellationToken: taskContnuation.cancellationToken, numberOfRetries: taskContnuation.numberOfRetries)
                }
            }
        }
    }
    
    /// Waits for the Task to completed.
    public func wait() {
        _taskCompletedCondition.lock()
        if isTerminated == false {
            _taskCompletedCondition.wait()
        }
        _taskCompletedCondition.unlock()
    }
    
    /// Waits for the Task to completed until the input date.
    public func waitUntilDate(_ limit: Date) -> Bool {
        if isTerminated == false {
            return _taskCompletedCondition.wait(until: limit)
        }
        return true
    }
    
    /// Throws an exception whether in faulted state
    public func throwIfFaulted(_ alternativeErrorMessage:String) throws {
        if isFaulted == true {
            if let err = error {
                throw err
            }
            throw TaskError.unhandled(alternativeErrorMessage)
        }
    }
    
    //#MARK: Methods - Cancel
    
    /// Cancel the current task
    internal func cancelSync() {
        status = .canceled
        processContinuations()
    }
    
    //#MARK: Methods - Start
    
    fileprivate func setResult(_ result:T) {
        self.result = result
        status = TaskStatus.ranToCompletion
        signalTaskCompletedCondition()
        processContinuations()
    }
    
    fileprivate func setError(_ error:NSError, errorMessage:String) {
        self.error = error
        self.errorMessage = errorMessage
        status = TaskStatus.faulted(error)
        signalTaskCompletedCondition()
        processContinuations()
    }
   
    fileprivate func startOperation(_ retryCounter:Int, numberOfRetries:Int) {
        if retryCounter < 1 || numberOfRetries < 1 || retryCounter > numberOfRetries {
            fatalError("Invalid number of retries")
        }
        startSync()
        guard let taskAction = _taskAction else {
            return
        }
        //Start task
        let context = TaskContext<T>(retryCounter: retryCounter, onSuccess: { [weak self] result in guard let this = self else { return }
                if let token = this._cancellationToken , token.isCancellationRequested {
                    this.cancelSync()
                }
                else {
                    this.setResult(result)
                }
                this.signalTaskCompletedCondition()
            }, onFailure: { [weak self] error, errorMessage in guard let this = self else { return }
                if let token = this._cancellationToken , token.isCancellationRequested {
                    this.cancelSync()
                }
                else if (retryCounter < numberOfRetries) {
                    this.startOperation(retryCounter + 1, numberOfRetries:numberOfRetries)
                    return
                }
                else {
                    if let token = this._cancellationToken , token.isCancellationRequested {
                        this.cancelSync()
                    }
                    else {
                        this.setError(error, errorMessage: errorMessage)
                    }
                }
                this.signalTaskCompletedCondition()
            })
        taskAction(context)
    }
    
    /// Set the task in started state
    internal func startSync() -> (setResult:(T)-> Void, setError:(_ error:NSError, _ errorMessage:String) -> Void) {
        status = TaskStatus.running
        return (setResult, setError)
    }
    
    /// Starts the input task synchronously with a number of retries in case of error.
    internal func startSync(_ taskScheduler:TaskScheduler, cancellationToken:CancellationToken?, numberOfRetries:Int) {
        if let taskQueue = taskScheduler.getTaskQueue() {
            taskQueue.sync {
                self.startOperation(1, numberOfRetries: numberOfRetries)
            }
        } else {
            startOperation(1, numberOfRetries: numberOfRetries)
        }
    }
    
    /// Starts the input task asynchronously with a number of retries in case of error.
    internal func startAsync(_ taskScheduler:TaskScheduler, cancellationToken:CancellationToken?, numberOfRetries:Int) {
        let taskQueue = taskScheduler.getTaskQueueOrDefault()
        taskQueue.async {
            self.startOperation(1, numberOfRetries: numberOfRetries)
        }
    }
    
    /// Starts the input task asynchronously after the input number of milliseconds with a number of retries in case of error.
    internal func startAfter(_ numberMs:Double, taskScheduler:TaskScheduler, cancellationToken:CancellationToken?, numberOfRetries:Int) {
        let taskQueue = taskScheduler.getTaskQueueOrDefault()
        let delayTime = DispatchTime.now() + Double(Int64(numberMs * Double(NSEC_PER_MSEC))) / Double(NSEC_PER_SEC)
        taskQueue.asyncAfter(deadline: delayTime) {
            self.startOperation(1, numberOfRetries: numberOfRetries)
        }
    }

    /// Gets the result.
    public func getResult() throws -> T {
        guard let tmpResult = result else {
            throw TaskError.nilResult
        }
        return tmpResult
    }
}
