//
//  UITest.m
//  Test_Framework
//
//  Created by Joe Hogue on 4/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "gsMainMenu.h"
#import "About.h"
#import "Options.h"
#import "gsSoundTest.h"
#import "ResourceManager.h" //for getting savefile
#import "Game3dAppDelegate.h" //for savefile filename 
#import "BestTimes.h"

#import "RingsState.h"

@implementation gsMainMenu

-(gsMainMenu*) initWithFrame:(CGRect)frame andManager:(GameStateManager*)pManager
{
	if (self = [super initWithFrame:frame andManager:pManager]) {
		NSLog(@"MainMenu init");
		//load the uitest.xib file here.  this will instantiate the 'subview' uiview.
		[[NSBundle mainBundle] loadNibNamed:@"MainMenu" owner:self options:nil];
		//add subview as... a subview.  This will let everything from the nib file show up on screen.
		[self addSubview:subview];
	}
	
	NSNumber *besttime = [[RingsState bestTimes] objectAtIndex:0];
	if(besttime != nil){
		bestTime.text = [NSString stringWithFormat:@"Best Time: %.2f seconds", [besttime doubleValue]];
	}
	return self;
}

- (IBAction) doRingsState{
	[g_ResManager stopMusic];
	[m_pManager doStateChange:[RingsState class]];
}

- (IBAction) doAboutScreen{
	[g_ResManager stopMusic];
	[m_pManager doStateChange:[About class]];
}

- (IBAction) doOptionsScreen{
	[m_pManager doStateChange:[Options class]];
}

- (IBAction) doSoundTest{
	[m_pManager doStateChange:[gsSoundTest class]];
}

- (IBAction) doHighScores {
	[m_pManager doStateChange:[BestTimes class]];
}

@end

