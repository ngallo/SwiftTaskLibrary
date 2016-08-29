//
// TaskError.swift
// SwiftTaskLibrary
//
// Created by Nicola Gallo on 19/06/2016.
// Copyright © 2016 Nicola Gallo. All rights reserved.
//

import Foundation

/// Defines a Task's error.
public enum TaskError: ErrorType {
    
    /// A generic task error.
    case Unhandled(String)
    
    /// A cencellation task error.
    case Canceled
    
    /// A cencellation task error.
    case NilResult

}
