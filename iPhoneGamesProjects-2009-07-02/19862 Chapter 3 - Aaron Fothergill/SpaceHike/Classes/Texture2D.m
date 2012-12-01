/*
 
 File: Texture2D.m
 Abstract: Creates OpenGL 2D textures from images or text.
 
 Originally based on Apple sample code from Crash Lander but trimmed, optimised, simplified and turned into straight C
 
 */

#import <OpenGLES/ES1/glext.h>

#import "Texture2D.h"
#import "SpaceHikeAppDelegate.h"


//CONSTANTS:

#define kMaxTextureSize	 1024

int spr[64];
sprite_type gSprite[64];
texture_type gTexture[64];
int gNumSprites = 0;
int gNumTextures = 0;
int gLastName;

void LoadTextureImage(CFStringRef filename,CFStringRef type,int sprname)
{
	NSUInteger				width,
	height,
	i;
	CGContextRef			context = nil;
	void*					data = nil;;
	CGColorSpaceRef			colorSpace;
	void*					tempData;
	unsigned int*			inPixel32;
	unsigned short*			outPixel16;
	BOOL					hasAlpha;
	CGImageAlphaInfo		info;
	CGAffineTransform		transform;
	CGSize					imageSize;
	Texture2DPixelFormat    pixelFormat;
	CGImageRef				image;
	UIImageOrientation		orientation;
	BOOL					sizeToFit = NO;
	
	
	image = CreateNamedImage(filename,type);
	orientation = UIImageOrientationUp; 
	if(image == NULL) 
	{
		
		printf("Image is Null %d %@\n",gNumSprites,CFStringGetCStringPtr(filename,kCFStringEncodingASCII));
		return;
	}
	
	
	info = CGImageGetAlphaInfo(image);
	hasAlpha = ((info == kCGImageAlphaPremultipliedLast) || (info == kCGImageAlphaPremultipliedFirst) || (info == kCGImageAlphaLast) || (info == kCGImageAlphaFirst) ? YES : NO);
	if(CGImageGetColorSpace(image)) {
		if(hasAlpha)
			pixelFormat = kTexture2DPixelFormat_RGBA8888;
		else
			pixelFormat = kTexture2DPixelFormat_RGB565;
	} 
	else  //NOTE: No colorspace means a mask image
	{
		pixelFormat = kTexture2DPixelFormat_A8;
		imageSize.width *= 0.5;
	}
	
	imageSize = CGSizeMake(CGImageGetWidth(image), CGImageGetHeight(image));
	transform = CGAffineTransformIdentity;
	
	width = imageSize.width;
	// round up to nearest power of 2
	if((width != 1) && (width & (width - 1))) {
		i = 1;
		while((sizeToFit ? 2 * i : i) < width)
			i *= 2;
		width = i;
	}
	height = imageSize.height;
	// round up to nearest power of 2
	if((height != 1) && (height & (height - 1))) {
		i = 1;
		while((sizeToFit ? 2 * i : i) < height)
			i *= 2;
		height = i;
	}
	
	// check texture size is within maximum texture size (1024x1024), although if you're loading in textures this big you're going to have memory issues anyway
	while((width > kMaxTextureSize) || (height > kMaxTextureSize)) {
		width /= 2;
		height /= 2;
		transform = CGAffineTransformScale(transform, 0.5, 0.5);
		imageSize.width *= 0.5;
		imageSize.height *= 0.5;
	}
	
	switch(pixelFormat) {		
		case kTexture2DPixelFormat_RGBA8888:
			colorSpace = CGColorSpaceCreateDeviceRGB();
			data = calloc(height * width * 4,1);
			context = CGBitmapContextCreate(data, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
			CGColorSpaceRelease(colorSpace);
			break;
		case kTexture2DPixelFormat_RGB565:
			colorSpace = CGColorSpaceCreateDeviceRGB();
			data = calloc(height * width * 4,1);
			context = CGBitmapContextCreate(data, width, height, 8, 4 * width, colorSpace, kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big);
			CGColorSpaceRelease(colorSpace);
			break;
			
		case kTexture2DPixelFormat_A8:
			data = calloc(height * width,1);
			context = CGBitmapContextCreate(data, width, height, 8, width, NULL, kCGImageAlphaOnly);
			break;				
		default:
			[NSException raise:NSInternalInconsistencyException format:@"Invalid pixel format"];
	}
	
	
	CGContextClearRect(context, CGRectMake(0, 0, width, height));
	CGContextTranslateCTM(context, 0, height - imageSize.height);
	
	if(!CGAffineTransformIsIdentity(transform))
		CGContextConcatCTM(context, transform);
	CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
	//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRGGGGGGBBBBB"
	if(pixelFormat == kTexture2DPixelFormat_RGB565) {
		tempData = calloc(height * width * 2,1);
		inPixel32 = (unsigned int*)data;
		outPixel16 = (unsigned short*)tempData;
		for(i = 0; i < width * height; ++i, ++inPixel32)
			*outPixel16++ = ((((*inPixel32 >> 0) & 0xFF) >> 3) << 11) | ((((*inPixel32 >> 8) & 0xFF) >> 2) << 5) | ((((*inPixel32 >> 16) & 0xFF) >> 3) << 0);
		free(data);
		data = tempData;
		
	}
	printf("texture loaded, w/h = %d,%d to  %d\n",width,height,gNumTextures);


	gTexture[gNumTextures++] = InitTexture(data,pixelFormat,width,height,imageSize,sprname);
	
	CGContextRelease(context);
	free(data);
	CGImageRelease(image);
	
	return;
}

// CreateNamedImage(name,type) : creates a CGImageRef for the named image file.

// note, this version only works with png files, but by testing the value of the type parameter and using CGImageCreateWithJPGDataProvider you can easily add jpeg loading

CGImageRef CreateNamedImage(CFStringRef imageName, CFStringRef type)
{
	CGImageRef img = NULL;
	CFURLRef url = CFBundleCopyResourceURL(CFBundleGetMainBundle(),imageName,type,NULL);
	if(url != NULL)
	{
		CGDataProviderRef imgSrc = CGDataProviderCreateWithURL(url);
		if(imgSrc != NULL)
		{
			img = CGImageCreateWithPNGDataProvider(imgSrc,NULL,false,kCGRenderingIntentDefault);
			CFRelease(imgSrc);
		}
		else
		{
			printf("imgSrc = null for %s.%s\n",CFStringGetCStringPtr(imageName,kCFStringEncodingASCII),CFStringGetCStringPtr(type,kCFStringEncodingASCII));
		}
		CFRelease(url);
	}
	else
	{
		printf("url = null for %s.%s\n",CFStringGetCStringPtr(imageName,kCFStringEncodingASCII),CFStringGetCStringPtr(type,kCFStringEncodingASCII));
	}
	return img;
}

texture_type InitTexture(const void* data, Texture2DPixelFormat pixelFormat, NSUInteger width, NSUInteger height, CGSize size,int sprname)
{
	texture_type ret;
	glGenTextures(1, &ret.name);
	glBindTexture(GL_TEXTURE_2D, ret.name);
	
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
	
	
	switch(pixelFormat) 
	{
			
		case kTexture2DPixelFormat_RGBA8888:
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
			break;
		case kTexture2DPixelFormat_RGB565:
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_SHORT_5_6_5, data);
			break;
		case kTexture2DPixelFormat_A8:
			glTexImage2D(GL_TEXTURE_2D, 0, GL_ALPHA, width, height, 0, GL_ALPHA, GL_UNSIGNED_BYTE, data);
			break;
		default:
			[NSException raise:NSInternalInconsistencyException format:@""];
			
	}
	
	ret.size = size;
	ret.width = width;
	ret.height = height;
	ret.format = pixelFormat;
	ret.maxS = size.width / (float)width;
	ret.maxT = size.height / (float)height;
	CreateSprite(gNumSprites,width * ret.maxS,height * ret.maxT,0,0,ret.maxS,ret.maxT,ret.name,sprname);
	return ret;
}

