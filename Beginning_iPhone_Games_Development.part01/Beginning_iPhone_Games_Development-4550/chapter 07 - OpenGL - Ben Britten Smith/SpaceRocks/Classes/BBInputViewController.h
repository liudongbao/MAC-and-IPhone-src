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


- (void)clearEvents;
- (void)dealloc ;
- (void)didReceiveMemoryWarning ;
- (void)loadView ;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)viewDidUnload ;
- (void)loadInterface;
- (void)updateInterface;
- (void)renderInterface;

-(CGRect)screenRectFromMeshRect:(CGRect)rect atPoint:(CGPoint)meshCenter;
// 7 methods



@end
