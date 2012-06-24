//
//  DetailViewController.m
//  Presidents
//
//  Created by Dave Mark on 12/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"
#import "RootViewController.h"
#import "LanguageListController.h"

@interface DetailViewController ()
@property (nonatomic, retain) UIPopoverController *popoverController;
- (void)configureView;
@end



@implementation DetailViewController
@synthesize languageButton, languagePopoverController, languageString;

@synthesize toolbar, popoverController, detailItem, detailDescriptionLabel;
@synthesize webView;

static NSString * modifyUrlForLanguage(NSString *url, NSString *lang) {
    if (!lang) {
        return url;
    }
    
    // We're relying on a particular Wikipedia URL format here. This
    // is a bit fragile!
    NSRange languageCodeRange = NSMakeRange(7, 2);
    if ([[url substringWithRange:languageCodeRange] isEqualToString:lang]) {
        return url;
    } else {
        NSString *newUrl = [url stringByReplacingCharactersInRange:languageCodeRange
														withString:lang];
        return newUrl;
    }
}

#pragma mark -
#pragma mark Managing the detail item

/*
 When setting the detail item, update the view and dismiss the popover controller if it's showing.
 */
- (void)setDetailItem:(id)newDetailItem {
    if (detailItem != newDetailItem) {
        [detailItem release];
        detailItem = [modifyUrlForLanguage(newDetailItem, languageString) retain];
        
        // Update the view.
        [self configureView];
    }

    if (self.popoverController != nil) {
        [self.popoverController dismissPopoverAnimated:YES];
    }
	if (languagePopoverController != nil) {
        [languagePopoverController dismissPopoverAnimated:YES];
    }     	
}


- (void)configureView {
    // Update the user interface for the detail item.
    NSURL *url = [NSURL URLWithString:detailItem];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
	
    detailDescriptionLabel.text = [detailItem description];
}


#pragma mark -
#pragma mark Split view support

- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc {

    barButtonItem.title = @"Presidents";
    NSMutableArray *items = [[toolbar items] mutableCopy];
    [items insertObject:barButtonItem atIndex:0];
    [toolbar setItems:items animated:YES];
    [items release];
    self.popoverController = pc;
}


// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    
    NSMutableArray *items = [[toolbar items] mutableCopy];
    [items removeObjectAtIndex:0];
    [toolbar setItems:items animated:YES];
    [items release];
    self.popoverController = nil;
}


#pragma mark -
#pragma mark Rotation support

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


#pragma mark -
#pragma mark View lifecycle

/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
 */

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.popoverController = nil;
    self.webView = nil;
    self.languageButton = nil;
    self.languagePopoverController = nil;
}


#pragma mark -
#pragma mark Memory management

/*
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
*/

- (void)dealloc {
    [popoverController release];
    [toolbar release];
    
    [detailItem release];
    [detailDescriptionLabel release];
	[webView release];
	[languageButton release];
    [super dealloc];
}

- (void)setLanguageString:(NSString *)newString {
    if (![newString isEqualToString:languageString]) {
        [languageString release];
        languageString = [newString copy];
        self.detailItem = modifyUrlForLanguage(detailItem, languageString);
    }
}

- (IBAction)touchLanguageButton {
    LanguageListController *languageListController = [[LanguageListController alloc]
													  init];
    languageListController.detailViewController = self;
    UIPopoverController *poc = [[UIPopoverController alloc]
								initWithContentViewController:languageListController];
    [poc presentPopoverFromBarButtonItem:languageButton 
                permittedArrowDirections:UIPopoverArrowDirectionAny 
                                animated:YES];
    self.languagePopoverController = poc;
    [poc release];
    [languageListController release];
}

@end
