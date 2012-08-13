//
//  ViewController.h
//  FlowerColorTable
//
//  Created by John E. Ray on 10/17/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *redFlowers;
@property (nonatomic, strong) NSArray *blueFlowers;

@end
