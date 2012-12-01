//
//  RingState.mm
//  Chapter 5 Game
//
//  Created by Joe Hogue on 6/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RingsState.h"
#import "ResourceManager.h"
#import "gsMainMenu.h"
//#import "pointmath.h"

float min(float a, float b){
	return a<b?a:b;
}
float sign(float a){
	return a<0?-1:1;
}

@implementation RingsState

- (void) xcodeisbrokenandwontrunwithoutabreakpointsomewhere {
	NSLog(@"so here is your breakpoint");
}

-(void) dealloc {
	[ship release];
	[camera release];
	for(int i=0;i<RING_COUNT;i++)
		[rings[i] release];
	for(int i=0;i<MAX_PARTICLES;i++)
		[particle[i] release];
	[engine_particle release];
	[ring_particle release];
	[skybox release];
	[super dealloc];
}

- (void) setupWorld {
	//test = [[Sprite3D spriteWithModel:[Model modelFromFile:@"poo.pod"]] retain]; //todo: need a noiser error message when file not found.
	//[test setTranslateX:0.0f Y:0.0f Z:-100.0f]; //move it into view.
	//[test setScale:0.3f]; //shrink it to visible size

	//these are the positions of the rings in the level.  created from originals/ring positions.psd
	int positions[] = {
	0, 0, 0, //z, x, y.  note that the increasing z in position means the player's ship will generally be moving in the positive z direction.
	132, 154, 100,
	340, 366, 174,
	552, 370, 166,
	674, 152, 114,
	922, 196, -46,
	1116, 430, -120,
	1490, 466, 96,
	1702, 200, 168,
	2008, 152, 90,
	2292, 270, -24,
	};
	
	//these are the orientations of the rings in the level.  created from originals/ring positions.psd
	int normals[] = {
	64, 64, 51, //z, x, y
	64, 64, 38,
	64, 44, 0,
	46, -64, -25,
	64, -60, -35,
	52, 64, -37,
	64, 44, 0,
	55, -64, 34,
	64, -49, -19,
	64, 31, -27,
	64, 22, -26,
	};
	
	Model *ringmodel = [Model modelFromFile:@"ring.pod"];
	for(int i=0;i<RING_COUNT;i++){
		rings[i] = [[Ring ringWithModel:ringmodel] retain];
		//also flipping z here, because our camera currently faces toward -z.
		[rings[i] setTranslateX:positions[i*3+1] Y:positions[i*3+2] Z:-positions[i*3+0]];
		//rotate each ring to point along a natural path bewteen the rings.
		[rings[i] forwardX:normals[i*3+1] Y:normals[i*3+2] Z:-normals[i*3+0]];
	}
	
	ship = [[Sprite3D spriteWithModel:[Model modelFromFile:@"ship.pod"]] retain];
	[ship setScale:4.0f];
	
	ring_particle = [[Model modelFromFile:@"star.pod"] retain];
	engine_particle = [[Model modelFromFile:@"flare.pod"] retain];
	for(int i=0;i<MAX_PARTICLES;i++){
		particle[i] = [[Particle particleWithModel:ring_particle] retain];
		[particle[i] resetLife:0 velocitiy:PVRTVec3(0, 0, 0) framespeed:0];
	}
	//[particle setScale:10.0f];
	
	camera = [[Camera camera] retain];
	PVRTVec3 tmppos = rings[0].position;
	tmppos += -100*rings[0].normal;
	camera.position = tmppos;
	
	ship.position = camera.position;
	ship.rotation = camera.rotation;
		
	[camera offsetLook:100.0f up:30.0f right:0.0f];
	
	skybox = [[Sprite3D spriteWithModel:[Model modelFromFile:@"skybox.pod"]] retain];

	//setup some hud stuff
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA); //needed
	//glEnable(GL_BLEND); //needed, otherwise extra chunks of the image are drawn
	//glEnableClientState(GL_TEXTURE_COORD_ARRAY); //needed, else nothing renders.  moved to per-frame in render.	


	//Set the OpenGL projection matrix.  this was in glesgamestate3d, moved to here for when we re-enter this game state.
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	const GLfloat			//lightShininess = 100.0,
	zNear = 0.1,
	zFar = 3000.0, //probably should be done in substates.
	fieldOfView = 60.0;
	GLfloat size = zNear * tanf(fieldOfView / 180.0f * PVRT_PI / 2.0);
	CGRect rect = CGRectMake(0, 0, 320, 480);
	glFrustumf(-size, size, -size / (rect.size.width / rect.size.height), size / (rect.size.width / rect.size.height), zNear, zFar);
	glViewport(0, 0, rect.size.width, rect.size.height);
	glRotatef(90.0f, 0, 0, -1); //rotate the display, so we play in landscape.  need to modify accelerometer data to reflect this world rotation, as well.
	glMatrixMode(GL_MODELVIEW);
	
	invertY = [[g_ResManager getUserData:@"invertY.on"] boolValue];
	invertX = [[g_ResManager getUserData:@"invertX.on"] boolValue];
	
	//load accelerometer calibration.
	NSString *calibratedata = [g_ResManager getUserData:@"calibrate"];
	NSArray *tmp = [calibratedata componentsSeparatedByString:@","];
	PVRTVec3 calibrate_axis([[tmp objectAtIndex:0] floatValue], [[tmp objectAtIndex:1] floatValue], [[tmp objectAtIndex:2] floatValue]); //considered straight forward
	calibrate_axis.normalize();
	calibrate_axis_right = PVRTVec3(0, 1, 0); //right
	calibrate_axis_up = calibrate_axis_right.cross(calibrate_axis);
	calibrate_axis_right = calibrate_axis.cross(calibrate_axis_up);
	
	startTime = [[NSDate date] timeIntervalSince1970];
	
	speed_knob = 0.0f;
}

