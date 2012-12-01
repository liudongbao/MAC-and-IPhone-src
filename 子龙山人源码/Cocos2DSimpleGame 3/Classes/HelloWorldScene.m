//
// cocos2d Hello World example
// http://www.cocos2d-iphone.org
//

// Import the interfaces
#import "HelloWorldScene.h"
#import "SimpleAudioEngine.h"
#import "GameOverScene.h"
#import "Monster.h"
#import "Cocos2DSimpleGameAppDelegate.h"
#import "Level.h"
#import "Projectile.h"

@implementation HelloWorldScene
@synthesize layer = _layer;

+(id) scene
{
	// 'scene' is an autorelease object.
	HelloWorldScene *scene = [HelloWorldScene node];
	
	// 'layer' is an autorelease object.
	HelloWorld *layer = [HelloWorld node];
    scene.layer = layer;
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (void)dealloc {
    self.layer = nil;
    [super dealloc];
}

@end

// HelloWorld implementation
@implementation HelloWorld
@synthesize curBg = _curBg;
@synthesize scoreLabel = _scoreLabel;
@synthesize nextProjectile = _nextProjectile;

-(void)spriteMoveFinished:(id)sender {
    
	CCSprite *sprite = (CCSprite *)sender;
	[self removeChild:sprite cleanup:YES];
	
	if (sprite.tag == 1) { // target
		[_targets removeObject:sprite];

		Cocos2DSimpleGameAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        [delegate loadGameOverScene];
		
	} else if (sprite.tag == 2) { // projectile
		[_projectiles removeObject:sprite];
	}
	
}

-(void)reset {

    // Clear out any objects
    for (CCSprite *target in _targets) {
        [self removeChild:target cleanup:YES];
    }
    [_targets removeAllObjects];    
    for (CCSprite *projectile in _projectiles) {
        [self removeChild:projectile cleanup:YES];
    }
    [_projectiles removeAllObjects];
    
    // Remove old bg if it exists
    if (_curBg != nil) {
        [self removeChild:_curBg cleanup:YES];
        self.curBg = nil;
    }
    
    // Add new bg
    Cocos2DSimpleGameAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    CCSprite *bg = [CCSprite spriteWithFile:delegate.curLevel.bgImageName];
    bg.position = ccp(240,160);
    [self addChild:bg];
    
    // Store reference to current background so we can remove it on next reset
    self.curBg = bg;
    
    // Reset stats
    _projectilesDestroyed = 0;
    self.nextProjectile = nil;
    
    // Start up timers again
    self.isTouchEnabled = YES;
    [self schedule:@selector(update:)];
    [self schedule:@selector(gameLogic:) interval:1.0];
    
    // Don't forget to reset score!  (via @Mark W)
    _score = 0;
    _oldScore = -1;
    
}

-(void)addTarget {
    
	//CCSprite *target = [CCSprite spriteWithFile:@"Target.png" rect:CGRectMake(0, 0, 27, 40)]; 
    Monster *target = nil;
    if ((arc4random() % 2) == 0) {
        target = [WeakAndFastMonster monster];
    } else {
        target = [StrongAndSlowMonster monster];
    }
	
	// Determine where to spawn the target along the Y axis
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	int minY = target.contentSize.height/2;
	int maxY = winSize.height - target.contentSize.height/2;
	int rangeY = maxY - minY;
	int actualY = (arc4random() % rangeY) + minY;
	
	// Create the target slightly off-screen along the right edge,
	// and along a random position along the Y axis as calculated above
	target.position = ccp(winSize.width + (target.contentSize.width/2), actualY);
	[self addChild:target z:1];
	
	// Determine speed of the target
	int minDuration = target.minMoveDuration; //2.0;
	int maxDuration = target.maxMoveDuration; //4.0;
	int rangeDuration = maxDuration - minDuration;
	int actualDuration = (arc4random() % rangeDuration) + minDuration;
	
	// Create the actions
	id actionMove = [CCMoveTo actionWithDuration:actualDuration position:ccp(-target.contentSize.width/2, actualY)];
	id actionMoveDone = [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)];
	[target runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
	
	// Add to targets array
	target.tag = 1;
	[_targets addObject:target];
	
}

-(void)gameLogic:(ccTime)dt {

	static double lastTimeTargetAdded = 0;
    double now = [[NSDate date] timeIntervalSince1970];
    Cocos2DSimpleGameAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    if(lastTimeTargetAdded == 0 || now - lastTimeTargetAdded >= delegate.curLevel.spawnRate) {
        [self addTarget];
        lastTimeTargetAdded = now;
    }

}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super initWithColor:ccc4(255,255,255,255)] )) {
        
		// Enable touch events
		self.isTouchEnabled = YES;
		
		// Initialize arrays
		_targets = [[NSMutableArray alloc] init];
		_projectiles = [[NSMutableArray alloc] init];
		
		// Get the dimensions of the window for calculation purposes
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		
		// Add the player to the middle of the screen along the y-axis, 
		// and as close to the left side edge as we can get
		// Remember that position is based on the anchor point, and by default the anchor
		// point is the middle of the object.
		_player = [[CCSprite spriteWithFile:@"Player2.png"] retain];
		_player.position = ccp(_player.contentSize.width/2 + 100, winSize.height/2);
		[self addChild:_player z:1];
        
        // Set up score and score label
        _score = 0;
        _oldScore = -1;
        self.scoreLabel = [CCLabelTTF labelWithString:@"" dimensions:CGSizeMake(100, 50) alignment:UITextAlignmentRight fontName:@"Marker Felt" fontSize:32];
        _scoreLabel.position = ccp(winSize.width - _scoreLabel.contentSize.width/2, _scoreLabel.contentSize.height/2);
        _scoreLabel.color = ccc3(0,0,0);
        [self addChild:_scoreLabel z:1];
        
        // Useful for taking screenshots
        //[[CCScheduler sharedScheduler] setTimeScale:0.1];
		
		// Call game logic about every second
        [self schedule:@selector(update:)];
		[self schedule:@selector(gameLogic:) interval:1.0];		
        	
		// Start up the background music
		[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"background-music-aac.caf"];
		
	}
	return self;
}

