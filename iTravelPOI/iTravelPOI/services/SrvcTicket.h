//
//  SrvcTicket.h
//  iTravelPOI
//
//  Created by jzarzuela on 26/02/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

// Definicion para que se pueda marcar de forma visible las operaciones
#define SRVC_ASYNCHRONOUS void


//*********************************************************************************************************************
#pragma mark -
#pragma mark SrvcTicket interface definition
//---------------------------------------------------------------------------------------------------------------------
@interface SrvcTicket : NSObject 

@property (nonatomic, readonly) BOOL isCancelled;

- (void) cancel;

@end
