//
//  BestTimes.m
//  Chapter5
//
//  Created by Joe Hogue on 7/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BestTimes.h"
#import "gsMainMenu.h"
#import "RingsState.h"

@implementation BestTimes

@synthesize subview;

- (void) loadTimes {
	NSArray* storedtimes = [RingsState bestTimes];
	NSString* str = [NSString string];
	for(NSNumber* time in storedtimes){
		str = [str stringByAppendingString:[NSString stringWithFormat:@"%.2f seconds\n", [time doubleValue]]];
	}
	times.text = str;
	
}

- (BestTimes*) initWithFrame:(CGRect)frame andManager:(GameStateManager*)pManager
{
	if (self = [super initWithFrame:frame andManager:pManager]) {
		[[NSBundle mainBundle] loadNibNamed:@"BestTimes" owner:self options:nil];
		//add subview as... a subview.  This will let everything from the nib file show up on screen.
		[self addSubview:subview];
	}
	
	[self loadTimes];
	
	return self;
}

- (void) dealloc {
	//self.subview = nil; //seems ok without this, Leaks says.
	[super dealloc];
}

- (IBAction) done{
	[m_pManager doStateChange:[gsMainMenu class]];
}

- (IBAction) reset{
	UIAlertView* startalert = [[UIAlertView alloc] initWithTitle:@"Really reset best times?" message:nil delegate:self cancelButtonTitle:@"What? No!" otherButtonTitles:@"Yes, nuke 'em", nil];
	[startalert show];
	[startalert release];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
	//zero is cancel, one is confirm.
	if(buttonIndex == 1){
		[RingsState defaultBestTimes];
		[self loadTimes];
	}
}

@end
