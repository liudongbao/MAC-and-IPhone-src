//
//  About.h
//  Chapter3 Framework
//
//  Created by Joe Hogue on 6/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GameState.h"

@interface About : GameState {
	UIView* subview;
}

@property (nonatomic, retain) IBOutlet UIView* subview;

- (IBAction) yup;

@end
