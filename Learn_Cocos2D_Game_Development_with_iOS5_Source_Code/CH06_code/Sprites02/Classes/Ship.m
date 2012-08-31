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
#import "Bullet.h"
#import "GameScene.h"

@interface Ship (PrivateMethods)
-(id) initWithShipImage;
@end


@implementation Ship

+(id) ship
{
	return [[[self alloc] initWithShipImage] autorelease];
}

-(id) initWithShipImage
{
	if ((self = [super initWithFile:@"ship.png"]))
	{
        // call "update" for every frame
		[self scheduleUpdate];
	}
	return self;
}

-(void) update:(ccTime)delta
{
	// keep creating new bullets
	Bullet* bullet = [Bullet bulletWithShip:self];
	
	// add the bullets to the ship's parent, otherwise moving the ship would cause all flying bullets
	// to mimic the ship's movement
	CCNode* gameScene = [self parent];
	[gameScene addChild:bullet z:0 tag:GameSceneNodeTagBullet];
}

@end
