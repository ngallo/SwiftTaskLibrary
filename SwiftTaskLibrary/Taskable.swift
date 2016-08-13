//
// Taskable.swift
// SwiftTaskLibrary
//
// Created by Nicola Gallo on 26/06/2016.
// Copyright © 2016 Nicola Gallo. All rights reserved.
//

import Foundation

internal protocol Taskable {
    
    //#MARK: Properties
    
    var id:String { get }


    //#MARK: Methods

    func cancelSync()
    func startSync(taskScheduler:TaskScheduler, cancellationToken:CancellationToken?, numberOfRetries:Int)
    func startAsync(taskScheduler:TaskScheduler, cancellationToken:CancellationToken?, numberOfRetries:Int)
    func startAfter(numberMs:Double, taskScheduler:TaskScheduler, cancellationToken:CancellationToken?, numberOfRetries:Int)
    
}
