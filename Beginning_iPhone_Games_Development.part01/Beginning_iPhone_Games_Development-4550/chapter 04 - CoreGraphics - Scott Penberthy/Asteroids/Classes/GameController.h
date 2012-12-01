//
//  GameController.h
//  Asteroids
//
//  Created by Scott Penberthy on 3/11/10.
//  Copyright 2010 North Highland Partners, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsteroidsModel.h"
#import "AsteroidsView.h"
#import "Sprite.h"
#import "AudioController.h"

@interface GameController : NSObject {
	AsteroidsModel *model;
	AsteroidsView *view;
	AudioController *audio;
	BOOL start;
	int restartDelay;
}

@property (assign) AsteroidsModel *model;
@property (assign) AsteroidsView *view;
@property (nonatomic, retain) AudioController *audio;
@property (assign) BOOL start;

- (id) initWithView: (AsteroidsView *) theView;
- (void) tic: (NSTimeInterval) dt;
- (void) updateModel: (NSTimeInterval) dt;
- (void) updateView: (NSTimeInterval) dt;
- (void) updateBullets: (NSTimeInterval) dt;
- (void) moveShip: (NSTimeInterval) dt;
- (void) moveRocks: (NSTimeInterval) dt;
- (void) fireBullet;
- (void) hitRock: (Sprite *) rock with: (Sprite *) bullet;
- (void) hitShipWithRock: (Sprite *) s;
- (void) creditScoreForRockOfSize: (CGFloat) size;
- (id) initWithView: (AsteroidsView *) theView;
- (void) detectBulletCollision: (Sprite *) bullet startedAt: (CGPoint) firePoint;

@end
