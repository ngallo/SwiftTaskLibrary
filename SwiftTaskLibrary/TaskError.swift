//
// TaskError.swift
// SwiftTaskLibrary
//
// Created by Nicola Gallo on 19/06/2016.
// Copyright © 2016 Nicola Gallo. All rights reserved.
//

import Foundation

/// Defines a Task's error.
public enum TaskError: Error {
    
    /// A generic task error.
    case unhandled(String)
    
    /// A cencellation task error.
    case canceled
    
    /// A cencellation task error.
    case nilResult

}
