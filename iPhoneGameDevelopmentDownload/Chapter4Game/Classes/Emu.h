//
//  Emu.h
//  Chapter3 Framework
//
//  Created by Joe Hogue on 6/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Entity.h"

@interface Emu : Entity {
	CGPoint worldSpeed;
	CGPoint nextSpeed;
	CGPoint collision_tweak;
	bool runawaymode;
}

@property (nonatomic) bool runawaymode;

- (id) initWithPos:(CGPoint) pos sprite:(Sprite*)spr;
-(void) flockAgainst:(Emu**) others count:(int)count;
- (void) avoid:(Entity*) other;
- (void) goal:(Entity*) other;
- (void) update:(CGFloat) time;

@end
