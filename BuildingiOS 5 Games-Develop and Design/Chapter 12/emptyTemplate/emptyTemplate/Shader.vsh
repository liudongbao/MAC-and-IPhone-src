attribute vec4 position;
attribute vec2 texCoordIn;

varying vec2 texCoordOut;

mat4 projectionMatrix = mat4( 2.0/320.0, 0.0, 0.0, -1.0,
                              0.0, 2.0/480.0, 0.0, -1.0,
                              0.0, 0.0, -1.0, 0.0,
                              0.0, 0.0, 0.0, 1.0); 

uniform mat4 translation;

void main()
{
    
    gl_Position = translation * position;
    gl_Position *= projectionMatrix;

    texCoordOut = texCoordIn;
}