//
//  MainScene.m
//  CaveAdventure
//
//  Created by ogre on 15/10/5.
//  Copyright (c) 2015年 ogre. All rights reserved.
//

#import "MainScene.h"
#import "RestartView.h"

#define HERO_SIZE CGSizeMake(40, 30)
#define WALL_WIDTH 40
#define WALL_WIDTH_SCALE_MAX 3.0f
#define WALL_WIDTH_SCALE_MIN 1.0f
#define WALL_HEIGHT_SCALE_MAX 3.0f
#define WALL_HEIGHT_SCALE_MIN 1.5f

#define NODENAME_HERO @"heronode"
#define NODENAME_BRICK @"brick"
#define NODENAME_WALL @"wall"
#define NODENAME_HOLE @"hole"
#define NODENAME_DUST @"dust"

#define ACTIONKEY_ADDWALL @"addwall"
#define ACTIONKEY_MOVEWALL @"movewall"
#define ACTIONKEY_FLY @"fly"
#define ACTIONKEY_ADDDUST @"adddust"
#define ACTIONKEY_MOVEHEAD @"movehead"
#define ACTIONKEY_MOVEHEADUP @"moveheadup"
#define ACTIONKEY_MOVEHEADDOWN @"moveheaddown"

#define GROUND_HEIGHT 50.0f
#define SKY_HEIGHT 50.0f

#define TIMEINTERVAL_ADDWALL 4.0f
#define TIMEINTERVAL_MOVEWALL 4.0f

#define DUST_WIDTH 20.0f
#define DUST_HEIGHT 1.0f
#define DUSTWIDTH_MIN 2
#define DUSTWIDTH_MAX 5

#define COLOR_HERO color(244, 118, 148, 1)
#define COLOR_BG [UIColor whiteColor]
#define COLOR_WALL color(34, 166, 159, 1)
#define COLOR_LABEL color(17, 39, 57, 1)

static const uint32_t heroCategory = 0x1 << 0;
static const uint32_t wallCategory = 0x1 << 1;
static const uint32_t holeCategory = 0x1 << 2;
static const uint32_t groundCategory = 0x1 << 3;
static const uint32_t skyCategory = 0x1 << 3;
static const uint32_t edgeCategory = 0x1 << 4;

@interface MainScene() <SKPhysicsContactDelegate, RestartViewDelegate>

@property (strong, nonatomic) SKSpriteNode *hero;

@property (strong, nonatomic) SKAction *moveWallAction;
@property (strong, nonatomic) SKAction *moveHeadAction;

@property (strong, nonatomic) SKAction *moveUpHeadAction;
@property (strong, nonatomic) SKAction *moveDownHeadAction;

@property (strong, nonatomic) SKSpriteNode *ground;
@property (strong, nonatomic) SKSpriteNode *sky;

@property (strong, nonatomic) SKLabelNode *labelNode;

@property BOOL isGameOver;
@property BOOL isGameStart;

@property float heightScale;

@end

@implementation MainScene

- (void)initalize
{
    [super initalize];
    
    //self
    self.backgroundColor = COLOR_BG;
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsBody.categoryBitMask = edgeCategory;
    self.physicsWorld.contactDelegate = self;
    self.physicsWorld.gravity = CGVectorMake(0.0f, 0.0f);
    
    self.moveWallAction = [SKAction moveToX:-WALL_WIDTH duration:TIMEINTERVAL_MOVEWALL];
    
    SKAction *upHeadAction = [SKAction rotateToAngle:M_PI / 12 duration:0.2f];
    upHeadAction.timingMode = SKActionTimingEaseOut;
    SKAction *downHeadAction = [SKAction rotateToAngle:-M_PI / 12 duration:0.2f];
    downHeadAction.timingMode = SKActionTimingEaseOut;
    self.moveHeadAction = [SKAction sequence:@[upHeadAction, downHeadAction,]];
    self.moveUpHeadAction = upHeadAction;
    self.moveDownHeadAction = downHeadAction;
    
    self.heightScale = WALL_HEIGHT_SCALE_MAX;
    //ground
    [self addGroundNode];
    
    //sky
    [self addSkyNode];
    
    //hero
    [self addHeroNode];
    
    //label
    [self addResultLabelNode];

    //dust
    [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[
                                                                       [SKAction performSelector:@selector(addDust) onTarget:self],
                                                                       [SKAction waitForDuration:0.3f],
                                                                       ]]] withKey:ACTIONKEY_ADDDUST];
}

