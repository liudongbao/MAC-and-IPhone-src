//
//  Animation.h
//  Chapter3 Framework
//
//  Created by Joe Hogue on 6/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

/*
 Animation will hold a set of related animation frames, such as the frames in a single walk cycle.
 Animation does not hold the current state of that animation; this way, more than one Sprite can share the frame information stored in an Animation.
 */

#import <Foundation/Foundation.h>

@interface AnimationSequence : NSObject
{
	@public
	int frameCount;
	float* timeout;
	CGRect* frames;
	bool flipped;
	NSString* next;
}

- (AnimationSequence*) initWithFrames:(NSDictionary*) animData width:(float) width height:(float) height;

@end


@interface Animation : NSObject {
	NSString* image;
	NSMutableDictionary* sequences;
	CGPoint anchor;
}

//@property (readonly) int frameCount;

//- (Animation*) initWithImage:(NSString*) img frameSize:(int) frameSize frames:(NSArray*) framesData;
//- (void) drawAtPoint:(CGPoint) point withFrame:(int)frame;
- (Animation*) initWithAnim:(NSString*) img;
- (void) drawAtPoint:(CGPoint) point withSequence:(NSString*) sequence withFrame:(int) frame;

-(int) getFrameCount:(NSString*) sequence;
-(NSString*) firstSequence;

-(AnimationSequence*) get:(NSString*) sequence;

@end
