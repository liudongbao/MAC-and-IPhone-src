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
		// color background to make the UIAlertView "darkening" effect noticable
		glClearColor(0.1f, 0.3f, 0.7f, 1.0f);

		CCLabelTTF* label = [CCLabelTTF labelWithString:@"Hello Cocos2D!" fontName:@"Marker Felt" fontSize:54];
		CGSize size = [[CCDirector sharedDirector] winSize];
		label.position = CGPointMake(size.width / 2, size.height / 6);
		[self addChild:label];

		[self addSomeCocoaTouch];
		
		self.isTouchEnabled = YES;
	}
	return self;
}

-(void) addSomeCocoaTouch
{
	CCLOG(@"Creating Cocoa Touch view ...");

	UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"UIAlertView over Cocos2D"
														message:@"Hello Cocoa Touch!"
													   delegate:self
											  cancelButtonTitle:@"Well"
											  otherButtonTitles:@"Done", nil];
	[alertView show];
	[alertView release];
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
	CGSize size = [[CCDirector sharedDirector] winSize];
	label.position = CGPointMake(CCRANDOM_0_1() * size.width, CCRANDOM_0_1() * size.height);
	label.color = labelColor;
	[self addChild:label];
	
	// keep the alert view alive by bringing it up again
	[self addSomeCocoaTouch];
}

// Notice how touch events are not received while the UIAlertView is active!
-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	CCLOG(@"I'm touched! %@", event);
}

@end
