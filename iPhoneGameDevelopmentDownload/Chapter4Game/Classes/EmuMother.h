//
//  EmuMother.h
//  Chapter3 Framework
//
//  Created by Joe Hogue on 6/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Emu.h"

typedef enum EmuMotherState {
	EM_WALKING = 0,
	EM_IDLING,
} EmuMotherState;

//making EmuMother a subclass of Emu, because i just want emu's update method.
@interface EmuMother : Emu{
	EmuMotherState state;
	float state_timeout; //set with state, decremented in update, triggers state change when expired.
	CGRect bounds; //where we will wander around.
}

@end
