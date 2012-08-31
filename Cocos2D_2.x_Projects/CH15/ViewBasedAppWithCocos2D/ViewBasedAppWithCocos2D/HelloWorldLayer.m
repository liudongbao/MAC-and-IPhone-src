//
//  HelloWorldLayer.m
//  cocos2d-project
//
//  Created by Steffen Itterheim on 11.06.11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


#import "HelloWorldLayer.h"

@interface HelloWorldLayer (PrivateMethods)
-(void) addManyLabels;
@end

@implementation HelloWorldLayer

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	HelloWorldLayer *layer = [HelloWorldLayer node];
	[scene addChild:layer];
	return scene;
}

-(id) init
{
	if ((self = [super init]))
	{
		[self addManyLabels];
		
		CCLabelTTF* label = [CCLabelTTF labelWithString:@"Hello Cocos2D!" 
											   fontName:@"Marker Felt" 
											   fontSize:CCRANDOM_0_1() * 40 + 30];

		CGSize size = [CCDirector sharedDirector].winSize;
	
		label.position = CGPointMake(size.width / 2, size.height / 2);
		label.color = ccc3(CCRANDOM_0_1() * 128 + 127, CCRANDOM_0_1() * 128 + 127, CCRANDOM_0_1() * 128 + 127);
		[self addChild:label];
		
		glClearColor(CCRANDOM_0_1() * 0.5f, CCRANDOM_0_1() * 0.5f, CCRANDOM_0_1() * 0.5f, 1.0f);
		id rotate = [CCRotateBy actionWithDuration:600 angle:CCRANDOM_0_1() * 360 * 100];
		[label runAction:rotate];
	}
	return self;
}

-(void) addManyLabels
{
	CGSize size = [CCDirector sharedDirector].winSize;
	
	NSArray* strings = [NSArray arrayWithObjects:
						@"Hello!",
						@"Deploying.",
						@"Preparing to dispense product.",
						@"Activated!",
						@"There you are! ",
						@"Who’s there? ",
						@"Hi!",
						@"Target acquired! ",
						@"Dispensing product.",
						@"Firing.",
						@"Hello, friend.",
						@"Gotcha!",
						@"Could you come over here?",
						@"Are you still there?",
						@"Coming through!",
						@"Excuse me.",
						@"Sorry.",
						@"My fault.",
						@"Oh! Ahhahahaha!",
						@"Critical error! ",
						@"Sorry! We’re closed.",
						@"Shutting down. ",
						@"I don’t blame you.",
						@"I don’t hate you.",
						@"Malfunction!",
						@"Hey! Hey, hey, hey! Put me down!",
						@"Whoa!",
						@"Syntax error! ",
						@"Unknown error!",
						@"Malfunctioning!",
						@"Oh! Ow ow ow ow ow!",
						@"Nap time…",
						@"Whyyyyyy… ",
						@"No hard feelings.",
						@"Owowowowowowow!",
						@"Sleep mode activated.",
						@"Hibernating.",
						@"Goodnight.",
						@"Resting.",
						@"Target lost! ",
						@"Can I help you?",
						@"Searching.",
						@"Canvassing.",
						@"Sentry mode activated.",
						@"Hey! It’s me! Don’t shoot!", nil];
	NSArray* fonts = [NSArray arrayWithObjects:@"Arial", @"Courier", @"Futura", @"Helvetica", @"Marker Felt", @"Verdana", @"Zapfino", nil];

	for (int i = 0; i < 50; i++) 
	{
		NSString* string = [strings objectAtIndex:CCRANDOM_0_1() * (strings.count - 1)];
		NSString* font = [fonts objectAtIndex:CCRANDOM_0_1() * (fonts.count - 1)];
		
		CCLabelTTF* label = [CCLabelTTF labelWithString:string 
											   fontName:font
											   fontSize:CCRANDOM_0_1() * 16 + 8];
		
		label.position = CGPointMake(CCRANDOM_0_1() * size.width, CCRANDOM_0_1() * size.height);
		label.color = ccc3(CCRANDOM_0_1() * 128, CCRANDOM_0_1() * 128, CCRANDOM_0_1() * 128);
		[self addChild:label];
		
		id rotate = [CCRotateBy actionWithDuration:600 angle:CCRANDOM_0_1() * 360 * 100];
		[label runAction:rotate];
	}
}

@end
