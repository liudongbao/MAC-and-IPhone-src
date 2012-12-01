//
//  GameViewController.h
//  IVBricker
//
//  Created by PJ Cabrera on 9/26/09.
//  Copyright PJ Cabrera 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/CADisplayLink.h>

@interface IVBrickerViewController : UIViewController {
	UILabel *scoreLabel;
	int score;

	UIImageView *ball;
	
	CGPoint ballMovement;

	UIImageView *paddle;
	float touchOffset;
	
	int lives;
	UILabel *livesLabel;
	UILabel *messageLabel;
	
	BOOL isPlaying;
	CADisplayLink *theTimer;

#define BRICKS_WIDTH 5
#define BRICKS_HEIGHT 4
	UIImageView *bricks[BRICKS_WIDTH][BRICKS_HEIGHT];
	NSString *brickTypes[4];
	
	NSMutableSet *hitBricks;
}

@property (nonatomic, retain) IBOutlet UILabel *scoreLabel;

@property (nonatomic, retain) IBOutlet UIImageView *ball;

@property (nonatomic, retain) IBOutlet UIImageView *paddle;

@property (nonatomic, retain) IBOutlet UILabel *livesLabel;
@property (nonatomic, retain) IBOutlet UILabel *messageLabel;

- (void)initializeTimer;
- (void)pauseGame;
- (void)startPlaying;

- (void)initializeBricks;
- (void)processCollision:(UIImageView *)brick;

- (void)saveGameState;
- (void)loadGameState;

@end

