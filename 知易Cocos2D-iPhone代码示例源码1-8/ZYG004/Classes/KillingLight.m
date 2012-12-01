//
//  KillingLight.m
//  G05
//
//  Created by zhu yi on 9/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "KillingLight.h"


@implementation KillingLight

+(id)KillingLightWithRect:(CGRect)rect spriteManager:(CCSpriteSheet*)manager
{
	id rtn = [[[self alloc] initWithTexture:manager.texture rect:rect] autorelease];
	
	return rtn;
}

- (CGRect)rect
{
	// NSLog([self description]);
	return CGRectMake(-rect_.size.width / 2, -rect_.size.height / 2, rect_.size.width, rect_.size.height);
}

- (void)onEnter
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
	[super onEnter];
}

- (void)onExit
{
	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
	[super onExit];
}	

- (BOOL)containsTouchLocation:(UITouch *)touch
{
	CGPoint pt = [self convertTouchToNodeSpaceAR:touch];
	NSLog([NSString stringWithFormat:@"Rect x=%.2f, y=%.2f, width=%.2f, height=%.2f, Touch point: x=%.2f, y=%.2f", self.rect.origin.x, self.rect.origin.y, self.rect.size.width, self.rect.size.height, pt.x, pt.y]); 
	
	return CGRectContainsPoint(self.rect, [self convertTouchToNodeSpaceAR:touch]);
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	if ( ![self containsTouchLocation:touch] ) return NO;
	
	return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	
	CGPoint touchPoint = [touch locationInView:[touch view]];
	touchPoint = [[CCDirector sharedDirector] convertToGL:touchPoint];
	
	self.position = CGPointMake(touchPoint.x, touchPoint.y);
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
}

- (void) dealloc
{
//	[[CCTouchDispatcher sharedDispatcher] removeDelegate:self];

	[super dealloc];
}

@end
