//
//  Ship.m
//  SpriteBatches
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

#import "Ship.h"

@implementation Ship

+(id) ship
{
	return [[[self alloc] init] autorelease];
}

-(id) init
{
	CCLOG(@"Ship init called ... this will repeat infinetely.");
	
	// WARNING: this will cause an infinite loop!
	// Reason: [super initWithFile:...] will call -(id) init which is overridden here ... repeat ad infinitum
	// Fix: rename this init method, for example initWithShipImage
	// Tip: never call anything but [super init] in your class' init method. If you call any initWith* method
	// then you should never do this from the -(id) init method.
	if ((self = [super initWithFile:@"ship.png"]))
	{
		[self scheduleUpdate];
	}
	return self;
}

-(void) update:(ccTime)delta
{
	// keep creating new bullets	
}

@end
