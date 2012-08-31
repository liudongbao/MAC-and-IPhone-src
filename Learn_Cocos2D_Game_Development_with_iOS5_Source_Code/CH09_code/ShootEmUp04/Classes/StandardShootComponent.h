//
//  StandardShootComponent.h
//  ShootEmUp
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

#import <Foundation/Foundation.h>
#import "cocos2d.h"

// Why is it derived from CCSprite? Because enemies use a SpriteBatch, and CCSpriteBatchNode requires that all
// child nodes added to it are CCSprite. Under other circumstances I would use a CCNode as parent class of course, since
// the components won't have a texture and everything else that a Sprite has.
@interface StandardShootComponent : CCSprite 
{
	float updateCount;
	float shootFrequency;
	NSString* bulletFrameName;
	NSString* shootSoundFile;
}

@property (nonatomic) float shootFrequency;
@property (nonatomic, copy) NSString* bulletFrameName;
@property (nonatomic, copy) NSString* shootSoundFile;

@end
