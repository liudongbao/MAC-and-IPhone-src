//
//  Simple_TableViewController.h
//  Simple Table
//
//  Created by Dave Mark on 12/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Simple_TableViewController : UIViewController
<UITableViewDelegate, UITableViewDataSource>
{
    NSArray *listData;
}
@property (nonatomic, retain) NSArray *listData;
@end
