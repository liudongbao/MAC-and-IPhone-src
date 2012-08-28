//
//  Explode.m
//  Raiders
//
//  Created by James Sugrue on 1/10/11.
//  Copyright (c) 2011 SoftwareX Ltd. All rights reserved.
//

#import "Explode.h"
#import "Sprite.h"

@implementation Explode

@synthesize hasAnimationFinished;
@synthesize explosionPoint = _explosionPoint;

- (id)initWithPoint:(CGPoint)explosionPoint {
	self = [super init];
	if (self != nil) {
        _explosionPoint = explosionPoint;
        animationImages = [NSMutableArray array];
        
        for (int i = 1; i <= 8; i++) {
            NSString *spriteName = [NSString stringWithFormat:@"explode%d.png", i];
            Sprite *sprite = [[Sprite alloc] initWithImageNamed:spriteName];
            [animationImages addObject:sprite];
            [animationImages addObject:sprite];
        }
        
        animationIndex = 0;
        hasAnimationFinished = NO;
		
	}
	return self;
}

- (Sprite *)doAnimation {
    Sprite *sprite = [animationImages objectAtIndex:animationIndex];
    animationIndex++;
    
    if (animationIndex >= animationImages.count - 1) {
        hasAnimationFinished = YES;
    }
    
    return sprite;
}

- (Sprite *)currentSprite {
    Sprite *sprite = [animationImages objectAtIndex:animationIndex];
    return sprite;
}

@end
