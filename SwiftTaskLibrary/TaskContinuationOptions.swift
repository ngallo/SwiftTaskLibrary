//
// TaskContinuationOptions.swift
// SwiftTaskLibrary
//
// Created by Nicola Gallo on 21/06/2016.
// Copyright © 2016 Nicola Gallo. All rights reserved.
//

import Foundation

public enum TaskContinuationOptions {

    /// When no continuation options are specified, specifies that default behavior should be used when executing a continuation.
    case None
    /// Specifies that the continuation task should be executed synchronously.
    case ExecuteSynchronously
    /// Specifies that the continuation task should not be scheduled if its antecedent was canceled.
    case NotOnCanceled
    /// Specifies that the continuation task should not be scheduled if its antecedent threw an unhandled exception.
    case NotOnFaulted
    /// Specifies that the continuation task should not be scheduled if its antecedent ran to completion.
    case NotOnRanToCompletion
    /// Specifies that the continuation should be scheduled only if its antecedent was canceled.
    case OnlyOnCanceled
    /// Specifies that the continuation task should be scheduled only if its antecedent threw an unhandled exception. .
    case OnlyOnFaulted
    /// Specifies that the continuation should be scheduled only if its antecedent ran to completion..
    case OnlyOnRanToCompletion
    /// Specifies that the continuation task should be run asynchronously.
    case RunContinuationsAsynchronously
    
}
