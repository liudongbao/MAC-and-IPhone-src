//
//  Tom.h
//  Chapter3 Framework
//
//  Created by Joe Hogue on 6/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Entity.h"
#import "Rideable.h"

@interface Tom : Entity {
	CGPoint destPos; //tom-specific
	
	bool inJump; //set to true in jump call, used in update for special animation.  reset in update after jump is completed.
	Rideable* riding; //specific to main character in croc level... specifies which entity we are riding on.
	
	int last_direction; //specifies which idle animation we should go into after we stop moving.
	bool celebrating; //used at end of level.
	bool dying; //this is the point where joe thinks he should have made a state for the character, instead of adding more bool flags when features creep.
}

@property (nonatomic, readonly) Rideable* riding;
@property (nonatomic) bool celebrating;

- (void) moveToPosition:(CGPoint) point; //tom-specific
- (id) initWithPos:(CGPoint) pos sprite:(Sprite*)spr;
- (bool) doneMoving;

//specific to croc level.
- (void) jump;
@property (nonatomic, readonly) bool inJump;

//used on player death.  Caller can pass in special death animations per situation, such as drowning or mauling.
- (void) dieWithAnimation:(NSString*) deathanim;

@end
