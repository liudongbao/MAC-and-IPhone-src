//
//  gsMain.m
//  Test_Framework
//
//  Created by Paul Zirkle on 2/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "gsMain.h"
#import <UIKit/UIView.h>

#include "ExampleAppDelegate.h"

@implementation gsMain

//NOTE: -(id) init {}  is NOT called on GameStates, because initWithFrame is always used to initialize them

-(gsMain*) initWithFrame:(CGRect)frame andManager:(GameStateManager*)pManager
{

	if (self = [super initWithFrame:frame andManager:pManager]) {
		NSLog(@"gsMain init");

		[self setNeedsDisplay]; //note: do not use the (BOOL) param here, that is for OSX and NOT the iPhone
	}

	return self;
}

-(void)drawRect:(CGRect)rect
{
	NSLog(@"gsMain drawRect");
	
	//if we make gsMain manually (ie, outside of a xib), we have to draw stuff so the text shows up. 
	CGContextRef g = UIGraphicsGetCurrentContext();
	
	//fill background with gray color
	CGContextSetFillColorWithColor(g, [UIColor grayColor].CGColor);
	CGContextFillRect(g, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height));
	
	//text is anchored at the bottom left, even though the drawing coordinate start at top left.
	CGContextSetFillColorWithColor(g, [UIColor blackColor].CGColor);
	[@"test" drawAtPoint:CGPointMake(10.0,20.0) withFont:[UIFont systemFontOfSize:[UIFont systemFontSize]]];
}

-(void) Update
{
	NSLog(@"gsMain update");
}

-(void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
	UITouch* touch = [touches anyObject];
	NSUInteger numTaps = [touch tapCount];
	if( numTaps > 1 ) {
		//todo: [m_pManager doStateChange:[gsTest class]]; //switch to new states like this
	}
	
}

@end
