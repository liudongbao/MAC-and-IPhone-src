//
//  ViewController.h
//  FlowerWeb
//
//  Created by John Ray on 9/2/11.
//  Copyright (c) 2011 John E. Ray. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (strong, nonatomic) IBOutlet UISegmentedControl *colorChoice;
@property (strong, nonatomic) IBOutlet UIWebView *flowerView;
@property (strong, nonatomic) IBOutlet UIWebView *flowerDetailView;

- (IBAction)getFlower:(id)sender;
- (IBAction)toggleFlowerDetail:(id)sender;

@end
