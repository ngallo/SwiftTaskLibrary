//
// CancellationTokenSource.swift
// SwiftTaskLibrary
//
// Created by Nicola Gallo on 03/07/2016.
// Copyright © 2016 Nicola Gallo. All rights reserved.
//

import Foundation

public final class CancellationToken {
    
    //#MARK: Fields
    
    fileprivate var _canceled = false
    
    //#MARK: Constructors & Destructors
    
    fileprivate init() {
        id = UUID().uuidString
    }

    //#MARK: Properties
    
    public let id:String

    /// Gets whether cancellation has been requested for this token.
    public var isCancellationRequested:Bool {
        return _canceled == true
    }
    
    //#MARK: Methods

    fileprivate func cancel() {
        _canceled = true
    }
    
    /// Throws a TaskError.Canceled if this token has had cancellation requested.
    public func throwIfCancellationRequested() throws {
        if _canceled == true  {
            throw TaskError.canceled
        }
    }
    
}

public final class CancellationTokenSource {
    
    //#MARK: Constructors & Destructors
    
    public init() {
        token = CancellationToken()
    }

    //#MARK: Properties
    
    /// Gets whether cancellation has been requested for this CancellationTokenSource.
    public let token:CancellationToken
    
    //#MARK: Methods
    
    /// Communicates a request for cancellation.
    public func cancel() {
        token.cancel()
    }
    
}
