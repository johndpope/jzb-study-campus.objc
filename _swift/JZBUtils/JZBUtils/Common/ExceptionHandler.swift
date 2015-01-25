//  Swift Non-Standard Library
//
//  Created by Russ Bishop
//  http://github.com/xenadu/SwiftNonStandardLibrary
//
//  MIT licensed; see LICENSE for more information


import Foundation

///Executes a closure that returns no result.
///If an exception is thrown, the catch closure is executed.
///In all cases, the finally closure is executed.
///
public func try(action:()->Void, catch:((NSException!)->Void)? = nil, finally:(()->Void)? = nil) {
    
    OSSExceptionHelper.tryInvokeBlock(action, catch, finally)
}


///Executes a closure that returns T
///If an exception is thrown, the catch closure is executed and the overall result will be nil
///In all cases, the finally closure is executed.
///
public func try<T: AnyObject>(action:()->T, catch:((NSException!)->Void)? = nil, finally: (()->Void)? = nil) -> T? {
    
    if let result : AnyObject! = OSSExceptionHelper.tryInvokeBlockWithReturn(action, catch: { ex in
        if let catchClause = catch {
            catchClause(ex)
        }
        return nil
        }, finally: finally)
    {
        return result as? T
    } else {
        return nil
    }
}

///Executes a closure that returns T
///If an exception is thrown, the catch closure is executed; if the catch closure returns nil then the overall result is nil,
/// otherwise the catch closure can return an alternate T result
///In all cases, the finally closure is executed.
///
public func try<T: AnyObject>(action:()->T, catch:((NSException!)->T)? = nil, finally: (()->Void)? = nil) -> T? {

    if let result : AnyObject! = OSSExceptionHelper.tryInvokeBlockWithReturn(action, catch: catch, finally: finally) {
        return result as? T
    } else {
        return nil
    }
}

///Throws an NSException. This must be in the context of try() or your program will abort since Swift does not handle exceptions natively
public func throw(name:String, message:String) {
    OSSExceptionHelper.throwExceptionNamed(name, message: message)
}

///Throws an NSException. This must be in the context of try() or your program will abort since Swift does not handle exceptions natively
public func throw(ex:NSException) {
    OSSExceptionHelper.throwException(ex)
}