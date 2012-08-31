/*********************************************************************
 *	
 *	Chipmunk Sprite
 *
 *	cpSprite.h
 *
 *	Chipmunk Sprite Object
 *
 *	http://www.mobile-bros.com
 *
 *	Created by Robert Blackwood on 04/24/2009.
 *	Copyright 2009 Mobile Bros. All rights reserved.
 *
 **********************************************************************/

#import "cocos2d.h"
#import "chipmunk.h"
#import "cpCCNode.h"

@interface cpCCSprite : CCSprite<cpCCNodeProtocol>
{
	CPCCNODE_MEM_VARS;
}

/*! Use if you do not want the sprite to rotate with the shape */
@property (readwrite,assign) BOOL ignoreRotation;

/*! If this is anything other than zero, a position change will update the
 shapes velocity using integrationDt to calculate it */
@property (readwrite,assign) cpFloat integrationDt;

/*! If this is set to true & spaceManager is set, then the shape
 is deleted when dealloc is called */
@property (readwrite,assign) BOOL autoFreeShape;

/*! The shape we're connected to */
@property (readwrite,assign) cpShape *shape;

/*! The space manager, set this if you want autoFreeShape to work */
@property (readwrite,assign) SpaceManager *spaceManager;

/*! Apply an impulse (think gun shot) to our shape's body */
-(void) applyImpulse:(cpVect)impulse;

/*! Apply a constant force to our shape's body */
-(void) applyForce:(cpVect)force;

/*! Reset any forces accrued on this shape's body */
-(void) resetForces;

/*! Return an autoreleased cpCCSprite */
+ (id) spriteWithShape:(cpShape*)shape file:(NSString*) filename;

/*! Return an autoreleased cpCCSprite who is an "spriteSheet" */
+ (id) spriteWithShape:(cpShape*)shape spriteSheet:(CCSpriteBatchNode*)spriteSheet rect:(CGRect)rect;

/*! Return an autoreleased cpCCSprite */
+ (id) spriteWithShape:(cpShape *)shape texture:(CCTexture2D*)texture;

/*! Return an autoreleased cpCCSprite who is an "spriteSheet" */
+ (id) spriteWithShape:(cpShape *)shape texture:(CCTexture2D*)texture rect:(CGRect)rect;

/*! Return an autoreleased cpCCSprite */
+ (id) spriteWithShape:(cpShape *)shape spriteFrameName:(NSString*)frameName;

/*! Return an autoreleased cpCCSprite */
+ (id) spriteWithShape:(cpShape *)shape SpriteFrame:(CCSpriteFrame*)spriteFrame;

/*! Return an autoreleased cpCCSprite */
+ (id) spriteWithShape:(cpShape *)shape batchNode:(CCSpriteBatchNode*)batchNode rect:(CGRect)rect;

/*! Return an autoreleased cpCCSprite */
+ (id) spriteWithShape:(cpShape *)shape batchNode:(CCSpriteBatchNode*)batchNode rectInPixels:(CGRect)rect;

/*! Initialization method for basic cpSprite */
- (id) initWithShape:(cpShape*)shape file:(NSString*) filename;

/*! Initialization method for "spriteSheet" cpCCSprite */
- (id) initWithShape:(cpShape*)shape spriteSheet:(CCSpriteBatchNode*)spriteSheet rect:(CGRect)rect;

/*! Initialization method for basic cpCCSprite, given a texture */
- (id) initWithShape:(cpShape *)shape texture:(CCTexture2D*)texture;

/*! Initialization method for "AtlasSprite" cpCCSprite */
- (id) initWithShape:(cpShape *)shape texture:(CCTexture2D*)texture rect:(CGRect)rect;

/*! Initialization method for basic cpCCSprite */
- (id) initWithShape:(cpShape *)shape spriteFrameName:(NSString*)spriteFrameName;

/*! Initialization method for basic cpCCSprite */
- (id) initWithShape:(cpShape *)shape spriteFrame:(CCSpriteFrame*)spriteFrame;

/*! Initialization method for basic cpCCSprite */
- (id) initWithShape:(cpShape *)shape batchNode:(CCSpriteBatchNode*)batchNode rect:(CGRect)rect;

/*! Initialization method for basic cpCCSprite */
- (id) initWithShape:(cpShape *)shape batchNode:(CCSpriteBatchNode*)batchNode rectInPixels:(CGRect)rect;

@end

#if CC_COMPATIBILITY_WITH_0_8
typedef cpCCSprite cpSprite;
#endif
