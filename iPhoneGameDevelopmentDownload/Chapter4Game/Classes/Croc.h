//
//  Croc.h
//  Chapter3 Framework
//
//  Created by Joe Hogue on 6/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Entity.h"

@interface Croc : Entity {
	int direction; //will be -1 or 1, for pacing back and forth across the level.  speed probably hardcoded in update.
	CGRect bounds; //used for hit detection on jumping player.  probably could be recycled from rideable.
}

- (bool) under:(CGPoint)point;
- (void) attack:(Entity*) other;

@end
