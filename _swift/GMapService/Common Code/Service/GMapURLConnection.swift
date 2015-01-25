//
//  GMapURLConnection.swift
//  GMapService
//
//  Created by Jose Zarzuela on 28/12/2014.
//  Copyright (c) 2014 Jose Zarzuela. All rights reserved.
//

import Foundation
import JZBUtils


internal typealias TNameValue = (name:String, value:String)


//============================================================================================================================
internal class GMapURLConnection {
        
    
    //------------------------------------------------------------------------------------------------------------------------
    private init() {
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    internal class func GET(url:String, params:Array<TNameValue>) -> NSMutableURLRequest {
        
        var strURL = url
        for (index, param) in enumerate(params) {
            strURL += (index == 0 ? "?" : "&")
            strURL += param.0.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            strURL += "="
            strURL += param.1.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        }
        
        let request = NSMutableURLRequest(URL: NSURL(string: strURL)!)
        request.HTTPMethod = "GET"
        return request
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    internal class func POST(url:String, queryParams:Array<TNameValue>, bodyParams:Array<TNameValue>) -> NSMutableURLRequest {
        
        var strURL = url
        for (index, param) in enumerate(queryParams) {
            strURL += (index == 0 ? "?" : "&")
            strURL += param.0.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            strURL += "="
            strURL += param.1.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        }
        
        var bodyStr = ""
        for (index, param) in enumerate(bodyParams) {
            bodyStr += (index > 0 ? "&" : "")
            bodyStr += param.0.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            bodyStr += "="
            bodyStr += param.1.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        }
        
        let bodyData = bodyStr.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        
        let request = NSMutableURLRequest(URL: NSURL(string: strURL)!)
        request.HTTPMethod = "POST"
        request.setValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "content-type")
        request.HTTPBody = bodyData
        
        return request
    }

    //------------------------------------------------------------------------------------------------------------------------
    internal class func sendSynchronousRequest(request:NSMutableURLRequest, cookies:TCookiesDict, inout error:NSError?) -> TReqResponse? {
        
        var result : TReqResponse? = nil
        
        
        // Añadir cabeceras a la peticion
        _addDefaultHeaders(request)
        
        // Añadir cookies
        _addAllCookies(request, cookies:cookies)
        
        
        // Crea el Delegate que prohibe las redirecciones y el cacheo
        let delegate = GMapURLConnectionDelegate()
        
        // Hace la peticion
        if let conn = NSURLConnection(request: request, delegate: delegate, startImmediately: false) {
            conn.start()
        }
        
        // Permite que se ejecute la peticion esperando a que termine
        while (dispatch_semaphore_wait(delegate.semaphore, DISPATCH_TIME_NOW) != 0) {
            NSRunLoop.currentRunLoop().runUntilDate(NSDate(timeIntervalSinceNow: 0))
        }
        
        // Chequea que la respuesta, aunque se haya recibido, es correcta (HTTP-STATUS)
        if delegate.error == nil {
            
            // Retorna el resultado capturado en el delegate
            if _isResponseStatusOK(delegate) {
                result = (delegate.data, delegate.response as NSHTTPURLResponse!)
            }
            
        }
        
        // Devuelte el resultado
        error = delegate.error
        return result
    }
    
    //=====================================================================================================
    // MARK: Private util methods
    
    
    // ----------------------------------------------------------------------------------------------------
    private class func _addDefaultHeaders(request:NSMutableURLRequest) {
        
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/600.1.25 (KHTML, like Gecko) Version/8.0 Safari/600.1.25", forHTTPHeaderField: "User-Agent")
        request.setValue("en-us", forHTTPHeaderField: "Accept-Language")
        request.setValue("*/*,text/html,application/xhtml+xml,application/xml,application/vnd.google.map;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        request.setValue("no-cache", forHTTPHeaderField: "Pragma")
        request.setValue("1", forHTTPHeaderField: "X-Same-Domain")
    }
    
    // ----------------------------------------------------------------------------------------------------
    private class func _addAllCookies(request:NSMutableURLRequest, cookies:TCookiesDict) {
        
        let cookiesDict = NSHTTPCookie.requestHeaderFieldsWithCookies(Array<NSHTTPCookie>(cookies.values))
        for item in cookiesDict {
            request.setValue(item.1 as? String, forHTTPHeaderField: item.0 as String)
        }
    }
    
    // ----------------------------------------------------------------------------------------------------
    private class func _isResponseStatusOK(delegate : GMapURLConnectionDelegate) -> Bool {
        
        let statusCode = (delegate.response as? NSHTTPURLResponse)?.statusCode ?? 418 // I'm a teapot
        
        switch statusCode {
            
        case 0..<400:
            // Todo OK
            return true;
            
        case 429:
            // 429 es un error indicando que se han realizado demasiadas peticiones seguidas
            let statusReason = NSHTTPURLResponse.localizedStringForStatusCode(statusCode)
            delegate.error = _error("Response status was not OK (Too frequent calls)", failureReason: statusReason)
            return false
            
        default:
            // Traza el cuerpo de la peticion como debug
            let bodyTxt = NSString(data: delegate.data, encoding: NSUTF8StringEncoding) ?? ""
            log.error("HTTP code: \(statusCode), bodyTxt = \(bodyTxt)")
            
            let statusReason = NSHTTPURLResponse.localizedStringForStatusCode(statusCode)
            delegate.error = _error("Response status was not OK", failureReason: statusReason)
            return false
        }
    }
        
}


//============================================================================================================================
private class GMapURLConnectionDelegate: NSObject, NSURLConnectionDelegate, NSURLConnectionDataDelegate {
    
    let semaphore : dispatch_semaphore_t
    
    var error: NSError?
    var response: NSURLResponse?
    var data: NSMutableData = NSMutableData()
    
    
    
    //------------------------------------------------------------------------------------------------------------------------
    override init() {
        self.semaphore  = dispatch_semaphore_create(0)
        super.init()
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    // Sent when a connection fails to load its request successfully.
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        log.debug("error -> \(error)")
        self.error = error
        dispatch_semaphore_signal(semaphore)
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    // Sent when the connection has received sufficient data to construct the URL response for its request.
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
        self.response = response
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    // Sent as a connection loads data incrementally.
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        
        self.data.appendData(data)
        
        //NSThread.sleepForTimeInterval(10)
    }
    
    
    //------------------------------------------------------------------------------------------------------------------------
    // Sent as the body (message data) of a request is transmitted (such as in an http POST request).
    func connection(connection: NSURLConnection, didSendBodyData bytesWritten: Int, totalBytesWritten: Int, totalBytesExpectedToWrite: Int) {
    }
    
    
    //------------------------------------------------------------------------------------------------------------------------
    // Sent when a connection has finished loading successfully.
    func connectionDidFinishLoading(connection: NSURLConnection) {
        dispatch_semaphore_signal(semaphore)
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    // Sent when the connection determines that it must change URLs in order to continue loading a request.
    func connection(connection: NSURLConnection, willSendRequest request: NSURLRequest, redirectResponse: NSURLResponse?) -> NSURLRequest? {
        
        // Prohibe la redireccion
        if redirectResponse==nil {
            return request
        } else {
            return nil
        }
    }
    
    //------------------------------------------------------------------------------------------------------------------------
    // Called when an NSURLConnection needs to retransmit a request that has a body stream to provide a new, unopened stream.
    // private func connection(connection: NSURLConnection, needNewBodyStream request: NSURLRequest) -> NSInputStream? {
    //    log.debug("")
    //}
    
    //------------------------------------------------------------------------------------------------------------------------
    // Sent before the connection stores a cached response in the cache, to give the delegate an opportunity to alter it.
    func connection(connection: NSURLConnection, willCacheResponse cachedResponse: NSCachedURLResponse) -> NSCachedURLResponse? {
        
        // Prohibe el cacheo
        return nil
    }
    
}


