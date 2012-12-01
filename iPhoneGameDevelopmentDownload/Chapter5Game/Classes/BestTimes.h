//
//  BestTimes.h
//  Chapter5
//
//  Created by Joe Hogue on 7/27/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Options.h"
#import "GameState.h"

@interface BestTimes : GameState <UIAlertViewDelegate> {
	UIView* subview;
	IBOutlet UILabel* times;
}

- (IBAction) done;
- (IBAction) reset;

@property (nonatomic, retain) IBOutlet UIView* subview;

@end
