//
//  HelloWorldLayer.m
//  fish
//
//  Created by 海锋 周 on 12-4-11.
//  Copyright __MyCompanyName__ 2012年. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"
// HelloWorldLayer implementation
@implementation HelloWorldLayer

#define WINHEIGHT 768
#define WINWIDHT 1024
#define MAX_ENEMY 15
#define MOVESPEED 5

#define KProgressTag 100


+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	if( (self=[super init])) {
        
        Energy = 0;
        maxEnergy = 1000;
        
		self.isTouchEnabled = YES;
        
        [self LoadTexture];
        
        [self initUITab];
        
        srand(time(NULL));
       
        while ([[fishSheet children]count]<MAX_ENEMY)
        {
            [self addFish];
        }
        [self schedule:@selector(updateGame:) interval:0.05];
        

        
    }
    
	return self;
}

-(void) LoadTexture
{
    CCSprite *bg = [CCSprite spriteWithFile:@"bj01.jpg"];   
    bg.position = ccp(512, 368);
    [self addChild:bg];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"fish.plist"];
    fishSheet = [CCSpriteBatchNode batchNodeWithFile:@"fish.png"];
    [self addChild:fishSheet];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"fish2.plist"];
    fish2Sheet = [CCSpriteBatchNode batchNodeWithFile:@"fish2.png"];
    [self addChild:fish2Sheet];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"fish3.plist"];
    netSheet = [CCSpriteBatchNode batchNodeWithFile:@"fish3.png"];
    [self addChild:netSheet];
}


-(void) initUITab
{
    CCSprite *engryBox =[CCSprite spriteWithFile:@"ui_2p_004.png"];
    engryBox.anchorPoint = ccp(0.5, 0.5);
    engryBox.position = ccp(520,30);
    [self addChild:engryBox];
    
    engryPointer =[CCSprite spriteWithFile:@"ui_2p_005.png"];
    engryPointer.position = ccp(520,30);
    [self addChild:engryPointer];
    
    
    CCSprite *bgExp =[CCSprite spriteWithFile:@"ui_box_01.png"];
    bgExp.position = ccp(500, 700);
    [self addChild:bgExp];
    
    CCSprite *bgNum =[CCSprite spriteWithFile:@"ui_box_02.png"];
    bgNum.position = ccp(440, 90);
    [self addChild:bgNum];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"cannon.plist"];
    cannonSheet = [CCSpriteBatchNode batchNodeWithFile:@"cannon.png"];
    [self addChild:cannonSheet];
    
    score1 = [[UIRollNum alloc]init];
    [score1 setNumber:10000];
    [score1 setPosition:ccp(365, 17)];
    [self addChild:score1 z:100];
    
    gun = [CCSprite spriteWithSpriteFrameName:@"actor_cannon1_71.png"];
    gun.position = ccp(520, 50);
    [cannonSheet addChild:gun];
    
    /*添加进度条
     CCProgressTimer *ct=[CCProgressTimer progressWithFile:@"processbanner.png"];  
     ct.position=ccp(512 , 736);  
     ct.percentage=0;
     ct.type=kCCProgressTimerTypeHorizontalBarLR;
     [self addChild:ct z:10 tag:KProgressTag];  
     */  
}

/**************************************************
 scheduleUpdate 的回调函数
 *************************************************/
-(void) updateGame:(ccTime)delta
{
    CCFish *sprite;
    CCNet *net;
    CCScaleTo* scale0 = [CCScaleTo actionWithDuration:0.3 scale:1.1];
    CCScaleTo* scale1 = [CCScaleTo actionWithDuration:0.3 scale:0.9];
    
    CCARRAY_FOREACH([fishSheet children], sprite)
	{
        
        if ([sprite isCatch]) {
            continue;
        }
        /*
        CGPoint pos = sprite.position;
        pos.x -= MOVESPEED;
        sprite.position = pos;


        if(pos.x<-40||pos.y<-40)
        {
            [fishSheet removeChild:sprite cleanup:NO];
        }
         */
                    //碰撞检测
         CCARRAY_FOREACH([fish2Sheet children],net)
        {
            
              
            if (CGRectContainsPoint(sprite.boundingBox, net.position)) {
             
                if (![sprite randomCatch:sprite.tag]) 
                {
                    net.isCatching = NO;
                    break;
                }else{
                    net.isCatching = NO;
                    sprite.isCatch = YES;
                    NSMutableArray *fishi01 = [NSMutableArray array];
                    for(int i = 1; i <3; i++)
                    {
                        [fishi01 addObject:
                         [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                          [NSString stringWithFormat:@"fish0%d_catch_0%d.png",sprite.tag,i]]];
                    }
                    
                    CCActionInterval *fish01_catch_act = [CCRepeat actionWithAction:[CCAnimate actionWithAnimation:[CCAnimation animationWithFrames:fishi01 delay:0.2f]  restoreOriginalFrame:NO]times:2];
                    
                    CCSequence* fishSequence = [CCSequence actions:fish01_catch_act,[CCCallFuncO actionWithTarget:self selector:@selector(afterCatch:) object:sprite], nil];
                    
                    [sprite stopAllActions];
                    [sprite runAction:fishSequence];
                    
                    CCSprite *gold = [CCSprite spriteWithFile:@"+5.png"];
                    gold.position =  sprite.position;
                    
                    CCSequence* goldSequence = [CCSequence actions:scale0, scale1, scale0, scale1,[CCCallFuncO actionWithTarget:self selector:@selector(afterShow:) object:gold], nil];
                    [gold runAction:goldSequence];
                    [self addChild:gold];
                } 
            }
            
            
        }
              
	}
    
    CCARRAY_FOREACH([fish2Sheet children],net)
    {
        if ([net isCatching]) {
            continue;
        } 

        [fish2Sheet removeChild:net cleanup:NO];
    
        CCNet *tapnet = [CCNet spriteWithSpriteFrameName:@"net01.png"];
        tapnet.position = net.position;
        CCSequence* netSequence = [CCSequence actions:scale0, scale1, scale0, scale1,[CCCallFuncO actionWithTarget:self selector:@selector(afterShowNet:) object:tapnet], nil];
    
        [tapnet runAction:netSequence];
        [netSheet addChild:tapnet];                    
    
        [score1 setNumber:([score1 getNumber]+5)];
    
    
    }
    
    
    while ([[fishSheet children]count]<MAX_ENEMY)
    {
        [self addFish];
    }

	
}

