//
// Task_Status.swift
// SwiftTaskLibrary
//
// Created by Nicola Gallo on 23/06/2016.
// Copyright © 2016 Nicola Gallo. All rights reserved.
//

import Foundation

public extension Task {

    //#MARK: Properties
    
    /// Gets whether this Task instance has completed execution due to being canceled.
    public var isCanceled:Bool {
        switch status {
        case .Canceled:
            return true
        default:
            return false
        }
    }
    
    /// Gets whether this Task is in a faulted state.
    public var isFaulted:Bool {
        switch status {
        case .Faulted:
            return true
        default:
            return false
        }
    }
    
    /// Gets whether this Task is running.
    public var isRunning:Bool {
        switch status {
        case .Running:
            return true
        default:
            return false
        }
    }
    
    /// Gets whether this Task has completed.
    public var isCompleted:Bool {
        switch status {
        case .RanToCompletion:
            return true
        default:
            return false
        }
    }
    
    /// Gets whether this Task has an error.
    public var hasError:Bool {
        return isFaulted && error != nil
    }
    
    /// Gets whether this Task instance has completed execution.
    public var isTerminated:Bool {
        return isCanceled || isFaulted || isCompleted
    }
    
}
