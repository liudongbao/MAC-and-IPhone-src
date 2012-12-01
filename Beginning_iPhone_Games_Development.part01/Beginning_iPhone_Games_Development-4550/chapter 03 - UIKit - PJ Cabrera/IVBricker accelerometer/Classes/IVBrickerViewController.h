//
//  IVBrickerViewController.h
//  IVBricker
//
//  Created by PJ Cabrera on 9/26/09.
//  Copyright PJ Cabrera 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IVBrickerViewController : UIViewController 
<UIAccelerometerDelegate> 
{
	UILabel *scoreLabel;
	UIImageView *ball;
	UIImageView *paddle;
	
	CGPoint ballMovement;
}

@property (nonatomic, retain) IBOutlet UILabel *scoreLabel;
@property (nonatomic, retain) IBOutlet UIImageView *ball;
@property (nonatomic, retain) IBOutlet UIImageView *paddle;

- (void)initializeTimer;

- (void)animateBall:(NSTimer *)theTimer;

@end

