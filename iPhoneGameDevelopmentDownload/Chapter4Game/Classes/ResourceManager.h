//
//  ResourceManager.h
//  Test_Framework
//
//  Created by Joe Hogue on 4/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <Foundation/Foundation.h>
#import "GLTexture.h"
#import "GLFont.h"
@class GLESGameState;
@class ResourceManager;

#define STORAGE_FILENAME @"appstorage"

//some helper methods.  These don't really belong in this class.
//returns the distance between two points.
CGFloat distsquared(CGPoint a, CGPoint b);
//returns a unit vector pointing from a to b.
CGPoint toward(CGPoint a, CGPoint b);

extern ResourceManager *g_ResManager; //paul <3's camel caps, hungarian notation, and underscores.

@interface ResourceManager : NSObject {
	//used to allocate and manage GLTexture instances.  Needs to be cleared in dealloc.
	NSMutableDictionary*	textures;
	
	//used to track sound allocations.  The actual sound data is buffered in SoundEngine; 'sounds' here only tracks the openAL ids of the loaded sounds.
	NSMutableDictionary*	sounds;

	NSMutableDictionary*	storage;
	BOOL storage_dirty;
	NSString* storage_path;
	
	GLFont* default_font;
}

+ (ResourceManager *)instance;

- (void) shutdown;

//loads and buffers images as 2d opengles textures.
- (GLTexture*) getTexture: (NSString*) filename;
- (void) purgeTextures;

- (void) setupSound; //intialize the sound device.  Takes a non-trivial amount of time, and should be called during initialization.
- (UInt32) getSound:(NSString*) filename; //useful for preloading sounds; called automatically by playSound.  Buffers sounds.
- (void) purgeSounds;
- (void) playSound:(NSString*) filename; //play a sound.  Loads and buffers the sound if needed.
-(void) playMusic:(NSString*)filename; //play and loop a music file in the background.  streams the file.
-(void) stopMusic; //stop the music.  unloads the currently playing music file.

//useful for loading binary files that you include in the program bundle, such as game level data
- (NSData*) getBundleData:(NSString*) filename;

//for saving preferences or other game data.  This is stored in the documents directory, and may persist between app version updates.
- (BOOL) storeUserData:(id) data toFile:(NSString*) filename;
//for loading prefs or other data saved with storeData.  Returns nil if the file does not exist.
- (id) getUserData:(NSString*) filename;
- (BOOL) userDataExists:(NSString*) filename;
+ (NSString*) appendStorePath:(NSString*) filename;

- (GLFont *) defaultFont;
- (void) setDefaultFont: (GLFont *) newValue;
@end
