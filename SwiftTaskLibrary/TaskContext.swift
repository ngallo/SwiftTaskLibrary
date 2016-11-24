//
// TaskContext.swift
// SwiftTaskLibrary
//
// Created by Nicola Gallo on 23/06/2016.
// Copyright © 2016 Nicola Gallo. All rights reserved.
//

import Foundation

/// Represents a Task<T> execution context.
internal final class TaskContext<T> {
    
    //#MARK: Fields
    
    fileprivate let _onSuccess:(T) -> Void
    fileprivate let _onFailure:(NSError, String) -> Void
    
    //#MARK: Constructors & Destructors
    
    internal init(retryCounter:Int, onSuccess:@escaping (T) -> Void, onFailure:@escaping (NSError, String) -> Void) {
        self.retryCounter = retryCounter
        _onSuccess = onSuccess
        _onFailure = onFailure
    }
    
    //#MARK: Properties
    
    /// Gets the current retry counter.
    internal let retryCounter:Int
    
    //#MARK: Methods
    
    /// Sets the task in a completed state and assign the result.
    internal func setResult(_ result:T) {
        _onSuccess(result)
    }
    
    /// Sets the task in a faulted state.
    internal func setError(_ error:NSError, errorMessage:String) {
        _onFailure(error, errorMessage)
    }
    
}
