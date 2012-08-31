//
//  PhysicsSprite.h
//  cocos2d-2.x-Chipmunk-ARC-iOS
//
//  Created by Steffen Itterheim on 18.05.12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "cocos2d.h"
#import "chipmunk.h"

@interface PhysicsSprite : CCSprite
{
	cpBody* physicsBody;
}

@property cpBody* physicsBody;

-(void) setPhysicsBody:(cpBody*)body;

@end