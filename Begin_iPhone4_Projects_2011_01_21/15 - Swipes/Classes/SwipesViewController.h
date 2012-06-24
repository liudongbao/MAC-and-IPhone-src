//
//  SwipesViewController.h
//  Swipes
//
//  Created by Dave Mark on 12/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SwipesViewController : UIViewController {
    UILabel     *label;
    CGPoint     gestureStartPoint;
}
@property (nonatomic, retain) IBOutlet UILabel *label;
@property CGPoint gestureStartPoint;
- (void)eraseText;
@end