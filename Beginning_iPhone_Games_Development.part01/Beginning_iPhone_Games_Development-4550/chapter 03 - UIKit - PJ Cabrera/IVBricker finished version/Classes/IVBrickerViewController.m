//
//  GameViewController.m
//  IVBricker
//
//  Created by PJ Cabrera on 9/26/09.
//  Copyright PJ Cabrera 2009. All rights reserved.
//

#import "IVBrickerViewController.h"
#import "ImageCache.h"

@implementation IVBrickerViewController

@synthesize scoreLabel;

@synthesize ball;

@synthesize paddle;

@synthesize livesLabel;
@synthesize messageLabel;

- (void)dealloc {
	[scoreLabel release];
	
	[ball release];
	
	[paddle release];
	
	[livesLabel release];
	[messageLabel release];
	
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self loadGameState];
	
	[self initializeBricks];

	[self startPlaying];
}

- (void)initializeBricks
{
	brickTypes[0] = @"bricktype1.png";
	brickTypes[1] = @"bricktype2.png";
	brickTypes[2] = @"bricktype3.png";
	brickTypes[3] = @"bricktype4.png";
		
	int count = 0;
	for (int y = 0; y < BRICKS_HEIGHT; y++)
	{
		for (int x = 0; x < BRICKS_WIDTH; x++)
		{
			UIImage *image = [ImageCache loadImage:brickTypes[count++ % 4]];
			bricks[x][y] = [[[UIImageView alloc] initWithImage:image] autorelease];
			CGRect newFrame = bricks[x][y].frame;
			newFrame.origin = CGPointMake(x * 64, (y * 40) + 50);
			bricks[x][y].frame = newFrame;
			[self.view addSubview:bricks[x][y]];
		}
	}
}

- (void)startPlaying {
	if (!lives) {
		lives = 3;
		score = 0;

		for (int y = 0; y < BRICKS_HEIGHT; y++)
		{
			for (int x = 0; x < BRICKS_WIDTH; x++)
			{
				bricks[x][y].alpha = 1.0;
			}
		}
	}
	scoreLabel.text = [NSString stringWithFormat:@"%05d", score];
	livesLabel.text = [NSString stringWithFormat:@"%d", lives];

	ball.center = CGPointMake(159, 239);
	ballMovement = CGPointMake(4,4);
	// choose whether the ball moves left to right or right to left
	if (arc4random() % 100 < 50)
		ballMovement.x = -ballMovement.x;

	messageLabel.hidden = YES;
	isPlaying = YES;

	[self initializeTimer];
}

- (void)pauseGame {
	[theTimer invalidate];
	theTimer = nil;
}

- (void)initializeTimer {
	if (theTimer == nil) {
		theTimer = [CADisplayLink displayLinkWithTarget:self 
			selector:@selector(gameLogic)];
		theTimer.frameInterval = 2;
		[theTimer addToRunLoop: [NSRunLoop currentRunLoop] 
					   forMode: NSDefaultRunLoopMode];
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if (isPlaying) {
		UITouch *touch = [[event allTouches] anyObject];
		touchOffset = paddle.center.x - 
			[touch locationInView:touch.view].x;
	} else {
		[self startPlaying];
	}

}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if (isPlaying) {
		UITouch *touch = [[event allTouches] anyObject];
		float distanceMoved = 
			([touch locationInView:touch.view].x + touchOffset) - 
			paddle.center.x;
		float newX = paddle.center.x + distanceMoved;
		if (newX > 30 && newX < 290)
			paddle.center = CGPointMake( newX, paddle.center.y );
		if (newX > 290)
			paddle.center = CGPointMake( 290, paddle.center.y );
		if (newX < 30)
			paddle.center = CGPointMake( 30, paddle.center.y );
	}
}

