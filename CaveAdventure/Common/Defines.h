//
//  Defines.h
//  CaveAdventure
//
//  Created by ogre on 15/10/5.
//  Copyright (c) 2015年 ogre. All rights reserved.
//

#ifndef CaveAdventure_Defines_h
#define CaveAdventure_Defines_h

#define DEVICE_BOUNDS [[UIScreen mainScreen] applicationFrame]
#define DEVICE_SIZE [[UIScreen mainScreen] applicationFrame].size
#define WINDOW_SIZE [[UIApplication sharedApplication] keyWindow].frame.size
#define DELTA_Y ( DEVICE_OS_VERSION >= 7.0f? 20.0f:0.0f)

#define color(r, g, b, a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define DEVICE_OS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

#endif
