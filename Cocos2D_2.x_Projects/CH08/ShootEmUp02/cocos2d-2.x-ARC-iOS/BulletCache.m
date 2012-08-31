//
//  BulletCache.m
//  ShootEmUp01
//
//  Created by Steffen Itterheim on 05.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BulletCache.h"
#import "Bullet.h"

@implementation BulletCache

-(id) init
{
    if ((self = [super init]))
    {
        // get any bullet image from the texture atlas we're using
        CCSpriteFrame* bulletFrame = [[CCSpriteFrameCache sharedSpriteFrameCache]
									  spriteFrameByName:@"bullet.png"];
		
        // use the bullet's texture
        batch = [CCSpriteBatchNode batchNodeWithTexture:bulletFrame.texture];
        [self addChild:batch];
        
        // Create a number of bullets up front and re-use them
        for (int i = 0; i < 200; i++)
        {
            Bullet* bullet = [Bullet bullet];
            bullet.visible = NO;
            [batch addChild:bullet];
        }
    }
    
    return self;
}

-(void) shootBulletFrom:(CGPoint)startPosition
			   velocity:(CGPoint)velocity 
			  frameName:(NSString*)frameName
{
    CCArray* bullets = batch.children;
    CCNode* node = [bullets objectAtIndex:nextInactiveBullet];
    NSAssert([node isKindOfClass:[Bullet class]], @"not a Bullet!");
    
    Bullet* bullet = (Bullet*)node;
    [bullet shootBulletFrom:startPosition velocity:velocity frameName:frameName];
    
    nextInactiveBullet++;
    if (nextInactiveBullet >= bullets.count)
    {
        nextInactiveBullet = 0;
    }
}
@end
