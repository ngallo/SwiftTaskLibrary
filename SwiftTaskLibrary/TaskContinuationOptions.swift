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
    case none
    /// Specifies that the continuation task should be executed synchronously.
    case executeSynchronously
    /// Specifies that the continuation task should not be scheduled if its antecedent was canceled.
    case notOnCanceled
    /// Specifies that the continuation task should not be scheduled if its antecedent threw an unhandled exception.
    case notOnFaulted
    /// Specifies that the continuation task should not be scheduled if its antecedent ran to completion.
    case notOnRanToCompletion
    /// Specifies that the continuation should be scheduled only if its antecedent was canceled.
    case onlyOnCanceled
    /// Specifies that the continuation task should be scheduled only if its antecedent threw an unhandled exception. .
    case onlyOnFaulted
    /// Specifies that the continuation should be scheduled only if its antecedent ran to completion..
    case onlyOnRanToCompletion
    /// Specifies that the continuation task should be run asynchronously.
    case runContinuationsAsynchronously
    
}
