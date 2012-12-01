//
//  HelloWorldLayer.m
//  WhackAMole
//
//  Created by Ray Wenderlich on 1/5/11.
//  Copyright Ray Wenderlich 2011. All rights reserved.
//

// Import the interfaces
#import "HelloWorldScene.h"
#import "SimpleAudioEngine.h"

// HelloWorld implementation
@implementation HelloWorld

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorld *layer = [HelloWorld node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (CGPoint)convertPoint:(CGPoint)point {    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return ccp(32 + point.x*2, 64 + point.y*2);
    } else {
        return point;
    }    
}

- (CCAnimation *)animationFromPlist:(NSString *)animPlist delay:(float)delay {
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:animPlist ofType:@"plist"];
    NSArray *animImages = [NSArray arrayWithContentsOfFile:plistPath];
    NSMutableArray *animFrames = [NSMutableArray array];
    for(NSString *animImage in animImages) {
        [animFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:animImage]];
    }
    return [CCAnimation animationWithFrames:animFrames delay:delay];
    
}

- (float)convertFontSize:(float)fontSize {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return fontSize * 2;
    } else {
        return fontSize;
    }
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init] )) {
		
        // Determine names of sprite sheets and plists to load
        NSString *bgSheet = @"background.pvr.ccz";
        NSString *bgPlist = @"background.plist";
        NSString *fgSheet = @"foreground.pvr.ccz";
        NSString *fgPlist = @"foreground.plist";
        NSString *sSheet = @"sprites.pvr.ccz";
        NSString *sPlist = @"sprites.plist";
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            bgSheet = @"background-hd.pvr.ccz";
            bgPlist = @"background-hd.plist";
            fgSheet = @"foreground-hd.pvr.ccz";
            fgPlist = @"foreground-hd.plist";
            sSheet = @"sprites-hd.pvr.ccz";
            sPlist = @"sprites-hd.plist";            
        }

        // Load background and foreground
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:bgPlist];       
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:fgPlist];

        // Add background
        CGSize winSize = [CCDirector sharedDirector].winSize;
        CCSprite *dirt = [CCSprite spriteWithSpriteFrameName:@"bg_dirt.png"];
        dirt.scale = 2.0;
        dirt.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:dirt z:-2]; 

        // Add foreground
        CCSprite *lower = [CCSprite spriteWithSpriteFrameName:@"grass_lower.png"];
        lower.anchorPoint = ccp(0.5, 1);
        lower.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:lower z:1];

        CCSprite *upper = [CCSprite spriteWithSpriteFrameName:@"grass_upper.png"];
        upper.anchorPoint = ccp(0.5, 0);
        upper.position = ccp(winSize.width/2, winSize.height/2);
        [self addChild:upper z:-1];

        // Load sprites
        CCSpriteBatchNode *spriteNode = [CCSpriteBatchNode batchNodeWithFile:sSheet];
        [self addChild:spriteNode z:0];
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:sPlist];      

        moles = [[NSMutableArray alloc] init];

        CCSprite *mole1 = [CCSprite spriteWithSpriteFrameName:@"mole_1.png"];
        mole1.position = [self convertPoint:ccp(85, 85)];
        [spriteNode addChild:mole1];
        [moles addObject:mole1];

        CCSprite *mole2 = [CCSprite spriteWithSpriteFrameName:@"mole_1.png"];
        mole2.position = [self convertPoint:ccp(240, 85)];
        [spriteNode addChild:mole2];
        [moles addObject:mole2];

        CCSprite *mole3 = [CCSprite spriteWithSpriteFrameName:@"mole_1.png"];
        mole3.position = [self convertPoint:ccp(395, 85)];
        [spriteNode addChild:mole3];
        [moles addObject:mole3];
        
        [self schedule:@selector(tryPopMoles:) interval:0.5];
        
        // Create animations
        laughAnim = [self animationFromPlist:@"laughAnim" delay:0.1];        
        hitAnim = [self animationFromPlist:@"hitAnim" delay:0.02];
        [[CCAnimationCache sharedAnimationCache] addAnimation:laughAnim name:@"laughAnim"];
        [[CCAnimationCache sharedAnimationCache] addAnimation:hitAnim name:@"hitAnim"];
        
        // Set touch enabled
        self.isTouchEnabled = YES;

        // Add label
        float margin = 10;
        label = [CCLabelTTF labelWithString:@"Score: 0" fontName:@"Verdana" fontSize:[self convertFontSize:14.0]];
        label.anchorPoint = ccp(1, 0);
        label.position = ccp(winSize.width - margin, margin);
        [self addChild:label z:10];
        
        // Preload sound effects
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"laugh.caf"];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"ow.caf"];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"whack.caf" loop:YES];
        
	}
	return self;
}

