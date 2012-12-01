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
#import "BBUFO.h"
#import "BBRock.h"
#import "BBCollisionController.h"
#import "BBConfiguration.h"
#import "BBParticleSystem.h"

@implementation BBSceneController

@synthesize inputController, openGLView;
@synthesize animationInterval, animationTimer,levelStartTime,deltaTime;

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

-(void)restartScene
{
	// queue up all the old objects to be removed
	[objectsToRemove addObjectsFromArray:sceneObjects];
	// reload the scene
	needToLoadScene = YES;
}


-(void)gameOver
{
	[inputController gameOver];
}


// this is where we initialize all our scene objects
-(void)loadScene
{
	needToLoadScene = NO;
	RANDOM_SEED();
	// this is where we store all our objects
	if (sceneObjects == nil) sceneObjects = [[NSMutableArray alloc] init];	
	
	// our 'character' object
	BBSpaceShip * ship = [[BBSpaceShip alloc] init];
	ship.translation = BBPointMake(0.0, 0.0, 0.0);
	ship.scale = BBPointMake(30, 30, 30.0);
	[self addObjectToScene:ship];
	[ship release];	

	// make our rocks
	[self generateRocks];
	
	// if we do not have a collision controller, then make one and link it to our
	// sceneObjects
	if (collisionController == nil) collisionController = [[BBCollisionController alloc] init];
	collisionController.sceneObjects = sceneObjects;
	if (DEBUG_DRAW_COLLIDERS)	[self addObjectToScene:collisionController];

	// reload our interface
	[inputController loadInterface];
	
	// our first UFO will show up in 300 frames
//	UFOCountDown = 300;
	UFOCountDown = 30;
}

// here we add a little enemy to the scene to make it more interesting
-(void)addUFO
{
	BBUFO * ufo = [[BBUFO alloc] init];
	// the UFO starts in the pper left and moves to the right
	ufo.translation = BBPointMake(-270.0, 120.0, 0.0);
	ufo.speed = BBPointMake(40.0, 0.0, 0.0);
	ufo.scale = BBPointMake(30, 30, 30.0);
	ufo.rotation = BBPointMake(-20.0, 0.0, 0.0);
	ufo.rotationalSpeed = BBPointMake(0.0, 0.0, 50.0);
	[self addObjectToScene:ufo];
	[ufo release];	
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
	self.animationInterval = 1.0/BB_FPS;
	[self startAnimation];
	self.levelStartTime = [NSDate date];
	lastFrameStartTime = 0;
}



#pragma mark Game Loop

- (void)gameLoop
{
	// we use our own autorelease pool so that we can control when garbage gets collected
	NSAutoreleasePool * apool = [[NSAutoreleasePool alloc] init];

	timeSinceLevelStart = [levelStartTime timeIntervalSinceNow];
	deltaTime =  lastFrameStartTime - timeSinceLevelStart;
	lastFrameStartTime = timeSinceLevelStart;
	
	UFOCountDown--;
	if (UFOCountDown <=0 ) {
		[self addUFO];
		UFOCountDown = RANDOM_INT(500,800);
	}
	
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
	if (needToLoadScene) [self loadScene];
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
	
	[self setupLighting];
	// simply call 'render' on all our scene objects
	[sceneObjects makeObjectsPerformSelector:@selector(render)];
	// draw the interface on top of everything
	[inputController renderInterface];
	// finalize this frame
	[openGLView finishDraw];
}

-(void)setupLighting
{
	// cull the unseen faces
	// we use 'front' culling because Cheetah3d exports our models to be compatible
	// with this way
	glEnable(GL_CULL_FACE);
	glCullFace(GL_FRONT);
	
  // Light features
  GLfloat light_ambient[]= { 0.2f, 0.2f, 0.2f, 1.0f };
  GLfloat light_diffuse[]= { 80.0f, 80.0f, 80.0f, 0.0f };
  GLfloat light_specular[]= { 80.0f, 80.0f, 80.0f, 0.0f };
  // Set up light 0
  glLightfv (GL_LIGHT0, GL_AMBIENT, light_ambient);
  glLightfv (GL_LIGHT0, GL_DIFFUSE, light_diffuse);
  glLightfv (GL_LIGHT0, GL_SPECULAR, light_specular);
  
// // // Material features
//  GLfloat mat_specular[] = { 0.5, 0.5, 0.5, 1.0 };
//  GLfloat mat_shininess[] = { 120.0 };
//  glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, mat_specular);
//  glMaterialfv(GL_FRONT_AND_BACK, GL_SHININESS, mat_shininess);
  
  glShadeModel (GL_SMOOTH);
  
  // Enable lighting and lights
  glEnable(GL_LIGHTING);
  glEnable(GL_LIGHT0);
  
  // Place the light up and to the right
  GLfloat light0_position[] = { 50.0, 50.0, 50.0, 1.0 };
  glLightfv(GL_LIGHT0, GL_POSITION, light0_position);
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
