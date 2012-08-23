//
//  AppDelegate.m
//  GBMSync
//
//  Created by Jose Zarzuela on 18/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "XMLReader/XMLReader.h"
#import "SafariBookmarks.h"


@implementation AppDelegate
@synthesize userName;
@synthesize userPwd;
@synthesize browser;
@synthesize tracesView;


//** CONSTANTS ***********************************************************************************************************
#define JS_LOGIN_CHECK  @"document.forms['gaia_loginform'].elements['Email']!=null && \
                          document.forms['gaia_loginform'].elements['Passwd']!=null"

#define JS_LOGIN_SUBMIT @"document.forms['gaia_loginform'].elements['Email'].value='%@'; \
                          document.forms['gaia_loginform'].elements['Passwd'].value='%@'; \
                          document.forms['gaia_loginform'].elements['PersistentCookie'].checked=0; \
                          document.forms['gaia_loginform'].submit();"

#define URL_LOGOUT  @"https://accounts.google.com/Logout?hl=es"
#define URL_XMLDATA @"https://www.google.com/bookmarks/?output=xml&num=100000"

#define PHASE_ERROR  -1
#define PHASE_LOGOUT  0
#define PHASE_LOGIN   1
#define PHASE_DATA    2
#define PHASE_DONE    3

int getXmlDataPhase = PHASE_LOGOUT;


//** IMPLEMENTATION ******************************************************************************************************

//------------------------------------------------------------------------------------------------------------------------
- (void) applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    // http://www.mmartins.com/mmartins/googlebookmarksapi/
    // 997 2708 1044 7266 2867
    // 1E4B481B-FD3B-41C6-9CE7-49D808B33408
}

//------------------------------------------------------------------------------------------------------------------------
- (void) clearTrace {
    
    NSLog(@"\n\n----- TRACE -----------------------------\n\n");
    
    NSAttributedString *txt = [[NSAttributedString alloc] initWithString:@""];
    NSTextStorage *storage = [tracesView textStorage];
    [storage beginEditing];
    [storage setAttributedString:txt];
    [storage endEditing];
}

//------------------------------------------------------------------------------------------------------------------------
- (void) trace:(NSString *)msg,... {
    
    va_list args;
    va_start(args, msg);
    NSString *msgString = [[NSString alloc] initWithFormat:msg arguments:args];
    va_end(args);

    NSLog(@"TRACE: %@", msgString);
    
    NSAttributedString *txt = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",msgString]];
    NSTextStorage *storage = [tracesView textStorage];
    [storage beginEditing];
    [storage appendAttributedString:txt];
    [storage endEditing];
    
}

//------------------------------------------------------------------------------------------------------------------------
- (void) msgBox:(NSString *)title msg:(NSString *)msg,... {
    
    va_list args;
    va_start(args, msg);
    NSString *msgString = [[NSString alloc] initWithFormat:msg arguments:args];
    va_end(args);
    
    NSAlert *alert = [NSAlert alertWithMessageText:title 
                                     defaultButton:nil 
                                   alternateButton:nil 
                                       otherButton:nil 
                         informativeTextWithFormat:msgString];
    
    /*
    [alert addButtonWithTitle:@"Cancel"]; 
     */
    [alert setAlertStyle:NSWarningAlertStyle]; 
    NSInteger rc = [alert runModal];
}

//------------------------------------------------------------------------------------------------------------------------
- (BOOL) checkIfLoginPage:(NSString *)pageData {
    
    BOOL s0 = [pageData rangeOfString:@"gaia_loginform"].length>0;
    BOOL s1 = [pageData rangeOfString:@"Email"].length>0;
    BOOL s2 = [pageData rangeOfString:@"Passwd"].length>0;
    BOOL s3 = [pageData rangeOfString:@"PersistentCookie"].length>0;
    
    BOOL isLoginPage = s0 && s1 && s2 && s3;
    return isLoginPage;
}

//------------------------------------------------------------------------------------------------------------------------
- (BOOL) checkIfRefreshPage:(NSString *)pageData {
    
    BOOL isRefreshaPage = [pageData rangeOfString:@"refresh"].length>0;
    
    return isRefreshaPage;
}


//------------------------------------------------------------------------------------------------------------------------
- (BOOL) checkIfXmlDataPage:(NSString *)pageData {
    
    BOOL isXmlDataPage = [pageData rangeOfString:@"<xml_api_reply"].length>0;
    
    return isXmlDataPage;
}

//------------------------------------------------------------------------------------------------------------------------
- (void) doLogin {
    
    NSString *un=userName.stringValue;
    NSString *up=userPwd.stringValue;
    
    NSString *jsStr = [NSString stringWithFormat:JS_LOGIN_SUBMIT,un,up];
    [[browser windowScriptObject] evaluateWebScript:jsStr];
}