- (void)setTappable:(id)sender {
    CCSprite *mole = (CCSprite *)sender;    
    [mole setUserData:TRUE];
    [[SimpleAudioEngine sharedEngine] playEffect:@"laugh.caf"];
}

- (void)unsetTappable:(id)sender {
    CCSprite *mole = (CCSprite *)sender;
    [mole setUserData:FALSE];
}

- (void) popMole:(CCSprite *)mole {
    
    if (totalSpawns > 50) return;
    totalSpawns++;
    
    [mole setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"mole_1.png"]];
    
    // Pop mole
    CCMoveBy *moveUp = [CCMoveBy actionWithDuration:0.2 position:ccp(0, mole.contentSize.height)];
    CCCallFunc *setTappable = [CCCallFuncN actionWithTarget:self selector:@selector(setTappable:)];
    CCEaseInOut *easeMoveUp = [CCEaseInOut actionWithAction:moveUp rate:3.0];
    CCAnimate *laugh = [CCAnimate actionWithAnimation:laughAnim restoreOriginalFrame:YES];
    CCCallFunc *unsetTappable = [CCCallFuncN actionWithTarget:self selector:@selector(unsetTappable:)];    
    CCAction *easeMoveDown = [easeMoveUp reverse];
    
    [mole runAction:[CCSequence actions:easeMoveUp, setTappable, laugh, unsetTappable, easeMoveDown, nil]];  
    
}

-(void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:kCCMenuTouchPriority swallowsTouches:NO];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{ 
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    for (CCSprite *mole in moles) {
        if (mole.userData == FALSE) continue;
        if (CGRectContainsPoint(mole.boundingBox, touchLocation)) {
            
            [[SimpleAudioEngine sharedEngine] playEffect:@"ow.caf"];
            
            mole.userData = FALSE;            
            score+= 10;
            
            [mole stopAllActions];
            CCAnimate *hit = [CCAnimate actionWithAnimation:hitAnim restoreOriginalFrame:NO];
            CCMoveBy *moveDown = [CCMoveBy actionWithDuration:0.2 position:ccp(0, -mole.contentSize.height)];
            CCEaseInOut *easeMoveDown = [CCEaseInOut actionWithAction:moveDown rate:3.0];
            [mole runAction:[CCSequence actions:hit, easeMoveDown, nil]];
        }
    }    
    return TRUE;
}

- (void)tryPopMoles:(ccTime)dt {
    
    if (gameOver) return;

    [label setString:[NSString stringWithFormat:@"Score: %d", score]];

    if (totalSpawns >= 50) {
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        
        CCLabelTTF *goLabel = [CCLabelTTF labelWithString:@"Level Complete!" fontName:@"Verdana" fontSize:[self convertFontSize:48.0]];
        goLabel.position = ccp(winSize.width/2, winSize.height/2);
        goLabel.scale = 0.1;
        [self addChild:goLabel z:10];                
        [goLabel runAction:[CCScaleTo actionWithDuration:0.5 scale:1.0]];
        
        gameOver = true;
        return;
        
    }
    
    for (CCSprite *mole in moles) {            
        if (arc4random() % 3 == 0) {
            if (mole.numberOfRunningActions == 0) {
                [self popMole:mole];
            }
        }
    }     
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	[moles release];
    moles = nil;
    
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
