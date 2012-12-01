//
//  BBInputViewController.h
//  BBOpenGLGameTemplate
//
//  Created by ben smith on 1/07/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BBInputViewController : UIViewController {
	NSMutableSet* touchEvents;
	
	NSMutableArray * interfaceObjects;
	
	CGFloat forwardMagnitude;
	CGFloat rightMagnitude;
	CGFloat leftMagnitude;
	BOOL fireMissile;
}

@property (retain) NSMutableSet* touchEvents;
@property (assign) CGFloat forwardMagnitude;
@property (assign) BOOL fireMissile;
@property (assign) CGFloat rightMagnitude;
@property (assign) CGFloat leftMagnitude;


- (CGRect)screenRectFromMeshRect:(CGRect)rect atPoint:(CGPoint)meshCenter;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil ;
- (void)clearEvents;
- (void)dealloc ;
- (void)didReceiveMemoryWarning ;
- (void)fireButtonDown;
- (void)fireButtonUp;
- (void)forwardButtonDown;
- (void)forwardButtonUp;
- (void)gameOver;
- (void)gameOverButtonDown;
- (void)gameOverButtonUp;
- (void)leftButtonDown;
- (void)leftButtonUp;
- (void)loadInterface;
- (void)loadView;
- (void)renderInterface;
- (void)rightButtonDown;
- (void)rightButtonUp;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)updateInterface;
- (void)viewDidUnload ;

// 24 methods



@end