-(id) initWithFrame:(CGRect)frame andManager:(GameStateManager*)pManager;
{
    [super initWithFrame:frame andManager:pManager];
	[self setupWorld];
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / 100.0)];
	[[UIAccelerometer sharedAccelerometer] setDelegate:self];
    return self;
}

- (void) ringParticleAt:(PVRTVec3) position inDirection:(PVRTVec3)axis {
	for(int i=0;i<MAX_PARTICLES;i++){
		if(![particle[i] alive]){
			[particle[i] resetLife:1+(random() % 100)/100.0f
			 velocitiy:axis*(200+(random() % 100)-50) 
			 framespeed:100+(random()%60)-30];
			particle[i].position = position;
			particle[i].model = ring_particle;
			[particle[i] setScale:(random() % 100) / 100.0f * 0.25f];
			break;
		}
	}
}

- (void) engineParticleAt:(PVRTVec3) position inDirection:(PVRTVec3)axis speed:(float)speed{
	for(int i=0;i<MAX_PARTICLES;i++){
		if(![particle[i] alive]){
			float life = 0.25f;
			[particle[i] resetLife:life
			 velocitiy:axis*(-speed-60.0f/life)
			 framespeed:100.0f/life];
			particle[i].position = position+axis*5;
			[particle[i] forwardX:axis.x Y:axis.y Z:axis.z];
			particle[i].model = engine_particle;
			//particle[i].frame = 0;
			//[particle[i] setScale:(random() % 100) / 100.0f * 0.25f];
			particle[i].scale = 1.0f;
			break;
		}
	}
}

