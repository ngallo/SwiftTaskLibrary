//
// ViewController.swift
// SwiftTaskLibraryDemo
//
// Created by Nicola Gallo on 19/06/2016.
// Copyright © 2016 Nicola Gallo. All rights reserved.
//

import UIKit
import SwiftTaskLibrary

public class Sample1ViewController: UIViewController {

    //#MARK: Fields
    
    @IBOutlet weak var _startBtn: UIButton!
    @IBOutlet weak var _startBtn2: UIButton!
    @IBOutlet weak var _textView: UITextView!
    
    //#MARK: Methods
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        _startBtn.layer.cornerRadius = 5.0
        _startBtn2.layer.cornerRadius = 5.0
    }
    
    private func getCurrentTime() -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.stringFromDate(NSDate())
    }
    
    private func concatResult(token:CancellationToken, result1:String?, result2:String) throws -> String {
        try token.throwIfCancellationRequested()
        return "\(result1 ?? "NO RESULT")\n\(result2)"
    }
    
    private func getResult(taskName:String) -> String  {
        return "\(getCurrentTime()) - \(taskName)"
    }
    
    private func getResultWithToken(token:CancellationToken, taskName:String) throws -> String  {
        try token.throwIfCancellationRequested()
        return getResult(taskName)
    }
    
    //#MARK: Operations

    @IBAction func startTouchUp(sender: AnyObject) {
        let nOfRetries = 1
        let cTokenSource = CancellationTokenSource()
        let token = cTokenSource.token
        cTokenSource.cancel()
        TaskFactory.startAsync(TaskScheduler.background(), cancellationToken: token, numberOfRetries: nOfRetries) {
                return try self.getResultWithToken(token, taskName: "Task1")
            }
            .continueWith(cancellationToken: token, numberOfRetries: nOfRetries, taskContinuationOption: TaskContinuationOptions.OnlyOnRanToCompletion) {
                [unowned self] task in
                return try self.concatResult(token, result1:task.result, result2: self.getResult("Task2"))
            }
            .continueWith(cancellationToken: token, numberOfRetries: nOfRetries, taskContinuationOption: TaskContinuationOptions.OnlyOnCanceled) {
                [unowned self] task in
                return try self.concatResult(token, result1:task.result, result2: self.getResult("Task3"))
            }
            .continueWith(TaskScheduler.ui(), cancellationToken: token, numberOfRetries: nOfRetries) {
                [unowned self] task in
                self._textView.text = task.result ?? "NO RESULT"
        }
        _textView.text = ""
    }
    
    @IBAction func startTaskCompletionSourceTouchUp(sender: AnyObject) {
        let cTokenSource = CancellationTokenSource()
        let token = cTokenSource.token
        
        let tcs = TaskCompletionSource<String>()
        tcs.task
            .continueWith(cancellationToken: token, numberOfRetries: 2) {
                [unowned self] task in
                return try self.concatResult(token, result1:task.result, result2: self.getResult("Task2"))
            }
            .continueWith(cancellationToken: token, numberOfRetries: 2, taskContinuationOption: TaskContinuationOptions.OnlyOnRanToCompletion) {
                [unowned self] task in
                return try self.concatResult(token, result1:task.result, result2: self.getResult("Task3"))
            }
            .continueWith(TaskScheduler.ui(), cancellationToken: token, numberOfRetries: 2) {
                [unowned self] task in
                self._textView.text = task.result ?? "NO RESULT"
        }
        
        
        //Simulate and async operation dispatched from another framework
        let backgroundQueue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)
        dispatch_async(backgroundQueue) {
            dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                self._textView.text = "TaskCompletionSource - Running"
            })
            sleep(2)
            tcs.setResult(self.getResult("TaskCompletionSource - Completed"))
        }
        
        
    }
}