- (void)gameLogic {
	ball.center = CGPointMake(ball.center.x+ballMovement.x,
		ball.center.y+ballMovement.y);
	
    BOOL paddleCollision = ball.center.y >= paddle.center.y - 16 && 
	ball.center.y <= paddle.center.y + 16 && 
	ball.center.x >= paddle.center.x - 32 && 
	ball.center.x <= paddle.center.x + 32;
    
    if(paddleCollision) {
        ballMovement.y = -ballMovement.y;
		
        if (ball.center.y >= paddle.center.y - 16 && ballMovement.y < 0) {
            ball.center = CGPointMake(ball.center.x, paddle.center.y - 16);
        } else if (ball.center.y <= paddle.center.y + 16 && ballMovement.y > 0) {
            ball.center = CGPointMake(ball.center.x, paddle.center.y + 16);
        } else if (ball.center.x >= paddle.center.x - 32 && ballMovement.x < 0) {
            ball.center = CGPointMake(paddle.center.x - 32, ball.center.y);
        } else if (ball.center.x <= paddle.center.x + 32 && ballMovement.x > 0) {
            ball.center = CGPointMake(paddle.center.x + 32, ball.center.y);
        }
	}

	BOOL there_are_solid_bricks = NO;
	
	for (int y = 0; y < BRICKS_HEIGHT; y++)
	{
		for (int x = 0; x < BRICKS_WIDTH; x++)
		{
			if (1.0 == bricks[x][y].alpha) 
			{
				there_are_solid_bricks = YES;
				if ( CGRectIntersectsRect(ball.frame, bricks[x][y].frame) )
				{
					[self processCollision:bricks[x][y]];
				}
			} 
			else 
			{
				if (bricks[x][y].alpha > 0)
					bricks[x][y].alpha -= 0.1;
			}
		}
	}
	
	if (!there_are_solid_bricks) {
		[self pauseGame];
		isPlaying = NO;
		lives = 0;
		[self saveGameState];
		
		messageLabel.text = @"You Win!";
		messageLabel.hidden = NO;
	}    
	
	if (ball.center.x > 310 || ball.center.x < 16)
		ballMovement.x = -ballMovement.x;
	if (ball.center.y < 32)
		ballMovement.y = -ballMovement.y;

	if (ball.center.y > 444) {

		[self pauseGame];
		isPlaying = NO;
		lives--;
		livesLabel.text = [NSString stringWithFormat:@"%d", lives];

		if (!lives) {
			[self saveGameState];
			messageLabel.text = @"Game Over";
		} else {
			messageLabel.text = @"Ball Out of Bounds";
		}
		messageLabel.hidden = NO;
	}    
}

- (void)processCollision:(UIImageView *)brick 
{
	score += 10;
	scoreLabel.text = [NSString stringWithFormat:@"%d", score];

	if (ballMovement.x > 0 && brick.frame.origin.x - ball.center.x <= 4) 
		ballMovement.x = -ballMovement.x;
	else if (ballMovement.x < 0 && ball.center.x - (brick.frame.origin.x + brick.frame.size.width) <= 4) 
		ballMovement.x = -ballMovement.x;

	if (ballMovement.y > 0 && brick.frame.origin.y - ball.center.y <= 4) 
		ballMovement.y = -ballMovement.y;
	else if (ballMovement.y < 0 && ball.center.y - (brick.frame.origin.y + brick.frame.size.height) <= 4) 
		ballMovement.y = -ballMovement.y;

	brick.alpha -= 0.1;
}

NSString *kLivesKey = @"IVBrickerLives";
NSString *kScoreKey = @"IVBrickerScore";

- (void)saveGameState {
	[[NSUserDefaults standardUserDefaults] setInteger:lives forKey:kLivesKey];
	[[NSUserDefaults standardUserDefaults] setInteger:score forKey:kScoreKey];
}

- (void)loadGameState {
	lives = [[NSUserDefaults standardUserDefaults] integerForKey:kLivesKey];
	livesLabel.text = [NSString stringWithFormat:@"%d", lives];
	score = [[NSUserDefaults standardUserDefaults] integerForKey:kScoreKey];
	scoreLabel.text = [NSString stringWithFormat:@"%d", score];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}
/*
- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}
*/
@end
