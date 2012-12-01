//
//  AsteroidsViewController.h
//  Asteroids
//
//  Created by Scott Penberthy on 2/26/10.
//  Copyright North Highland Partners, Inc. 2010. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AsteroidsModel.h"
#import "AsteroidsView.h"
#import "Defs.h"
#import "GameController.h"

@interface AsteroidsViewController : UIViewController {
	GameController *game;
	NSTimer *animationTimer;
	NSTimeInterval animationInterval;
	NSTimeInterval deltaTime;
	NSTimeInterval lastFrameStartTime;
	NSTimeInterval timeSinceLevelStart;
	NSDate * levelStartTime;
}

@property (retain, nonatomic) NSTimer *animationTimer;
@property (assign) NSTimeInterval animationInterval;
@property (assign) NSTimeInterval deltaTime;
@property (assign) NSTimeInterval lastFrameStartTime;
@property (assign) NSTimeInterval timeSinceLevelStart;
@property (assign) NSDate *levelStartTime;

- (void) startAnimation;
- (void) stopAnimation;

@end