- (void) Update {
	float time = 0.033f;
	for(int i=0;i<MAX_PARTICLES;i++){
		[particle[i] update:time];
	}

	PVRTVec3 accel_vec(accel[0], accel[1], accel[2]);
	
	//yaw
	float yaw; //these can be negated to correlate with user's axis inversion preferences.
	yaw = accel_vec.dot(calibrate_axis_right);
	if(invertX) yaw = -yaw;
	
	//pitch
	float pitch;
	pitch = -accel_vec.dot(calibrate_axis_up);
	if(invertY) pitch = -pitch;
	
	PVRTVec3 movement_axis(0, 0, -1);
	if(speed_knob) {
		movement_axis = [ship getAxis:movement_axis];
		float speed = 20.0f*speed_knob;
		PVRTVec3 tmppos = ship.position;
		tmppos += speed*movement_axis;
		ship.position = tmppos;
		
		PVRTVec3 engine;

		if((random() % 100) / 100.0f < speed_knob){
			//figure out where the right engine is.
			engine = [ship getAxis:PVRTVec3(5.0f, 0.2f, 3.0f)];
			engine = engine*ship.scale;
			[self engineParticleAt:engine+ship.position inDirection:-movement_axis speed:speed];
		}

		if((random() % 100) / 100.0f < speed_knob){
			//figure out where the left engine is.
			engine = [ship getAxis:PVRTVec3(-5.0f, 0.2f, 3.0f)];
			engine = engine*ship.scale;
			[self engineParticleAt:engine+ship.position inDirection:-movement_axis speed:speed];
		}
	}

	float follow_tightness = 0.3f;
	camera.position = (1.0f-follow_tightness)*camera.position+follow_tightness*ship.position;
	camera.rotation = ship.rotation;
	
	if(fabs(yaw) > 0.15f)
	{
		[ship yaw:(yaw-sign(yaw)*0.15f)*0.25f];
	}
	
	if(fabs(pitch) > 0.15f)
	{
		[ship pitch:(pitch-sign(pitch)*0.15f)*0.25f];
	}
	
	for(int i=0;i<RING_COUNT;i++){
		if ([rings[i] update:time collideWith:ship]){
			//player passed through an active ring, make explosion or something.
			for(int j=0;j<20;j++){
				PVRTVec3 axis((random()%100)/99.0f-0.5f, (random()%100)/99.0f-0.5f, (random()%100)/99.0f-0.5f);
				axis.normalize(); //possible to divide by zero here, but not likely.
				[self 
				 ringParticleAt:rings[i].position //launch from center of ring
				 inDirection:axis.cross(rings[i].normal)+movement_axis //cross with normal to make particles move in ring's plane, then add movement axis to make them blow in front of player.
				];
			}
			//if this was the last active ring, mark the final time.
			bool finished = true;
			for(int k=0;k<RING_COUNT;k++){
				if(rings[k].active){
					finished = false;
					break;
				}
			}
			if(finished){
				[self onWin];
			}
		}
	}
	
	[self updateEndgame:time];
}

- (void) Render {
	//clear anything left over from the last frame, and set background color.
	glClearColor(0xff/256.0f, 0xcc/256.0f, 0x99/256.0f, 1.0f);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT); //important to clear the depth buffer as well as color buffer.
	
	glLoadIdentity();
	
	//grab the camera's matrix for orienting the skybox
	PVRTMat4 view;
	PVRTMatrixRotationQuaternion(view, camera.rotation);
	PVRTMatrixInverse(view, view);
	glPushMatrix();
	glMultMatrixf((float*)&view);
	glDisable(GL_CULL_FACE);
	glDepthMask(GL_FALSE);
	[skybox draw];
	glDepthMask(GL_TRUE);
	glEnable(GL_CULL_FACE);
	glPopMatrix();

	[camera apply];
		
	for(int i=0;i<RING_COUNT;i++){
		[rings[i] draw];
	}
	
	[ship draw];
	
	//draw our particles as semi-transparent orange.
	glColor4f(1.0f, 0.6f, 0.0f, 0.5f); 
	//the particles have simple geometry, and are made to see both sides of polygons.
	glDisable(GL_CULL_FACE); 
	glBlendFunc(GL_SRC_ALPHA, GL_ONE); //shiny blend
	glEnable(GL_BLEND);
	for(int i=0;i<MAX_PARTICLES;i++){
		[particle[i] draw];
	}
	glDisable(GL_BLEND);
	glEnable(GL_CULL_FACE);
	//reset global color
	glColor4f(1.0f, 1.0f, 1.0f, 1.0f);

	//Set up OpenGL projection matrix for 2d hud rendering.
	glMatrixMode(GL_PROJECTION);
	glPushMatrix(); //pushing so we can restore the main game view after playing with the hud.
	glLoadIdentity(); //needed, glorthof doesn't clobber the matrix like joe would expect
	glOrthof(0, self.frame.size.width, 0, self.frame.size.height, -1, 1);
	
	//setup for drawing the alpha blended textures used in the hud.
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity(); //needed
	glEnableClientState(GL_TEXTURE_COORD_ARRAY); //needed, every frame, else nothing renders
	glEnable(GL_BLEND); //needed, otherwise extra chunks of the image are drawn
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA); //needed
	glDisable(GL_DEPTH_TEST); //needed for overlaying images
	
	//start drawing 2d stuff
	int ycenter = 40;
	int xcenter = self.frame.size.width/2;
	int slide_groove = 246; //size, in pixels, of the area the slider knob can appear in.
	//int xmax = xcenter + slide_groove/2;
	int xmin = xcenter - slide_groove/2;
	[[g_ResManager getTexture:@"slider.png"] drawAtPoint:CGPointMake(xcenter, ycenter) withRotation:-90 withScale:1];
	[[g_ResManager getTexture:@"knob.png"] drawAtPoint:CGPointMake(xmin+speed_knob*slide_groove, ycenter) withRotation:90 withScale:1];

	[self renderEndgame];
	
	double currTime = [[NSDate date] timeIntervalSince1970];
	glRotatef(90, 0, 0, -1);
	//After rotation, -x is up the screen, and +y is right.  origin still on bottom left.
	double displaytime = currTime-startTime;
	if(endgame_state != 0){
		displaytime = endTime;
	}
	[[g_ResManager defaultFont] drawString:[NSString stringWithFormat:@"time %.1f", displaytime] atPoint:CGPointMake(-480, 0) withAnchor:GRAPHICS_BOTTOM | GRAPHICS_LEFT];
	//end drawing 2d stuff
	
	glEnable(GL_DEPTH_TEST);
	glDisable(GL_BLEND); //needed, our model textures don't take kindly to blending.

	//pop the 2d hud stuff off the projection stack
	glMatrixMode(GL_PROJECTION);
	glPopMatrix();
	glMatrixMode(GL_MODELVIEW);

	//you get a nice boring white screen if you forget to swap buffers.
	[self swapBuffers];
}

