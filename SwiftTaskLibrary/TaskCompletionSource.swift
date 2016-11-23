//
//  TaskCompletionSource.swift
//  SwiftTaskLibrary
//
//  Created by Nicola Gallo on 10/08/2016.
//  Copyright © 2016 Nicola Gallo. All rights reserved.
//

import Foundation

public final class TaskCompletionSource<T> {

    //#MARK: Fields
    
    fileprivate var _task:Task<T>?
    fileprivate var _syncRoot = NSObject()
    fileprivate var _isInitialized = false
    fileprivate var _setResult:((T) -> Void)? = nil
    fileprivate var _setError:((_ error:NSError, _ errorMessage:String) -> Void)? = nil
    
    //#MARK: Constructors & Destructors
    
    public init() {
        
        print("OK")
    }
    
    //#MARK: Properties
    
    public var task:Task<T> {
        get {
            initialiseTask()
            return _task!
        }
    }
    
    //#MARK: Methods
    
    fileprivate func initialiseTask() {
        if _isInitialized == true {
            return
        }
        task_lock(_syncRoot) {
            if _isInitialized == true {
                return
            }
            self._task = Task<T>(taskCompletion: self)
            let actions = self._task?.startSync()
            self._setResult = actions!.setResult
            self._setError = actions!.setError
            self._isInitialized = true
        }
    }
    
    ///Transitions the underlying Task<T> into the RanToCompletion state.
    public func setResult(_ result:T) {
        initialiseTask()
        _setResult!(result)
    }
    
    // Transitions the underlying Task<T> into the Faulted state and binds it to a specified error.
    public func setError(_ errorMessage:String) {
        let nsError = NSError(domain: "SwiftTaskLibrary", code: 0, userInfo: [:])
        setError(nsError, errorMessage: errorMessage)
    }
    
    // Transitions the underlying Task<T> into the Faulted state and binds it to a specified error.
    public func setError(_ error:NSError, errorMessage:String) {
        initialiseTask()
        _setError!(error, errorMessage)
    }
    
}
