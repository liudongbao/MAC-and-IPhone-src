//
//  ViewController.h
//  ViewBasedAppWithCocos2D
//
//  Created by Steffen Itterheim on 24.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <CCDirectorDelegate>
- (IBAction)switchChanged:(id)sender;
- (IBAction)sceneChanged:(id)sender;

@end
