//
//  Async.swift
//  JZBUtils
//
//  Created by Jose Zarzuela on 24/12/2014.
//  Copyright (c) 2014 Jose Zarzuela. All rights reserved.
//

import Foundation


public class Async {
    
    
    
    //------------------------------------------------------------------------------------------------------------------------
    internal init() {
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    public class func exec(#block:()->Void, onMain:()->Void) {
        
        let async_q : dispatch_queue_t = dispatch_queue_create("Async queue", DISPATCH_QUEUE_CONCURRENT)
        dispatch_async(async_q) {
            
            block()
            
            dispatch_sync(dispatch_get_main_queue(), {onMain()})
        }
        
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    public class func exec(#block:()->Any?, onMain:(result:Any?)->Void) {
        
        let async_q : dispatch_queue_t = dispatch_queue_create("Async queue", DISPATCH_QUEUE_CONCURRENT)
        dispatch_async(async_q) {
            
            let value = block()
            
            dispatch_sync(dispatch_get_main_queue(), {onMain(result: value)})
        }
        
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    public class func exec(#block:()->(result:Any?, error:NSError?), onSuccess:(result:Any?)->Void, onError:(error:NSError)->Void) {

        let async_q : dispatch_queue_t = dispatch_queue_create("Async queue", DISPATCH_QUEUE_CONCURRENT)
        dispatch_async(async_q) {
            
            let value = block()
            
            if value.error == nil {
                dispatch_sync(dispatch_get_main_queue(), {onSuccess(result:value.result)})
            } else {
                dispatch_sync(dispatch_get_main_queue(), {onError(error: value.error!)})
            }
            
        }
        
    }
    
    
}