#pragma mark - method
- (void)addResultLabelNode
{
    self.labelNode = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    _labelNode.text = @"0";
    _labelNode.fontSize = 30.0f;
    _labelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    _labelNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
    _labelNode.position = CGPointMake(10, self.frame.size.height - SKY_HEIGHT - 20);
    _labelNode.fontColor = COLOR_LABEL;
    [self addChild:_labelNode];
}

- (SKAction *)getFlyAction
{
    SKAction *flyUp = [SKAction moveToY:_hero.position.y + 10 duration:0.3f];
    flyUp.timingMode = SKActionTimingEaseOut;
    SKAction *flyDown = [SKAction moveToY:_hero.position.y - 10 duration:0.3f];
    flyDown.timingMode = SKActionTimingEaseOut;
    SKAction *fly = [SKAction sequence:@[flyUp, flyDown]];
    return fly;
}

- (SKAction *)flyUpAction
{
    float movePositon = self.frame.size.height - self.labelNode.frame.size.height - self.sky.frame.size.height;
    SKAction *flyUp1 = [SKAction moveToY:movePositon duration:(movePositon - _hero.position.y)/100.0];
    flyUp1.timingMode = SKActionTimingEaseOut;
    return flyUp1;
}

- (SKAction *)flyDownAction
{
    float movePositon = self.ground.frame.size.height;
    SKAction *flyDown1 = [SKAction moveToY:movePositon duration:(_hero.position.y - movePositon)/100.0];
    flyDown1.timingMode = SKActionTimingEaseOut;
    return flyDown1;
}

- (void)addHeroNode
{
    self.hero = [SKSpriteNode spriteNodeWithColor:COLOR_HERO size:HERO_SIZE];
    _hero.anchorPoint = CGPointMake(0.5, 0.5);
    _hero.position = CGPointMake(self.frame.size.width / 3, CGRectGetMidY(self.frame));
    _hero.name = NODENAME_HERO;
    _hero.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_hero.size center:CGPointMake(0, 0)];
    _hero.physicsBody.categoryBitMask = heroCategory;
    _hero.physicsBody.collisionBitMask = wallCategory | groundCategory;
    _hero.physicsBody.contactTestBitMask = holeCategory | wallCategory | groundCategory;
    _hero.physicsBody.dynamic = YES;
    _hero.physicsBody.affectedByGravity = NO;
    _hero.physicsBody.allowsRotation = YES;
    _hero.physicsBody.restitution = 0;
    _hero.physicsBody.usesPreciseCollisionDetection = YES;
    [self addChild:_hero];
    
    [_hero runAction:[SKAction repeatActionForever:[self getFlyAction]]
             withKey:ACTIONKEY_FLY];
}

- (void)addGroundNode
{
    self.ground = [SKSpriteNode spriteNodeWithColor:COLOR_WALL size:CGSizeMake(self.frame.size.width, GROUND_HEIGHT)];
    _ground.anchorPoint = CGPointMake(0, 0);
    _ground.position = CGPointMake(0, 0);
    _ground.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_ground.size center:CGPointMake(_ground.size.width / 2.0f, _ground.size.height / 2.0f)];
    _ground.physicsBody.categoryBitMask = groundCategory;
    _ground.physicsBody.dynamic = NO;
    [self addChild:_ground];
}

- (void)addSkyNode
{
    self.sky = [SKSpriteNode spriteNodeWithColor:COLOR_WALL size:CGSizeMake(self.frame.size.width, SKY_HEIGHT)];
    _sky.anchorPoint = CGPointMake(0, 0);
    _sky.position = CGPointMake(0, self.frame.size.height - SKY_HEIGHT);
    _sky.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_sky.size center:CGPointMake(_sky.size.width / 2.0f, _sky.size.height / 2.0f)];
    _sky.physicsBody.categoryBitMask = skyCategory;
    _sky.physicsBody.dynamic = NO;
    [self addChild:_sky];
}

- (void)addDust
{
    CGFloat dustWidth = (arc4random() % (DUSTWIDTH_MAX - DUSTWIDTH_MIN + 1) + DUSTWIDTH_MIN) * DUST_WIDTH;
    SKSpriteNode *dustNode = [SKSpriteNode spriteNodeWithColor:color(230, 230, 230, 1) size:CGSizeMake(dustWidth, DUST_HEIGHT)];
    dustNode.anchorPoint = CGPointMake(0, 0);
    dustNode.name = NODENAME_DUST;
    dustNode.position = CGPointMake(self.frame.size.width, arc4random() % (int)(self.frame.size.height / 3) + self.frame.size.height / 3);
    [dustNode runAction:[SKAction moveToX:-dustWidth duration:1.0f]];
    [self addChild:dustNode];
}

