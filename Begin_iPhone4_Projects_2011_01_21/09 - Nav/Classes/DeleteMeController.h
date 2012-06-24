//
//  DeleteMeController.h
//  Nav
//
//  Created by Dave Mark on 12/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SecondLevelViewController.h"

@interface DeleteMeController : SecondLevelViewController {
    NSMutableArray *list;
}
@property (nonatomic, retain) NSMutableArray *list;
- (IBAction)toggleEdit:(id)sender;
@end
