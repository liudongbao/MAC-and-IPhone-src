//
//  Paddle.h
//  GKPong
//
//  Created by Peter Bakhyryev on 6/23/09.
//  Copyright 2009 ByteClub LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Paddle;

@interface Paddle : NSObject {
  // Image of the paddle
  UIImageView *view;

  // Average speed calculator
  float frameSpeedAccumulator;
  float speedSamples[3];
  int nextSampleIndex;
}

// Properties
@property (nonatomic,readonly,getter=speed) float speed;
@property (nonatomic,readonly,getter=frame) CGRect frame;
@property (nonatomic,setter=setCenter:,getter=center) CGPoint center;
@property (nonatomic,readonly) UIImageView *view;

// Methods
- (void)processOneFrame;
- (void)moveHorizontallyByDistance:(float)distance inViewFrame:(CGRect)parentViewFrame;
 
@end
