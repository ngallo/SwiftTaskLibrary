//
// CancellationTokenSource.swift
// SwiftTaskLibrary
//
// Created by Nicola Gallo on 03/07/2016.
// Copyright © 2016 Nicola Gallo. All rights reserved.
//

import Foundation

public class CancellationToken {
    
    //#MARK: Fields
    
    private var _canceled = false
    
    //#MARK: Constructors & Destructors
    
    private init() {
        id = NSUUID().UUIDString
    }

    //#MARK: Properties
    
    public let id:String

    /// Gets whether cancellation has been requested for this token.
    public var isCancellationRequested:Bool {
        return _canceled == true
    }
    
    //#MARK: Methods

    private func cancel() {
        _canceled = true
    }
    
    /// Throws a TaskError.Canceled if this token has had cancellation requested.
    public func throwIfCancellationRequested() throws {
        if _canceled == true  {
            throw TaskError.Canceled
        }
    }
    
}

public class CancellationTokenSource {
    
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
