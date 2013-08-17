//
//  Util_Macros.h
//  iTravelPOI-iOS
//
//  Created by Jose Zarzuela on 20/06/13.
//  Copyright (c) 2013 Jose Zarzuela. All rights reserved.
//

#ifndef iTravelPOI_iOS_Util_Macros_h
#define iTravelPOI_iOS_Util_Macros_h


#define frameSetX(view,value)       { CGRect rect=view.frame; rect.origin.x=value; view.frame=rect;}
#define frameSetY(view,value)       { CGRect rect=view.frame; rect.origin.y=value; view.frame=rect;}
#define frameSetXY(view,vX,vY)      { CGRect rect=view.frame; rect.origin.x=vX; rect.origin.y=vY; view.frame=rect;}
#define frameSetWidth(view,value)   { CGRect rect=view.frame; rect.size.width=value; view.frame=rect;}
#define frameSetHeight(view,value)  { CGRect rect=view.frame; rect.size.height=value; view.frame=rect;}
#define frameSetSize(view,vW,vH)    { CGRect rect=view.frame; rect.size.width=vW; rect.size.height=vH; view.frame=rect;}


#endif
