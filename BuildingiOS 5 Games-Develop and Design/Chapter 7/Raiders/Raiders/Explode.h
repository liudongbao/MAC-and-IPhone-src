//
//  Explode.h
//  Raiders
//
//  Created by James Sugrue on 1/10/11.
//  Copyright (c) 2011 SoftwareX Ltd. All rights reserved.
//
#import "Sprite.h"

@interface Explode : NSObject {
    NSMutableArray *animationImages;
    int animationIndex;
    CGPoint _explosionPoint;
}

@property (assign) BOOL hasAnimationFinished;
@property (readonly) CGPoint explosionPoint;
@property (nonatomic, readonly) Sprite *currentSprite;

- (id)initWithPoint:(CGPoint)explosionPoint;
- (Sprite *)doAnimation;

@end
