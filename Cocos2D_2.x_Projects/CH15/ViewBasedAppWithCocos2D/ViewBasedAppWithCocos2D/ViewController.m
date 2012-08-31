//
//  ViewController.m
//  ViewBasedAppWithCocos2D
//
//  Created by Steffen Itterheim on 24.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "HelloWorldLayer.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) 
	{
	    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
	}
	else 
	{
	    return YES;
	}
}

- (IBAction)switchChanged:(id)sender 
{
	UISwitch* switchButton = (UISwitch*)sender;
	CCDirectorIOS* director = (CCDirectorIOS*)[CCDirector sharedDirector];
	
	if (switchButton.on)
	{
		// if there's no running scene yet, add one
		if (director.runningScene == nil)
		{
			[director runWithScene:[HelloWorldLayer scene]];
		}
		
		[director startAnimation];
		director.view.hidden = NO;
	}
	else
	{
		[director stopAnimation];
		director.view.hidden = YES;
	}
}

- (IBAction) sceneChanged:(id)sender 
{
	CCDirector* director = [CCDirector sharedDirector];
	if (director.view.hidden == NO)
	{
		UISegmentedControl* sceneChanger = (UISegmentedControl*)sender;
		int selection = sceneChanger.selectedSegmentIndex;
		
		CCScene* newScene = [HelloWorldLayer scene];
		CCScene* trans = nil;
		if (selection == 0) 
		{
			trans = [CCTransitionSlideInL transitionWithDuration:1 scene:newScene];
		}
		else if (selection == 1)
		{
			trans = [CCTransitionShrinkGrow transitionWithDuration:1 scene:newScene];
		}
		else
		{
			trans = [CCTransitionSlideInR transitionWithDuration:1 scene:newScene];
		}
		
		[director replaceScene:trans];
	}
}

@end
