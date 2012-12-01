//
//  BBInputViewController.m
//  BBOpenGLGameTemplate
//
//  Created by ben smith on 1/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BBInputViewController.h"
#import "BBButton.h"
#import "BBTexturedButton.h"
#import "BBArrowButton.h"


@implementation BBInputViewController

@synthesize touchEvents, forwardMagnitude, rightMagnitude, leftMagnitude,fireMissile;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		// init our touch storage set
		touchEvents = [[NSMutableSet alloc] init];
		forwardMagnitude = 0.0;
		leftMagnitude = 0.0;
		rightMagnitude = 0.0;
	}
	return self;
}

-(void)loadView
{
	
}

-(CGRect)screenRectFromMeshRect:(CGRect)rect atPoint:(CGPoint)meshCenter
{
	// find the point on the screen that is the center of the rectangle
	// and use that to build a screen-space rectangle
	CGPoint screenCenter = CGPointZero;
	CGPoint rectOrigin = CGPointZero;
	// since our view is rotated, then our x and y are flipped
	screenCenter.x = meshCenter.y + 160.0; // need to shift it over
	screenCenter.y = meshCenter.x + 240.0; // need to shift it up
	
	rectOrigin.x = screenCenter.x - (CGRectGetHeight(rect)/2.0); // height and width 
	rectOrigin.y = screenCenter.y - (CGRectGetWidth(rect)/2.0); // are flipped
	
	return CGRectMake(rectOrigin.x, rectOrigin.y, CGRectGetHeight(rect), CGRectGetWidth(rect));
}


#pragma mark Touch Event Handlers

// just a handy way for other object to clear our events
- (void)clearEvents
{
	[touchEvents removeAllObjects];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	// just store them all in the big set.
	[touchEvents addObjectsFromArray:[touches allObjects]];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	// just store them all in the big set.
	[touchEvents addObjectsFromArray:[touches allObjects]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	// just store them all in the big set.
	[touchEvents addObjectsFromArray:[touches allObjects]];
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

#pragma mark Loading the Buttons

-(void)loadInterface
{
	if (interfaceObjects == nil) interfaceObjects = [[NSMutableArray alloc] init];
	[interfaceObjects removeAllObjects];

	// right arrow button
	
	BBTexturedButton * rightButton = [[BBTexturedButton alloc] initWithUpKey:@"rightUp" downKey:@"rightDown"];
	rightButton.scale = BBPointMake(50.0, 50.0, 1.0);
	rightButton.translation = BBPointMake(-155.0, -130.0, 0.0);
	rightButton.target = self;
	rightButton.buttonDownAction = @selector(rightButtonDown);
	rightButton.buttonUpAction = @selector(rightButtonUp);
	rightButton.active = YES;
	[rightButton awake];
	[interfaceObjects addObject:rightButton];
	[rightButton release];
	
	// left arrow
	BBTexturedButton * leftButton = [[BBTexturedButton alloc] initWithUpKey:@"leftUp" downKey:@"leftDown"];
	leftButton.scale = BBPointMake(50.0, 50.0, 1.0);
	leftButton.translation = BBPointMake(-210.0, -130.0, 0.0);
	leftButton.target = self;
	leftButton.buttonDownAction = @selector(leftButtonDown);
	leftButton.buttonUpAction = @selector(leftButtonUp);
	leftButton.active = YES;
	[leftButton awake];
	[interfaceObjects addObject:leftButton];
	[leftButton release];
	
	// forward button
	BBTexturedButton * forwardButton = [[BBTexturedButton alloc] initWithUpKey:@"thrustUp" downKey:@"thrustDown"];
	forwardButton.scale = BBPointMake(50.0, 50.0, 1.0);
	forwardButton.translation = BBPointMake(-185.0, -75.0, 0.0);
	forwardButton.target = self;
	forwardButton.buttonDownAction = @selector(forwardButtonDown);
	forwardButton.buttonUpAction = @selector(forwardButtonUp);	
	forwardButton.active = YES;
	[forwardButton awake];
	[interfaceObjects addObject:forwardButton];
	[forwardButton release];
	
	// fire Button
	BBTexturedButton * fireButton = [[BBTexturedButton alloc] initWithUpKey:@"fireUp" downKey:@"fireDown"];
	fireButton.scale = BBPointMake(50.0, 50.0, 1.0);
	fireButton.translation = BBPointMake(210.0, -130.0, 0.0);
	fireButton.target = self;
	fireButton.buttonDownAction = @selector(fireButtonDown);
	fireButton.buttonUpAction = @selector(fireButtonUp);
	fireButton.active = YES;
	[fireButton awake];
	[interfaceObjects addObject:fireButton];
	[fireButton release];
	
	self.fireMissile = NO;
}

-(void)gameOver
{
	[interfaceObjects removeAllObjects];
	// fire Button
	BBTexturedButton * gameOverButton = [[BBTexturedButton alloc] initWithUpKey:@"gameOver" downKey:@"gameOver"];
	gameOverButton.scale = BBPointMake(80.0, 45.0, 1.0);
	gameOverButton.translation = BBPointMake(0.0, 0.0, 0.0);
	gameOverButton.target = self;
	gameOverButton.buttonDownAction = @selector(gameOverButtonDown);
	gameOverButton.buttonUpAction = @selector(gameOverButtonUp);
	gameOverButton.active = YES;
	[gameOverButton awake];
	[interfaceObjects addObject:gameOverButton];
	[gameOverButton release];	
}

-(void)updateInterface
{
	[interfaceObjects makeObjectsPerformSelector:@selector(update)];
}

-(void)renderInterface
{
	glMatrixMode(GL_PROJECTION);
	glPushMatrix();
	glLoadIdentity();
	glRotatef(-90.0f, 0.0f, 0.0f, 1.0f);
	
	// set up the viewport so that it is analagous to the screen pixels
	glOrthof(-240, 240, -160, 160, -1.0f, 50.0f);
	
	glMatrixMode(GL_MODELVIEW);
	glDisable(GL_LIGHTING);
	glDisable(GL_CULL_FACE);
//	glCullFace(GL_FRONT);

	// simply call 'render' on all our scene objects
	[interfaceObjects makeObjectsPerformSelector:@selector(render)];

	glMatrixMode(GL_PROJECTION);
	glPopMatrix();
	glMatrixMode(GL_MODELVIEW);

}

#pragma mark Input Registers

-(void)gameOverButtonDown 
{ 
	[[BBSceneController sharedSceneController] restartScene];
}

-(void)gameOverButtonUp { }


-(void)fireButtonDown { self.fireMissile = YES; }

-(void)fireButtonUp { }

-(void)leftButtonDown {	self.leftMagnitude = 1.0; }

-(void)leftButtonUp { self.leftMagnitude = 0.0;	}

-(void)rightButtonDown {	self.rightMagnitude = 1.0;	}

-(void)rightButtonUp {	self.rightMagnitude = 0.0; }

-(void)forwardButtonDown {	self.forwardMagnitude = 1.0;	}

-(void)forwardButtonUp {	self.forwardMagnitude = 0.0;	}


- (void)dealloc 
{
	[touchEvents release];
	[super dealloc];
}


@end

