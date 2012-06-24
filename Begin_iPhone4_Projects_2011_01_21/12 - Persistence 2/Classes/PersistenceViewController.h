//
//  PersistenceViewController.h
//  Persistence
//
//  Created by Dave Mark on 12/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kFilename         @"archive"
#define kDataKey          @"Data"

@interface PersistenceViewController : UIViewController {
    UITextField *field1;
    UITextField *field2;
    UITextField *field3;
    UITextField *field4;
}
@property (nonatomic, retain) IBOutlet UITextField *field1;
@property (nonatomic, retain) IBOutlet UITextField *field2;
@property (nonatomic, retain) IBOutlet UITextField *field3;
@property (nonatomic, retain) IBOutlet UITextField *field4;
- (NSString *)dataFilePath;
- (void)applicationWillResignActive:(NSNotification *)notification;
@end
