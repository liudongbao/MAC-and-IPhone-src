//
//  AsteroidsViewController.m
//  Asteroids
//
//  Created by Scott Penberthy on 2/26/10.
//  Copyright North Highland Parnters, Inc. 2010. All rights reserved.
//

#import "AsteroidsViewController.h"

@implementation AsteroidsViewController

@synthesize animationTimer, animationInterval, deltaTime, timeSinceLevelStart, levelStartTime, lastFrameStartTime;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	UIView *v = [self view];
	v.multipleTouchEnabled = YES;
	game = [[GameController alloc] initWithView: (AsteroidsView *) v];
	printf("Inside viewdidload\n");
	[self startAnimation];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

//
// Core game loop
//
// these methods are copied over from the EAGLView template

- (void)startAnimation {
	self.animationInterval = 1.0/kFPS;
	self.levelStartTime = nil;
	self.timeSinceLevelStart = 0;
	self.deltaTime = 0;
	self.levelStartTime = [[NSDate date] retain];
	self.lastFrameStartTime = [levelStartTime timeIntervalSinceNow];
	self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:self.animationInterval
														   target:self 
														 selector:@selector(gameLoop) 
														 userInfo:nil 
														  repeats:YES];
}

- (void)stopAnimation {
	self.animationTimer = nil;
}

- (void)setAnimationTimer:(NSTimer *)newTimer {
	[animationTimer invalidate];
	animationTimer = newTimer;
}

- (void)setAnimationInterval:(NSTimeInterval)interval {	
	animationInterval = interval;
	if (animationTimer) {
		[self stopAnimation];
		[self startAnimation];
	}
}

- (void)gameLoop
{
	// we use our own autorelease pool so that we can control when garbage gets collected
	NSAutoreleasePool * apool = [[NSAutoreleasePool alloc] init];
	
	self.timeSinceLevelStart = [levelStartTime timeIntervalSinceNow];
	self.deltaTime =  lastFrameStartTime - timeSinceLevelStart;
	self.lastFrameStartTime = timeSinceLevelStart;	

	[game tic: self.deltaTime];
	
	[apool release];
}

//
// Basic UI - store touches in the model
//

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	NSSet *allTouches = [event allTouches];
    for (UITouch *touch in allTouches) {
        // Get the point where the player has touched the screen
        CGPoint touchLocation = [touch locationInView:self.view];
		[game.model placeFinger: [touch hash] at: touchLocation];
    }
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event {
    NSSet *allTouches = [event allTouches];
    for (UITouch *touch in allTouches) {
		CGPoint touchLocation = [touch locationInView:self.view];
		[game.model moveFinger: [touch hash] to: touchLocation];
	}
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	for (UITouch *touch in touches) {
		[game.model liftFinger: [touch hash]];
	}
}


- (void)dealloc {
	self.animationTimer = nil;
	[self stopAnimation];
	[game release];
    [super dealloc];
}

@end
