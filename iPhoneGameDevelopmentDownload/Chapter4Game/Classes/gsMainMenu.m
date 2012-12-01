//
//  UITest.m
//  Test_Framework
//
//  Created by Joe Hogue on 4/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "gsMainMenu.h"
#import "EmuLevel.h"
#import "LionLevel.h"
#import "MazeLevel.h"
#import "RiverLevel.h"
#import "About.h"
#import "gsSoundTest.h"
#import "ResourceManager.h" //for getting savefile
#import "Game2dAppDelegate.h" //for savefile filename 

@implementation gsMainMenu

@synthesize lvl1, lvl2, lvl3, lvl4;

-(gsMainMenu*) initWithFrame:(CGRect)frame andManager:(GameStateManager*)pManager
{
	if (self = [super initWithFrame:frame andManager:pManager]) {
		NSLog(@"MainMenu init");
		//load the uitest.xib file here.  this will instantiate the 'subview' uiview.
		[[NSBundle mainBundle] loadNibNamed:@"MainMenu" owner:self options:nil];
		//add subview as... a subview.  This will let everything from the nib file show up on screen.
		[self addSubview:subview];
	}
	
	UIButton* lvls[] = {
		lvl1, lvl2, lvl3, lvl4
	};
	
	int unlocked = [[g_ResManager getUserData:ProgressionSavefile] intValue];
	for(int i=0;i<4;i++){
		lvls[i].enabled = i <= unlocked;
	}

	[g_ResManager stopMusic];
	[g_ResManager playMusic:@"island.mp3"];
	return self;
}

- (IBAction) doEmuLevel{
	[g_ResManager stopMusic];
	[m_pManager doStateChange:[EmuLevel class]];
}

- (IBAction) doLionLevel{
	[g_ResManager stopMusic];
	[m_pManager doStateChange:[LionLevel class]];
}

- (IBAction) doMazeLevel{
	[g_ResManager stopMusic];
	[m_pManager doStateChange:[MazeLevel class]];
}

- (IBAction) doRiverLevel{
	[g_ResManager stopMusic];
	[m_pManager doStateChange:[RiverLevel class]];
}

- (IBAction) doAboutScreen{
	[g_ResManager stopMusic];
	[m_pManager doStateChange:[About class]];
}

- (IBAction) doSoundTest{
	[m_pManager doStateChange:[gsSoundTest class]];
}


@end

