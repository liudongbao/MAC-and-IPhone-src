/*

File: Texture2D.h

 modified and simplified from Apple's sample code.
 
*/

#import <UIKit/UIKit.h>
#import <OpenGLES/ES1/gl.h>

extern int gNumSprites;
extern int gNumTextures;


typedef enum {
	kTexture2DPixelFormat_Automatic = 0,
	kTexture2DPixelFormat_RGBA8888,
	kTexture2DPixelFormat_RGB565,
	kTexture2DPixelFormat_A8,
} Texture2DPixelFormat;

typedef struct {
	GLuint name;
	GLfloat verts[12];
	GLfloat tverts[8];
} sprite_type;

typedef struct {
	GLuint	name;
	CGSize	size;
	NSUInteger	width,height;
	Texture2DPixelFormat format;
	GLfloat	maxS,maxT;
	
} texture_type;

void LoadTextureImage(CFStringRef filename,CFStringRef type,int sprname);
CGImageRef CreateNamedImage(CFStringRef imageName, CFStringRef type);
texture_type InitTexture(const void* data, Texture2DPixelFormat pixelFormat, NSUInteger width, NSUInteger height, CGSize size, int sprname);


void CreateSprite(int a,float width,float height,float u1,float v1,float u2,float v2,GLuint text, int sprname);
void GrabSpriteSet(int across, int down, int count, int sprname);
void DrawSpriteAt(int a, float x,float y);
void DrawSpriteScaledAt(int a, float x,float y,float sx,float sy);
void DrawNumberAt(int num,float x,float y);

