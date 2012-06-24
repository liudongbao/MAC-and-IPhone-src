//
//  DetailViewController.h
//  Presidents
//
//  Created by Dave Mark on 12/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate> {
    
    UIPopoverController *popoverController;
    UIToolbar *toolbar;
    
    id detailItem;
    UILabel *detailDescriptionLabel;
    UIWebView *webView;
	UIBarButtonItem *languageButton;
    UIPopoverController *languagePopoverController;
    NSString *languageString;	
}

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;

@property (nonatomic, retain) id detailItem;
@property (nonatomic, retain) IBOutlet UILabel *detailDescriptionLabel;
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *languageButton;
@property (nonatomic, retain) UIPopoverController *languagePopoverController;
@property (nonatomic, copy) NSString *languageString;
- (IBAction)touchLanguageButton;
@end