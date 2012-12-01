//
//  Rideable.h
//  Chapter3 Framework
//
//  Created by Joe Hogue on 6/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Entity.h"

@interface Rideable : Entity {
	CGRect bounds;
	Entity* m_rider;
	int sunkframe;
}

- (bool) under:(CGPoint) point;
- (void) markRidden:(Entity*) rider;

@end
