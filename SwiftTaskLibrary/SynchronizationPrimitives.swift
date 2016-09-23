//
// SynchronizationPrimitives.swift
// SwiftTaskLibrary
//
// Created by Nicola Gallo on 18/06/2016.
// Copyright © 2016 Nicola Gallo. All rights reserved.
//

import Foundation

/// Marks the block as a critical section by obtaining the mutual-exclusion lock for a given object.
public func task_lock(_ lock: AnyObject, closure: () -> Void) {
    objc_sync_enter(lock)
    closure()
    objc_sync_exit(lock)
}

/// Marks the block as a critical section by obtaining the mutual-exclusion lock for a given object.
public func task_trylock(_ lock: AnyObject, closure: () throws -> ()) throws {
    objc_sync_enter(lock)
    do {
        try closure()
        objc_sync_exit(lock)
    }
    catch let error as NSError {
        objc_sync_exit(lock)
        throw error
    }
}
