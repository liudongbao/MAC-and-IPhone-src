//
//  GameState.h
//  Test_Framework
//
//  Created by Paul Zirkle on 2/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GameStateManager.h"
#import <UIKit/UIView.h>

/*  GameState - usage
 
 GameState inherits from UIView, so create instances as [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 200)]
 
 */

@interface GameState : UIView {
	GameStateManager* m_pManager;
}
-(id) initWithFrame:(CGRect)frame andManager:(GameStateManager*)pManager;
-(void) Render;
-(void) Update;
-(bool) HandleEvent: (void*)event;

@end
