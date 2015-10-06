//
//  SRScene.m
//  CaveAdventure
//
//  Created by ogre on 15/10/5.
//  Copyright (c) 2015年 ogre. All rights reserved.
//

#import "SRScene.h"

@interface SRScene()

@property BOOL contentCreated;

@end

@implementation SRScene

- (void)didMoveToView:(SKView *)view
{
    if (_contentCreated) {
        return;
    }
    
    [self initalize];
    self.contentCreated = YES;
}

- (void)initalize
{
    
}

@end
