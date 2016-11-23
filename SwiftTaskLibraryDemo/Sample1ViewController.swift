//
// ViewController.swift
// SwiftTaskLibraryDemo
//
// Created by Nicola Gallo on 19/06/2016.
// Copyright © 2016 Nicola Gallo. All rights reserved.
//

import UIKit
import SwiftTaskLibrary

open class Sample1ViewController: UIViewController {

    //#MARK: Fields
    
    @IBOutlet weak var _startBtn: UIButton!
    @IBOutlet weak var _startBtn2: UIButton!
    @IBOutlet weak var _textView: UITextView!
    
    //#MARK: Methods
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        _startBtn.layer.cornerRadius = 5.0
        _startBtn2.layer.cornerRadius = 5.0
    }
    
    fileprivate func getCurrentTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: Date())
    }
    
    fileprivate func concatResult(_ token:CancellationToken, result1:String?, result2:String) throws -> String {
        try token.throwIfCancellationRequested()
        return "\(result1 ?? "NO RESULT")\n\(result2)"
    }
    
    fileprivate func getResult(_ taskName:String) -> String  {
        return "\(getCurrentTime()) - \(taskName)"
    }
    
    fileprivate func getResultWithToken(_ token:CancellationToken, taskName:String) throws -> String  {
        try token.throwIfCancellationRequested()
        return getResult(taskName)
    }
    
    //#MARK: Operations

    @IBAction func startTouchUp(_ sender: AnyObject) {
        let nOfRetries = 1
        let cTokenSource = CancellationTokenSource()
        let token = cTokenSource.token
        cTokenSource.cancel()
        TaskFactory.startAsync(TaskScheduler.background(), cancellationToken: token, numberOfRetries: nOfRetries) {
                return try self.getResultWithToken(token, taskName: "Task1")
            }
            .continueWith(cancellationToken: token, numberOfRetries: nOfRetries, taskContinuationOption: TaskContinuationOptions.onlyOnRanToCompletion) {
                [unowned self] task in
                return try self.concatResult(token, result1:task.result, result2: self.getResult("Task2"))
            }
            .continueWith(cancellationToken: token, numberOfRetries: nOfRetries, taskContinuationOption: TaskContinuationOptions.onlyOnCanceled) {
                [unowned self] task in
                return try self.concatResult(token, result1:task.result, result2: self.getResult("Task3"))
            }
            .continueWith(TaskScheduler.ui(), cancellationToken: token, numberOfRetries: nOfRetries) {
                [unowned self] task in
                self._textView.text = task.result ?? "NO RESULT"
        }
        _textView.text = ""
    }
    
    @IBAction func startTaskCompletionSourceTouchUp(_ sender: AnyObject) {
        let cTokenSource = CancellationTokenSource()
        let token = cTokenSource.token
        
        let tcs = TaskCompletionSource<String>()
        tcs.task
            .continueWith(cancellationToken: token, numberOfRetries: 2) {
                [unowned self] task in
                return try self.concatResult(token, result1:task.result, result2: self.getResult("Task2"))
            }
            .continueWith(cancellationToken: token, numberOfRetries: 2, taskContinuationOption: TaskContinuationOptions.onlyOnRanToCompletion) {
                [unowned self] task in
                return try self.concatResult(token, result1:task.result, result2: self.getResult("Task3"))
            }
            .continueWith(TaskScheduler.ui(), cancellationToken: token, numberOfRetries: 2) {
                [unowned self] task in
                self._textView.text = task.result ?? "NO RESULT"
        }
        
        
        //Simulate and async operation dispatched from another framework
        let backgroundQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        backgroundQueue.async {
            DispatchQueue.main.sync(execute: { () -> Void in
                self._textView.text = "TaskCompletionSource - Running"
            })
            sleep(2)
            tcs.setResult(self.getResult("TaskCompletionSource - Completed"))
        }
        
        
    }
    
    @IBAction func startMemoryLeakCheck(_ sender: Any) {
        TaskFactory.startAsync() { () -> String in 
            print("OK")
            return "RESULT"
            }.continueWith(TaskScheduler.ui()) {
                [unowned self] task in
                self._textView.text = task.result ?? "NO RESULT"
        }
    }
}
