//
//  GlobalDefs.swift
//  GMapService
//
//  Created by Jose Zarzuela on 28/12/2014.
//  Copyright (c) 2014 Jose Zarzuela. All rights reserved.
//

import Foundation
import JZBUtils


//============================================================================================================================
// MARK: TYPE ALIASES

// ----------------------------------------------------------------------------------------------------
private typealias BOnSuccess = () -> Void
private typealias BOnError = (error:NSError) -> Void

internal typealias TCookiesDict = Dictionary<String, NSHTTPCookie>
internal typealias TReqResponse = (data:NSData, httpRsp:NSHTTPURLResponse)


//============================================================================================================================
// MARK: GLOBAL VARs
// Global module logger
internal let log = XCGLogger.defaultInstance()


//============================================================================================================================
// MARK: GLOBAL UTIL FUNCs

// ----------------------------------------------------------------------------------------------------
internal func _error(descInfo:String, failureReason:String! = nil, prevError:NSError! = nil) -> NSError {
    
    var userInfo : Dictionary<String, AnyObject> = [NSLocalizedDescriptionKey:descInfo]
    userInfo[NSLocalizedFailureReasonErrorKey]=failureReason
    userInfo[NSUnderlyingErrorKey]=prevError
    
    return NSError(domain: "GMapService.GService", code: 5000, userInfo: userInfo)
}
