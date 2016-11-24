//
// SynchronizationPrimitives.swift
// SwiftTaskLibrary
//
// Created by Nicola Gallo on 18/06/2016.
// Copyright © 2016 Nicola Gallo. All rights reserved.
//

import Foundation

/// Marks the block as a critical section by obtaining the mutual-exclusion lock for a given object.
@discardableResult
public func task_lock<T>(_ lock: AnyObject, closure: () -> T) -> T {
    defer {
        objc_sync_exit(lock)
    }
    objc_sync_enter(lock)
    return closure()
}

/// Marks the block as a critical section by obtaining the mutual-exclusion lock for a given object.
@discardableResult
public func task_trylock<T>(_ lock: AnyObject, closure: () throws -> T) throws -> T {
    defer {
        objc_sync_exit(lock)
    }
    objc_sync_enter(lock)
    return try closure()
}
