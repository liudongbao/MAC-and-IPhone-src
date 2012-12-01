//
//  AsteroidsModel.m
//  Asteroids
//
//  Created by Scott Penberthy on 2/26/10.
//  Copyright 2010 North Highland Partners, Inc.. All rights reserved.
//

#import "AsteroidsModel.h"
#import "VectorSprite.h"
#import "AtlasSprite.h"
#import "Defs.h"
#import "images.h"

@implementation AsteroidsModel
@synthesize rocks, bullets, state, ship, saucer;
@synthesize deadSprites, newSprites, fingers, time;
@synthesize left, right, fire, thrust, status, lives;

#pragma mark game state

+ (CGPoint) gamePoint: (CGPoint) p
{
	// Touch points start in the upper left of the screen,
	// in landscape mode.  Here we translate these points to 
	// game space.
	
	CGFloat w2 = kScreenWidth*0.5;
	CGFloat h2 = kScreenHeight*0.5;
	
	return CGPointMake(p.y - h2, p.x - w2);
}

+ (AsteroidsModel *) sharedModel
{
	static AsteroidsModel *sharedInstance;
	
	@synchronized(self)
	{
		if (!sharedInstance)
			sharedInstance = [[AsteroidsModel alloc] init];
		
		return sharedInstance;
	}
	return sharedInstance;
}

+ (int) getState: (NSString *) indicator 
{
	AsteroidsModel *game = [AsteroidsModel sharedModel]; 
	if (game.state == nil) game.state = [[NSMutableDictionary alloc] init];
	NSNumber *n = [game.state objectForKey: indicator];
	if (n) {
		return [n intValue];
	}
	return kUnknown;
}

+ (void) setState: (NSString *) indicator to: (int) val
{
	AsteroidsModel *game = [AsteroidsModel sharedModel];
	if (game.state == nil) game.state = [[NSMutableDictionary alloc] init];
	NSNumber *n = [NSNumber numberWithInt: val];
	[game.state setObject: n forKey: indicator];
}

#pragma mark model methods

- (id) init
{
	self = [super init];
	if (self) {
		state = [[NSMutableDictionary alloc] init];
		rocks = [[NSMutableArray alloc] init];
		bullets = [[NSMutableArray alloc] init];
		deadSprites = [[NSMutableArray alloc] init];
		newSprites = [[NSMutableArray alloc] init];
		state = [[NSMutableDictionary alloc] init];
		fingers = [[NSMutableDictionary alloc] init];
		time = 0;
		[self addObjects];
	}
	return self;
}

- (void) kill: (Sprite *) s
{
	[deadSprites addObject: s];
}

- (void) unleashGrimReaper
{
	int count = [deadSprites count];
	if (count > 0) {
		printf("Reaping %d sprites\n",count);
		[rocks removeObjectsInArray: deadSprites];
		[bullets removeObjectsInArray: deadSprites];
		[deadSprites removeAllObjects];
	}
}

- (void) initState
{
	[AsteroidsModel setState: kThrust to: kThrustOff];
	[AsteroidsModel setState: kLeft to: kLeftOff];
	[AsteroidsModel setState: kRight to: kRightOff];
	[AsteroidsModel setState: kFire to: kFireOff];
	[AsteroidsModel setState: kReload to: 0];
	[AsteroidsModel setState: kGameOver to: 0];
	[AsteroidsModel setState: kLife to: kLives];
	[AsteroidsModel setState: kScore to: 0];
	[AsteroidsModel setState: kLevel to: 0];
	[AsteroidsModel setState: kGameState to: kGameStatePlay];
}

- (void) addBullets
{
	Sprite *bullet;
	
	for (int i=0; i < kBullets; i++) {
		bullet = [[Sprite alloc] init];
		bullet.width = bullet.height = 2.0;
		bullet.wrap = NO;
		bullet.type = kBulletType;
		[bullets addObject: bullet];
	}
	lastBullet = 0;
}

- (void) addButtons
{
	thrust = [AtlasSprite fromFile: @"buttons.png" withRows: 2 withColumns: 4];
	left = [AtlasSprite fromFile: @"buttons.png" withRows: 2 withColumns: 4];
	right = [AtlasSprite fromFile: @"buttons.png" withRows: 2 withColumns: 4];
	fire = [AtlasSprite fromFile: @"buttons.png" withRows: 2 withColumns: 4];
	
	thrust.frame = kThrustOff;
	left.frame = kLeftOff;
	right.frame = kRightOff;
	fire.frame = kFireOff;
	
	[thrust moveTo: kThrustLocation];
	[left moveTo: kLeftLocation];
	[right moveTo: kRightLocation];
	[fire moveTo: kFireLocation];
}

