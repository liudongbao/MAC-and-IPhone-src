//
//  Tom.h
//  Chapter3 Framework
//
//  Created by Joe Hogue on 6/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Entity.h"

@interface MazeButton : Entity {
	int color;
}

- (id) initWithPos:(CGPoint) pos sprite:(Sprite*)spr color:(int)col;
//used to trigger the pressed animation.
- (void) press;
//used to determine if this button is under the specified entity
- (bool) under:(Entity*)other;

@end
