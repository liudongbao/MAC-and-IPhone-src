//
//  BBMaterialController.m
//  SpaceRocks
//
//  Created by ben smith on 14/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BBMaterialController.h"
#import "BBTexturedQuad.h"
#import "BBAnimatedQuad.h"


@implementation BBMaterialController
// Singleton accessor.  this is how you should ALWAYS get a reference
// to the controller.  Never init your own. 
+(BBMaterialController*)sharedMaterialController
{
  static BBMaterialController *sharedMaterialController;
  @synchronized(self)
  {
    if (!sharedMaterialController)
      sharedMaterialController = [[BBMaterialController alloc] init];
		
    return sharedMaterialController;
  }
	return sharedMaterialController;
}

- (id) init
{
	self = [super init];
	if (self != nil) {
		if (DEBUG_DRAW_COLLIDERS) [self loadTextureImage:@"testTexture.png" materialKey:@"testTexture"];

		// preload all our textures and atlases
		[self loadTextureImage:@"rockTexture.png" materialKey:@"rockTexture"];
		[self loadTextureImage:@"shipTexture.png" materialKey:@"shipTexture"];
		[self loadTextureImage:@"ufoTexture.png" materialKey:@"ufoTexture"];
		[self loadTextureImage:@"ufoMissileTexture.png" materialKey:@"ufoMissileTexture"];
		[self loadTextureImage:@"missileTexture.png" materialKey:@"missileTexture"];
		[self loadAtlasData:@"SpaceRocksAtlas"];
		[self loadAtlasData:@"particleAtlas"];
	}
	return self;
}


// load the atlas data and load the atlas texture
-(void)loadAtlasData:(NSString*)atlasName
{
	NSAutoreleasePool * apool = [[NSAutoreleasePool alloc] init];	

	if (quadLibrary == nil) quadLibrary = [[NSMutableDictionary alloc] init];

	// load the texture and remember how big it is so we can properly calculate
	// the UV positions
	CGSize atlasSize = [self loadTextureImage:[atlasName stringByAppendingPathExtension:@"png"] materialKey:atlasName];

	// load all the items from the atlas plist file
	NSArray * itemData = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:atlasName ofType:@"plist"]];
	
	// go through each record and build a textured quad for each record
	for (NSDictionary * record in itemData) {
		BBTexturedQuad * quad = [self texturedQuadFromAtlasRecord:record atlasSize:atlasSize materialKey:atlasName];
		[quadLibrary setObject:quad forKey:[record objectForKey:@"name"]];
	}
	
	[apool release];
}

// just a handy way to get a pre-defined quad
-(BBTexturedQuad*)quadFromAtlasKey:(NSString*)atlasKey
{
	return [quadLibrary objectForKey:atlasKey];
}

// a handy way to get an animation that is composed of quads
-(BBAnimatedQuad*)animationFromAtlasKeys:(NSArray*)atlasKeys
{
	BBAnimatedQuad * animation = [[BBAnimatedQuad alloc] init];
	for (NSString * key in atlasKeys) {
		[animation addFrame:[self quadFromAtlasKey:key]];
	}
	return [animation autorelease];
}

// build a textured quad from a dictionary
-(BBTexturedQuad*)texturedQuadFromAtlasRecord:(NSDictionary*)record 
																		atlasSize:(CGSize)atlasSize
																	materialKey:(NSString*)key;
{
	BBTexturedQuad * quad = [[BBTexturedQuad alloc] init];
	
	GLfloat xLocation = [[record objectForKey:@"xLocation"] floatValue];
	GLfloat yLocation = [[record objectForKey:@"yLocation"] floatValue];
	GLfloat width = [[record objectForKey:@"width"] floatValue];
	GLfloat height = [[record objectForKey:@"height"] floatValue];
	
	// find the normalized texture coordinates
	GLfloat xMin = xLocation/atlasSize.width;
	GLfloat yMin = yLocation/atlasSize.height;
	GLfloat xMax = (xLocation + width)/atlasSize.width;
	GLfloat yMax = (yLocation + height)/atlasSize.height;
	
	// build my quad UVs
	quad.uvCoordinates[0] = xMin;
	quad.uvCoordinates[1] = yMax;
	
	quad.uvCoordinates[2] = xMax;
	quad.uvCoordinates[3] = yMax;
	
	quad.uvCoordinates[4] = xMin;
	quad.uvCoordinates[5] = yMin;

	quad.uvCoordinates[6] = xMax;
	quad.uvCoordinates[7] = yMin;
	
	quad.materialKey = key;
	
	return [quad autorelease];
}



