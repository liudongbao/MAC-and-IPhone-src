//
//  ShakeAndBreakViewController.h
//  ShakeAndBreak
//
//  Created by JN on 1/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

@interface ShakeAndBreakViewController : UIViewController {
    UIImageView *imageView;

    BOOL brokenScreenShowing; 
    SystemSoundID soundID;
    UIImage *fixed;
    UIImage *broken;
}
@property (nonatomic, retain) IBOutlet UIImageView *imageView; 
@property (nonatomic, retain) UIImage *fixed;
@property (nonatomic, retain) UIImage *broken;

@end