- (void)addWall
{
    CGFloat spaceHeigh = self.frame.size.height - GROUND_HEIGHT - SKY_HEIGHT;
    
    if (self.heightScale > WALL_HEIGHT_SCALE_MIN*1.2)
    {self.heightScale -= 0.01;}
    CGFloat holeLength = HERO_SIZE.height * ((arc4random()%(int)((self.heightScale - WALL_HEIGHT_SCALE_MIN)*100))/ 100.0 + WALL_HEIGHT_SCALE_MIN);
    CGFloat holeWidth = WALL_WIDTH * ((arc4random()%(int)((WALL_WIDTH_SCALE_MAX - WALL_WIDTH_SCALE_MIN)*100))/ 100.0 + WALL_HEIGHT_SCALE_MIN);
    int holePosition = arc4random() % (int)((spaceHeigh - holeLength) / HERO_SIZE.height);
    
    CGFloat x = self.frame.size.width;
    
    //上部分
    CGFloat upHeight = holePosition * HERO_SIZE.height;
    if (upHeight > 0) {
        SKSpriteNode *upWall = [SKSpriteNode spriteNodeWithColor:COLOR_WALL size:CGSizeMake(holeWidth, upHeight)];
        upWall.anchorPoint = CGPointMake(0, 0);
        upWall.position = CGPointMake(x, self.frame.size.height - upHeight);
        upWall.name = NODENAME_WALL;
        
        upWall.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:upWall.size center:CGPointMake(upWall.size.width / 2.0f, upWall.size.height / 2.0f)];
        upWall.physicsBody.categoryBitMask = wallCategory;
        upWall.physicsBody.dynamic = NO;
        upWall.physicsBody.friction = 0;
        
        SKAction *moveUpWallAction = [SKAction moveToX:-holeWidth duration:TIMEINTERVAL_MOVEWALL];
        [upWall runAction:moveUpWallAction withKey:ACTIONKEY_MOVEWALL];
        
        [self addChild:upWall];
    }
    
    //下部分
    CGFloat downHeight = spaceHeigh - upHeight - holeLength;
    if (downHeight > 0) {
        SKSpriteNode *downWall = [SKSpriteNode spriteNodeWithColor:COLOR_WALL size:CGSizeMake(holeWidth, downHeight)];
        downWall.anchorPoint = CGPointMake(0, 0);
        downWall.position = CGPointMake(x, GROUND_HEIGHT);
        downWall.name = NODENAME_WALL;
        
        downWall.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:downWall.size center:CGPointMake(downWall.size.width / 2.0f, downWall.size.height / 2.0f)];
        downWall.physicsBody.categoryBitMask = wallCategory;
        downWall.physicsBody.dynamic = NO;
        downWall.physicsBody.friction = 0;
        
        SKAction *moveDownWallAction = [SKAction moveToX:-holeWidth duration:TIMEINTERVAL_MOVEWALL];
        [downWall runAction:moveDownWallAction withKey:ACTIONKEY_MOVEWALL];
        
        [self addChild:downWall];
    }
    
    //中空部分
    SKSpriteNode *hole = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:CGSizeMake(holeWidth, holeLength)];
    hole.anchorPoint = CGPointMake(0, 0);
    hole.position = CGPointMake(x, self.frame.size.height - upHeight - holeLength);
    hole.name = NODENAME_HOLE;
    
    hole.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:hole.size center:CGPointMake(hole.size.width / 2.0f, hole.size.height / 2.0f)];
    hole.physicsBody.categoryBitMask = holeCategory;
    hole.physicsBody.dynamic = NO;
    
    SKAction *moveHoleAction = [SKAction moveToX:-holeWidth duration:TIMEINTERVAL_MOVEWALL];
    [hole runAction:moveHoleAction withKey:ACTIONKEY_MOVEWALL];
    
    [self addChild:hole];
}

- (void)update:(NSTimeInterval)currentTime
{
    __block int wallCount = 0;
    [self enumerateChildNodesWithName:NODENAME_WALL usingBlock:^(SKNode *node, BOOL *stop) {
        if (wallCount >= 2) {
            *stop = YES;
            return;
        }
        
        if (node.position.x <= -WALL_WIDTH) {
            wallCount++;
            [node removeFromParent];
        }
    }];
    
    [self enumerateChildNodesWithName:NODENAME_HOLE usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.x <= -WALL_WIDTH) {
            [node removeFromParent];
            *stop = YES;
        }
    }];
    
    [self enumerateChildNodesWithName:NODENAME_DUST usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.x <= -node.frame.size.width) {
            [node removeFromParent];
        }
    }];
}

