/*
 *  Defs.h
 *  Asteroids
 *
 *  Created by Scott Penberthy on 2/26/10.
 *  Copyright 2010 North Highland Partners, Inc.. All rights reserved.
 *
 */

//
// Configuration constants
//

#define RANDOM_SEED() srandom(time(NULL))
#define RANDOM_INT(__MIN__, __MAX__) ((__MIN__) + random() % ((__MAX__+1) - (__MIN__)))

#define kFPS 30.0
#define kPi	3.14159 

// a handy constant to keep around
#define APRADIANS_TO_DEGREES 57.2958

// material import settings
#define AP_CONVERT_TO_4444 0
#define RANDOM_PCT() (((CGFloat)(arc4random() % 40001) )/40000.0)

// Various constants

#define kRocks					1		// Number of new rocks per level
#define kMaxRocks				8		// Maximum number of rocks to start
#define kScreenWidth			320
#define kScreenHeight			480
#define kShipRotationChange		10  // Number of degrees to move per frame if pressed
#define kShipVelocityChange		2
#define kBulletSpeed			400
#define kReloadTime				5
#define kRockDispersion			30		// +/- degrees to blow up a rock
#define kRockMinSize			30			// minimum size of a rock at level 1
#define kTracerSpacing			5		// a tracer every N bullets
#define kDefaultFont			@"Helvetica"
#define kDefaultFontSize		14

// Scoring
#define kScoreTinyRock			500
#define kScoreMediumRock		250
#define kScoreBigRock			100

// Sprite types
#define kSpriteType				1
#define kRockType				100
#define kShipType				101
#define kSaucerType				102
#define kBulletType				103
#define kBullets				50
#define kLives					3

// Various states
#define kUnknown	-1
#define kScore		@"score"
#define kLevel		@"level"
#define kLife		@"life"
#define kDied		@"dead"
#define kGameOver	@"over"
#define kThrust		@"thrust"
#define kLeft		@"left"
#define kRight		@"right"
#define kFire		@"fire"
#define kReload		@"reload"

#define kGameState			@"gameState"
#define kGameStatePlay		0
#define kGameStateLevel		1
#define kGameStateNewLife	2
#define kGameStateDone		3


// Button frames, as stored in buttons.png
#define kThrustOff				0
#define kLeftOff				2
#define kRightOff				4
#define kFireOff				6
#define kThrustOn				1
#define kLeftOn					3
#define kRightOn				5
#define kFireOn					7

// Location of things
#define kThrustLocation			CGPointMake(-186,-76)
#define kLeftLocation			CGPointMake(-212,-132)
#define kRightLocation			CGPointMake(-158,-132)
#define kFireLocation			CGPointMake(212,-132)
#define kShipLocation			CGPointMake(0,0)
#define kStatusLocation			CGPointMake(-230,145)
#define kLivesLocation			CGPointMake(160,145)

// Sound effects
#define kSound				@"sound"
#define kSoundNone			-1
#define kSoundExplode1		0
#define kSoundExplode2		1
#define kSoundExplode3		2
#define kSoundFire			3
#define kSoundSaucerFire	4
#define kSoundSaucer1		5
#define kSoundSaucer2		6
#define kSoundThrust		7
#define kSoundAlert			8

#define kTotalSounds		9 // must equal the number of sound effects we have
#define kSoundReload		0.10 // Sounds need at least a tenth of a second before playing again
#define kNewLifeDelay		60 // Number of frames to delay before a new life is begun

// Debugging switches

//#define DEBUG_SPRITE_CENTERS

