//
// AggregateError.swift
// SwiftTaskLibrary
//
// Created by Nicola Gallo on 26/06/2016.
// Copyright © 2016 Nicola Gallo. All rights reserved.
//

import Foundation

/// Represents one or more errors that occur during tasks execution.
public struct AggregateError : ErrorType {
    
    //#MARK: Constructors & Destructors
    
    private init(innerError:ErrorType, innerErrors:[ErrorType]) {
        self.innerError = innerError
        self.innerErrors = innerErrors
    }
    
    internal init(innerError:ErrorType) {
        self.init(innerError: innerError, innerErrors: [ErrorType]())
    }

    internal init(innerErrors:[ErrorType]) {
        self.init(innerError: innerErrors.first ?? TaskError.Unhandled("Error"), innerErrors: innerErrors)
    }

    //#MARK: Properties
    
    /// Gets the error that caused the current error.
    public let innerError:ErrorType
    
    /// Gets errors that caused the current error.
    public let innerErrors:[ErrorType]
    
}
