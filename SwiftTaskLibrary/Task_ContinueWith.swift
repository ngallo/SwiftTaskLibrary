//
// Task_ContinueWith.swift
// SwiftTaskLibrary
//
// Created by Nicola Gallo on 23/06/2016.
// Copyright © 2016 Nicola Gallo. All rights reserved.
//

import Foundation

public extension Task {

    //#MARK: Methods - Continue With Task<T>
    
    /// Creates a continuation Task<T>.
    public func continueWith<T1>(_ taskScheduler: TaskScheduler = TaskScheduler.runningContext(), cancellationToken:CancellationToken? = nil, numberOfRetries:Int = 1
            , taskContinuationOption:TaskContinuationOptions = TaskContinuationOptions.none, task:@escaping (Task<T>) throws -> T1) -> Task<T1> {
        let task = Task<T1>(task: { return try task(self) })
        addContinuationTask(TaskContinuation(taskScheduler: taskScheduler, cancellationToken: cancellationToken, numberOfRetries: numberOfRetries, taskContinuationOption: taskContinuationOption, taskable: task))
        return task
    }

}