void CreateSprite(int a,float width,float height,float u1,float v1,float u2,float v2,GLuint tex, int sprname)
{
	int b;
	GLfloat		coordinates[8] = { u1,v2,
		u2,	v2,
		u1,		v1,
	u2,	v1 };
	GLfloat		vertices[12] = {	-width / 2,	-height / 2 ,	0.0,
		width / 2 ,	-height / 2,	0.0,
		-width / 2 ,	height / 2 ,	0.0,
	width / 2 ,	height / 2 ,	0.0 };
	gSprite[a].name = tex;
	for(b = 0; b < 8;b++)
	{
		gSprite[a].tverts[b] = coordinates[b];
	}
	for(b = 0; b < 12;b++)
	{
		gSprite[a].verts[b] = vertices[b];
	}
	spr[sprname] = gNumSprites;
	gNumSprites++;
}

void GrabSpriteSet(int across, int down, int count, int sprname )
{
	int b;
	texture_type lasttext;
	int x,y;
	GLfloat vertices[12];
	GLfloat coordinates[8];
	float width,height;
	GLfloat u1,u2,v1,v2;
	
	lasttext = gTexture[gNumTextures - 1];
	width = lasttext.width / across;
	height = lasttext.height / down;
	
	vertices[0] = -width / 2;
	vertices[1] = -height / 2;
	vertices[2] = 0;
	vertices[3] = width / 2;
	vertices[4] = -height / 2;
	vertices[5] = 0;
	vertices[6] = -width / 2;
	vertices[7] = height / 2;
	vertices[8] = 0;
	vertices[9] = width / 2;
	vertices[10] = height / 2;
	vertices[11] = 0;

	for(y = 0; y < down && count > 0 ;y++)
	{
		for(x = 0; x < across && count > 0;x++)
		{
			
			spr[sprname++] = gNumSprites;
			u1 = (lasttext.maxS * x) / across;
			u2 = (lasttext.maxS * (x + 1)) / across;
			v1 = (lasttext.maxT * y) / down;
			v2 = (lasttext.maxT * (y + 1)) / down;
			
			coordinates[0] = u1;
			coordinates[1] = v2;
			coordinates[2] = u2;
			coordinates[3] = v2;
			coordinates[4] = u1;
			coordinates[5] = v1;
			coordinates[6] = u2;
			coordinates[7] = v1;
			
			gSprite[gNumSprites].name = lasttext.name;
			for(b = 0; b < 8;b++)
			{
				gSprite[gNumSprites].tverts[b] = coordinates[b];
			}
			for(b = 0; b < 12;b++)
			{
				gSprite[gNumSprites].verts[b] = vertices[b];
			}
			
			gNumSprites++;
			count--;
			
		}
	}
	
}