- (void)update:(ccTime)dt {
    
	NSMutableArray *projectilesToDelete = [[NSMutableArray alloc] init];
	for (Projectile *projectile in _projectiles) {
		CGRect projectileRect = CGRectMake(projectile.position.x - (projectile.contentSize.width/2), 
										   projectile.position.y - (projectile.contentSize.height/2), 
										   projectile.contentSize.width, 
										   projectile.contentSize.height);
        
        BOOL monsterHit = FALSE;
		NSMutableArray *targetsToDelete = [[NSMutableArray alloc] init];
		for (CCSprite *target in _targets) {
			CGRect targetRect = CGRectMake(target.position.x - (target.contentSize.width/2), 
										   target.position.y - (target.contentSize.height/2), 
										   target.contentSize.width, 
										   target.contentSize.height);
            
			if (CGRectIntersectsRect(projectileRect, targetRect)) {
				
                if (![projectile shouldDamageMonster:target]) continue;
                
                //[targetsToDelete addObject:target];	
                monsterHit = TRUE;
                Monster *monster = (Monster *)target;
                monster.hp--;
                if (monster.hp <= 0) {
                    _score ++;
                    [targetsToDelete addObject:target];
                }
                break;
                
			}						
		}
		
		for (CCSprite *target in targetsToDelete) {
			[_targets removeObject:target];
			[self removeChild:target cleanup:YES];									
			_projectilesDestroyed++;
			if (_projectilesDestroyed > 2) {
                
                Cocos2DSimpleGameAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
                [delegate levelComplete];
                
			}
		}
		
		if (monsterHit) {
			//[projectilesToDelete addObject:projectile];
            [[SimpleAudioEngine sharedEngine] playEffect:@"explosion.caf"];
		}
		[targetsToDelete release];
	}
	
	for (CCSprite *projectile in projectilesToDelete) {
		[_projectiles removeObject:projectile];
		[self removeChild:projectile cleanup:YES];
	}
	[projectilesToDelete release];
    
    // Update score only when it changes for efficiency
    if (_score != _oldScore) {
        _oldScore = _score;
        [_scoreLabel setString:[NSString stringWithFormat:@"%d", _score]];
    }
}


- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (_nextProjectile != nil) return;
    
    //
    // Easier method using Cocos2D helper functions, suggested by 
    // Caleb Wren - see comments for post
    //
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:[touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    // Play a sound!
    [[SimpleAudioEngine sharedEngine] playEffect:@"pew-pew-lei.caf"];
    
    // Set up initial location of projectile
    //CGSize winSize = [[CCDirector sharedDirector] winSize];
    self.nextProjectile = [[[Projectile alloc] initWithFile:@"Projectile2.png"] autorelease];
    _nextProjectile.position = _player.position;
    
    // Rotate player to face shooting direction
    CGPoint shootVector = ccpSub(location, _nextProjectile.position);
    CGFloat shootAngle = ccpToAngle(shootVector);
    CGFloat cocosAngle = CC_RADIANS_TO_DEGREES(-1 * shootAngle);

    CGFloat curAngle = _player.rotation;
    CGFloat rotateDiff = cocosAngle - curAngle;    
    if (rotateDiff > 180)
		rotateDiff -= 360;
	if (rotateDiff < -180)
		rotateDiff += 360;    
    CGFloat rotateSpeed = 0.5 / 180; // Would take 0.5 seconds to rotate half a circle
    CGFloat rotateDuration = fabs(rotateDiff * rotateSpeed);
    
    // Move player slightly backwards
    //CGPoint position = ccpAdd(_player.position, ccp(-10, 0));
    
    [_player runAction:[CCSequence actions:
                        //[CCMoveBy actionWithDuration:0.1 position:ccp(-10, 0)],
                        [CCRotateTo actionWithDuration:rotateDuration angle:cocosAngle],
                        [CCCallFunc actionWithTarget:self selector:@selector(finishShoot)],
                        nil]];
    
    // Move projectile offscreen
    ccTime delta = 1.0;
    CGPoint normalizedShootVector = ccpNormalize(shootVector);
    CGPoint overshotVector = ccpMult(normalizedShootVector, 420);
    CGPoint offscreenPoint = ccpAdd(_nextProjectile.position, overshotVector);
    
    [_nextProjectile runAction:[CCSequence actions:
                                [CCMoveTo actionWithDuration:delta position:offscreenPoint],
                                [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)],
                                nil]];
    
    // Add to projectiles array
    _nextProjectile.tag = 2;
    
}

- (void)finishShoot {
        
    // Ok to add now - we've finished rotation!
    [self addChild:_nextProjectile z:1];
    [_projectiles addObject:_nextProjectile];
    
    // Release
    self.nextProjectile = nil;
    
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	[_targets release];
	_targets = nil;
	[_projectiles release];
	_projectiles = nil;
    [_player release];
    _player = nil;
	
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
