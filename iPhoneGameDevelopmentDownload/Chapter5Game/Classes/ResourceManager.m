//
//  ResourceManager.m
//  Test_Framework
//
//  Created by Joe Hogue on 4/4/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ResourceManager.h"
#import "GLESGameState.h"
#import <OpenGLES/EAGLDrawable.h>
#import <QuartzCore/QuartzCore.h>
#import "SoundEngine.h"

//sound stuff leaks memory in the simulator, which is distracting when looking for real leaks.  use this to hack out SoundEngine calls.
#define DEBUG_SOUND_ENABLED true

ResourceManager *g_ResManager;

@implementation ResourceManager

//initialize is called automatically before the class gets any other message, per from http://stackoverflow.com/questions/145154/what-does-your-objective-c-singleton-look-like
+ (void)initialize
{
    static BOOL initialized = NO;
    if(!initialized)
    {
        initialized = YES;
        g_ResManager = [[ResourceManager alloc] init];
    }
}

+ (ResourceManager *)instance
{
	return(g_ResManager);
}

- (ResourceManager*) init
{
	[super init];
	textures = [[NSMutableDictionary dictionary] retain];
	sounds = [[NSMutableDictionary dictionary] retain];
	[self setupSound];
	
	storage_path = [[ResourceManager appendStorePath:STORAGE_FILENAME] retain];
	storage_dirty = FALSE;
	storage = [[NSMutableDictionary alloc] init];
	[storage setDictionary:[NSDictionary dictionaryWithContentsOfFile:storage_path]];
	if(storage == nil){
		NSLog(@"creating empty storage.");
		storage = [[NSMutableDictionary alloc] init];
		storage_dirty = TRUE;
	}
	
	return self;
}

- (void) shutdown {
	[self purgeSounds];
	[self purgeTextures];
	if(DEBUG_SOUND_ENABLED)
		SoundEngine_Teardown();
	if(storage_dirty){
		[storage writeToFile:storage_path atomically:YES];
	}
	[storage_path release];
	[storage release];
	[default_font release];
}

#pragma mark image cache

//creates and returns a texture for the given image file.  The texture is buffered,
//so the first call to getTexture will create the texture, and subsequent calls will
//simply return the same texture object.
//todo: catch allocation failures here, purge enough textures to make it work, and retry loading the texture.
- (GLTexture*) getTexture: (NSString*) filename
{
	//lookup is .00001 (seconds) to .00003 on simulator, and consistently .00003 on device.  tested average over 1000 cycles, compared against using a local cache (e.g. not calling gettexture).  If you are drawing over a thousand instances per frame, you should use a local cache.
	GLTexture* retval = [textures valueForKey:filename];
	if(retval != nil)
		return retval;

	//load time seems to correlate with image complexity with png files.  Images loaded later in the app were quicker as well.  Ranged 0.075 (seconds) to 0.288 in test app.  Tested once per image, on device, with varying load order.
	NSString *fullpath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:filename];
	UIImage *loadImage = [UIImage imageWithContentsOfFile:fullpath];
	retval = [[GLTexture alloc] initWithImage: loadImage];
	[textures setValue:[retval autorelease] forKey:filename];
	return retval;
}

- (void) purgeTextures
{
	/*NSEnumerator* e = [textures objectEnumerator];
	GLTexture* tex;
	while(tex = [e nextObject]){
		[tex release];
	}*/ //if we didn't autorelease the textures (in getTexture), we would have to do something like this code block.
	[textures removeAllObjects];
}

#pragma mark sound code

//load and buffer the specified sound.  File should preferably be in core-audio format (.caf).  Not sure if other formats work, todo: test.
-(UInt32) getSound:(NSString*)filename{
	NSNumber* retval = [sounds valueForKey:filename];
	if(retval != nil)
		return [retval intValue];
	NSString *fullpath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:filename];
	UInt32 loadedsound;
	SoundEngine_LoadEffect([fullpath UTF8String], &loadedsound);
	[sounds setValue:[NSNumber numberWithInt:loadedsound] forKey:filename];
	NSLog(@"loaded %@", filename);
	return loadedsound;
}

- (void) purgeSounds
{
	NSEnumerator* e = [sounds objectEnumerator];
	NSNumber* snd;
	while(snd = [e nextObject]){
		SoundEngine_UnloadEffect([snd intValue]);
	}
	[sounds removeAllObjects];
}

//play specified file.  File is loaded and buffered as necessary.
-(void) playSound:(NSString*)filename{
	//if(!soundOn)return;
	if(DEBUG_SOUND_ENABLED)
		SoundEngine_StartEffect([self getSound:filename]);
}

//works with mp3 files.
//works with caf files.
//works with wav files.
//does not work with midi files.
-(void) playMusic:(NSString*)filename{	
	NSString *fullpath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:filename];
	SoundEngine_StopBackgroundMusic(FALSE);
	SoundEngine_UnloadBackgroundMusicTrack();
	SoundEngine_LoadBackgroundMusicTrack([fullpath UTF8String], false, false);
	SoundEngine_StartBackgroundMusic();
}

