//
//  Ball.h
//  GKPong
//
//  Created by Peter Bakhyryev on 6/18/09.
//  Copyright 2009 ByteClub LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Ball, Paddle;

// Our delegate
@protocol BallDelegate
- (void)ballMissedPaddle:(Paddle*)paddle;
@end


@interface Ball : NSObject {
  // Image of the ball
  UIImageView *view;

  // Direction of the ball: Radian values between 0 and 2 * M_PI
  float direction;
  
  // Speed of the ball: Number of pixels it will move by during each iteration of the game loop
  float speed;
  
  // Whether or not ball needs to bounce again
  BOOL alreadyBouncedOffPaddle;
  BOOL alreadyBouncedOffWall;
  
  // Configuration of the playing field
  CGRect fieldFrame;
  Paddle *topPaddle;
  Paddle *bottomPaddle;
  
  // Our delegate
  id<BallDelegate> delegate;
}

// Properties
@property (nonatomic,setter=setDirection:) float direction;
@property (nonatomic,assign) float speed;
@property (nonatomic,setter=setCenter:,getter=center) CGPoint center;
@property (nonatomic,readonly) UIImageView *view;
@property (nonatomic,retain) id<BallDelegate> delegate;
@property (nonatomic,assign) CGRect fieldFrame;
@property (nonatomic,retain) Paddle *topPaddle;
@property (nonatomic,retain) Paddle *bottomPaddle;

// Methods
- (void)processOneFrame;
- (void)reset;
- (id)initWithField:(CGRect)fieldFrame topPaddle:(Paddle*)paddle bottomPaddle:(Paddle*)bottomPaddle;

@end
