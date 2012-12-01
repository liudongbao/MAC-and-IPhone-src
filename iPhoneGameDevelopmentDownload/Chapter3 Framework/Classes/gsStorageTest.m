//
//  StorageTest.m
//  Test_Framework
//
//  Created by Joe Hogue on 4/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "gsStorageTest.h"
#import "ResourceManager.h"
#import "gsMainMenu.h"

@implementation gsStorageTest

-(gsStorageTest*) initWithFrame:(CGRect)frame andManager:(GameStateManager*)pManager
{
	
	if (self = [super initWithFrame:frame andManager:pManager]) {
		NSLog(@"storagetest init");
		//load the uitest.xib file here.  this will instantiate the 'subview' uiview.
		[[NSBundle mainBundle] loadNibNamed:@"storagetest" owner:self options:nil];
		//add subview as... a subview.  This will let everything from the nib file show up on screen.
		[self addSubview:subview];
	}
	//load the last saved state of the toggle switch.
	toggle.on = [[g_ResManager getUserData:@"toggle.on"] boolValue];
	[self runTests];
	
	return self;
}

-(void) log:(NSString*)str {
	//just dump to console.
	NSLog(str);
}

-(NSString*)passfail:(BOOL)pass{
	return pass?@"(pass)":@"(fail)";
}

//unit tests for data storage.  Anything that comes out as (fail) is problematic.
-(void) runTests {
	{
		NSData* nonexistantfile = [g_ResManager getUserData:@"notfound"];
		[self log:[NSString stringWithFormat:@"%@ load non existant file: %@", [self passfail:nonexistantfile==nil], nonexistantfile]];
		
		BOOL fileexists = [g_ResManager userDataExists:@"notfound"];
		[self log:[NSString stringWithFormat:@"%@ non existant file test: %d", [self passfail:!fileexists], fileexists]];
	}
	
	{
		NSString* savedString = @"some saved text.";
		BOOL saveok = [g_ResManager storeUserData:[savedString dataUsingEncoding:NSUnicodeStringEncoding] toFile:@"savetest"];
		[self log:[NSString stringWithFormat:@"%@ save result: %d", [self passfail:saveok], saveok]];
		
		BOOL fileexists = [g_ResManager userDataExists:@"savetest"];
		[self log:[NSString stringWithFormat:@"%@ existant file test: %d", [self passfail:fileexists], fileexists]];
		
		NSString* loadedString = [[NSString alloc] initWithData: [g_ResManager getUserData:@"savetest"] encoding:NSUnicodeStringEncoding];
		[self log:[NSString stringWithFormat:@"%@ load result: %@", [self passfail:[loadedString isEqualToString:savedString]], loadedString]];
		
		[loadedString release];
	}
	
	{
		NSString* savedString = @"another saved text.";
		NSString* loadedString = [g_ResManager getUserData:@"savetest2"];
		if(loadedString == nil){
			[self log:@"Restart app to test loading from persistent storage.  If you already have, then something might have failed."];
		} else {
			[self log:[NSString stringWithFormat:@"%@ second save test loaded as %@", [self passfail:[loadedString isEqualToString:savedString]], loadedString]];
		}
		[g_ResManager storeUserData:savedString toFile:@"savetest2"];
	}	
}

-(IBAction) back {
	[m_pManager doStateChange:[gsMainMenu class]];
}

-(IBAction) toggled {
	//we can't directly store a bool, but we can store a nsnumber with a bool.
	[g_ResManager storeUserData:[NSNumber numberWithBool:toggle.on] toFile:@"toggle.on"];
}

@end
