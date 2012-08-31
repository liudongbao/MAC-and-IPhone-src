//
//  RootViewController.m
//  CocosWithCocoa01
//
//  Created by Steffen Itterheim on 08.06.11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

//
// RootViewController + iAd
// If you want to support iAd, use this class as the controller of your iAd
//

#import "cocos2d.h"

#import "RootViewController.h"
#import "GameConfig.h"

@implementation RootViewController

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
	CCLOG(@"shouldAutorotateTo: %i", interfaceOrientation);

#if GAME_AUTOROTATION == kGameAutorotationNone

	return (interfaceOrientation == UIInterfaceOrientationPortrait);
	
#elif GAME_AUTOROTATION == kGameAutorotationCCDirector

	// autorotate to landscape orientations
	if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
	{
		[[CCDirector sharedDirector] setDeviceOrientation:kCCDeviceOrientationLandscapeRight];
	}
	else if (interfaceOrientation == UIInterfaceOrientationLandscapeRight)
	{
		[[CCDirector sharedDirector] setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
	}

	// if your app only supports portrait mode uncomment this block and remove the above code
	// or leave the above code to support all four device orientations
	/*
	if (interfaceOrientation == UIInterfaceOrientationPortrait)
    {
        [[CCDirector sharedDirector] setDeviceOrientation:kCCDeviceOrientationPortrait];
    }
    else if (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) 
    {
        [[CCDirector sharedDirector] setDeviceOrientation:kCCDeviceOrientationPortraitUpsideDown];
    }
	*/

	return (interfaceOrientation == UIInterfaceOrientationPortrait);
	
#elif GAME_AUTOROTATION == kGameAutorotationUIViewController

	// support all landscape orientations
	return (UIInterfaceOrientationIsLandscape(interfaceOrientation));

	// support all portrait orientations
	//return (UIInterfaceOrientationIsPortrait(interfaceOrientation));

	// support all four orientations
	//return (UIInterfaceOrientationIsLandscape(interfaceOrientation) || UIInterfaceOrientationIsPortrait(interfaceOrientation));
	
#else
#error Unknown value in GAME_AUTOROTATION
#endif // GAME_AUTOROTATION
	
	return NO;
}

//
// This callback only will be called when GAME_AUTOROTATION == kGameAutorotationUIViewController
//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	CGRect screenRect = [UIScreen mainScreen].bounds;
	CGRect rect = CGRectZero;
	
	if (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
	{
		rect = screenRect;
	}
	else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight)
	{
		rect.size = CGSizeMake(screenRect.size.height, screenRect.size.width);
	}
	
	CCDirector* director = [CCDirector sharedDirector];
	EAGLView* glView = director.openGLView;
	float contentScaleFactor = [director contentScaleFactor];
	
	if (contentScaleFactor != 1) 
	{
		rect.size.width *= contentScaleFactor;
		rect.size.height *= contentScaleFactor;
	}
	
	glView.frame = rect;
}
#endif // GAME_AUTOROTATION == kGameAutorotationUIViewController

@end

