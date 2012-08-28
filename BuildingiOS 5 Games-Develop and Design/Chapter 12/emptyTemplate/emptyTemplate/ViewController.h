//
//  ViewController.h
//  emptyTemplate
//
//  Created by James Sugrue on 10/27/11.
//  Copyright (c) 2011 SoftwareX. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GameController;

@interface ViewController : UIViewController {
    GameController *sharedGameController;
}

- (void)draw;
- (void)setup;

@end