-(void) stopMusic {
	SoundEngine_StopBackgroundMusic(FALSE);
	SoundEngine_UnloadBackgroundMusicTrack();
}
	
-(void) setupSound{
	if(DEBUG_SOUND_ENABLED){
		SoundEngine_Initialize(44100);
		SoundEngine_SetListenerPosition(0.0, 0.0, 1.0);	
	}
}

//For loading data files from your application bundle.  You should retain and release the return value that you get from getData if you plan on keeping it around.
-(NSData*) getBundleData:(NSString*) filename{
	NSString *fullpath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:filename];
	NSData* data = [NSData dataWithContentsOfFile:fullpath];
	return data;
}


#pragma mark data storage

//for saving preferences or other game data.  This is stored in the documents directory, and may persist between app version updates.
- (BOOL) storeUserData:(id) data toFile:(NSString*) filename {
	[[NSUserDefaults standardUserDefaults] setObject:data forKey:filename];
	return YES;
}

//for loading prefs or other data saved with storeData.
- (id) getUserData:(NSString*) filename {
	return [[NSUserDefaults standardUserDefaults] objectForKey:filename];
}

- (BOOL) userDataExists:(NSString*) filename{
	return [self getUserData:filename] != nil;
}

#pragma mark default font helpers

- (GLFont *) defaultFont {
	if(default_font == nil){
		default_font = [[GLFont alloc] initWithString:@"0123456789timeTIMERank,.?!@/: " //cut down the font because it doesn't support trimming texture down to 1024 pixels yet, todo
			fontName:@"Helvetica" 
			fontSize:24.0f
			strokeWidth:1.0f
			fillColor:[UIColor whiteColor]
			strokeColor:[UIColor grayColor]];
	}
	return default_font;
}

- (void) setDefaultFont: (GLFont *) newValue {
	[default_font autorelease];
	default_font = [newValue retain];
}

#pragma mark unsupported features and generally abusive functions.

+ (NSString*) appendStorePath:(NSString*) filename
{
	//find the user's document directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	//there should be only one directory returned
    NSString *documentsDirectory = [paths objectAtIndex:0];
	//make the full path name.  stringByAppendingPathComponent adds slashies as needed.
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:filename];
	return filePath;	
	
	//return [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:filename]; //will read but not write on simulator or device. 
	//return filename; //doing this saves to '/' on the simulator.  does not save on device.
}

+ (void) scrapeData {
	//so there is a bunch of unexpected interesting stuff in here, including language settings and the user's phone number.
	//stuff that we add in storeUserData is not accessible to other apps, so it is a local storage.  The global ones are something else.
	NSDictionary* datas = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
	NSArray* keys = [datas allKeys];
	for(int i=0;i<keys.count;i++){
		NSLog(@"key %@ val %@", [keys objectAtIndex:i], [datas objectForKey:[keys objectAtIndex:i]]);
	}
}

//debug code to determine which directories are actually writable.
+ (void) directoryMasher
{
	int paths[] = {
		NSApplicationDirectory,//0
		NSDemoApplicationDirectory,
		NSDeveloperApplicationDirectory,
		NSAdminApplicationDirectory,
		NSLibraryDirectory,//4, writeable
		NSDeveloperDirectory,
		NSUserDirectory, //6, no directories
		NSDocumentationDirectory,
		NSDocumentDirectory,//8, writeable
		NSCoreServiceDirectory, //9, no directories
		NSDesktopDirectory,
		NSCachesDirectory,
		NSApplicationSupportDirectory,
		NSDownloadsDirectory,
		NSAllApplicationsDirectory,
		NSAllLibrariesDirectory //15, writeable
	};
	int paths_length=16;
	//simulator can write to directories 4, 8, and 15. same on device.
	//searching NSAllDomainsMask will return many directories on the simulator, many of which are writeable.  Only the directories from NSUserDomainMask are valid on device, though.
	for(int i=0;i<paths_length;i++){
		//find the user's document directory
		NSArray *found_paths = NSSearchPathForDirectoriesInDomains(paths[i], NSUserDomainMask, YES);
		if(found_paths == nil || found_paths.count == 0){
			NSLog(@"path %d no paths found", i);
			continue;
		}
		for(int j=0;j<found_paths.count;j++){
			NSString *documentsDirectory = [found_paths objectAtIndex:j];
			//make the full path name.  stringByAppendingPathComponent adds slashies as needed.
			NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"masher"];
			
			[[NSString stringWithString:@"o hai"] writeToFile:filePath atomically:YES];
			NSString* loaded = [NSString stringWithContentsOfFile:filePath];
			if(loaded != nil)
				NSLog(@"path %d:%d loaded %@ from %@", i, j, loaded, filePath);
		}
	}
}

@end