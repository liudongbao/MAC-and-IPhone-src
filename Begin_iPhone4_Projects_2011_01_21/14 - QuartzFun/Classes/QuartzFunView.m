//
//  QuartzFunView.m
//  QuartzFun
//
//  Created by Dave Mark on 12/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "QuartzFunView.h"
#import "UIColor-Random.h"

@implementation QuartzFunView
@synthesize firstTouch;
@synthesize lastTouch;
@synthesize currentColor;
@synthesize shapeType;
@synthesize drawImage;
@synthesize useRandomColor;
@synthesize redrawRect;

- (CGRect)currentRect {
    return CGRectMake (firstTouch.x,
                       firstTouch.y,
                       lastTouch.x - firstTouch.x,
                       lastTouch.y - firstTouch.y);
}

- (id)initWithCoder:(NSCoder*)coder {
    if (self = [super initWithCoder:coder]) {
        currentColor = [[UIColor redColor] retain];
        useRandomColor = NO;
        if (drawImage == nil) {
            drawImage = [[UIImage imageNamed:@"iphone.png"] retain];
        }
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    if (currentColor == nil)
        self.currentColor = [UIColor redColor];
	
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2.0);
    CGContextSetStrokeColorWithColor(context, currentColor.CGColor);
	
    CGContextSetFillColorWithColor(context, currentColor.CGColor);
	
    switch (shapeType) {
        case kLineShape:
            CGContextMoveToPoint(context, firstTouch.x, firstTouch.y);
            CGContextAddLineToPoint(context, lastTouch.x, lastTouch.y);
            CGContextStrokePath(context);
            break;
        case kRectShape:
            CGContextAddRect(context, self.currentRect);
            CGContextDrawPath(context, kCGPathFillStroke);
            break;
        case kEllipseShape:
            CGContextAddEllipseInRect(context, self.currentRect);
            CGContextDrawPath(context, kCGPathFillStroke);
            break;
        case kImageShape: {
            CGFloat horizontalOffset = drawImage.size.width / 2;
            CGFloat verticalOffset = drawImage.size.height / 2;
            CGPoint drawPoint = CGPointMake(lastTouch.x - horizontalOffset,
											lastTouch.y - verticalOffset);
            [drawImage drawAtPoint:drawPoint];
            break;
        }
        default:
            break;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (useRandomColor) {
        self.currentColor = [UIColor randomColor];
    }
    UITouch *touch = [touches anyObject];
    firstTouch = [touch locationInView:self];
    lastTouch = [touch locationInView:self];
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    lastTouch = [touch locationInView:self];
	
	if (shapeType == kImageShape) {
		CGFloat horizontalOffset = drawImage.size.width / 2;
		CGFloat verticalOffset = drawImage.size.height / 2;
		redrawRect = CGRectUnion(redrawRect, 
								 CGRectMake(lastTouch.x - horizontalOffset,
											lastTouch.y - verticalOffset, drawImage.size.width, 
											drawImage.size.height));
	}
	else
		redrawRect = CGRectUnion(redrawRect, self.currentRect);
	redrawRect = CGRectInset(redrawRect, -2.0, -2.0);
	[self setNeedsDisplayInRect:redrawRect];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    lastTouch = [touch locationInView:self];
	
	if (shapeType == kImageShape) {
		CGFloat horizontalOffset = drawImage.size.width / 2;
		CGFloat verticalOffset = drawImage.size.height / 2;
		redrawRect = CGRectUnion(redrawRect,
								 CGRectMake(lastTouch.x - horizontalOffset,
											lastTouch.y - verticalOffset, drawImage.size.width,
											drawImage.size.height));
    }
    redrawRect = CGRectUnion(redrawRect, self.currentRect);
    [self setNeedsDisplayInRect:redrawRect];
}

- (void)dealloc {
    [currentColor release];
    [drawImage release];
    [super dealloc];
}

@end
