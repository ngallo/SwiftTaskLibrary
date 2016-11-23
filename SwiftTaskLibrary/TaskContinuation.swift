//
// TaskContinuation.swift
// SwiftTaskLibrary
//
// Created by Nicola Gallo on 26/06/2016.
// Copyright © 2016 Nicola Gallo. All rights reserved.
//

import Foundation

/// Defines a task continuation description
internal final class TaskContinuation {

    //#MARK: Constructors & Destructors
    
    internal init(taskScheduler: TaskScheduler, cancellationToken:CancellationToken?, numberOfRetries:Int, taskContinuationOption:TaskContinuationOptions, taskable:Taskable) {
        self.taskScheduler = taskScheduler
        self.cancellationToken = cancellationToken
        self.numberOfRetries = numberOfRetries
        self.taskContinuationOption = taskContinuationOption
        self.taskable = taskable
    }
    
    deinit {
        print("")
    }
    
    //#MARK: Properties
    
    internal let taskScheduler:TaskScheduler
    internal let cancellationToken:CancellationToken?
    internal let numberOfRetries:Int
    internal let taskContinuationOption:TaskContinuationOptions
    internal weak var taskable:Taskable?
    internal var isStarted:Bool = false
    
}
