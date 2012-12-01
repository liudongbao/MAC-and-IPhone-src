//
//  Cell.m
//  TicTacToe
//
//  Created by Swipe Interactive on 3/10/09.
//  Copyright Swipe Interactive 2009. All rights reserved.
//

#import "Cell.h"

// TicTacToe Cell UIView

@implementation Cell

-(id)initWithHPos:(NSInteger)i vPos:(NSInteger)j 
		   sender:(TicTacToeViewController *)sender 
{
	
	viewController = sender;
	
	[self initWithFrame:CGRectMake(i*100 + 10, j*100 + 10, 100, 100)];
	
	self.multipleTouchEnabled = NO;
	[self setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:1.0]];
	
	// UIView tag used to identify cell
	self.tag = j*3 + i + 1;
	
	cellTappedLocal = NO;
	cellTappedRemote = NO;
	
	return self;
	
}

-(void)remoteTap {
	
	cellTappedRemote = YES;
	[self setNeedsDisplay];
	
}

-(void)clearCell {
	cellTappedLocal = NO;
	cellTappedRemote = NO;
	[self setNeedsDisplay];
}

- (void) touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	
	if(!cellTappedLocal && !cellTappedRemote) 
		if([viewController tappedCell:[self tag]]) {
			cellTappedLocal = YES;
			[self setNeedsDisplay];
		}
	
}

- (void)drawRect:(CGRect)rect {
	
	// Draw box around cell so we can see it
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetLineWidth(context,1.0);
	CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
	CGContextSetLineCap(context, kCGLineCapRound);
	CGContextAddRect(context, CGRectMake(1, 1, 98, 98));
	CGContextStrokePath(context);
	
	// put relevant mark in cell if tapped
	if(cellTappedLocal) {
		
		[[NSString stringWithString:@"X"] 
         drawInRect:self.bounds 
		 withFont:[UIFont boldSystemFontOfSize:100.0] 
		 lineBreakMode:0 
		 alignment:UITextAlignmentCenter];
		
	} else if (cellTappedRemote) {
		
		[[NSString stringWithString:@"O"] 
         drawInRect:self.bounds 
		 withFont:[UIFont boldSystemFontOfSize:100.0] 
		 lineBreakMode:0 
		 alignment:UITextAlignmentCenter];
		
	}
	
}

- (void)dealloc {
	[super dealloc];
}

@end