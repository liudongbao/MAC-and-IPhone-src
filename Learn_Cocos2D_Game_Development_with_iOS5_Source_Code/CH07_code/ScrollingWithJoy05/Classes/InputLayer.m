//
//  InputLayer.m
//  ScrollingWithJoy
//
//  Created by Steffen Itterheim on 04.08.10.
//
//  Updated by Andreas Loew on 20.06.11:
//  * retina display
//  * framerate independency
//  * using TexturePacker http://www.texturepacker.com
//
//  Copyright Steffen Itterheim and Andreas Loew 2010-2011. 
//  All rights reserved.
//

#import "InputLayer.h"

@interface InputLayer (PrivateMethods)
-(void) addFireButton;
@end


@implementation InputLayer

-(id) init
{
	if ((self = [super init]))
	{
		[self addFireButton];
		
		[self scheduleUpdate];
	}
	
	return self;
}

-(void) dealloc
{
	[super dealloc];
}

-(void) addFireButton
{
	float buttonRadius = 80;
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	
	fireButton = [[[SneakyButton alloc] initWithRect:CGRectZero] autorelease];
	fireButton.radius = buttonRadius;
	fireButton.position = CGPointMake(screenSize.width - buttonRadius, buttonRadius);
	[self addChild:fireButton];
}

-(void) update:(ccTime)delta
{
	if (fireButton.active)
	{
		CCLOG(@"FIRE!!!");
	}
}

@end
