//
//  BBTexturedMesh.h
//  SpaceRocks3D
//
//  Created by ben smith on 15/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BBMesh.h"
#import "BBMaterialController.h"

@interface BBTexturedMesh : BBMesh {
	GLfloat * uvCoordinates;
	GLfloat * normals;
	NSString * materialKey;
}

@property (assign) GLfloat * uvCoordinates;
@property (assign) GLfloat * normals;
@property (retain) NSString * materialKey;

@end
