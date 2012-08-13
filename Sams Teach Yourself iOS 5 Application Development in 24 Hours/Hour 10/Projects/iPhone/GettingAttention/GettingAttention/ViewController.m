//
//  ViewController.m
//  GettingAttention
//
//  Created by John Ray on 9/9/11.
//  Copyright (c) 2011 John E. Ray. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController
@synthesize userOutput;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setUserOutput:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (IBAction)doAlert:(id)sender {
    UIAlertView *alertDialog;
	alertDialog = [[UIAlertView alloc] 
                   initWithTitle: @"Alert Button Selected" 
                   message:@"I need your attention NOW!" 
                   delegate: nil 
                   cancelButtonTitle: @"Ok"
                   otherButtonTitles: nil];
	[alertDialog show];
}

- (IBAction)doMultiButtonAlert:(id)sender {
    UIAlertView *alertDialog;
    alertDialog = [[UIAlertView alloc] 
                   initWithTitle: @"Alert Button Selected"
                   message:@"I need your attention NOW!" 
                   delegate: self 
                   cancelButtonTitle: @"Ok" 
                   otherButtonTitles: @"Maybe Later", @"Never", nil]; 
	[alertDialog show];
}

- (IBAction)doAlertInput:(id)sender {
    UIAlertView *alertDialog;
	alertDialog = [[UIAlertView alloc] 
                   initWithTitle: @"Email Address" 
                   message:@"Please enter your email address:" 
                   delegate: self 
                   cancelButtonTitle: @"Ok"
                   otherButtonTitles: nil];
    alertDialog.alertViewStyle=UIAlertViewStylePlainTextInput;
	[alertDialog show];
}

- (IBAction)doActionSheet:(id)sender {
    UIActionSheet *actionSheet;
	actionSheet=[[UIActionSheet alloc] initWithTitle:@"Available Actions"
                                  delegate:self 
                         cancelButtonTitle:@"Cancel" 
                    destructiveButtonTitle:@"Destroy"
                         otherButtonTitles:@"Negotiate",@"Compromise",nil];
	actionSheet.actionSheetStyle=UIActionSheetStyleBlackTranslucent;
    [actionSheet showFromRect:[(UIButton *)sender frame] 
                       inView:self.view animated:YES];
//	[actionSheet showInView:self.view];
}


- (IBAction)doSound:(id)sender {
    SystemSoundID soundID;
    NSString *soundFile = [[NSBundle mainBundle] 
						   pathForResource:@"soundeffect" ofType:@"wav"];
    
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)
									 [NSURL fileURLWithPath:soundFile]
									 , &soundID);
    AudioServicesPlaySystemSound(soundID); 
}


- (IBAction)doAlertSound:(id)sender {
    SystemSoundID soundID;
    NSString *soundFile = [[NSBundle mainBundle] 
						   pathForResource:@"alertsound" ofType:@"wav"];
    
    AudioServicesCreateSystemSoundID((__bridge CFURLRef) 
									 [NSURL fileURLWithPath:soundFile]
									 , &soundID);
    AudioServicesPlayAlertSound(soundID);  
}

- (IBAction)doVibration:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

- (void)actionSheet:(UIActionSheet *)actionSheet
        clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSString *buttonTitle=[actionSheet buttonTitleAtIndex:buttonIndex];
	if ([buttonTitle isEqualToString:@"Destroy"]) {
		self.userOutput.text=@"Clicked 'Destroy'";
	} else if ([buttonTitle isEqualToString:@"Negotiate"]) {
		self.userOutput.text=@"Clicked 'Negotiate'";
	} else if ([buttonTitle isEqualToString:@"Compromise"]) {
		self.userOutput.text=@"Clicked 'Compromise'";
	} else {
		self.userOutput.text=@"Clicked 'Cancel'";
	}
}

- (void)alertView:(UIAlertView *)alertView
        clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSString *buttonTitle=[alertView buttonTitleAtIndex:buttonIndex];
	if ([buttonTitle isEqualToString:@"Maybe Later"]) {
		self.userOutput.text=@"Clicked 'Maybe Later'";
    } else if ([buttonTitle isEqualToString:@"Never"]) {
		self.userOutput.text=@"Clicked 'Never'";
	} else {
		self.userOutput.text=@"Clicked 'Ok'";
	}
    
    if ([alertView.title 
         isEqualToString: @"Email Address"]) { 
        self.userOutput.text=[[alertView textFieldAtIndex:0] text];
    }
}


@end
