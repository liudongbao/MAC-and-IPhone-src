//
//  Paddle.m
//  GKPong
//
//  Created by Peter Bakhyryev on 6/23/09.
//  Copyright 2009 ByteClub LLC. All rights reserved.
//

#import "Paddle.h"

// Constants
#define MAX_PADDLE_AVERAGE_SPEED 8.0


@implementation Paddle

@synthesize view;

- (id)init {
  // create image of the ball
  view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"paddle.png"]];
  view.opaque = YES;
  
  return self;
}

- (void)dealloc {
  [view removeFromSuperview];
  [super dealloc];
}


#pragma mark Getters and setters

// Calculate our speed based on a few recent samples
// Don't go over speed limit
- (float)speed {
  float averageSpeed = (speedSamples[0] + speedSamples[1] + speedSamples[2]) / 3.0;

  if ( fabs(averageSpeed) > MAX_PADDLE_AVERAGE_SPEED ) {
    averageSpeed = copysign(MAX_PADDLE_AVERAGE_SPEED, averageSpeed);
  }

  return averageSpeed;
}

// Our position is the position of the image view
- (CGRect)frame {
  return view.frame;
}

- (void)setCenter:(CGPoint)center {
  view.center = center;
}

- (CGPoint)center {
  return view.center;
}


#pragma mark Game loop

- (void)processOneFrame {
  // Record accumulated movement distance as speed
  speedSamples[nextSampleIndex] = frameSpeedAccumulator;
  
  // Start accumulating from scratch
  frameSpeedAccumulator = 0.0;
  
  // Keep rolling the sample index
  if ( ++nextSampleIndex > 2 ) {
    nextSampleIndex = 0;
  }
}


# pragma mark Movement

- (void)moveHorizontallyByDistance:(float)distance inViewFrame:(CGRect)parentViewFrame {
  // Accumulate movement
  frameSpeedAccumulator += distance;

  // Make sure we are not going too far past window's boundaries
  float destinationX = view.center.x + distance;
  
  if ( destinationX < 0 ) {
    destinationX = 0;
  }
  else if ( destinationX > parentViewFrame.size.width ) {
    destinationX = parentViewFrame.size.width;
  }

  // Only move our view if position has actually changed
  if ( destinationX != view.center.x ) {
    // Move view
    view.center = CGPointMake(destinationX, view.center.y);
  }
}

@end
