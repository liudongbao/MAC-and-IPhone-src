//
//  BBTexturedMesh.m
//  SpaceRocks3D
//
//  Created by ben smith on 15/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BBTexturedMesh.h"


@implementation BBTexturedMesh

@synthesize normals, uvCoordinates, materialKey;

// called once every frame
-(void)render
{
	[[BBMaterialController sharedMaterialController] bindMaterial:materialKey];
	
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnableClientState(GL_NORMAL_ARRAY);
  glDisableClientState(GL_COLOR_ARRAY);
	
	glVertexPointer(vertexSize, GL_FLOAT, 0, vertexes);
  glTexCoordPointer(2, GL_FLOAT, 0, uvCoordinates);
  glNormalPointer(GL_FLOAT, 0, normals);
  glDrawArrays(renderStyle, 0, vertexCount);
}
@end
