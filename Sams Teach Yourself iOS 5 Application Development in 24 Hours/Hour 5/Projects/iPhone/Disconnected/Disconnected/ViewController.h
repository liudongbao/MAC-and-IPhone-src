//
//  ViewController.h
//  Disconnected
//
//  Created by John Ray on 8/14/11.
//  Copyright (c) 2011 John E. Ray. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (strong, nonatomic) IBOutlet UISegmentedControl *colorChoice;
@property (strong, nonatomic) IBOutlet UIWebView *flowerView;
@property (strong, nonatomic) IBOutlet UILabel *chosenColor;

-(IBAction)getFlower:(id)sender;

@end