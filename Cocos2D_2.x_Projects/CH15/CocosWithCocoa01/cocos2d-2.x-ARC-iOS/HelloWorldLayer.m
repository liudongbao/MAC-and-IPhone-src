//
//  HelloWorldLayer.m
//  cocos2d-2.x-ARC-iOS
//
//  Created by Steffen Itterheim on 27.04.12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


#import "HelloWorldLayer.h"

@implementation HelloWorldLayer

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	HelloWorldLayer *layer = [HelloWorldLayer node];
	[scene addChild: layer];
	return scene;
}

-(id) init
{
	if ((self = [super init]))
	{
		CCLayerGradient* layer = [CCLayerGradient layerWithColor:ccc4(100, 150, 255, 255)
														fadingTo:ccc4(255, 200, 50, 100) 
													 alongVector:ccp(0.75f, 0.25f)];
		[self addChild:layer];
		
		CCLabelTTF* label = [CCLabelTTF labelWithString:@"Hello Cocos2D!" fontName:@"Marker Felt" fontSize:100];
		CGSize size = [CCDirector sharedDirector].winSize;
		label.position = CGPointMake(size.width / 2, size.height / 2);
		label.color = ccRED;
		[self addChild:label];
		
		id rotate = [CCRotateBy actionWithDuration:3.6f angle:360];
		id repeat = [CCRepeatForever actionWithAction:rotate];
		[label runAction:repeat];
		
		CCLabelTTF* label2 = [CCLabelTTF labelWithString:@"Hello Cocos2D!" fontName:@"Marker Felt" fontSize:50];
		label2.position = CGPointMake(340, 270);
		label2.color = ccORANGE;
		[self addChild:label2];
		
		
		self.isTouchEnabled = YES;
		
		[self showAlertView];
		[self addSomeTextFields];
	}
	return self;
}

-(void) showAlertView
{
	CCLOG(@"Creating Cocoa Touch view ...");
	
	UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"UIAlertView over Cocos2D"
														message:@"Hello Cocoa Touch!"
													   delegate:self
											  cancelButtonTitle:@"Well"
											  otherButtonTitles:@"Done", nil];
	[alertView show];
}

-(void) alertView:(UIAlertView*)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	CCLOG(@"UIAlertView dismissed - Button Index: %i", buttonIndex);
	
	NSString* message = @"Well";
	ccColor3B labelColor = ccYELLOW;
	if (buttonIndex == 1)
	{
		message = @"Done";
		labelColor = ccGREEN;
	}
	
	CCLabelTTF* label = [CCLabelTTF labelWithString:message fontName:@"Arial" fontSize:32];
	CGSize size = [CCDirector sharedDirector].winSize;
	label.position = CGPointMake(CCRANDOM_0_1() * size.width, CCRANDOM_0_1() * size.height);
	label.color = labelColor;
	[self addChild:label];
	
	// keep the alert view alive by bringing it up again
	//[self showAlertView];
}

// Notice how touch events are not received while the UIAlertView is active!
-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	CCLOG(@"I'm touched! %@", event);
}

-(void) addSomeTextFields
{
	CCLOG(@"Creating Cocoa Touch view ...");
	
	// regular text field with rounded corners
	UITextField* textField = [[UITextField alloc] initWithFrame:CGRectMake(40, 20, 200, 24)];
	textField.text = @"  Regular UITextField";
	textField.borderStyle = UITextBorderStyleRoundedRect;
	textField.delegate = self;
	
	// text field that uses an image as background
	UITextField* textFieldSkinned = [[UITextField alloc] initWithFrame:CGRectMake(40, 60, 200, 24)];
	textFieldSkinned.text = @"  With background image";
	textFieldSkinned.delegate = self;
	
	// load and assign the image
	CCFileUtils* fileUtils = [CCFileUtils sharedFileUtils];
	NSString* imageFile = [fileUtils fullPathFromRelativePath:@"background-frame.png"];
	UIImage* image = [[UIImage alloc] initWithContentsOfFile:imageFile];
	textFieldSkinned.background = image;
	
	// add the text fields to the view
	UIView* glView = [CCDirector sharedDirector].view;
	[glView addSubview:textField];
	[glView addSubview:textFieldSkinned];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
	// only by calling this method will the keyboard be dismissed when tapping the RETURN key
	[textField resignFirstResponder];
	
	// if the text is empty, remove the text field
	if (textField.text.length == 0) 
	{
		[textField removeFromSuperview];
	}
	return YES;
}

@end
