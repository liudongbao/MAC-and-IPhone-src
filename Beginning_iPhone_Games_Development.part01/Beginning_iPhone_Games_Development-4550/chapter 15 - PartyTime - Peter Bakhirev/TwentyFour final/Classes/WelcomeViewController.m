//
//  WelcomeViewController.m
//  TwentyFour
//

#import "WelcomeViewController.h"
#import "TwentyFourAppDelegate.h"


@implementation WelcomeViewController

@synthesize input;

// View is now visible
- (void)viewDidAppear:(BOOL)animated {
  // Display keyboard
  [input becomeFirstResponder];
  [super viewDidAppear:animated];
}

// This is called whenever "Return" is touched on iPhone's keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
  if ( theTextField.text == nil || [theTextField.text length] < 1 ) {
    return NO;
  }

  // Dismiss keyboard
  [theTextField resignFirstResponder];

  // Save player's name and move on to the next view
  [[TwentyFourAppDelegate getInstance] playerNameEntered:theTextField.text];

	return YES;
}

- (void)dealloc {
  self.input = nil;
  [super dealloc];
}

@end
