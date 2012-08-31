//
//  BodyNode.h
//  PhysicsBox2d
//
//  Created by Steffen Itterheim on 21.09.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Box2D.h"
#import "Helper.h"
#import "Constants.h"
#import "PinballTable.h"

@interface BodyNode : CCNode 
{
	b2Body* body;
	CCSprite* sprite;
}

@property (readonly, nonatomic) b2Body* body;
@property (readonly, nonatomic) CCSprite* sprite;

-(void) createBodyInWorld:(b2World*)world bodyDef:(b2BodyDef*)bodyDef fixtureDef:(b2FixtureDef*)fixtureDef spriteFrameName:(NSString*)spriteFrameName;

-(void) removeSprite;
-(void) removeBody;

@end
