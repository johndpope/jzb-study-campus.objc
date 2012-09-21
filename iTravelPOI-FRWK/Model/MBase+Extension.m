//
//  MBase+Extension.m
//  iTravelPOI
//
//  Created by Jose Zarzuela on 03/08/12.
//  Copyright (c) 2012 Jose Zarzuela. All rights reserved.
//

#import "MBase+Extension.h"

//*********************************************************************************************************************
#pragma mark -
#pragma mark MBase+Extension category implementation
//---------------------------------------------------------------------------------------------------------------------
@implementation MBase (Extension)



//---------------------------------------------------------------------------------------------------------------------
#pragma mark -
#pragma mark MBase+Extension CLASS public methods
//---------------------------------------------------------------------------------------------------------------------
/*
@discussion Un dia tiene 86.400 segundos. Que se puede expresar con 17 bits (sobrando). Luego con 32 bits se puede
 añadir otros 15 bits con un contador iniciado en un numero aleatorio.

 Con eso el UID se repetiria si 2 UIDs se generasen en dias diferentes exactamente en el mismo segundo y con el mismo 
 contador aleatorio. Algo bastante improbable con lo que se puede vivir.
 */
+ (UInt32) calcUID {
    
    static UInt32 s_idCounter = 0;
    if(s_idCounter==0) {
        srand((unsigned)time(0L));
        s_idCounter = (UInt32)rand();
    }
    s_idCounter++;
    
    UInt32 _time = (UInt32)time(0);
    
    UInt32 nextID = (s_idCounter << 17) | (_time & 0x0001FFFF);
    
    return nextID;
}
 
//---------------------------------------------------------------------------------------------------------------------
+ (NSString *) stringForUID:(UInt32)uid {
    
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    char text[8] = "#0000000";
    
    // 7 caracteres para poner los 32 bits en texto
    for(int n=1;n<8;n++) {
        int index = uid & 0x03F;
        text[n]=table[index];
        uid = uid >> 6;
    }
    
    NSString *strUID = [NSString stringWithUTF8String:text];
    return strUID;
}


//*********************************************************************************************************************
#pragma mark -
#pragma mark Getter/Setter methods
//---------------------------------------------------------------------------------------------------------------------

@end
