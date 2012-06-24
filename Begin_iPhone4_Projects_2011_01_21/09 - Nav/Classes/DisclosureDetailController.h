//
//  DisclosureDetailController.h
//  Nav
//
//  Created by Dave Mark on 12/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DisclosureDetailController : UIViewController {
    UILabel    *label;
    NSString   *message;
}
@property (nonatomic, retain) IBOutlet UILabel *label;
@property (nonatomic, copy) NSString *message;
@end
