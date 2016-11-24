//
//  TaskPool.swift
//  SwiftTaskLibrary
//
//  Created by Nicola Gallo on 24/11/2016.
//  Copyright © 2016 Nicola Gallo. All rights reserved.
//

import Foundation

/// Track tasks and manage strong references.
internal class TaskRefCounter {
    
    //#MARK: Fields
    
    private static var _syncRoot = NSObject()
    private static var _tasksMap = [String: Taskable]()

    //#MARK: Methods

    internal static func register(task:Taskable) {
        task_lock(_syncRoot) {
            if self._tasksMap[task.id] == nil {
                self._tasksMap[task.id] = task
            }
        }
    }
    
    internal static func unregister(task:Taskable) {
        task_lock(_syncRoot) {
            self._tasksMap.removeValue(forKey: task.id)
        }
    }
    
}
