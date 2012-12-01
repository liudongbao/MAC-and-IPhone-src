//
//  About.m
//  Chapter3 Framework
//
//  Created by Joe Hogue on 6/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "About.h"
#import "gsMainMenu.h"

@implementation About

@synthesize subview;

-(About*) initWithFrame:(CGRect)frame andManager:(GameStateManager*)pManager
{
	if (self = [super initWithFrame:frame andManager:pManager]) {
		NSLog(@"MainMenu init");
		//load the uitest.xib file here.  this will instantiate the 'subview' uiview.
		[[NSBundle mainBundle] loadNibNamed:@"About" owner:self options:nil];
		//add subview as... a subview.  This will let everything from the nib file show up on screen.
		[self addSubview:subview];
	}
	
	return self;
}

- (IBAction) yup {
	[m_pManager doStateChange:[gsMainMenu class]];
}

- (void) dealloc {
	[subview release];
	[super dealloc];
}

@end
