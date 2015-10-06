//
//  GameViewController.m
//  CaveAdventure
//
//  Created by ogre on 15/10/5.
//  Copyright (c) 2015年 ogre. All rights reserved.
//

#import "GameViewController.h"
#import "MainScene.h"

//@implementation SKScene (Unarchive)
//
//+ (instancetype)unarchiveFromFile:(NSString *)file {
//    /* Retrieve scene file path from the application bundle */
//    NSString *nodePath = [[NSBundle mainBundle] pathForResource:file ofType:@"sks"];
//    /* Unarchive the file to an SKScene object */
//    NSData *data = [NSData dataWithContentsOfFile:nodePath
//                                          options:NSDataReadingMappedIfSafe
//                                            error:nil];
//    NSKeyedUnarchiver *arch = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
//    [arch setClass:self forClassName:@"SKScene"];
//    SKScene *scene = [arch decodeObjectForKey:NSKeyedArchiveRootObjectKey];
//    [arch finishDecoding];
//    
//    return scene;
//}
//
//@end

@interface GameViewController ()

@property (strong, nonatomic) MainScene *mainScene;

@end

@implementation GameViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    SKView *view = (SKView *)self.view;
    view.showsDrawCount = YES;
    view.showsFPS = YES;
    view.showsNodeCount = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.mainScene = [[MainScene alloc] initWithSize:CGSizeMake(self.view.frame.size.width, self.view.frame.size.height)];
    _mainScene.scaleMode = SKSceneScaleModeAspectFit;
    
    SKView *view = (SKView *)self.view;
    [view presentScene:_mainScene];
}

@end
