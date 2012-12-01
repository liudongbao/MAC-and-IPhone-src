//
//  Sprite.m
//  Chapter3 Framework
//
//  Created by Joe Hogue on 5/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Sprite.h"
#import "ResourceManager.h"
#import "Animation.h"

@implementation Sprite

@synthesize anim;
@synthesize sequence;
@synthesize currentFrame;

+ (Sprite*) spriteWithAnimation:(Animation*) anim {
	Sprite* retval = [[Sprite alloc] init];

	retval.anim = anim;
	retval.sequence = [retval.anim firstSequence];
	
	[retval autorelease];
	return retval;
}

- (void) drawAtPoint:(CGPoint) point {
	[anim drawAtPoint:point withSequence:sequence withFrame:currentFrame];
}

- (void) update:(float) time{
	AnimationSequence* seq = [anim get:sequence];
	//if(!seq) return; //should probably make a noisier error message here.  specified sequence does not exist.
	if(seq->timeout == NULL){
		currentFrame++;
		if(currentFrame >= [anim getFrameCount:sequence]) currentFrame = 0;
	} else {
		sequence_time += time;
		if(sequence_time > seq->timeout[seq->frameCount-1]){
			if(seq->next == nil){
				sequence_time -= seq->timeout[seq->frameCount-1];
			} else {
				self.sequence = seq->next;
			}
		}
		for(int i=0;i<seq->frameCount;i++){
			if(sequence_time < seq->timeout[i]) {
				currentFrame = i;
				break;
			}
		}
	}
}

- (void) setSequence:(NSString*) seq {
	[seq retain];
	[self->sequence release];
	self->sequence = seq;
	currentFrame = 0;
	sequence_time = 0;
}

- (void) dealloc {
	[anim release];
	[self->sequence release];
	[super dealloc];
}

@end
