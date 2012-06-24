//
//  RowControlsController.h
//  Nav
//
//  Created by Dave Mark on 12/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SecondLevelViewController.h"

@interface RowControlsController : SecondLevelViewController {
    NSArray *list;
}
@property (nonatomic, retain) NSArray *list;
- (IBAction)buttonTapped:(id)sender;
@end
