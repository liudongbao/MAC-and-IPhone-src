//
//  Ball.m
//  GKPong
//
//  Created by Peter Bakhyryev on 6/18/09.
//  Copyright 2009 ByteClub LLC. All rights reserved.
//

#import "Ball.h"
#import "Paddle.h"

// Constants
#define MIN_BOUNCE_ANGLE ((30.0/180.0) * M_PI)
#define MIN_SPEED 4.0
#define MAX_SPEED 15.0


@implementation Ball

@synthesize direction, speed, delegate, view;
@synthesize fieldFrame, topPaddle, bottomPaddle;

- (id)initWithField:(CGRect)field topPaddle:(Paddle*)topP
    bottomPaddle:(Paddle*)bottomP {
  // create image of the ball
  view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ball.png"]];
  view.opaque = YES;
  alreadyBouncedOffPaddle = NO;
  alreadyBouncedOffWall = NO;
  
  self.fieldFrame = field;
  self.topPaddle = topP;
  self.bottomPaddle = bottomP;
  
  return self;
}

- (void)reset {
  alreadyBouncedOffPaddle = NO;
  alreadyBouncedOffWall = NO;
}

- (void)dealloc {
  [view removeFromSuperview];

  self.delegate = nil;
  self.topPaddle = nil;
  self.bottomPaddle = nil;

  [super dealloc];
}


#pragma mark Getters and setters

- (void)setCenter:(CGPoint)center {
  view.center = center;
}

- (CGPoint)center {
  return view.center;
}

- (void)setDirection:(float)newDirection {
  // Keep the values within range from 0 to 2.0 * M_PI
  if ( newDirection > 2.0 * M_PI ) {
    direction = fmod( newDirection, 2.0 * M_PI );
  }
  else if ( newDirection < 0 ) {
    direction = 2.0 * M_PI - (fmod(fabs(newDirection), 2.0 * M_PI));
  }
  else {
    direction = newDirection;
  }
}


#pragma mark Movement

- (void)bounceBallOffPaddle:(Paddle*)paddle {
  // Figure out which way it will go. Depends on which paddle we are bouncing off
  float verticalDirection = (paddle == topPaddle)?1.0:-1.0;
  
  self.direction = 2.0 * M_PI - direction;
  alreadyBouncedOffPaddle = YES;

  if ( paddle.speed != 0.0 ) {
    // add paddle movement vector
    float pX = paddle.speed;
    float pY = verticalDirection; // a bit of vertical momentum
    float bX = -speed * cos(direction);
    float bY = -speed * sin(direction);
    self.speed = hypot( bX + pX, bY + pY );
    self.direction = atan2f( bY + pY, bX + pX ) + M_PI;

    // Make sure that the angle of the bounce is not too "flat"
    float minAngle = (M_PI_2 + verticalDirection * M_PI_2 + MIN_BOUNCE_ANGLE);
    float maxAngle = (M_PI + M_PI_2 + verticalDirection * M_PI_2 - MIN_BOUNCE_ANGLE);
    
    if ( direction < minAngle ) {
      direction = minAngle;
    }
    else if ( direction > maxAngle ) {
      direction = maxAngle;
    }
    
    // Make sure the ball is not too slow
    if ( speed < MIN_SPEED ) {
      speed = MIN_SPEED;
    }
    else if ( speed > MAX_SPEED ) {
      speed = MAX_SPEED;
    }
  }
}

- (void)processOneFrame {
  // Recalculate our position
  CGPoint ballPosition = view.center;

  ballPosition.x -= speed * cos(direction);
  ballPosition.y -= speed * sin(direction);
  view.center = ballPosition;

  // Are we hitting the wall on the right?
  if ( ballPosition.x >= (fieldFrame.size.width - view.frame.size.width/2) ) {
    if ( !alreadyBouncedOffWall ) {
      self.direction = M_PI - direction;
      alreadyBouncedOffWall = YES;
    }
  }
  // Are we hitting the wall on the left?
  else if ( ballPosition.x <= view.frame.size.width/2 ) {
    if ( !alreadyBouncedOffWall ) {
      self.direction = M_PI - direction;
      alreadyBouncedOffWall = YES;
    }
  }
  else {
    alreadyBouncedOffWall = NO;
  }

  // If we have moved out of the bouncing zone, reset "already bounced" flag
  if ( alreadyBouncedOffPaddle &&
      ballPosition.y + view.frame.size.height/2 < bottomPaddle.frame.origin.y &&
      ballPosition.y - view.frame.size.height/2 > topPaddle.frame.origin.y +
      topPaddle.frame.size.height) {
    alreadyBouncedOffPaddle = NO;
  }

  // Are we moving past bottom paddle?
  if ( ballPosition.y + view.frame.size.height/2 >= (bottomPaddle.frame.origin.y) &&
      ! alreadyBouncedOffPaddle ) {
    // Bounce or miss?
    if ( ballPosition.x + view.frame.size.width/2 > bottomPaddle.frame.origin.x &&
        ballPosition.x - view.frame.size.width/2 < bottomPaddle.frame.origin.x +
        bottomPaddle.frame.size.width ) {
      [self bounceBallOffPaddle:bottomPaddle];
      [delegate ballBounced];
    }
    else {
      // We missed the paddle
      [delegate ballMissedPaddle:bottomPaddle];
    }
  }
}

@end
