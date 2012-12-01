//
//  BBTexturedButton.h
//  SpaceRocks
//
//  Created by ben smith on 14/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BBButton.h"


@interface BBTexturedButton : BBButton {
	BBTexturedQuad * upQuad;
	BBTexturedQuad * downQuad;
}

- (id) initWithUpKey:(NSString*)upKey downKey:(NSString*)downKey;
- (void) dealloc;
- (void)awake;
- (void)setNotPressedVertexes;
- (void)setPressedVertexes;
- (void)update;

// 6 methods


@end
