//
//  GameController.m
//  Asteroids
//
//  Created by Scott Penberthy on 3/11/10.
//  Copyright 2010 North Highland Partners, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameController.h"

@implementation GameController

@synthesize model, view, audio, start;

- (id) initWithView: (AsteroidsView *) theView
{
	self = [super init];
	if (self) {
		AsteroidsModel *m = [AsteroidsModel sharedModel];
		self.audio = [[AudioController alloc] init];
		self.model = m;
		self.view = theView;
		self.start = YES;
		[m initState];
		[theView useModel: m];
	}
	return self;
}

- (void) tic: (NSTimeInterval) dt
{
	if (start) {
		start = NO;
		model.time = 0;
	}
	else {
		[self updateModel: dt];
		[self updateView: dt];
		[audio tic: dt];
	}
}

- (void) updateShip: (NSTimeInterval) dt
{
	if (![AsteroidsModel getState: kGameOver]) {
		[self moveShip: dt];
	}
	else if ([AsteroidsModel getState: kLife] > 0) {
		if (restartDelay <= 0) {
			[AsteroidsModel setState: kGameOver to: 0];
			[model.lives 
			 newText: [NSString stringWithFormat: @"Lives %d", [AsteroidsModel getState: kLife]]];
			restartDelay = 0;
			model.lives.r = 1.0;
			model.lives.g = 1.0;
			model.lives.b = 1.0;
			[AsteroidsModel setState: kGameState to: kGameStatePlay];
		}
		else {
			restartDelay--;
		}
	}
}

- (void) updateFingers: (NSTimeInterval) dt
{	
	// update our fingers
	for (id key in model.fingers) {
		Finger *f = [model.fingers objectForKey: key];
		[f tic: dt];
	}	
}
	

- (void) updateModel: (NSTimeInterval) dt
{
	model.time += dt;
	[self moveRocks: dt];
	[self updateShip: dt];
	[self updateFingers: dt];
	[self updateBullets: dt];
	[model updateButtons];
	[model unleashGrimReaper];
}

- (void) updateBullets: (NSTimeInterval) dt
{
	NSMutableArray *bullets = [model bullets];
	for (Sprite *bullet in bullets) {
		CGPoint bulletStart;
		bulletStart.x = bullet.box.origin.x;
		bulletStart.y = bullet.box.origin.y;
		[bullet tic: dt];
		if (bullet.offScreen) {
			[model kill: bullet];
		}
		[self detectBulletCollision: bullet startedAt: bulletStart];
	}
	int reload = [AsteroidsModel getState: kReload];
	if (reload > 0) [AsteroidsModel setState: kReload to: reload-1];
	
	// bullets
	if ([AsteroidsModel getState: kGameOver]) return;  // can't fire anymore
	if ([AsteroidsModel getState: kFire] == kFireOn) {
		[self fireBullet];
	}
}

- (void) detectBulletCollision: (Sprite *) bullet startedAt: (CGPoint) firePoint
{
	CGPoint bpoint = bullet.box.origin;
	for (Sprite *rock in model.rocks) {
		if ([rock lineHitTest: firePoint p1: bpoint]) {
			[self hitRock: rock with: bullet];
			[model kill: bullet];
			return;
		}
	}
}

- (void) boomSoundForRockOfSize: (CGFloat) size
{
	uint boom = kSoundExplode3;
	if (size <= kRockMinSize) {
		boom = kSoundExplode3;
	}
	else if (size <= 2*kRockMinSize) {
		boom = kSoundExplode2;
	}
	else {
		boom = kSoundExplode1;
	}
	[AsteroidsModel setState: kSound to: boom];
}

- (void) creditScoreForRockOfSize: (CGFloat) size
{
	uint score = [AsteroidsModel getState: kScore]; 
	if (size <= kRockMinSize) {
		score += kScoreTinyRock; 
	}
	else if (size <= 2*kRockMinSize) {
		score += kScoreMediumRock;
	}
	else {
		score += kScoreBigRock;
	}
	[AsteroidsModel setState: kScore to: score];
	[model.status newText: [NSString stringWithFormat: @"Score: %d",score]];
}
		
- (void) hitRock: (Sprite *) rock with: (Sprite *) bullet
{
	// Blow up a rock, splitting it into two chunks of the same 
	// color, heading in the general direction of the first rock
	// with a random spread of +/- kRockDispersion.
	//
	// If the rock is small enough, it just disappears.
	//
	
	RANDOM_SEED();
	CGFloat newSpeed = rock.speed*1.5;						// smaller, faster
	CGFloat spread = RANDOM_INT(0,kRockDispersion);
	CGFloat a1 = rock.angle + spread;
	CGFloat a2 = rock.angle - spread;
	CGFloat newScale = rock.scale*0.75;
	CGFloat newSize = rock.box.size.width*newScale;
	
	[model kill: rock];
	// Make boom
	[self boomSoundForRockOfSize: rock.scale];
	[self creditScoreForRockOfSize: rock.scale]; 
	if (newSize < kRockMinSize) return;
	
	Sprite *chunk1 = [model randomRock];
	Sprite *chunk2 = [model randomRock];
	
	chunk1.x = rock.x;
	chunk1.y = rock.y;
	chunk1.speed = newSpeed;
	chunk1.r = rock.r;
	chunk1.g = rock.g;
	chunk1.b = rock.b;
	chunk1.scale = newScale;
	[chunk1 setAngle: a1];
	 
	chunk2.x = rock.x;
	chunk2.y = rock.y;
	chunk2.speed = newSpeed;
	chunk2.scale = newScale;
	[chunk1 setAngle: a2];
	chunk2.r = rock.r;
	chunk2.g = rock.g;
	chunk2.b = rock.b;
	
	// Move the rocks a bit
	[chunk1 tic: 0.1];
	[chunk2 tic: 0.1];
	
	// Add them in
	[model addRock: chunk1];
	[model addRock: chunk2];
}


