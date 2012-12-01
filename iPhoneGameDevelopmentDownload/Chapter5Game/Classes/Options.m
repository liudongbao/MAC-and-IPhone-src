//
//  Options.m
//  Chapter5
//
//  Created by Joe Hogue on 7/26/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Options.h"
#import "gsMainMenu.h"
#import "ResourceManager.h"

@implementation Options

@synthesize subview;

- (void) loadOptions {
	invertY.on = [[g_ResManager getUserData:@"invertY.on"] boolValue];
	invertX.on = [[g_ResManager getUserData:@"invertX.on"] boolValue];
	NSString *calibratedata = [g_ResManager getUserData:@"calibrate"];
	NSArray *tmp = [calibratedata componentsSeparatedByString:@","];
	NSString *result = [NSString 
						stringWithFormat:@"x: %.2f, y: %.2f, z: %.2f", 
						[[tmp objectAtIndex:0] floatValue], 
						[[tmp objectAtIndex:1] floatValue], 
						[[tmp objectAtIndex:2] floatValue]
						];
	[calibrateResult setText:result];
	
}

- (Options*) initWithFrame:(CGRect)frame andManager:(GameStateManager*)pManager
{
	if (self = [super initWithFrame:frame andManager:pManager]) {
		[[NSBundle mainBundle] loadNibNamed:@"Options" owner:self options:nil];
		//add subview as... a subview.  This will let everything from the nib file show up on screen.
		[self addSubview:subview];
	}
	
	[self loadOptions];

	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / 100.0)];
	[[UIAccelerometer sharedAccelerometer] setDelegate:self]; //when we switch back to the main game state, we will need to re-aquire the accelerometer there.
	return self;
}

- (void) dealloc {
	[subview release];
	[super dealloc];
}

-(IBAction) invertY {
	[g_ResManager storeUserData:[NSNumber numberWithBool:invertY.on] toFile:@"invertY.on"];
}

-(IBAction) invertX {
	[g_ResManager storeUserData:[NSNumber numberWithBool:invertX.on] toFile:@"invertX.on"];
}

-(IBAction) calibrate {
	NSString *result = [NSString stringWithFormat:@"x: %.2f, y: %.2f, z: %.2f", accel[0], accel[1], accel[2]];
	[calibrateResult setText:result];
	[g_ResManager storeUserData:[NSString stringWithFormat:@"%f, %f, %f", accel[0], accel[1], accel[2]] toFile:@"calibrate"];
}

-(IBAction) done {
	[[UIAccelerometer sharedAccelerometer] setDelegate:nil]; //will crash if you don't reset the accelerometer delegate before freeing this game state.
	[m_pManager doStateChange:[gsMainMenu class]];
}

+ (void) setupDefaults {
	//called on first run and on user-initiated data reset.
	[g_ResManager storeUserData:[NSNumber numberWithBool:true] toFile:@"invertY.on"];
	[g_ResManager storeUserData:[NSNumber numberWithBool:false] toFile:@"invertX.on"];
	[g_ResManager storeUserData:[NSString stringWithFormat:@"%f, %f, %f", 0.0f, 0.0f, -1.0f] toFile:@"calibrate"];
}

-(IBAction) defaults {
	[Options setupDefaults];
	[self loadOptions];
}

#define kFilteringFactor			0.1
- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{
	//Use a basic low-pass filter to only keep the gravity in the accelerometer values
	accel[0] = acceleration.x * kFilteringFactor + accel[0] * (1.0 - kFilteringFactor);
	accel[1] = acceleration.y * kFilteringFactor + accel[1] * (1.0 - kFilteringFactor);
	accel[2] = acceleration.z * kFilteringFactor + accel[2] * (1.0 - kFilteringFactor);
}

@end
