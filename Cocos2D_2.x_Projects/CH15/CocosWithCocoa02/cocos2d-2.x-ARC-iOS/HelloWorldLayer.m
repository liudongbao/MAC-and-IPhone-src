//
//  HelloWorldLayer.m
//  cocos2d-2.x-ARC-iOS
//
//  Created by Steffen Itterheim on 27.04.12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


#import "HelloWorldLayer.h"
#import "MyView.h"

@implementation CCGLView (hittest)
-(BOOL) hitTestNodeChildren:(CCArray*)children point:(CGPoint)point
{
    BOOL hit = NO;
	
    if (children.count > 0)
    {
        Class sceneClass = [CCScene class];
        Class layerClass = [CCLayer class];
		
        for (CCNode* node in children)
        {
            // check the node's children first
            hit = [self hitTestNodeChildren:node.children point:point];
            
            // abort search on first hit
            if (hit)
            {
                break;
            }
            
            // scenes/layers are typically full screen, so do not hitTest them
            if ([node isKindOfClass:sceneClass] || [node isKindOfClass:layerClass]) 
            {
                continue;
            }
			
            // check the node itself
            hit = CGRectContainsPoint(node.boundingBox, point);
            
            // abort search on first hit
            if (hit) 
            {
                break;
            }
        }
    }
    
    return hit;
}

-(UIView*) hitTest:(CGPoint)point withEvent:(UIEvent*)event
{
    UIView* hitView = [super hitTest:point withEvent:event];
    
    if (hitView == self) 
    {
        CCScene* runningScene = [CCDirector sharedDirector].runningScene;
        CCArray* sceneChildren = runningScene.children;
        CGPoint glPoint = [[CCDirector sharedDirector] convertToGL:point];
		
        BOOL hit = [self hitTestNodeChildren:sceneChildren point:glPoint];
        return (hit ? self : nil);
    }
    
    return hitView;
}
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
		/*
		CCLayerGradient* layer = [CCLayerGradient layerWithColor:ccc4(255, 100, 255, 222)
														fadingTo:ccc4(50, 255, 50, 222) 
													 alongVector:ccp(0.75f, -0.25f)];
		[layer changeWidth:200 height:100];
		layer.position = CGPointMake(200, 150);
		[self addChild:layer];
		 */
		
		CCLabelTTF* label = [CCLabelTTF labelWithString:@"Hello Cocos2D!" fontName:@"Marker Felt" fontSize:50];
		CGSize size = [CCDirector sharedDirector].winSize;
		label.position = CGPointMake(size.width / 2, size.height / 2);
		label.color = ccRED;
		label.opacity = 200;
		[self addChild:label];
		
		id rotate = [CCRotateBy actionWithDuration:3.6f angle:360];
		id repeat = [CCRepeatForever actionWithAction:rotate];
		[label runAction:repeat];
		
		CCLabelTTF* label2 = [CCLabelTTF labelWithString:@"Hello Cocos2D!" fontName:@"Marker Felt" fontSize:50];
		label2.position = CGPointMake(340, 270);
		label2.color = ccORANGE;
		[self addChild:label2];
		
		
		self.isTouchEnabled = YES;
		
		//[self showAlertView];
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
	CCLOG(@"cocos2d view touched: %@", event);
	
	// highlight touched cocos2d nodes
	UITouch* touch = touches.anyObject;
	CGPoint touchLocation = [touch locationInView:touch.view];
	touchLocation = [[CCDirector sharedDirector] convertToGL:touchLocation];
	
	for (CCNode* node in self.children)
	{
		BOOL hit = CGRectContainsPoint(node.boundingBox, touchLocation);
		if (hit && [node conformsToProtocol:@protocol(CCRGBAProtocol)])
		{
			ccColor3B randomColor = ccc3(CCRANDOM_0_1() * 255, CCRANDOM_0_1() * 255, CCRANDOM_0_1() * 255);
			[(CCNode<CCRGBAProtocol>*)node setColor:randomColor];
		}
	}
}

-(void) addSomeTextFields
{
	CCLOG(@"Creating Cocoa Touch view ...");
	
	// get the cocos2d view (it's the EAGLView class which inherits from UIView)
	UIView* glView = [CCDirector sharedDirector].view;
	// The window UIView  created in the App delegate is the superview of the glView
	UIView* window = glView.superview;
	
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
	CCFileUtils* fileUtils = [CCFileUtils sharedFileUtils];
	NSString* imageFile = [fileUtils fullPathFromRelativePath:@"background-frame.png"];
	CCLOG(@"imageFile with path = %@", imageFile);
	UIImage* image = [[UIImage alloc] initWithContentsOfFile:imageFile];
	textFieldSkinned.background = image;
	
	// add the text fields to the window
	[window addSubview:textField];
	[window addSubview:textFieldSkinned];
	
	// send the cocos2d view to the front so it is in front of the other views
	[window bringSubviewToFront:glView];
	
	// make the cocos2d view transparent
	// IMPORTANT: transparent cocos2d view requires EAGLView pixelFormat
	// set to kEAGLColorFormatRGBA8 (not the default RGB565)
	glClearColor(0, 0, 0, 0);
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
	
	
	// add a Interface Builder view
	MyView* myViewController = [[MyView alloc] initWithNibName:@"MyView" bundle:nil];
	[window addSubview:myViewController.view];
	[window sendSubviewToBack:myViewController.view]; // optional
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
