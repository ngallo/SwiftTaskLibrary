//
// TaskStatus.swift
// SwiftTaskLibrary
//
// Created by Nicola Gallo on 19/06/2016.
// Copyright © 2016 Nicola Gallo. All rights reserved.
//

import Foundation

/// Represents the current stage in the lifecycle of a Task.
public enum TaskStatus {
    
    /// The task has been initialized but has not yet been started.
    case created
    /// The task has been started but has been canceled.
    case canceled
    /// The task completed due to an unhandled error.
    case faulted(Error)
    /// The task is running but has not yet completed.
    case running
    /// The task completed execution successfully.
    case ranToCompletion

}
