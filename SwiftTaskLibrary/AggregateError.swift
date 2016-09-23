//
// AggregateError.swift
// SwiftTaskLibrary
//
// Created by Nicola Gallo on 26/06/2016.
// Copyright © 2016 Nicola Gallo. All rights reserved.
//

import Foundation

/// Represents one or more errors that occur during tasks execution.
public struct AggregateError : Error {
    
    //#MARK: Constructors & Destructors
    
    fileprivate init(innerError:Error, innerErrors:[Error]) {
        self.innerError = innerError
        self.innerErrors = innerErrors
    }
    
    internal init(innerError:Error) {
        self.init(innerError: innerError, innerErrors: [Error]())
    }

    internal init(innerErrors:[Error]) {
        self.init(innerError: innerErrors.first ?? TaskError.unhandled("Error"), innerErrors: innerErrors)
    }

    //#MARK: Properties
    
    /// Gets the error that caused the current error.
    public let innerError:Error
    
    /// Gets errors that caused the current error.
    public let innerErrors:[Error]
    
}
