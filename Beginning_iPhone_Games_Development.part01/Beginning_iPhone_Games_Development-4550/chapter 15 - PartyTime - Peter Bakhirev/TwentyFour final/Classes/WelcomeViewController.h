//
//  WelcomeViewController.h
//  TwentyFour
//

#import <UIKit/UIKit.h>


@interface WelcomeViewController : UIViewController <UITextFieldDelegate> {
  UITextField *input;
}

@property (nonatomic, retain) IBOutlet UITextField *input;

@end
