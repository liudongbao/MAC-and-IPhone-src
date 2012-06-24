//
//  FlipsideViewController.h
//  AppSettings
//
//  Created by Dave Mark on 11/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FlipsideViewControllerDelegate;


@interface FlipsideViewController : UIViewController {
	id <FlipsideViewControllerDelegate> delegate;
	UISwitch *engineSwitch;
    UISlider *warpFactorSlider;
}

@property (nonatomic, assign) id <FlipsideViewControllerDelegate> delegate;
@property (nonatomic, retain) IBOutlet UISwitch *engineSwitch;
@property (nonatomic, retain) IBOutlet UISlider *warpFactorSlider;

- (void)refreshFields;
- (IBAction)touchEngineSwitch;
- (IBAction)touchWarpSlider;
- (IBAction)done:(id)sender;
@end


@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end

