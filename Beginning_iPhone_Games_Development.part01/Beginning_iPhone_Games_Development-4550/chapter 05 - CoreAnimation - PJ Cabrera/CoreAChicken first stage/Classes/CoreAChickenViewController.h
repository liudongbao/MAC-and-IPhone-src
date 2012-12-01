//
//  CoreAChickenViewController.h
//  CoreAChicken
//
//  Created by PJ Cabrera on 9/3/09.
//  Copyright PJ Cabrera 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CoreAChickenViewController : UIViewController {
	UIBarButtonItem *animateButton;
	UIView *firstView;
	UIView *secondView;
	UIImageView *theChicken;
	UIImageView *theRoad;
}

@property (nonatomic, retain) IBOutlet UIBarButtonItem *animateButton;
@property (nonatomic, retain) IBOutlet UIView *firstView;
@property (nonatomic, retain) IBOutlet UIView *secondView;
@property (nonatomic, retain) IBOutlet UIImageView *theChicken;
@property (nonatomic, retain) IBOutlet UIImageView *theRoad;

- (IBAction)animate;

@end

