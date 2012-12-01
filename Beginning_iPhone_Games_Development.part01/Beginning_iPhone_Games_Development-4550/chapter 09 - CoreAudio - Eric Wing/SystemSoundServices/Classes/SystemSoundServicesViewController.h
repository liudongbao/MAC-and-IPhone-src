//
//  SystemSoundServicesViewController.h
//  SystemSoundServices
//
//  Created by Eric Wing on 7/2/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <AudioToolbox/AudioToolbox.h>

@interface SystemSoundServicesViewController : UIViewController
{
	SystemSoundID alertSoundID;
}

@property(nonatomic, assign) SystemSoundID alertSoundID;

- (IBAction) playSystemSound;
- (IBAction) playAlertSound;
- (IBAction) vibrate;

@end

