//
//  Tom.h
//  Chapter3 Framework
//
//  Created by Joe Hogue on 6/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Entity.h"

//we coould use the state string names, but the enum is useful for switch blocks.
typedef enum LionState {
	ASLEEP = 0,
	WAKING,
	ALERT,
	ATTACKING
} LionState;

@interface Lion : Entity {
	LionState state;
	float state_time; //how long we have been in current state.  set in setstate, incremented in update.
	int m_rage; //roughly how long a player has been too close to the lion.  incremented in wakeagainst, used to increment state
	bool flip;
}

- (id) initWithPos:(CGPoint) pos sprite:(Sprite*)spr facingLeft:(bool)faceleft;
- (bool) wakeAgainst:(Entity*) other;
- (void) obstruct;

@end
