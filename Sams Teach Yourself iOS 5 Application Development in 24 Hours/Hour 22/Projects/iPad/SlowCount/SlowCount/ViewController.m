//
//  ViewController.m
//  SlowCount
//
//  Created by John Ray on 9/21/11.
//  Copyright (c) 2011 John E. Ray. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController
@synthesize theCount;
@synthesize theTimer;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    counterTask = [[UIApplication sharedApplication]
                   beginBackgroundTaskWithExpirationHandler:^{
                       // If you’re worried about exceeding 10 minutes, handle it here
                   }];
    count=0;
    self.theTimer=[NSTimer scheduledTimerWithTimeInterval:0.1
                                              target:self
                                            selector:@selector(countUp)
                                            userInfo:nil
                                             repeats:YES];
}

- (void)countUp {
    if (count==1000) {
        [self.theTimer invalidate];
        [self setTheTimer:nil];
        [[UIApplication sharedApplication] endBackgroundTask:counterTask];
    } else {
        count++;
        NSString *currentCount;
        currentCount=[[NSString alloc] initWithFormat:@"%d",count];
        self.theCount.text=currentCount;
    }
}

- (void)viewDidUnload
{
    [self setTheTimer:nil];
    [self setTheCount:nil];
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

@end