- (void)startGame
{
    self.isGameStart = YES;
    [self removeActionForKey:ACTIONKEY_ADDDUST];
    
    //hero
    _hero.physicsBody.affectedByGravity = YES;
    [_hero removeActionForKey:ACTIONKEY_FLY];
    [_hero runAction:[self flyDownAction]];
    
    //add wall
    SKAction *addWall = [SKAction sequence:@[
                                             [SKAction performSelector:@selector(addWall) onTarget:self],
                                             [SKAction waitForDuration:((arc4random()%100)/100/5 + 1)*TIMEINTERVAL_ADDWALL],
                                             ]];
    
    [self runAction:[SKAction repeatActionForever:addWall] withKey:ACTIONKEY_ADDWALL];
}

- (void)gameOver
{
    self.isGameOver = YES;
    
    [_hero removeActionForKey:ACTIONKEY_MOVEHEADUP];
    
    [self removeActionForKey:ACTIONKEY_ADDWALL];
    
    [self enumerateChildNodesWithName:NODENAME_WALL usingBlock:^(SKNode *node, BOOL *stop) {
        [node removeActionForKey:ACTIONKEY_MOVEWALL];
    }];
    [self enumerateChildNodesWithName:NODENAME_HOLE usingBlock:^(SKNode *node, BOOL *stop) {
        [node removeActionForKey:ACTIONKEY_MOVEWALL];
    }];
    
    RestartView *restartView = [RestartView getInstanceWithSize:self.size];
    restartView.delegate = self;
    [restartView showInScene:self];
}

- (void)restart
{
    //label
    self.labelNode.text = @"0";
    
    //remove all wall and hole
    [self enumerateChildNodesWithName:NODENAME_HOLE usingBlock:^(SKNode *node, BOOL *stop) {
        [node removeFromParent];
    }];
    
    [self enumerateChildNodesWithName:NODENAME_WALL usingBlock:^(SKNode *node, BOOL *stop) {
        [node removeFromParent];
    }];
    
    //reset hero
    [_hero removeFromParent];
    self.hero = nil;
    [self addHeroNode];
    
    //dust
    [self runAction:[SKAction repeatActionForever:[SKAction sequence:@[
                                                                       [SKAction performSelector:@selector(addDust) onTarget:self],
                                                                       [SKAction waitForDuration:0.3f],
                                                                       ]]] withKey:ACTIONKEY_ADDDUST];
    
    //flag
    self.isGameStart = NO;
    self.isGameOver = NO;
}

- (void)playSoundWithName:(NSString *)fileName
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self runAction:[SKAction playSoundFileNamed:fileName waitForCompletion:YES]];
    });
}

#pragma mark - TouchEvent
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_isGameOver) {
        return;
    }
    if (!_isGameStart) {
        [self startGame];
    }
    
    //_hero.physicsBody.velocity = CGVectorMake(0, 200);
    //[_hero runAction:_moveHeadAction withKey:ACTIONKEY_MOVEHEAD];
    //[_hero removeActionForKey:ACTIONKEY_FLY];
    [_hero removeActionForKey:ACTIONKEY_MOVEHEADDOWN];
    [_hero runAction:[self moveUpHeadAction]withKey:ACTIONKEY_MOVEHEADUP];
    [_hero runAction:[self flyUpAction]];
    //[self playSoundWithName:@"sfx_wing.caf"];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (_isGameOver)
    {return;}
    
    if (_isGameStart)
    {
        [_hero removeActionForKey:ACTIONKEY_MOVEHEADUP];
        [_hero runAction:[self moveDownHeadAction] withKey:ACTIONKEY_MOVEHEADDOWN];
        [_hero runAction:[self flyDownAction]];
    }
}

#pragma mark - SKPhysicsContactDelegate
- (void)didBeginContact:(SKPhysicsContact *)contact
{
    if (_isGameOver) {
        return;
    }
    
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    } else {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if ((firstBody.categoryBitMask & heroCategory) && (secondBody.categoryBitMask & holeCategory)) {
        int currentPoint = [_labelNode.text intValue];
        _labelNode.text = [NSString stringWithFormat:@"%d", currentPoint + 1];
        [self playSoundWithName:@"sfx_point.caf"];
    } else {
        [self playSoundWithName:@"sfx_hit.caf"];
        [self gameOver];
    }
}

#pragma mark - RestartViewDelegate
- (void)restartView:(RestartView *)restartView didPressRestartButton:(SKSpriteNode *)restartButton
{
    [restartView dismiss];
    [self restart];
}
@end






