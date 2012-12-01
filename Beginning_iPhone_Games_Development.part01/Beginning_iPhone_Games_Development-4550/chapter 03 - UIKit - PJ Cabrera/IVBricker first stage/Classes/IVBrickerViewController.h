//
//  IVBrickerViewController.h
//  IVBricker
//
//  Created by PJ Cabrera on 9/12/09.
//  Copyright PJ Cabrera 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IVBrickerViewController : UIViewController {
    UILabel *scoreLabel;
    int score;
}

@property (nonatomic, retain) IBOutlet UILabel *scoreLabel;

@end

