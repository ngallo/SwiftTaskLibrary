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

    internal static func reference(task:Taskable) {
        task_lock(_syncRoot) {
            if self._tasksMap[task.id] == nil {
                self._tasksMap[task.id] = task
            }
        }
    }
    
    internal static func signalTermination() {
        task_lock(_syncRoot) {
            let values = _tasksMap.values
            for value in values {
                if (value.refCounterActive ==  false) {
                    _tasksMap.removeValue(forKey: value.id)
                }
            }
        }
    }
    
}
