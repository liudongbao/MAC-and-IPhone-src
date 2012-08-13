//
//  ViewController.h
//  BestFriend
//
//  Created by John Ray on 9/23/11.
//  Copyright (c) 2011 John E. Ray. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MessageUI/MessageUI.h>
#import <Twitter/Twitter.h>


@interface ViewController : UIViewController 
    <ABPeoplePickerNavigationControllerDelegate,
    MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UILabel *name;
@property (strong, nonatomic) IBOutlet UILabel *email;
@property (strong, nonatomic) IBOutlet UIImageView *photo;
@property (strong, nonatomic) IBOutlet MKMapView *map;
@property (strong, nonatomic) MKPlacemark *zipAnnotation;

- (IBAction)newBFF:(id)sender;
- (IBAction)sendEmail:(id)sender;
- (IBAction)sendTweet:(id)sender;

- (void)centerMap:(NSString*)zipCode showAddress:(NSDictionary*)fullAddress;

@end
