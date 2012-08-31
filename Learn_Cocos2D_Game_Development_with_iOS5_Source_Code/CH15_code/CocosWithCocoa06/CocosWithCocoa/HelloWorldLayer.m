//
//  HelloWorldLayer.m
//  CocosWithCocoa01
//
//  Created by Steffen Itterheim on 08.06.11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "HelloWorldLayer.h"
#import "MyView.h"


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
		CCLabelTTF* label = [CCLabelTTF labelWithString:@"Hello Cocos2D!" fontName:@"Marker Felt" fontSize:80];
		CGSize size = [[CCDirector sharedDirector] winSize];
		label.position = CGPointMake(size.width / 2, size.height);
		label.color = ccORANGE;
		[self addChild:label];
		
		id move1 = [CCMoveTo actionWithDuration:4 position:CGPointMake(size.width / 2, 0)];
		id move2 = [CCMoveTo actionWithDuration:4 position:label.position];
		id sequence = [CCSequence actions:move1, move2, nil];
		id repeat = [CCRepeatForever actionWithAction:sequence];
		[label runAction:repeat];

		CCLabelTTF* label2 = [CCLabelTTF labelWithString:@"Hello Cocos2D!" fontName:@"Marker Felt" fontSize:66];
		label2.position = CGPointMake(310, 270);
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

	// get the cocos2d view (it's the EAGLView class which inherits from UIView)
	UIView* glView = [CCDirector sharedDirector].openGLView;
	// The dummy UIView you created in the App delegate is the superview of the glView
	UIView* dummyView = glView.superview;

	
	// regular text field with rounded corners
	UITextField* textField = [[UITextField alloc] initWithFrame:CGRectMake(40, 20, 200, 24)];
	textField.text = @"  Regular UITextField";
	textField.borderStyle = UITextBorderStyleRoundedRect;
	textField.delegate = self;
	
	// text field that uses an image as background (aka "skinning")
	UITextField* textFieldSkinned = [[UITextField alloc] initWithFrame:CGRectMake(40, 60, 200, 24)];
	textFieldSkinned.text = @"  With background image";
	textFieldSkinned.delegate = self;
	
	// load and assign the UIImage as background of the text field
	NSString* imageFile = [CCFileUtils fullPathFromRelativePath:@"background-frame.png"];
	CCLOG(@"imageFile with path = %@", imageFile);
	UIImage* image = [[UIImage alloc] initWithContentsOfFile:imageFile];
	textFieldSkinned.background = image;
	

	// add the text fields to the dummy view
	[dummyView addSubview:textField];
	[dummyView addSubview:textFieldSkinned];

	[textField release];
	[textFieldSkinned release];
	[image release];

	
	// send the cocos2d view to the front so it is in front of the other views
	[dummyView bringSubviewToFront:glView];

	
	// make the cocos2d view transparent
	// IMPORTANT: transparent cocos2d view requires EAGLView pixelFormat set to kEAGLColorFormatRGBA8 (not the default)
	glClearColor(0.0, 0.0, 0.0, 0.0);
	glView.opaque = NO;

	
	// Allow touches to be ignored by cocos2d view and passed through to the text fields.
	// This will disable all touch events for cocos2d view however, so it's only useful in some cases.
	//glView.userInteractionEnabled = NO;

	
	// just for kicks, add another text field which is still in front of cocos2d
	UITextField* textFieldFront = [[UITextField alloc] initWithFrame:CGRectMake(280, 40, 200, 24)];
	textFieldFront.text = @"  On top of Cocos2D";
	textFieldFront.borderStyle = UITextBorderStyleRoundedRect;
	textFieldFront.delegate = self;
	
	[glView addSubview:textFieldFront];
	// send to back if you want to
	//[glView sendSubviewToBack:textFieldFront]; 
	[textFieldFront release];
	
	
	// add a Interface Builder view
	MyView* myViewController = [[MyView alloc] initWithNibName:@"MyView" bundle:nil];
	[dummyView addSubview:myViewController.view];
	[dummyView sendSubviewToBack:myViewController.view]; // optional
	[myViewController release];
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

-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	CCLOG(@"cocos2d view touched: %@", event);
	
	// highlight touched cocos2d nodes
	UITouch* touch = [touches anyObject];
	CGPoint touchLocation = [touch locationInView:[touch view]];
	touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];

	CCNode* node = nil;
	CCARRAY_FOREACH([self children], node)
	{
		bool hit = CGRectContainsPoint([node boundingBox], touchLocation);
		if (hit && [node conformsToProtocol:@protocol(CCRGBAProtocol)])
		{
			ccColor3B randomColor = ccc3(CCRANDOM_0_1() * 255, CCRANDOM_0_1() * 255, CCRANDOM_0_1() * 255);
			[(CCNode<CCRGBAProtocol>*)node setColor:randomColor];
		}
	}
}

@end
