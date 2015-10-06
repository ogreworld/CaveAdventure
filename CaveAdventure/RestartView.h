//
//  RestartView.h
//  CaveAdventure
//
//  Created by ogre on 15/10/5.
//  Copyright (c) 2015年 ogre. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Defines.h"

@class RestartView;
@protocol RestartViewDelegate <NSObject>

- (void)restartView:(RestartView *)restartView didPressRestartButton:(SKSpriteNode *)restartButton;

@end

@interface RestartView : SKSpriteNode

@property (weak, nonatomic) id <RestartViewDelegate> delegate;

+ (RestartView *)getInstanceWithSize:(CGSize)size;
- (void)dismiss;
- (void)showInScene:(SKScene *)scene;

@end