- (void) touchSpeedKnob:(UITouch*) touch {
	CGPoint pos = [self touchPosition:touch];
	//variables for the slider position copied from render method... this is a horrible way to handle touch, which will 
	//quickly become apparent when adding more touchable items.  I'm going to pretend that it is acceptable when I only 
	//have one touchable item.
	int ycenter = 40;
	
	//early bail if the touch is outside the y bounds of the slider.
	if(
		pos.y > ycenter + [g_ResManager getTexture:@"slider.png"].width / 2 || //using width instead of height here, because slider is rotated 90 degrees on draw.
		pos.y < ycenter - [g_ResManager getTexture:@"slider.png"].width / 2
	   )
	{
		return;
	}
	
	int xcenter = self.frame.size.width/2;
	int slide_groove = 246; //size, in pixels, of the area the slider knob can appear in.
	int xmax = xcenter + slide_groove/2;
	int xmin = xcenter - slide_groove/2;
	if(pos.x > xmax) pos.x = xmax;
	if(pos.x < xmin) pos.x = xmin;
	speed_knob = (pos.x - xmin) / slide_groove;
}

-(void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
	[self touchSpeedKnob:[touches anyObject]];
}

-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
	[self touchSpeedKnob:[touches anyObject]];
	[self touchEndgame];
}

-(void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
	[self touchSpeedKnob:[touches anyObject]];
}

#define kFilteringFactor			0.1
- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{
	//Use a basic low-pass filter to only keep the gravity in the accelerometer values
	accel[0] = acceleration.x * kFilteringFactor + accel[0] * (1.0 - kFilteringFactor);
	accel[1] = acceleration.y * kFilteringFactor + accel[1] * (1.0 - kFilteringFactor);
	accel[2] = acceleration.z * kFilteringFactor + accel[2] * (1.0 - kFilteringFactor);
}


#pragma mark begin endgame/progression code

- (void) onWin{
	if(endgame_state == 0){
		endTime = [[NSDate date] timeIntervalSince1970]-startTime;
		newbest = [RingsState insertBestTime:endTime];
		endgame_state = WINNING;
	}
}
/*- (void) onFail{
	if(endgame_state == 0){
		endgame_state = LOSING;
	}
}*/ //currently no way to fail or bail out of a level.

