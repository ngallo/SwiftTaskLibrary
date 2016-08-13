//
// TaskContext.swift
// SwiftTaskLibrary
//
// Created by Nicola Gallo on 23/06/2016.
// Copyright © 2016 Nicola Gallo. All rights reserved.
//

import Foundation

/// Represents a Task<T> execution context.
internal class TaskContext<T> {
    
    //#MARK: Fields
    
    private let _onSuccess:(T) -> Void
    private let _onFailure:(NSError, String) -> Void
    
    //#MARK: Constructors & Destructors
    
    internal init(retryCounter:Int, onSuccess:(T) -> Void, onFailure:(NSError, String) -> Void) {
        self.retryCounter = retryCounter
        _onSuccess = onSuccess
        _onFailure = onFailure
    }
    
    //#MARK: Properties
    
    /// Gets the current retry counter.
    internal let retryCounter:Int
    
    //#MARK: Methods
    
    /// Sets the task in a completed state and assign the result.
    internal func setResult(result:T) {
        _onSuccess(result)
    }
    
    /// Sets the task in a faulted state.
    internal func setError(error:NSError, errorMessage:String) {
        _onFailure(error, errorMessage)
    }
    
}