// grabs the openGL texture ID from the library and calls the openGL bind texture method
-(void)bindMaterial:(NSString*)materialKey
{
	NSNumber * numberObj = [materialLibrary objectForKey:materialKey];
	if (numberObj == nil) return;
	
	GLuint textureID = [numberObj unsignedIntValue];
  glEnable(GL_TEXTURE_2D); 	
	glBindTexture(GL_TEXTURE_2D, textureID);
}


// does the heavy lifting for getting a named image into a texture
// that is loaded into openGL
// this is a modified version of the way Apple loads textures in their sample code
-(CGSize)loadTextureImage:(NSString*)imageName materialKey:(NSString*)materialKey
{
	CGContextRef spriteContext;
	GLubyte *spriteData;
	size_t	width, height;
	
	
	GLuint textureID;
	// grab the image off the file system, jam it into a CGImageRef
	
	UIImage*	uiImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imageName ofType:nil]];
	CGImageRef spriteImage = [uiImage CGImage];
	// Get the width and height of the image
	width = CGImageGetWidth(spriteImage);
	height = CGImageGetHeight(spriteImage);
	
	CGSize imageSize = CGSizeMake(width, height);
	// Texture dimensions must be a power of 2. If you write an application that allows users to supply an image,
	// you'll want to add code that checks the dimensions and takes appropriate action if they are not a power of 2.
	
	if(spriteImage) {
		// Allocated memory needed for the bitmap context
		spriteData = (GLubyte *) malloc(width * height * 4);
		memset(spriteData, 0, (width * height * 4));
		// Uses the bitmatp creation function provided by the Core Graphics framework. 
		spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width * 4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
		// After you create the context, you can draw the sprite image to the context.
		CGContextDrawImage(spriteContext, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height), spriteImage);
		// You don't need the context at this point, so you need to release it to avoid memory leaks.
		CGContextRelease(spriteContext);
		
		// Use OpenGL ES to generate a name for the texture.
		glGenTextures(1, &textureID);
		// Bind the texture name. 
		glBindTexture(GL_TEXTURE_2D, textureID);
		// Specidfy a 2D texture image, provideing the a pointer to the image data in memory
		
		//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRGGGGBBBBAAAA"
		if (BB_CONVERT_TO_4444) {
			void*					tempData;
			unsigned int*			inPixel32;
			unsigned short*			outPixel16;
			
			tempData = malloc(height * width * 2);
			
			inPixel32 = (unsigned int*)spriteData;
			outPixel16 = (unsigned short*)tempData;
			NSUInteger i;
			for(i = 0; i < width * height; ++i, ++inPixel32)
				*outPixel16++ = ((((*inPixel32 >> 0) & 0xFF) >> 4) << 12) | ((((*inPixel32 >> 8) & 0xFF) >> 4) << 8) | ((((*inPixel32 >> 16) & 0xFF) >> 4) << 4) | ((((*inPixel32 >> 24) & 0xFF) >> 4) << 0);
			
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_SHORT_4_4_4_4, tempData);
			free(tempData);
		} else {
			
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);			
		}
		
		free(spriteData);
		// Release the image data
		// Set the texture parameters to use a minifying filter and a linear filer (weighted average)
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
		
		// Enable use of the texture
		glEnable(GL_TEXTURE_2D);
		// Set a blending function to use
		glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
		// Enable blending
		glEnable(GL_BLEND);
	} else {
		return CGSizeZero;
	}
	[uiImage release];
	
	if (materialLibrary == nil) materialLibrary = [[NSMutableDictionary alloc] init];

	// now put the texture ID into the library
	[materialLibrary setObject:[NSNumber numberWithUnsignedInt:textureID] forKey:materialKey];
	return imageSize;
}

- (void) dealloc
{
	[materialLibrary release];
	[super dealloc];
}


@end
