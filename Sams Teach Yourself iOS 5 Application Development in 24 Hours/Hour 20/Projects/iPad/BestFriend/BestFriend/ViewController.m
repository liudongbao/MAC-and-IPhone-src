//
//  ViewController.m
//  BestFriend
//
//  Created by John Ray on 9/23/11.
//  Copyright (c) 2011 John E. Ray. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController
@synthesize name;
@synthesize email;
@synthesize photo;
@synthesize map;
@synthesize zipAnnotation;

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
    [self setName:nil];
    [self setEmail:nil];
    [self setPhoto:nil];
    [self setMap:nil];
    [self setZipAnnotation:nil];
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

- (IBAction)newBFF:(id)sender {
    ABPeoplePickerNavigationController *picker;
    picker=[[ABPeoplePickerNavigationController alloc] init];
	picker.peoplePickerDelegate = self;
    [self presentModalViewController:picker animated:YES];
}

- (void)peoplePickerNavigationControllerDidCancel:
(ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier {
    //We won't get to this delegate method
	
    return NO;
}

- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
	  shouldContinueAfterSelectingPerson:(ABRecordRef)person {
	
	// Retrieve the friend's name from the address book person record
    NSString *friendName;
    NSString *friendEmail;
    NSString *friendZip;
    
    friendName=(__bridge NSString *)ABRecordCopyValue
                    (person, kABPersonFirstNameProperty);
    self.name.text = friendName;
    
    ABMultiValueRef friendAddressSet;
	NSDictionary *friendFirstAddress;
    friendAddressSet = ABRecordCopyValue
                        (person, kABPersonAddressProperty);
    
    if (ABMultiValueGetCount(friendAddressSet)>0) {
        friendFirstAddress = (__bridge NSDictionary *)
                ABMultiValueCopyValueAtIndex(friendAddressSet,0);
        friendZip = [friendFirstAddress objectForKey:@"ZIP"];
        [self centerMap:friendZip showAddress:friendFirstAddress];
    }
    
    ABMultiValueRef friendEmailAddresses;
    friendEmailAddresses = ABRecordCopyValue
                            (person, kABPersonEmailProperty);
    
    if (ABMultiValueGetCount(friendEmailAddresses)>0) {
        friendEmail=(__bridge NSString *)
                ABMultiValueCopyValueAtIndex(friendEmailAddresses, 0);
        self.email.text = friendEmail;
    }
    
	if (ABPersonHasImageData(person)) {
		self.photo.image = [UIImage imageWithData:
                       (__bridge NSData *)ABPersonCopyImageData(person)];
	}
	
    [self dismissModalViewControllerAnimated:YES];
	return NO;
}

- (void)centerMap:(NSString*)zipCode 
      showAddress:(NSDictionary*)fullAddress {
    NSString *queryURL;
    NSString *queryResults;
    NSArray *queryData;
    double latitude;
    double longitude;
    MKCoordinateRegion mapRegion;
    
    queryURL = [[NSString alloc] 
                initWithFormat:
                @"http://maps.google.com/maps/geo?output=csv&q=%@", 
                zipCode];
    
    queryResults = [[NSString alloc] 
                    initWithContentsOfURL: [NSURL URLWithString:queryURL]
                    encoding: NSUTF8StringEncoding 
                    error: nil];
    queryData = [queryResults componentsSeparatedByString:@","];
    
    if([queryData count]==4) {
        latitude=[[queryData objectAtIndex:2] doubleValue];
        longitude=[[queryData objectAtIndex:3] doubleValue];
        //     CLLocationCoordinate2D;
        mapRegion.center.latitude=latitude;
        mapRegion.center.longitude=longitude;
        mapRegion.span.latitudeDelta=0.2;
        mapRegion.span.longitudeDelta=0.2;
        [self.map setRegion:mapRegion animated:YES];
		
		if (zipAnnotation!=nil) {
			[self.map removeAnnotation: zipAnnotation];
		}
		zipAnnotation = [[MKPlacemark alloc] 
                         initWithCoordinate:mapRegion.center 
                         addressDictionary:fullAddress];
        [map addAnnotation:zipAnnotation];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView 
            viewForAnnotation:(id <MKAnnotation>)annotation {
    MKPinAnnotationView *pinDrop=[[MKPinAnnotationView alloc]
                                  initWithAnnotation:annotation 
                                  reuseIdentifier:@"myspot"];
    pinDrop.animatesDrop=YES;
    pinDrop.canShowCallout=YES;
    pinDrop.pinColor=MKPinAnnotationColorPurple;
    return pinDrop;
}

- (IBAction)sendEmail:(id)sender {
    MFMailComposeViewController *mailComposer;
    NSArray *emailAddresses;
    emailAddresses=[[NSArray alloc]initWithObjects: self.email.text,nil];
    
    mailComposer=[[MFMailComposeViewController alloc] init];
    mailComposer.mailComposeDelegate=self;
    [mailComposer setToRecipients:emailAddresses];
    [self presentModalViewController:mailComposer animated:YES];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller 
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError*)error {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)sendTweet:(id)sender {
    TWTweetComposeViewController *tweetComposer;
    tweetComposer=[[TWTweetComposeViewController alloc] init];
    if ([TWTweetComposeViewController canSendTweet]) {
        [tweetComposer setInitialText:@"I'm on my way."];
        [self presentModalViewController:tweetComposer animated:YES];
    }
}

@end
