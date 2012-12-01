//
//  AsteroidsView.m
//  Asteroids
//
//  Created by Scott Penberthy on 2/26/10.
//  Copyright 2010 North Highland Partners, Inc.. All rights reserved.
//

#import "AsteroidsView.h"
//#import "images.h"
#import "Defs.h"

@implementation AsteroidsView
@synthesize model;

- (void) useModel: (AsteroidsModel *) theModel
{
	//self.ship = [AtlasSprite fromFile: @"pacman.jpg" withRows: 8 withColumns: 8];
	//self.ship = [Sprite fromFile: @"sprites.jpg" withRows: 5 withColumns: 6];
	self.model = theModel;
	ready = YES;
}

- (void)drawRect:(CGRect)rect {
	if (!ready) return;
	
	// Get a graphics context, with no transformations
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	
	CGAffineTransform t0 = CGContextGetCTM(context);
	t0 = CGAffineTransformInvert(t0);
	CGContextConcatCTM(context,t0);
	
	[model.status draw: context];
	[model.lives draw: context];
	
    // Draw
	if (![AsteroidsModel getState: kGameOver]) {
		[[model myShip] draw: context];
	}
	
	NSMutableArray *rocks = [model rocks];
	for (Sprite *rock in rocks) {
		[rock draw: context];
	}
	
	NSMutableArray *bullets = [model bullets];
	for (Sprite *bullet in bullets) {
		[bullet draw: context];
	}

	[model.left draw: context];
	[model.right draw: context];
	[model.thrust draw: context];
	[model.fire draw: context];
	
	CGContextRestoreGState(context);
	
}

- (void) tic: (NSTimeInterval) dt
{
	if (!model) return;
	[self setNeedsDisplay];
}

- (void)dealloc {
    [super dealloc];
}


@end
