// -------------------------------------------------------------------------- //
#include <OpenGLES/ES1/gl.h>
#include <OpenGLES/ES1/glext.h>
// -------------------------------------------------------------------------- //
#include "PVRTexture.h"
#include "Graphics.h"
// -------------------------------------------------------------------------- //

// -------------------------------------------------------------------------- //
void InitGraphics() {
	// Set up the Projection Matrix //
	glMatrixMode( GL_PROJECTION );
	glLoadIdentity();

	extern int ScreenWidth;
	extern int ScreenHeight;
		
	glViewport(
		0, 0,
		ScreenWidth, ScreenHeight
		);	

	glOrthof( 
		-(ScreenWidth >> 1),  +(ScreenWidth >> 1),
		+(ScreenHeight >> 1), -(ScreenHeight >> 1),
		-1.0f, 1.0f
		);
	
	// Set up the Model View Matrix //
	glMatrixMode( GL_MODELVIEW );
	glLoadIdentity();


	// Set Blending Mode //
	glBlendFunc( GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA );
	glEnable( GL_BLEND );

	glEnableClientState( GL_VERTEX_ARRAY );
}
// -------------------------------------------------------------------------- //

// -------------------------------------------------------------------------- //
extern PVRTexture BallData;
unsigned int BallTexture;
// -------------------------------------------------------------------------- //

// -------------------------------------------------------------------------- //
void LoadBallGraphic() {
	glGenTextures( 1, &BallTexture );
	glBindTexture( GL_TEXTURE_2D, BallTexture );
	
	// An inlined PVR Texture loader, supporting RGBA4444 and mipmaps //
	PVRTexture* Texture = &BallData;
	int RGBMode = GL_RGBA;
	int LoadFormat = GL_UNSIGNED_SHORT_4_4_4_4;

	int Width = Texture->Width;
	int Height = Texture->Height;
	int SizeOffset = 0;
	int ChunkSize = 0;
	int MipMap = 0;
	
	glTexImage2D( 
		GL_TEXTURE_2D,
		0,
		RGBMode,
		Width, Height,
		0,
		RGBMode, 
		LoadFormat, 
		&Texture->Data[SizeOffset]
		);
	
	
	for ( MipMap = 0; MipMap < Texture->MipMapCount; MipMap++ ) {		
		ChunkSize = (Width * Height) * (Texture->BitsPerPixel >> 3);
		
		// Offset and reduce the dimensions //
		SizeOffset += ChunkSize;
		Width >>= 1;
		Height >>= 1;
		
		// Load the Mipmap Texture //
		glTexImage2D(
			GL_TEXTURE_2D,
				MipMap+1,
				RGBMode, 
				Width, Height,
				0,
				RGBMode,
				LoadFormat, 
				&Texture->Data[SizeOffset]
				);
	}
}
// -------------------------------------------------------------------------- //
void FreeBallGraphic() {
	glDeleteTextures( 1, &BallTexture );
}
// -------------------------------------------------------------------------- //
void DrawBall( float x, float y, float Radius ) {
	glBindTexture( GL_TEXTURE_2D, BallTexture );
	glEnableClientState( GL_TEXTURE_COORD_ARRAY );

	glEnable( GL_TEXTURE_2D );
	
	// Enable MipMapping //
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_NEAREST);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	
	float Verts[] = {
		x+Radius, y+Radius,
		x+Radius, y-Radius,
		x-Radius, y+Radius,
		x-Radius, y-Radius,
	};
	
	float UV[] = {
		0, 0,
		0, 1,
		1, 0,
		1, 1,		
	};
    
	glVertexPointer( 2, GL_FLOAT, 0, Verts );
	glTexCoordPointer( 2, GL_FLOAT, 0, UV );
	glDrawArrays( GL_TRIANGLE_STRIP, 0, 4 );

	glDisable( GL_TEXTURE_2D );
	glDisableClientState( GL_TEXTURE_COORD_ARRAY );
}
// -------------------------------------------------------------------------- //

// -------------------------------------------------------------------------- //
void ClearBackground() {
	glClearColor( 0.2f, 0.3f, 0.7f, 1.0f );
	glClear( GL_COLOR_BUFFER_BIT );	
}
// -------------------------------------------------------------------------- //

// -------------------------------------------------------------------------- //
void DrawArrow() {
	glColor4f( 1.0f, 1.0f, 0.0f, 0.7f );
	
	glPushMatrix();
	
	// Get the orientation. //
	// This is a hack, as Orientation is actually a Vector2D. //
	extern float Orientation[2];

	// Apply the orientation to the matrix //
	{
		float MyMatrix[4*4] = {
			-Orientation[1],Orientation[0],0,0,
			Orientation[0],Orientation[1],0,0,
			0,0,1,0,
			0,0,0,1
		};
	
		glLoadMatrixf( MyMatrix );
	}
	
	int x = 0;
	int y = 0;

	float Verts[] = {
		x+8, y+32,
		x+8, y-32,
		x-8, y+32,
		x-8, y-32,
	};
    
	glVertexPointer( 2, GL_FLOAT, 0, Verts );
	glDrawArrays( GL_TRIANGLE_STRIP, 0, 4 );
	
	glPopMatrix();
	
	glColor4f( 1,1,1,1 );
}
// -------------------------------------------------------------------------- //
