//
//  BBParticle.h
//  SkateDude
//
//  Created by ben smith on 28/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BBPoint.h"


@interface BBParticle : NSObject {
  BBPoint position;
	BBPoint velocity;
	CGFloat life;
	CGFloat decay;
	CGFloat size;
	CGFloat grow;
}

@property (assign) BBPoint position;
@property (assign) BBPoint velocity;

@property (assign) CGFloat life;
@property (assign) CGFloat size;
@property (assign) CGFloat grow;
@property (assign) CGFloat decay;

-(void)update;

@end
