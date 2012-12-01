//
//  AsteroidsModel.h
//  Asteroids
//
//  Created by Scott Penberthy on 2/26/10.
//  Copyright 2010 North Highland Partners, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sprite.h"
#import "Finger.h"
#import "AtlasSprite.h"
#import "VectorSprite.h"
#import "TextSprite.h"

#define kShipIndex 0
#define kSaucerIndex 1

@interface AsteroidsModel : NSObject {
	NSMutableArray *rocks;
	NSMutableArray *bullets;
	NSMutableArray *deadSprites;
	NSMutableArray *newSprites;
	NSMutableDictionary *fingers;	
	Sprite *ship;
	Sprite *saucer;
	
	AtlasSprite *thrust;
	AtlasSprite *left;
	AtlasSprite *right;
	AtlasSprite *fire;
	TextSprite *status;
	TextSprite *lives;

	NSMutableDictionary *state;
	int lastBullet;
	CGFloat time;
}

@property (nonatomic, retain) NSMutableDictionary *state;
@property (nonatomic, retain) NSMutableArray *rocks;
@property (nonatomic, retain) NSMutableDictionary *fingers;
@property (nonatomic, retain) NSMutableArray *bullets;
@property (nonatomic, retain) NSMutableArray *deadSprites;
@property (nonatomic, retain) NSMutableArray *newSprites;
@property (nonatomic, retain) Sprite *ship;
@property (nonatomic, retain) Sprite *saucer;
@property (assign) CGFloat time;
@property (nonatomic, retain) AtlasSprite *thrust;
@property (nonatomic, retain) AtlasSprite *left;
@property (nonatomic, retain) AtlasSprite *right;
@property (nonatomic, retain) AtlasSprite *fire;
@property (nonatomic, retain) TextSprite *status;
@property (nonatomic, retain) TextSprite *lives;

+ (AsteroidsModel *) sharedModel;
+ (int) getState: (NSString *) indicator;
+ (void) setState: (NSString *) indicator to: (int) val;
- (void) addObjects;
- (void) addShips;
- (void) addRocks;
- (Sprite *) myShip;
+ (CGPoint) gamePoint: (CGPoint) p;
+ (BOOL) fingerIsTouching: (Sprite *) s;
- (void) initState;
- (void) updateButtons;
- (void) unleashGrimReaper;
- (void) kill: (Sprite *) s;
- (void) placeFinger: (NSUInteger) hash at: (CGPoint) p;
- (void) moveFinger: (NSUInteger) hash to: (CGPoint) p;
- (void) liftFinger: (NSUInteger) hash;	
- (void) addBullet: (Sprite *) b;
- (VectorSprite *) randomRock;
- (void) addRock: (Sprite *) rock;

@end
