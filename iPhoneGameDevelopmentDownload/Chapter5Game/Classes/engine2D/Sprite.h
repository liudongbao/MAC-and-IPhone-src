//
//  Sprite.h
//  Chapter3 Framework
//
//  Created by Joe Hogue on 5/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Animation;

@interface Sprite : NSObject {
	Animation* anim;
	NSString* sequence;
	float sequence_time;
	int currentFrame;
}

@property (nonatomic, retain) Animation* anim;
@property (nonatomic, retain) NSString* sequence;
@property (nonatomic, readonly) int currentFrame; //made accessible for Rideable
 
+ (Sprite*) spriteWithAnimation:(Animation*) anim;
- (void) drawAtPoint:(CGPoint) point;
- (void) update:(float) time;

@end
