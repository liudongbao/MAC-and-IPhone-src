//
//  SoundTest.m
//  Test_Framework
//
//  Created by Joe Hogue on 4/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "gsSoundTest.h"
#import "ResourceManager.h"
#import "gsMainMenu.h"


@implementation gsSoundTest

-(gsSoundTest*) initWithFrame:(CGRect)frame andManager:(GameStateManager*)pManager
{
	
	if (self = [super initWithFrame:frame andManager:pManager]) {
		NSLog(@"SoundTest init");
		//load the uitest.xib file here.  this will instantiate the 'subview' uiview.
		[[NSBundle mainBundle] loadNibNamed:@"soundtest" owner:self options:nil];
		//add subview as... a subview.  This will let everything from the nib file show up on screen.
		[self addSubview:subview];
	}
	
	return self;
}

-(IBAction) playCafSfx 
{
	[g_ResManager playSound:@"tap.caf"];
}

-(IBAction) stopMusic
{
	[g_ResManager stopMusic];
}

-(IBAction) playMp3
{
	[g_ResManager playMusic:@"social.mp3"];
}

-(IBAction) back {
	[m_pManager doStateChange:[gsMainMenu class]];
}

@end
