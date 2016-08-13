//
//  TaskCompletionSource.swift
//  SwiftTaskLibrary
//
//  Created by Nicola Gallo on 10/08/2016.
//  Copyright © 2016 Nicola Gallo. All rights reserved.
//

import Foundation

public class TaskCompletionSource<T> {
    
    //#MARK: Fields
    
    private var _task:Task<T>?
    private var _onceToken: dispatch_once_t = 0
    private var _setResult:((T) -> Void)? = nil
    private var _setError:((error:NSError, errorMessage:String) -> Void)? = nil
    
    //#MARK: Constructors & Destructors
    
    public init() {
    }
    
    //#MARK: Properties
    
    public var task:Task<T> {
        get {
            initialiseTask()
            return _task!
        }
    }
    
    //#MARK: Methods
    
    private func initialiseTask() {
        dispatch_once(&_onceToken) {
            self._task = Task<T>(taskCompletion: self)
            let actions = self._task?.startSync()
            self._setResult = actions!.setResult
            self._setError = actions!.setError
        }
    }
    
    ///Transitions the underlying Task<T> into the RanToCompletion state.
    public func setResult(result:T) {
        initialiseTask()
        _setResult!(result)
    }
    
    // Transitions the underlying Task<T> into the Faulted state and binds it to a specified error.
    public func SetError(error:NSError, errorMessage:String) {
        initialiseTask()
        _setError!(error: error, errorMessage:errorMessage)
    }
    
}