- (void) updateView: (NSTimeInterval) dt
{
	[view tic: dt];
}	

- (void) moveShip: (NSTimeInterval) dt
{
	// rotation
	CGFloat r = model.ship.rotation;
	CGFloat dr = 0;
	if ([AsteroidsModel getState: kLeft] == kLeftOn) {
		dr = kShipRotationChange;
	}
	else if ([AsteroidsModel getState: kRight] == kRightOn) {
		dr = -kShipRotationChange;
	}
	CGFloat deg = r*180.0/3.141592+dr;
	if (dr) [model.ship setRotation: deg];  // wtf fix me
	
	// thrust
	if ([AsteroidsModel getState: kThrust] == kThrustOn) {
		CGFloat thrustAngle = deg + 90;
		[model.ship applyForce: kShipVelocityChange atAngle: thrustAngle];
		[AsteroidsModel setState: kSound to: kSoundThrust];
	}
	
	[model.ship tic: dt];
	
	// rocks!
	CGRect me = model.ship.box;
	for (Sprite *rock in model.rocks) {
		if (CGRectIntersectsRect(me,rock.box)) {
			[self hitShipWithRock: rock]; 
			[model kill: rock];
			return;
		}
	}
}

- (void) hitShipWithRock: (Sprite *) s
{
	int lives = [AsteroidsModel getState: kLife];
	if (lives > 1) {
		restartDelay = kNewLifeDelay;
		[AsteroidsModel setState: kLife to: lives-1];
		[model.lives newText: @"Try again!"];
		model.lives.r = 1.0;
		model.lives.g = 0.0;
		model.lives.b = 0.0;
		[AsteroidsModel setState: kGameState to: kGameStateNewLife];
	}
	else {
		[model.lives newText: @"Game Over"];
		[AsteroidsModel setState: kGameState to: kGameStateDone];
	}
	[AsteroidsModel setState: kGameOver to: 1];
	[AsteroidsModel setState: kSound to: kSoundExplode1];
}


- (void) fireBullet
{
	int reload = [AsteroidsModel getState: kReload];
	if (reload > 0) return;
	
	Sprite *bullet = [[Sprite alloc] init];
	Sprite *ship = model.ship;
	bullet.width = bullet.height = 2.0;
	bullet.wrap = NO;
	bullet.type = kBulletType;
	bullet.angle = ship.rotation * 180.0/3.141592 + 90;
	bullet.speed = kBulletSpeed;
	bullet.y = ship.y + ship.box.size.height * sin(ship.rotation+3.141592*0.5);
	bullet.x = ship.x + ship.box.size.width * cos(ship.rotation+3.151592*0.5);
	[bullet updateBox];
	[model addBullet: bullet];
	[AsteroidsModel setState: kReload to: kReloadTime];
	
	// don't make bullet noises over explosions
	int playingSound = [AsteroidsModel getState: kSound];
	if (playingSound == kSoundNone) [AsteroidsModel setState: kSound to: kSoundFire];
}


- (void) moveRocks: (NSTimeInterval) dt
{
	BOOL hasRocks = NO;
	for (Sprite *rock in model.rocks) {
		[rock tic: dt];
		hasRocks = YES;
	}
	if (!hasRocks) {
		uint state = [AsteroidsModel getState: kGameState];
		if (state == kGameStatePlay) {
			int level = [AsteroidsModel getState: kLevel];
			level++;
			state = kGameStateLevel;
			restartDelay = kNewLifeDelay*2;
			[model.lives newText: [NSString stringWithFormat: @"Level %d", level]];
			model.lives.r = 1.0;
			model.lives.g = 0.0;
			model.lives.b = 0.0;
			[AsteroidsModel setState: kGameOver to: 1];
			[AsteroidsModel setState: kLevel to: level];
			[AsteroidsModel setState: kGameState to: kGameStateLevel];
			[AsteroidsModel setState: kSound to: kSoundAlert];
		}
		else if (state == kGameStateLevel) {
			restartDelay--;
			if (restartDelay <= 0) {
				[model addRocks];
				[model.lives newText: [NSString stringWithFormat: @"Lives %d", 
									   [AsteroidsModel getState: kLife]]];
				model.lives.r = 1.0;
				model.lives.g = 1.0;
				model.lives.b = 1.0;
				[model.ship moveTo: kShipLocation];
				model.ship.angle = 0.0;
				model.ship.rotation = 0.0;
				model.ship.speed = 0.0;
				[AsteroidsModel setState: kGameOver to: 0];
				[AsteroidsModel setState: kGameState to: kGameStatePlay];
			}
			if (restartDelay == kNewLifeDelay) {
				
			}
				
		}
	}
}

- (void) dealloc
{
	[audio release];
	[super dealloc];
}

@end
