//
//  State_LabViewController.m
//  State Lab
//
//  Created by Dave Mark on 12/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "State_LabViewController.h"

@interface State_LabViewController ()
- (void)rotateLabelUp;
- (void)rotateLabelDown;
@end

@implementation State_LabViewController
@synthesize label;
@synthesize smiley, smileyView;
@synthesize segmentedControl;

- (void)rotateLabelDown {
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         label.transform = CGAffineTransformMakeRotation(M_PI);
                     }
                     completion:^(BOOL finished){ 
                         [self rotateLabelUp]; }];
}

- (void)rotateLabelUp {
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         label.transform = CGAffineTransformMakeRotation(0);
                     }
                     completion:^(BOOL finished){
                         if (animate) {
                             [self rotateLabelDown]; 
                         }
                     }];
}

- (void)applicationWillResignActive {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    animate = NO;
}

- (void)applicationDidBecomeActive {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    animate = YES;
    [self rotateLabelDown];
}

- (void)applicationDidEnterBackground {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    UIApplication *app = [UIApplication sharedApplication];
    
    UIBackgroundTaskIdentifier taskId;
    taskId = [app beginBackgroundTaskWithExpirationHandler:^{
        NSLog(@"Background task ran out of time and was terminated.");
        [app endBackgroundTask:taskId];
    }];
    
    if (taskId == UIBackgroundTaskInvalid) {
        NSLog(@"Failed to start background task!");
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{        
        NSLog(@"Starting background task with %f seconds remaining",
              app.backgroundTimeRemaining);
		self.smiley = nil;
    self.smileyView.image = nil;
    NSInteger selectedIndex = self.segmentedControl.selectedSegmentIndex;
    [[NSUserDefaults standardUserDefaults] setInteger:selectedIndex 
                                               forKey:@"selectedIndex"];
    // simulate a lengthy procedure
    [NSThread sleepForTimeInterval:10];
        NSLog(@"Finishing background task with %f seconds remaining",
              app.backgroundTimeRemaining);
        [app endBackgroundTask:taskId];
    });
}

- (void)applicationWillEnterForeground {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    NSString *smileyPath = [[NSBundle mainBundle] pathForResource:@"smiley"
                                                           ofType:@"png"];
    self.smiley = [UIImage imageWithContentsOfFile:smileyPath];
    self.smileyView.image = self.smiley;
}

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


- (void)viewDidLoad {
    [super viewDidLoad];
	
    [[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(applicationDidEnterBackground) 
												 name:UIApplicationDidEnterBackgroundNotification
											   object:[UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(applicationWillEnterForeground) 
												 name:UIApplicationWillEnterForegroundNotification
											   object:[UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(applicationWillResignActive)
												 name:UIApplicationWillResignActiveNotification
											   object:[UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(applicationDidBecomeActive)
												 name:UIApplicationDidBecomeActiveNotification
											   object:[UIApplication sharedApplication]];

    CGRect bounds = self.view.bounds;
    CGRect labelFrame = CGRectMake(bounds.origin.x, CGRectGetMidY(bounds) - 50,
                                   bounds.size.width, 100);
    self.label = [[[UILabel alloc] initWithFrame:labelFrame] autorelease];
    label.font = [UIFont fontWithName:@"Helvetica" size:70];
    label.text = @"Bazinga!";
    label.textAlignment = UITextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    // smiley.png is 84 x 84
    CGRect smileyFrame = CGRectMake(CGRectGetMidX(bounds) - 42,
                                    CGRectGetMidY(bounds)/2 - 42,
                                    84, 84);
    self.smileyView = [[[UIImageView alloc] initWithFrame:smileyFrame] autorelease];
    self.smileyView.contentMode = UIViewContentModeCenter;
    NSString *smileyPath = [[NSBundle mainBundle] pathForResource:@"smiley"
                                                           ofType:@"png"];
    self.smiley = [UIImage imageWithContentsOfFile:smileyPath];
    self.smileyView.image = self.smiley;
    self.segmentedControl = [[[UISegmentedControl alloc] initWithItems:
                              [NSArray arrayWithObjects:
                               @"One", @"Two", @"Three", @"Four", nil]] autorelease];
    self.segmentedControl.frame = CGRectMake(bounds.origin.x + 20, 
                                             CGRectGetMaxY(bounds) - 50,
                                             bounds.size.width - 40, 30);
	
    [self.view addSubview:segmentedControl];	
    [self.view addSubview:smileyView];
    [self.view addSubview:label];
    NSNumber *indexNumber;
    if (indexNumber = [[NSUserDefaults standardUserDefaults]
                       objectForKey:@"selectedIndex"]) {
        NSInteger selectedIndex = [indexNumber intValue];
        self.segmentedControl.selectedSegmentIndex = selectedIndex;
    }
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.label = nil;
    self.smiley = nil;
    self.smileyView = nil;
    self.segmentedControl = nil;
    [super viewDidUnload];
}

- (void)dealloc {
    [label release];
    [smiley release];
    [smileyView release];
    [segmentedControl release];
    [super dealloc];
}


@end
