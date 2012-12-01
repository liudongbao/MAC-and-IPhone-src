//
// cocos2d Hello World example
// http://www.cocos2d-iphone.org
//

// Import the interfaces
#import "HelloWorldScene.h"

// HelloWorld implementation
@implementation HelloWorld
@synthesize bear = _bear;
@synthesize moveAction = _moveAction;
@synthesize walkAction = _walkAction;

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

-(id) init {
    if((self = [super init])) {
        
        // This loads an image of the same name (but ending in png), and goes through the
        // plist to add definitions of each frame to the cache.
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"AnimBear.plist"];        
        
        // Create a sprite sheet with the Happy Bear images
        CCSpriteBatchNode *spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"AnimBear.png"];
        [self addChild:spriteSheet];
        
        // Load up the frames of our animation
        NSMutableArray *walkAnimFrames = [NSMutableArray array];
        for(int i = 1; i <= 8; ++i) {
            [walkAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"bear%d.png", i]]];
        }
        CCAnimation *walkAnim = [CCAnimation animationWithFrames:walkAnimFrames delay:0.1f];
        
        // Create a sprite for our bear
        CGSize winSize = [CCDirector sharedDirector].winSize;
        self.bear = [CCSprite spriteWithSpriteFrameName:@"bear1.png"];        
        _bear.position = ccp(winSize.width/2, winSize.height/2);
        self.walkAction = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:walkAnim restoreOriginalFrame:NO]];
        //[_bear runAction:_walkAction];
        [spriteSheet addChild:_bear];
        
        self.isTouchEnabled = YES;
        
    }
    return self;
}

-(void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
	return YES;
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {    
    CGPoint touchLocation = [touch locationInView: [touch view]];		
    touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
    touchLocation = [self convertToNodeSpace:touchLocation];
    
    float bearVelocity = 480.0/3.0;
    CGPoint moveDifference = ccpSub(touchLocation, _bear.position);
    float distanceToMove = ccpLength(moveDifference);
    float moveDuration = distanceToMove / bearVelocity;
    
    if (moveDifference.x < 0) {
        _bear.flipX = NO;
    } else {
        _bear.flipX = YES;
    }    
    
    [_bear stopAction:_moveAction];
    
    if (!_moving) {
        [_bear runAction:_walkAction];
    }
    
    self.moveAction = [CCSequence actions:                          
                       [CCMoveTo actionWithDuration:moveDuration position:touchLocation],
                       [CCCallFunc actionWithTarget:self selector:@selector(bearMoveEnded)],
                       nil
                       ];
    
    
    [_bear runAction:_moveAction];   
    _moving = TRUE;
    
}

-(void)bearMoveEnded {
    [_bear stopAction:_walkAction];
    _moving = FALSE;
}


// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	self.bear = nil;
    self.walkAction = nil;
	[super dealloc];
}
@end
