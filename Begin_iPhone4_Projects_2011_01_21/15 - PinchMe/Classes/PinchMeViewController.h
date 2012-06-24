//
//  PinchMeViewController.h
//  PinchMe
//
//  Created by Dave Mark on 12/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PinchMeViewController : UIViewController {
    UILabel *label;
    CGFloat initialFontSize;
}
@property (nonatomic, retain) IBOutlet UILabel *label;
@property CGFloat initialFontSize;
@end