-(void) updateEnergry:(int) en
{
    Energy += en;
    if (Energy>=maxEnergy) {
        Energy = maxEnergy;
    }
    float rotation = 180.0 * Energy/maxEnergy;
    engryPointer.rotation  = rotation;
}

-(void) addFish
{
       int type = rand()%8+1;

        NSMutableArray *fishi01 = [NSMutableArray array];
        for(int i = 1; i <10; i++) {
            [fishi01 addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"fish0%d_0%d.png",type,i]]];
        }
        
        fish01_act = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:[CCAnimation animationWithFrames:fishi01 delay:0.2f] restoreOriginalFrame:YES]];
   
    
    CCFish *fish = [CCFish spriteWithSpriteFrameName: [NSString stringWithFormat:@"fish0%d_0%d.png",type,1]];
    fish.scale = 1.2f;
    fish.tag = type;
    fish.isCatch = NO;
    [fish runAction:fish01_act];
    [fish addPath];
    [fishSheet addChild:fish];
    
}


-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        CGPoint pos = [touch locationInView:touch.view];
		pos = [[CCDirector sharedDirector] convertToGL:pos];
        [gun setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"actor_cannon1_72.png"]];
        
        float angle = (pos.y - gun.position.y)/(pos.x-gun.position.x);
        angle = atanf(angle)/M_PI*180;
        if (angle<0) {
              gun.rotation = -(90+angle);
        }else if (angle>0)
        {
              gun.rotation = 90 - angle;
        }
    }
}

-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        [gun setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"actor_cannon1_71.png"]];
        CGPoint pos = [touch locationInView:touch.view];
		pos = [[CCDirector sharedDirector] convertToGL:pos];
        
        [score1 setNumber:([score1 getNumber]-rand()%20-2)];
      
        CCNet *labelboard = [CCNet spriteWithSpriteFrameName:@"bullet01.png"];
        labelboard.position = ccp(512, 50);
        labelboard.isCatching = YES;
        CCMoveTo *move = [CCMoveTo actionWithDuration:1.0 position:pos];
        
        CCSequence* netSequence = [CCSequence actions:move,[CCCallFuncO actionWithTarget:self selector:@selector(ShowNet:) object:labelboard], nil];
        
        labelboard.rotation = gun.rotation;
        [labelboard runAction:netSequence];
        [fish2Sheet addChild:labelboard];
        
        
        [self updateEnergry:rand()%20];
    }
}

-(void) ShowNet:(id)sender
{
    CCSprite *sp = sender;
 
    [fish2Sheet removeChild:sp cleanup:NO];
    
    [sp setDisplayFrame:[[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"net01.png"]];
 
    
    CCScaleTo* scale0 = [CCScaleTo actionWithDuration:0.3 scale:1.1];
    CCScaleTo* scale1 = [CCScaleTo actionWithDuration:0.3 scale:0.9];
    
    CCSequence* netSequence = [CCSequence actions:scale0, scale1, scale0, scale1,[CCCallFuncO actionWithTarget:self selector:@selector(afterShowNet:) object:sp], nil];
    
    [sp runAction:netSequence];
    [netSheet addChild:sp];
}

-(void) afterShowNet:(id)sender
{
    CCSprite *sp = sender;
    [netSheet removeChild:sp cleanup:NO];
}

-(void) afterShow:(id)sender
{
    CCSprite *sp = sender;
    [self removeChild:sp cleanup:NO];
}

-(void) afterCatch:(id)sender
{       
    CCSprite *sp = sender;
    [fishSheet removeChild:sp cleanup:NO];
}



// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
