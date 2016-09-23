//
// TaskScheduler.swift
// SwiftTaskLibrary
//
// Created by Nicola Gallo on 20/06/2016.
// Copyright © 2016 Nicola Gallo. All rights reserved.
//

import Foundation

//#MARK: Type aliases

/// Task queue.
public typealias TaskQueue = DispatchQueue

/// Represents a Task scheduler.
public final class TaskScheduler {
    
    //#MARK: Fields
    
    /// Gets the task queue.
    fileprivate let _taskQueue:TaskQueue?
    
    //#MARK: Constructors & Destructors

    fileprivate init(taskQueue:TaskQueue?) {
        _taskQueue = taskQueue
    }
    
    //#MARK: Properties
   
    /// The user interactive class represents tasks that need to be done immediately in order to provide a nice user experience.
    /// Use it for UI updates, event handling and small workloads that require low latency.
    /// The total amount of work done in this class during the execution of your app should be small.
    public static var globalUserInteractiveQueue: TaskQueue {
        return DispatchQueue.global(qos:.userInteractive)
    }
    
    /// The user initiated class represents tasks that are initiated from the UI and can be performed asynchronously.
    /// It should be used when the user is waiting for immediate results, and for tasks required to continue user interaction.
    public static var globalUserInitiatedQueue: TaskQueue {
        return DispatchQueue.global(qos:.userInitiated)
    }
    
    /// The utility class represents long-running tasks, typically with a user-visible progress indicator.
    /// Use it for computations, I/O, networking, continous data feeds and similar tasks. This class is designed to be energy efficient.
    public static var globalUtilityQueue: TaskQueue {
        return DispatchQueue.global(qos:.utility)

    }
    
    /// The background class represents tasks that the user is not directly aware of.
    /// Use it for prefetching, maintenance, and other tasks that don’t require user interaction and aren’t time-sensitive.
    public static var globalBackgroundQueue: TaskQueue {
        return DispatchQueue.global(qos:.background)
    }
    
    /// The global main queue represents tasks that need to be ran on the main UI thread.
    public static var globalMainQueue: TaskQueue {
        return DispatchQueue.main
    }
    
    //#MARK: Methods

    /// Gets the running task scheduler
    public static func runningContext() -> TaskScheduler {
        return TaskScheduler(taskQueue: nil)
    }
    
    /// Gets the UI task scheduler
    public static func ui() -> TaskScheduler {
        return TaskScheduler(taskQueue: globalMainQueue)
    }
    
    /// Gets the user interactive task scheduler
    public static func userInteractive() -> TaskScheduler {
        return TaskScheduler(taskQueue: globalUserInteractiveQueue)
    }
    
    /// Gets the user initiated task scheduler
    public static func userInitiated() -> TaskScheduler {
        return TaskScheduler(taskQueue: globalUserInitiatedQueue)
    }
    
    /// Gets the utility task scheduler
    public static func utility() -> TaskScheduler {
        return TaskScheduler(taskQueue: globalUtilityQueue)
    }
    
    /// Gets the background task scheduler
    public static func background() -> TaskScheduler {
        return TaskScheduler(taskQueue: globalBackgroundQueue)
    }
    
    /// Gets the task scheduler for a custom queue
    public static func queueContext(_ taskQueue:TaskQueue) -> TaskScheduler {
        return TaskScheduler(taskQueue: taskQueue)
    }
    
    /// Gets the task queue
    internal func getTaskQueue() -> TaskQueue? {
        return _taskQueue
    }
    
    /// Gets the task queue or default
    internal func getTaskQueueOrDefault() -> TaskQueue {
        return getTaskQueue() ?? TaskScheduler.globalBackgroundQueue
    }
}
