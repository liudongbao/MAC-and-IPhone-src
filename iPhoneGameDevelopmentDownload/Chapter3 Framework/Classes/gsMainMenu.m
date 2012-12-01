//
//  UITest.m
//  Test_Framework
//
//  Created by Joe Hogue on 4/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "gsMainMenu.h"
#import "gsTextureTest.h"
#import "gsStorageTest.h"
#import "gsSoundTest.h"

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

	return self;
}

- (IBAction) doTextureTest{
	[m_pManager doStateChange:[gsTextureTest class]];
}

- (IBAction) doStorageTest{
	[m_pManager doStateChange:[gsStorageTest class]];
}

- (IBAction) doSoundTest{
	[m_pManager doStateChange:[gsSoundTest class]];
}


@end

