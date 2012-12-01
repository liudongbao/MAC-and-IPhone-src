//
//  BBSceneController.m
//  BBOpenGLGameTemplate
//
//  Created by ben smith on 1/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BBSceneController.h"
#import "BBInputViewController.h"
#import "EAGLView.h"
#import "BBSpaceShip.h"
#import "BBRock.h"
#import "BBCollisionController.h"
#import "BBConfiguration.h"

@implementation BBSceneController

@synthesize inputController, openGLView;
@synthesize animationInterval, animationTimer;

// Singleton accessor.  this is how you should ALWAYS get a reference
// to the scene controller.  Never init your own. 
+(BBSceneController*)sharedSceneController
{
  static BBSceneController *sharedSceneController;
  @synchronized(self)
  {
    if (!sharedSceneController)
      sharedSceneController = [[BBSceneController alloc] init];
		
    return sharedSceneController;
  }
	return sharedSceneController;
}

#pragma mark scene preload

// this is where we initialize all our scene objects
-(void)loadScene
{
	RANDOM_SEED();
	// this is where we store all our objects
	sceneObjects = [[NSMutableArray alloc] init];
		
	BBSpaceShip * ship = [[BBSpaceShip alloc] init];
	ship.scale = BBPointMake(2.5, 2.5, 1.0);
	[self addObjectToScene:ship];
	[ship release];	

	[self generateRocks];
//
	collisionController = [[BBCollisionController alloc] init];
	collisionController.sceneObjects = sceneObjects;
	if (DEBUG_DRAW_COLLIDERS)	[self addObjectToScene:collisionController];
	
	[inputController loadInterface];
}

// we dont actualy add the object directly to the scene.
// this can get called anytime during the game loop, so we want to
// queue up any objects that need adding and add them at the start of
// the next game loop
-(void)addObjectToScene:(BBSceneObject*)sceneObject
{
	if (objectsToAdd == nil) objectsToAdd = [[NSMutableArray alloc] init];

	sceneObject.active = YES;
	[sceneObject awake];
	[objectsToAdd addObject:sceneObject];
}

// similar to adding objects, we cannot just remove objects from
// the scene at any time.  we want to queue them for removal 
// and purge them at the end of the game loop
-(void)removeObjectFromScene:(BBSceneObject*)sceneObject
{
	if (objectsToRemove == nil) objectsToRemove = [[NSMutableArray alloc] init];
	[objectsToRemove addObject:sceneObject];
}

// generate a bunch of random rocks and add them to the scene
-(void)generateRocks
{
	NSInteger rockCount = 10;
	NSInteger index;
	for (index = 0; index < rockCount; index ++) {
		[self addObjectToScene:[BBRock randomRock]];
	}	
}

// makes everything go
-(void) startScene
{
	self.animationInterval = 1.0/60.0;
	[self startAnimation];
}

#pragma mark Game Loop

- (void)gameLoop
{
	// we use our own autorelease pool so that we can control when garbage gets collected
	NSAutoreleasePool * apool = [[NSAutoreleasePool alloc] init];

	// add any queued scene objects
	if ([objectsToAdd count] > 0) {
		[sceneObjects addObjectsFromArray:objectsToAdd];
		[objectsToAdd removeAllObjects];
	}
	
	// update our model
	[self updateModel];
	// deal with collisions
	[collisionController handleCollisions];

	// send our objects to the renderer
	[self renderScene];
	
	// remove any objects that need removal
	if ([objectsToRemove count] > 0) {
		[sceneObjects removeObjectsInArray:objectsToRemove];
		[objectsToRemove removeAllObjects];
	}
	
	[apool release];
}

- (void)updateModel
{
	// simply call 'update' on all our scene objects
	[inputController updateInterface];
	[sceneObjects makeObjectsPerformSelector:@selector(update)];
	// be sure to clear the events
	[inputController clearEvents];
}

- (void)renderScene
{
	// turn openGL 'on' for this frame
	[openGLView beginDraw];
	// simply call 'render' on all our scene objects
	[sceneObjects makeObjectsPerformSelector:@selector(render)];
	// draw the interface on top of everything
	[inputController renderInterface];
	// finalize this frame
	[openGLView finishDraw];
}


#pragma mark Animation Timer

// these methods are copied over from the EAGLView template

- (void)startAnimation {
	self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationInterval target:self selector:@selector(gameLoop) userInfo:nil repeats:YES];
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

#pragma mark dealloc

- (void) dealloc
{
	[self stopAnimation];
	
	[sceneObjects release];
	[objectsToAdd release];
	[objectsToRemove release];
	[inputController release];
	[openGLView release];
	[collisionController release];
	
	[super dealloc];
}


@end
