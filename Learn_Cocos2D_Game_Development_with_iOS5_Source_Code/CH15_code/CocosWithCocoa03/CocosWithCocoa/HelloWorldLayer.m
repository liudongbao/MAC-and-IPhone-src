//
//  HelloWorldLayer.m
//  CocosWithCocoa01
//
//  Created by Steffen Itterheim on 08.06.11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "HelloWorldLayer.h"

@interface HelloWorldLayer (PrivateMethods)
-(void) addSomeCocoaTouch;
@end

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
		CCLabelTTF* label = [CCLabelTTF labelWithString:@"Hello Cocos2D!" fontName:@"Marker Felt" fontSize:100];
		CGSize size = [[CCDirector sharedDirector] winSize];
		label.position = CGPointMake(size.width / 2, size.height / 2);
		label.color = ccRED;
		[self addChild:label];
		
		id rotate = [CCRotateBy actionWithDuration:3.6f angle:360];
		id repeat = [CCRepeatForever actionWithAction:rotate];
		[label runAction:repeat];

		CCLabelTTF* label2 = [CCLabelTTF labelWithString:@"Hello Cocos2D!" fontName:@"Marker Felt" fontSize:54];
		label2.position = CGPointMake(340, 270);
		label2.color = ccMAGENTA;
		[self addChild:label2];
		
		[self addSomeCocoaTouch];
		
		self.isTouchEnabled = YES;
	}
	return self;
}

-(void) addSomeCocoaTouch
{
	CCLOG(@"Creating Cocoa Touch view ...");

	// regular text field with rounded corners
	UITextField* textField = [[UITextField alloc] initWithFrame:CGRectMake(40, 20, 200, 24)];
	textField.text = @"  Regular UITextField";
	textField.borderStyle = UITextBorderStyleRoundedRect;
	textField.delegate = self;
	
	// get the cocos2d view (it's the EAGLView class which inherits from UIView)
	UIView* glView = [CCDirector sharedDirector].openGLView;
	
	// add the text field to the cocos2d view
	[glView addSubview:textField];
	[textField release];

	// text field that uses an image as background (aka "skinning")
	UITextField* textFieldSkinned = [[UITextField alloc] initWithFrame:CGRectMake(40, 60, 200, 24)];
	textFieldSkinned.text = @"  With background image";
	textFieldSkinned.delegate = self;
	
	// load and assign the UIImage as background of the text field
	NSString* imageFile = [CCFileUtils fullPathFromRelativePath:@"background-frame.png"];
	CCLOG(@"imageFile with path = %@", imageFile);
	UIImage* image = [[UIImage alloc] initWithContentsOfFile:imageFile];
	textFieldSkinned.background = image;

	[glView addSubview:textFieldSkinned];
	[textFieldSkinned release];
	[image release];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
	// only by calling this method will the keyboard be dismissed when tapping the RETURN key
	[textField resignFirstResponder];
	
	// if the text is empty, remove the text field
	if ([textField.text length] == 0) 
	{
		[textField removeFromSuperview];
	}
	
	return YES;
}

@end
