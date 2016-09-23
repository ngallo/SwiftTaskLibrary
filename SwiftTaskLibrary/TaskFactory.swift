//
// TaskFactory.swift
// SwiftTaskLibrary
//
// Created by Nicola Gallo on 19/06/2016.
// Copyright © 2016 Nicola Gallo. All rights reserved.
//

import Foundation

/// Provides support for creating and starting Task objects.
public final class TaskFactory {
    
    //#MARK: Methods - Start Task<T>
    
    /// Starts the input task synchronously.
    @discardableResult
    public static func startSync<T>(_ taskScheduler: TaskScheduler = TaskScheduler.runningContext(), cancellationToken:CancellationToken? = nil, numberOfRetries:Int = 1, task: @escaping () throws -> T) -> Task<T> {
        let task = Task<T>(task: task)
        task.startSync(taskScheduler, cancellationToken: cancellationToken, numberOfRetries: numberOfRetries)
        return task
    }
    
    /// Starts the input task asynchronously.
    @discardableResult
    public static func startAsync<T>(_ taskScheduler: TaskScheduler = TaskScheduler.runningContext(), cancellationToken:CancellationToken? = nil, numberOfRetries:Int = 1, task: @escaping () throws -> T) -> Task<T> {
        let task = Task<T>(task: task)
        task.startAsync(taskScheduler, cancellationToken: cancellationToken, numberOfRetries: numberOfRetries)
        return task
    }
    
   
    /// Starts the input task asynchronously after the input number of milliseconds with a number of retries in case of error.
    @discardableResult
    public static func startAfter<T>(_ numberMs:Double, taskScheduler: TaskScheduler = TaskScheduler.runningContext(), cancellationToken:CancellationToken? = nil, numberOfRetries:Int = 1, task: @escaping() throws -> T) -> Task<T> {
        let task = Task<T>(task: task)
        task.startAfter(numberMs, taskScheduler:taskScheduler, cancellationToken: cancellationToken, numberOfRetries: numberOfRetries)
        return task
    }
   
}
