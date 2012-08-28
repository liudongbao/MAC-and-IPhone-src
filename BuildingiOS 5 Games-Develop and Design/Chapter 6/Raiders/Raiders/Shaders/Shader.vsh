//
//  Shader.vsh
//  Raiders
//
//  Created by James Sugrue on 14/08/11.
//  Copyright (c) 2011 SoftwareX Ltd. All rights reserved.
//

attribute vec4 position;
attribute vec2 texcoord;

uniform mat4 mvp;

varying mediump vec2 v_texcoord;

void main()
{
    gl_Position = mvp * position;
	v_texcoord=texcoord;
}