//------------------------------------------------------------------------------------------------------------------------
- (NSString *) getPageData {    
    
    NSData *responseData = browser.mainFrame.dataSource.data;
    NSString *content = [[NSString alloc]  initWithBytes:[responseData bytes]
                                                  length:[responseData length] encoding: NSUTF8StringEncoding];
    return content;
}


//------------------------------------------------------------------------------------------------------------------------
- (void) parseXmlInfo:(NSString *)xmlInfo {


    NSLog(@"xml = %@",xmlInfo);
    
    NSError *error = nil;
    NSDictionary *dict = [XMLReader dictionaryForFullPath:@"/Users/jzarzuela/Documents/gbkmks.xml" error:&error];
    //NSDictionary *dict = [XMLReader dictionaryForXMLString:xmlInfo error:&error];
    NSLog(@"error = %@",error);
    
    NSArray *bookmarks = [dict retrieveForPath:@"xml_api_reply.bookmarks.bookmark"];
    NSString *str = @"";
    for(NSDictionary *bkmrk in bookmarks) {
        str = [str stringByAppendingFormat:@"%@\n",[bkmrk objectForKey:@"id"]];
    }
    NSLog(@"pepe = %@",str);
}

//------------------------------------------------------------------------------------------------------------------------
- (void) parseSafariBookmarks {
    
    SafariBookmarks * sb = [SafariBookmarks new];
    [sb readSafariBookmarks];
    
}

//------------------------------------------------------------------------------------------------------------------------
- (IBAction) syncBookmarks:(NSButton *)sender {
    
    [self clearTrace];
    [self parseSafariBookmarks];
    [self parseXmlInfo:nil];
    /*
    
    if([userName.stringValue length]<=0 || [userPwd.stringValue length]<=0) {
        [self msgBox:@"Error: Mail or password missing" msg:@"User mail and password must be informed to synch bookmarks"];
    } else {
        
        [browser setPreferencesIdentifier:@"GBMSyncPrefs"];
        browser.preferences.privateBrowsingEnabled = true;
        browser.preferences.usesPageCache = false;
        browser.preferences.loadsImagesAutomatically = false;
        
        browser.frameLoadDelegate=self;
        
        [self trace:@"Logging out from any previous user"]; 
        getXmlDataPhase = PHASE_LOGOUT;
        [browser setMainFrameURL:URL_LOGOUT];
    }
     */
}

//------------------------------------------------------------------------------------------------------------------------
- (void) webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
    
    NSString *content = nil;
    
    switch (getXmlDataPhase) {
            
        case PHASE_LOGOUT:
            [self trace:@"User logged out.\nRequesting login page."]; 
            getXmlDataPhase = PHASE_LOGIN;
            [browser setMainFrameURL:URL_XMLDATA];
            break;
            
        case PHASE_LOGIN:
            content = [self getPageData];    
            if([self checkIfLoginPage:content]) {
                [self trace:@"Logging in for user: %@",userName.stringValue]; 
                getXmlDataPhase = PHASE_DATA;
                [self doLogin];
            } else {
                [self trace:@"Error, Login page was expected."]; 
            }
            break;
            
        case PHASE_DATA:
            content = [self getPageData];    
            if([self checkIfLoginPage:content]) {
                [self trace:@"Error loggin in requested user"]; 
                getXmlDataPhase = PHASE_ERROR;
            } else if([self checkIfRefreshPage:content]) {
                [self trace:@"User logged in. Redirecting to data page"]; 
                getXmlDataPhase = PHASE_DATA;
            } else if([self checkIfXmlDataPage:content]) {
                [self trace:@"User Bookmarks received. Procesing info"]; 
                getXmlDataPhase = PHASE_DONE;
                [self parseXmlInfo:content];
            } else {
                [self trace:@"Error, Login-Redirect or XmlInfo page was expected."]; 
            }
            break;
    }
    
    
}

//------------------------------------------------------------------------------------------------------------------------
/*!
 @method webView:didFailLoadWithError:forFrame:
 @abstract Notifies the delegate that the committed load of a frame has failed
 @param webView The WebView sending the message
 @param error The error that occurred
 @param frame The frame that failed to load
 @discussion This method is called after a data source has committed but failed to completely load.
 */
- (void) webView:(WebView *)sender didFailLoadWithError:(NSError *)error forFrame:(WebFrame *)frame {
    [self trace:@"Error navigating to page %@", error];
    getXmlDataPhase = PHASE_ERROR;
}



@end