- (void) addLabels
{
	printf("Adding labels\n");
	status = [TextSprite withString: @"Score: 0"];
	lives = [TextSprite withString: @"Lives: 3"];
	[status moveUpperLeftTo: kStatusLocation];
	[lives moveUpperLeftTo: kLivesLocation];
}

- (void) updateButtons
{
	thrust.frame = [AsteroidsModel fingerIsTouching: thrust] ? kThrustOn : kThrustOff;
	left.frame = [AsteroidsModel fingerIsTouching: left] ? kLeftOn : kLeftOff;
	right.frame = [AsteroidsModel fingerIsTouching: right] ? kRightOn : kRightOff;
	fire.frame = [AsteroidsModel fingerIsTouching: fire] ? kFireOn : kFireOff;
	
	[AsteroidsModel setState: kThrust to: thrust.frame];
	[AsteroidsModel setState: kLeft to: left.frame];
	[AsteroidsModel setState: kRight to: right.frame];
	[AsteroidsModel setState: kFire to: fire.frame];
}

- (VectorSprite *) randomRock
{
	VectorSprite *rock;
	int rockNum = RANDOM_PCT()*4;
	switch (rockNum) {
		case 0:
			rock = [VectorSprite withPoints: kRock1Points count: kRock1Count];
			break;
		case 1:
			rock = [VectorSprite withPoints: kRock2Points count: kRock2Count];
			break;
		case 2:
			rock = [VectorSprite withPoints: kRock3Points count: kRock3Count];
			break;
		default:
			rock = [VectorSprite withPoints: kRock4Points count: kRock4Count];
			break;
	}
	rock.wrap = YES;
	rock.type = kRockType;
	[rock setRotation: RANDOM_PCT()*360];
	return rock;
}

- (void) addRock: (Sprite *) rock
{
	[rocks addObject: rock];
}


- (void) addRocks
{
	int totalRocks = kRocks * (time > 0 ? [AsteroidsModel getState: kLevel] : 1);
	if (totalRocks > kMaxRocks) totalRocks = kMaxRocks;
	
	for (int i=0; i < totalRocks; i++) {
		VectorSprite *rock = [self randomRock];

		// place rocks outside the core ship area
		CGFloat theta = RANDOM_PCT()*360;
		CGFloat radius = 80+RANDOM_PCT()*kScreenHeight*0.5;
		CGFloat dx = radius*cos(theta*3.141592/180.0);
		CGFloat dy = radius*sin(theta*3.141592/180.0); 
		CGFloat angleMove = RANDOM_PCT()*360;
	
		[rock setAngle: angleMove];
		rock.speed = RANDOM_PCT()*100;
		rock.r = RANDOM_PCT();
		rock.g = RANDOM_PCT();
		rock.b = RANDOM_PCT();
		[rock moveTo: CGPointMake(dx,dy)];
		[rock scaleTo: 0.5+2.5*RANDOM_PCT()];
		[rocks addObject: rock];
	}
}

- (void) addShips
{
	ship = [VectorSprite withPoints: kShipPoints count: kShipCount];
	[ship moveTo: kShipLocation];
	[ship scaleTo: 1.6];
	ship.wrap = YES;
	ship.type = kShipType;
}

- (void) addBullet: (Sprite *) bullet
{
	[bullets addObject: bullet];
}

- (Sprite *) myShip
{
	return ship;
}

- (void) addObjects
{
	[self addRocks];
	[self addShips];
	[self addButtons];
	[self addLabels];
}

//
// Fingers
//

- (void) placeFinger: (NSUInteger) hash at: (CGPoint) p
{
	Finger *f = [Finger atPoint: p];
	f.hash = hash;
	[fingers setObject: f forKey: [NSNumber numberWithInt: hash]];
}

- (void) moveFinger: (NSUInteger) hash to: (CGPoint) p
{
	Finger *f = [fingers objectForKey: [NSNumber numberWithInt: hash]];
	if (!f) printf("Moving finger %d that doesn't exist.\n",hash);
	else {
		[f moveTo: p];
	}
}

- (void) liftFinger: (NSUInteger) hash
{
	Finger *f = [fingers objectForKey: [NSNumber numberWithInt: hash]];
	if (!f) printf("Trying to lift finger %d that was never placed.\n",hash);
	[fingers removeObjectForKey: [NSNumber numberWithInt: hash]];
	[f release];
}

+ (BOOL) fingerIsTouching: (Sprite *) s
{
	BOOL touching = NO;
	AsteroidsModel *model = [AsteroidsModel sharedModel]; 
	// update our fingers
	for (id key in model.fingers) {
		Finger *f = [model.fingers objectForKey: key];
		touching = touching || [f isTouching: s];
	}
	return touching;
}

- (void) dealloc
{
	// TODO iterate and release thru each
	[rocks release];
	[bullets release];
	[deadSprites release];
	[newSprites release];
	[fingers release];
	[state release];
	[super dealloc];
}

@end
