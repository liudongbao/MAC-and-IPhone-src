//
//  Shader.fsh
//  Raiders
//
//  Created by James Sugrue on 14/08/11.
//  Copyright (c) 2011 SoftwareX Ltd. All rights reserved.
//

varying mediump vec2 v_texcoord;
uniform sampler2D texture;

void main()
{
	gl_FragColor = texture2D(texture, v_texcoord);
}
