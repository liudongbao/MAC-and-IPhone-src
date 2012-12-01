//
//  BBTexturedQuad.h
//  SpaceRocks
//
//  Created by ben smith on 14/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BBMesh.h"
#import "BBMaterialController.h"


@interface BBTexturedQuad : BBMesh {
	GLfloat * uvCoordinates;
	NSString * materialKey;
}

@property (assign) GLfloat * uvCoordinates;
@property (retain) NSString * materialKey;


@end
