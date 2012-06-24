//
//  CellsViewController.h
//  Cells
//
//  Created by Dave Mark on 12/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kNameValueTag    1
#define kColorValueTag   2

@interface CellsViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate>
{
    NSArray    *computers;
	UITableViewCell *tvCell;
}
@property (nonatomic, retain) NSArray *computers;
@property (nonatomic, retain) IBOutlet UITableViewCell *tvCell;
@end