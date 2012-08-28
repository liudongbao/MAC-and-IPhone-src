precision mediump float;

varying lowp vec2 texCoordOut;
uniform sampler2D Texture;

void main()
{
    gl_FragColor = texture2D(Texture, texCoordOut);
}