void DrawSpriteAt(int a,float x,float y)
{
	glPushMatrix();
	glTranslatef(x,y,0);
	if(gSprite[spr[a]].name == 0)
	{
		printf("spr %d\n",a);
	}
	else
	{
		glBindTexture(GL_TEXTURE_2D,gSprite[spr[a]].name);
		glVertexPointer(3,GL_FLOAT,0,gSprite[spr[a]].verts);
		glTexCoordPointer(2,GL_FLOAT,0,gSprite[spr[a]].tverts);
		glDrawArrays(GL_TRIANGLE_STRIP,0,4);
	}
	glPopMatrix();
	
}

void DrawSpriteScaledAt(int a,float x,float y, float sx,float sy)
{
	glPushMatrix();
	glTranslatef(x,y,0);
	glScalef(sx,sy,1);
	if(gSprite[spr[a]].name == 0)
	{
		printf("spr %d\n",a);
	}
	else
	{
		glBindTexture(GL_TEXTURE_2D,gSprite[spr[a]].name);
		glVertexPointer(3,GL_FLOAT,0,gSprite[spr[a]].verts);
		glTexCoordPointer(2,GL_FLOAT,0,gSprite[spr[a]].tverts);
		glDrawArrays(GL_TRIANGLE_STRIP,0,4);
	}
	glPopMatrix();
	
}

void DrawNumberAt(int num,float x,float y)
{
	int a;
	int d;
	float b;
	int c;
	d = 10;
	a = 0;
	c = 1;
	while(d <= num)
	{
		d = d * 10;
		c++;
	}
	b = 0;
	
	while(c > 0)
	{
		d = d / 10;
		a = num / d;
	
		DrawSpriteScaledAt(SPR_DIGITS0 + a,x + b,y,0.75,0.75);
		b = b + 12;
		num = num - a * d;
		c--;
	}
	
	
	
}
