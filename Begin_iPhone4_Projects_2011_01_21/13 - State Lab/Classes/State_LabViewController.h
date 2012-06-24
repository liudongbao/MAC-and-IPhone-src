//
//  State_LabViewController.h
//  State Lab
//
//  Created by Dave Mark on 12/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

@interface State_LabViewController : UIViewController {
    BOOL animate;
    UILabel *label;
    UIImage *smiley;
    UIImageView *smileyView;
    UISegmentedControl *segmentedControl;
}
@property (nonatomic, retain) UILabel *label;
@property (nonatomic, retain) UIImage *smiley;
@property (nonatomic, retain) UIImageView *smileyView;
@property (nonatomic, retain) UISegmentedControl *segmentedControl;
@end
