//
//  ViewBasedAppWithCocos2DViewController.m
//  ViewBasedAppWithCocos2D
//
//  Created by Steffen Itterheim on 11.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewBasedAppWithCocos2DViewController.h"

#import "HelloWorldLayer.h"

@implementation ViewBasedAppWithCocos2DViewController

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES if you want to support all orientations
	//return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)switchChanged:(id)sender 
{
	UISwitch* switchButton = (UISwitch*)sender;
	CCDirector* director = [CCDirector sharedDirector];
	
	if (switchButton.on)
	{
		if (director.openGLView == nil)
		{
			if ([CCDirector setDirectorType:kCCDirectorTypeDisplayLink] == NO)
			{
				[CCDirector setDirectorType:kCCDirectorTypeDefault];
			}
			
			[director setAnimationInterval:1.0/60];
			[director setDisplayFPS:YES];
			
			NSArray* subviews = self.view.subviews;
			for (int i = 0; i < [subviews count]; i++)
			{
				UIView* subview = [subviews objectAtIndex:i];
				if ([subview isKindOfClass:[EAGLView class]]) 
				{
					[director setOpenGLView:(EAGLView*)subview];
					[director runWithScene:[HelloWorldLayer scene]];
					break;
				}
			}
		}
		else
		{
			[director startAnimation];
		}
		
		director.openGLView.hidden = NO;
	}
	else
	{
		director.openGLView.hidden = YES;
		[director stopAnimation];
	}
}

- (IBAction)sceneChanged:(id)sender 
{
	CCDirector* director = [CCDirector sharedDirector];
	if (director.openGLView == nil || director.openGLView.hidden)
	{
		return;
	}
	
	UISegmentedControl* sceneChanger = (UISegmentedControl*)sender;
	int selection = sceneChanger.selectedSegmentIndex;
	
	CCScene* newScene = nil;
	if (selection == 0) 
	{
		newScene = [CCTransitionSlideInL transitionWithDuration:1 scene:[HelloWorldLayer scene]];
	}
	else if (selection == 1)
	{
		newScene = [CCTransitionShrinkGrow transitionWithDuration:1 scene:[HelloWorldLayer scene]];
	}
	else
	{
		newScene = [CCTransitionSlideInR transitionWithDuration:1 scene:[HelloWorldLayer scene]];
	}
	
	[director replaceScene:newScene];
}

@end