- (void) renderEndgame{
	if(endgame_state != 0){
		//xoff is used to lay items out in a vertical flow, from top of screen:
		int xoff = self.frame.size.width-32;
		//center items in middle of screen:
		int yoff = self.frame.size.height/2;
		if(endgame_state == WINNING) {
			[[g_ResManager getTexture:@"levelcomplete.png"] 
			 drawAtPoint:CGPointMake(xoff, yoff)
			 withRotation:min(endgame_complete_time, 0.25f)*4*2*180 -90
			 withScale:min(endgame_complete_time, 0.25f)*4];
		}
		if(newbest != -1){
			//player got a new best score, so display their rank 
			xoff -= 64;
			if(endgame_complete_time > 1.0f){
				//draw "new best score" prompt
				[[g_ResManager getTexture:@"newbest.png"] 
				 drawAtPoint:CGPointMake(xoff, yoff)
				 withRotation:-90 //landscape mode
				 withScale:1
				 ];
				xoff -= 64;
				//draw which rank they got
				glPushMatrix();
					//font class can't rotate by itself, unfortuneatly
					glRotatef(90, 0, 0, -1); 
					[[g_ResManager defaultFont]
					 drawString:[NSString stringWithFormat:@"Rank %d", newbest+1]
					 atPoint:CGPointMake(-yoff, xoff)
					 withAnchor:GRAPHICS_HCENTER | GRAPHICS_VCENTER];
				glPopMatrix();
			}
		}
		xoff -= 64;
		//draw tap to continue prompt after 2 seconds
		if(endgame_complete_time > 2.0f){
			[[g_ResManager getTexture:@"taptocontinue.png"] 
			 drawAtPoint:CGPointMake(xoff, yoff)
			 withRotation:-90
			 withScale:1
			 ];
		}
	}
}
- (void) updateEndgame:(float) time{
	if(endgame_state != 0){
		endgame_complete_time += time;
	}
}
- (void) touchEndgame{
	if(endgame_complete_time > 2.0f){
		//will crash if you don't reset the accelerometer delegate before
		//freeing this game state.
		[[UIAccelerometer sharedAccelerometer] setDelegate:nil]; 
		[m_pManager doStateChange:[gsMainMenu class]];
	}
}

#pragma mark highscore saving/loading/querying

//setup some default best times.
+ (void) defaultBestTimes {
	NSArray *times = [NSArray arrayWithObjects:
	  [NSNumber numberWithDouble:40.0], 
	  [NSNumber numberWithDouble:50.0], 
	  [NSNumber numberWithDouble:60.0], 
	  [NSNumber numberWithDouble:70.0], 
	  nil];
	[g_ResManager storeUserData:times toFile:@"bestTimes"];
}

//grab the stored best times, and initialize to defaults if needed
//returns an NSArray of NSNumber doubles with sorted best times.
+ (NSArray*) bestTimes {
	id retval = [g_ResManager getUserData:@"bestTimes"];
	if(retval == nil){
		//no data stored, so setup defaults and try again.
		[RingsState defaultBestTimes];
		return [RingsState bestTimes];
	}
	return retval;
}

//returns the slot where time has been inserted into the best times list,
//or -1 if the time didn't make it onto the list.
+ (int) notinsertBestTime:(double) time {
	NSMutableArray* times = [[NSMutableArray alloc] 
				initWithArray:[RingsState bestTimes]];
	int retval = -1;
	//since times is already sorted, we need to find the first stored time that is
	//greater than the passed in time.
	for(int i=0;i<[times count];i++){
		if(time < [[times objectAtIndex:i] doubleValue]){
			//found the right insertion point, so insert.
			[times insertObject:[NSNumber numberWithDouble:time] atIndex:i];
			retval = i;
			break;
		}
	}
	//if we didn't beat any existing times, but there's room on the bottom, 
	//then insert there.
	if(retval == -1 && [times count] < MAX_TIMES){
		retval = [times count];
		[times insertObject:[NSNumber numberWithDouble:time] 
					atIndex:[times count]];
	}
	//if we inserted into a full list, then we need to bump off the 
	//times from the bottom.
	while ([times count] > MAX_TIMES){
		[times removeLastObject];
	}
	//dump the table back to persistent storage
	[g_ResManager storeUserData:times toFile:@"bestTimes"];
	return retval;
}

//returns the slot where time has been inserted into the best times list,
//or -1 if the time didn't make it onto the list.
+ (int) insertBestTime:(double) time {
	NSMutableArray* times = [NSMutableArray
							 arrayWithArray: [RingsState bestTimes]];
	NSNumber* timeNumber = [NSNumber numberWithDouble:time];
	//drop the time into the list, and then sort it
	[times addObject:timeNumber];
	[times sortUsingSelector: @selector(compare:)];
	
	//if we now have too many items in the list, we need to bump off the
	//times from the bottom
	if([times count] > MAX_TIMES){
		NSRange range = NSMakeRange(MAX_TIMES, [times count] - MAX_TIMES);
		[times removeObjectsInRange: range];
	}
	
	//find out where we inserted the number.
	NSUInteger index = [times indexOfObject: timeNumber];

	//if the number isn't in there, it must not have been good
	//enough, so return -1
	int retval = (NSNotFound == index) ? -1 : index;
	
	//dump the table back to persistent storage
	[g_ResManager storeUserData:times toFile:@"bestTimes"];
	return retval;
}

@end
