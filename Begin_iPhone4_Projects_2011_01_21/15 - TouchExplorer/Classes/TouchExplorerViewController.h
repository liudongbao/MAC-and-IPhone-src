//
//  TouchExplorerViewController.h
//  TouchExplorer
//
//  Created by Dave Mark on 12/14/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TouchExplorerViewController : UIViewController {
    UILabel    *messageLabel;
    UILabel    *tapsLabel;
    UILabel    *touchesLabel;
}
@property (nonatomic, retain) IBOutlet UILabel *messageLabel;
@property (nonatomic, retain) IBOutlet UILabel *tapsLabel;
@property (nonatomic, retain) IBOutlet UILabel *touchesLabel;
- (void)updateLabelsFromTouches:(NSSet *)touches;
@end
