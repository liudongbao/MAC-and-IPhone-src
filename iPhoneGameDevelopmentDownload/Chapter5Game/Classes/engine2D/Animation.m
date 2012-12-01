//
//  Animation.mm
//  Chapter3 Framework
//
//  Created by Joe Hogue on 6/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Animation.h"
#import "ResourceManager.h"

@implementation AnimationSequence

- (AnimationSequence*) initWithFrames:(NSDictionary*) animData width:(float) width height:(float) height{
	[super init];
	NSArray* framesData = [[animData valueForKey:@"anim"] componentsSeparatedByString:@","];
	NSArray* timeoutData = [[animData valueForKey:@"time"] componentsSeparatedByString:@","]; //will be nil if "time" is not present.
	bool flip = [[animData valueForKey:@"flipHorizontal"] boolValue];
	self->next = [[animData valueForKey:@"next"] retain];
	frameCount = [framesData count];
	frames = malloc(frameCount*sizeof(CGRect));
	flipped = flip;
	for(int i=0;i<frameCount;i++){
		//find where the frame is located.  this is trivial when all frames are in a straight strip,
		//but our opengl textures are limited to 1024 pixels in a dimension, so we have to wrap around
		//for longer animations.
		//assumes that width is an even multiple of 1024.
		int frame = [[framesData objectAtIndex:i] intValue];
		int x = (frame * (int)width) % 1024;
		int row = (( frame * width ) - x) / 1024;
		int y = row * height;
		frames[i] = CGRectMake(x, y, width, height);
	}
	timeout = NULL;
	//NSAssert(frameCount == [timeoutData count]);
	if(timeoutData){
		timeout = malloc(frameCount*sizeof(float));
		for(int i=0;i<frameCount;i++){
			timeout[i] = [[timeoutData objectAtIndex:i] floatValue] / 1000.0f;
			if(i > 0) timeout[i] += timeout[i-1];
		}
	}
	return self;
}

- (void) dealloc {
	free(frames);
	if(timeout) free(timeout);
	[self->next release];
	[super dealloc];
}

@end


@implementation Animation

- (Animation*) initWithAnim:(NSString*) img {
	NSData* pData;
	pData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Animations" ofType:@"plist"]];
    NSString *error;
    NSDictionary* animData;
    NSPropertyListFormat format;
    animData = [NSPropertyListSerialization propertyListFromData:pData  mutabilityOption:NSPropertyListImmutable format:&format errorDescription:&error];
	
	if(error){
		NSLog(@" plist read error %@", error);
		[error release];
	}
	
	animData = [animData objectForKey:img];
	//NSLog(@"found data %@ for img %@", animData, img);
	
	GLTexture *tex = [g_ResManager getTexture:img];
	image = img;

	float frameWidth, frameHeight;
	
	if([animData objectForKey:@"frameCount"]){
		int frameCount = [[animData objectForKey:@"frameCount"] intValue];
		//NSLog(@"frame count %d", frameCount);
		frameWidth = [tex width] / (float)frameCount;
		frameHeight = [tex height];
	}

	if([animData objectForKey:@"frameSize"]){
		NSArray* wh = [[animData objectForKey:@"frameSize"] componentsSeparatedByString:@"x"];
		frameWidth = [[wh objectAtIndex:0] intValue];
		frameHeight = [[wh objectAtIndex:1] intValue];
		NSLog(@" framesize read as %f, %f", frameWidth, frameHeight);
	}
	
	//anchor is the position in the image that is considered the center.
	//in pixels.  Relative to the bottom left corner.  Will typlcally be positive.
	//all frames in all sequences share the same anchor.
	NSString* anchorData = [animData valueForKey:@"anchor"];
	if(anchorData){
		NSArray* tmp = [anchorData componentsSeparatedByString:@","];
		anchor.x = [[tmp objectAtIndex:0] floatValue];
		anchor.y = [[tmp objectAtIndex:1] floatValue];
	}
	
	NSEnumerator *enumerator = [animData keyEnumerator];
	NSString* key;
	NSMutableDictionary* sequences_tmp = [NSMutableDictionary dictionaryWithCapacity:1];
	
	while ((key = [enumerator nextObject])) {

		//if([key isEqualToString:@"frameCount"]) continue; //might be cheaper than testing if objectforkey:key instanceof nsdictionary.
		//if([key isEqualToString:@"anchor"]) continue; //might be cheaper than testing if objectforkey:key instanceof nsdictionary.
		//if([key isEqualToString:@"frameSize"]) continue; //might be cheaper than testing if objectforkey:key instanceof nsdictionary.
		//NSLog(@" found key %@", key);
		
		NSDictionary* sequencedata = [animData objectForKey:key];
		if (![sequencedata isKindOfClass:[NSDictionary class]]) continue; //ok, the key string checks were getting out of hand. -joe
		
		//NSLog(@"flipped %d", [[sequencedata objectForKey:@"flipHorizontal"] boolValue]);
		
		AnimationSequence* tmp = [[AnimationSequence alloc] initWithFrames:sequencedata width:frameWidth height:frameHeight];
		
		[sequences_tmp setValue:[tmp autorelease] forKey:key];
	}
	
	sequences = [sequences_tmp retain];
	
	//NSLog(@" alloc'd sequences %@", sequences);
	
	return self;
}

-(int) getFrameCount:(NSString*) sequence{
	return ((AnimationSequence*)[sequences valueForKey:sequence])->frameCount;
}

-(AnimationSequence*) get:(NSString*) sequence {
	return (AnimationSequence*)[sequences valueForKey:sequence];
}

-(NSString*) firstSequence {
	return [[sequences allKeys] objectAtIndex:0];
}

- (void) drawAtPoint:(CGPoint) point withSequence:(NSString*) sequence withFrame:(int) frame{
	AnimationSequence* seq = [sequences valueForKey:sequence];
	CGRect currframe = seq->frames[frame];
	[[g_ResManager getTexture:image] 
	 drawInRect:CGRectMake(
						   point.x+(seq->flipped?currframe.size.width:0)-anchor.x, 
						   point.y-anchor.y, 
						   seq->flipped?-currframe.size.width:currframe.size.width, 
						   currframe.size.height) 
	 withClip:currframe 
	 withRotation:0];
}

- (void) dealloc {
	//NSLog(@" de-alloc'd sequences %@", sequences);
	[sequences removeAllObjects];
	[sequences release];
	[super dealloc];
}

@end
