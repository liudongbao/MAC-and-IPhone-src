//
//  HelloWorldLayer.m
//  Essentials
//
//  Created by Steffen Itterheim on 14.07.10.
//  Copyright Steffen Itterheim 2010. All rights reserved.
//

#import "HelloWorldScene.h"

#import "MenuScene.h"


// private methods are declared in this manner to avoid "may not respond to ..." compiler warnings
@interface HelloWorld (PrivateMethods)
-(void) onCallFunc;
-(void) onCallFuncN:(id)sender;
-(void) onCallFuncND:(id)sender data:(void*)data;
-(void) onCallFuncO:(id)object;
-(void) createLabelWithOffset:(int)offset;
@end

@implementation HelloWorld

+(id) scene
{
	CCScene* scene = [CCScene node];
	CCLayer* layer = [HelloWorld node];
	[scene addChild:layer];
	return scene;
}

-(id) init
{
	if ((self = [super init]))
	{
		CCLOG(@"init %@", self);
		
		// enable touch input
		self.isTouchEnabled = YES;
		
		// enable accelerometer input
		self.isAccelerometerEnabled = YES;
		
		CGSize size = [[CCDirector sharedDirector] winSize];

		// how about adding a background image for kicks?
		// IMPORTANT: filenames are case sensitive on iOS devices!
		CCSprite* background = [CCSprite spriteWithFile:@"Default.png"];
		background.position = CGPointMake(size.width / 2, size.height / 2);
		// scaling the image beyond recognition here
		background.scaleX = 2;
		background.scaleY = 0.75f;
		[self addChild:background];
		
		// creating several versions of the Hello label with a small offset, colorized and using alpha blending
		[self createLabelWithOffset:0];
		[self createLabelWithOffset:-3];
		[self createLabelWithOffset:-6];
		[self createLabelWithOffset:-9];

		// add the "touch to continue" label
		CCLabelTTF* label = [CCLabelTTF labelWithString:@"Touch Screen For Awesome" fontName:@"AmericanTypewriter-Bold" fontSize:30];
		label.position = CGPointMake(size.width / 2, size.height / 8);
		[self addChild:label];

		// creating another label and aligning it at the top-right corner of the screen
		CCLabelTTF* labelAligned = [CCLabelTTF labelWithString:@"I'm topright aligned!" fontName:@"HiraKakuProN-W3" fontSize:30];
		labelAligned.position = CGPointMake(size.width, size.height);
		labelAligned.anchorPoint = CGPointMake(1, 1);
		labelAligned.color = ccMAGENTA;
		[self addChild:labelAligned];
		
		// this will have the -(void) update:(ccTime)delta method called every frame
		//[self scheduleUpdate];
		[self schedule:@selector(update:) interval:0.1f];

		// You'll notice that this causes a build warning when uncommented, and when you run the App it will crash.
		// That's because the Method can't be found and the compiler normally doesn't even warn you about that fact.
		// The compiler warning is called "Undeclared Selector" and in this project I've enabled it for you.
		//[self schedule:@selector(nonExistingMethodName) interval:1];
		
		// Example usage of the CallFunc actions to report the end of the jumping sequence
		CCTintTo* tint1 = [CCTintTo actionWithDuration:2 red:255 green:0 blue:0];
		CCCallFunc* func = [CCCallFunc actionWithTarget:self selector:@selector(onCallFunc)];
		CCTintTo* tint2 = [CCTintTo actionWithDuration:2 red:0 green:0 blue:255];
		CCCallFuncN* funcN = [CCCallFuncN actionWithTarget:self selector:@selector(onCallFuncN:)];
		CCTintTo* tint3 = [CCTintTo actionWithDuration:2 red:0 green:255 blue:0];
		CCCallFuncND* funcND = [CCCallFuncND actionWithTarget:self selector:@selector(onCallFuncND:data:) data:(void*)background];
		CCCallFuncO* funcO = [CCCallFuncO actionWithTarget:self selector:@selector(onCallFuncO:) object:background];
		CCSequence* sequence = [CCSequence actions:tint1, func, tint2, funcN, tint3, funcND, funcO, nil];
		[label runAction:sequence];
	}
	return self;
}

// Action CallFunc Methods
-(void) onCallFunc
{
	CCLOG(@"end of tint1, callFunc called!");
}
-(void) onCallFuncN:(id)sender
{
	CCLOG(@"end of tint2, callFuncN called! sender: %@", sender);
}
-(void) onCallFuncND:(id)sender data:(void*)data
{
	// be careful when casting pointers like this - you have to be 100% sure the object is of this type!
	CCSprite* sprite = (CCSprite*)data;
	CCLOG(@"end of sequence, callFuncND called! sender: %@ - data: %@", sender, sprite);
}
-(void) onCallFuncO:(id)object
{
    // object is the object you passed to CCCallFuncO
    CCLOG(@"callFuncO called! With object: %@", object);
}

// called onStart, the default (super) implementation is to
-(void) registerWithTouchDispatcher
{
	// make sure either of the two following lines are used
	// if you use both you'll receive both standard and targeted touch events, at the very least wasting performance
	// if you leave this method blank then you'll receive no touch events at all, despite self.isTouchEnabled being set!
	
	// call the base implementation (default touch handler)
	[super registerWithTouchDispatcher];
	
	// or use the targeted touch handler instead
	//[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:INT_MIN+1 swallowsTouches:YES];
}

-(void) update:(ccTime)delta
{
	// called every frame thanks to [self scheduleUpdate]
	
	// unschedule this method (_cmd is a shortcut and stands for the current method) so it won't be called anymore
	[self unschedule:_cmd];
	
	CCLOG(@"update with delta time: %f", delta);
	
	// re-schedule update randomly within the next 10 seconds
	float nextUpdate = CCRANDOM_0_1() * 10;
	[self schedule:_cmd interval:nextUpdate];
}

// This method creates a label. By placing the code in a method we can call it several times to create several versions
// of the same label. This is always preferable than using copy & paste because it's easier to maintain.
-(void) createLabelWithOffset:(int)offset
{
	CGSize size = [[CCDirector sharedDirector] winSize];

	CCLabelTTF* label = [CCLabelTTF labelWithString:@"Hello Cocos2D" fontName:@"AppleGothic" fontSize:60];
	// reducing opacity let's background objects shine through (alpha blending)
	label.opacity = 160;
	label.position = CGPointMake(size.width / 2 + offset, size.height / 2);
	[self addChild:label];

	id rotate = [CCRotateBy actionWithDuration:5 + CCRANDOM_0_1() * 0.1f angle:-360];
	id repeat = [CCRepeatForever actionWithAction:rotate];
	[label runAction:repeat];

	/* List of iOS Fonts available in iOS 3.1 and above
	 Family name: AppleGothic
	 Font name: AppleGothic
	 Family name: Hiragino Kaku Gothic ProN
	 Font name: HiraKakuProN-W6
	 Font name: HiraKakuProN-W3
	 Family name: Arial Unicode MS
	 Font name: ArialUnicodeMS
	 Family name: Heiti K
	 Font name: STHeitiK-Medium
	 Font name: STHeitiK-Light
	 Family name: DB LCD Temp
	 Font name: DBLCDTempBlack
	 Family name: Helvetica
	 Font name: Helvetica-Oblique
	 Font name: Helvetica-BoldOblique
	 Font name: Helvetica
	 Font name: Helvetica-Bold
	 Family name: Marker Felt
	 Font name: MarkerFelt-Thin
	 Family name: Times New Roman
	 Font name: TimesNewRomanPSMT
	 Font name: TimesNewRomanPS-BoldMT
	 Font name: TimesNewRomanPS-BoldItalicMT
	 Font name: TimesNewRomanPS-ItalicMT
	 Family name: Verdana
	 Font name: Verdana-Bold
	 Font name: Verdana-BoldItalic
	 Font name: Verdana
	 Font name: Verdana-Italic
	 Family name: Georgia
	 Font name: Georgia-Bold
	 Font name: Georgia
	 Font name: Georgia-BoldItalic
	 Font name: Georgia-Italic
	 Family name: Arial Rounded MT Bold
	 Font name: ArialRoundedMTBold
	 Family name: Trebuchet MS
	 Font name: TrebuchetMS-Italic
	 Font name: TrebuchetMS
	 Font name: Trebuchet-BoldItalic
	 Font name: TrebuchetMS-Bold
	 Family name: Heiti TC
	 Font name: STHeitiTC-Light
	 Font name: STHeitiTC-Medium
	 Family name: Geeza Pro
	 Font name: GeezaPro-Bold
	 Font name: GeezaPro
	 Family name: Courier
	 Font name: Courier
	 Font name: Courier-BoldOblique
	 Font name: Courier-Oblique
	 Font name: Courier-Bold
	 Family name: Arial
	 Font name: ArialMT
	 Font name: Arial-BoldMT
	 Font name: Arial-BoldItalicMT
	 Font name: Arial-ItalicMT
	 Family name: Heiti J
	 Font name: STHeitiJ-Medium
	 Font name: STHeitiJ-Light
	 Family name: Arial Hebrew
	 Font name: ArialHebrew
	 Font name: ArialHebrew-Bold
	 Family name: Courier New
	 Font name: CourierNewPS-BoldMT
	 Font name: CourierNewPS-ItalicMT
	 Font name: CourierNewPS-BoldItalicMT
	 Font name: CourierNewPSMT
	 Family name: Zapfino
	 Font name: Zapfino
	 Family name: American Typewriter
	 Font name: AmericanTypewriter
	 Font name: AmericanTypewriter-Bold
	 Family name: Heiti SC
	 Font name: STHeitiSC-Medium
	 Font name: STHeitiSC-Light
	 Family name: Helvetica Neue
	 Font name: HelveticaNeue
	 Font name: HelveticaNeue-Bold
	 Family name: Thonburi
	 Font name: Thonburi-Bold
	 Font name: Thonburi
	 */
	
	// Did you notice that the label colors are always the same every time you run the app even though
	// the CCRANDOM_0_1() method is used? This is because the random method is deterministic, it always
	// returns the same sequence of values.
	// Refer to EssentialsAppDelegate applicationDidFinishLaunching method and look for the comment on srandom.
	// It will explain how to change the random number sequence to be truly (more or less) random.
	float rand = CCRANDOM_0_1();
	CCLOG(@"createLabel: rand = %f", rand);
	
	if (rand < 0.2f)
		label.color = ccYELLOW;
	else if (rand < 0.4f)
		label.color = ccBLUE;
	else if (rand < 0.6f)
		label.color = ccGREEN;
	else if (rand < 0.8f)
		label.color = ccORANGE;
	else
		label.color = ccRED;
}

// Touch Input Events
-(CGPoint) locationFromTouches:(NSSet *)touches
{
	UITouch *touch = [touches anyObject];
	CGPoint touchLocation = [touch locationInView: [touch view]];
	return [[CCDirector sharedDirector] convertToGL:touchLocation];
}

-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
}

-(void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint location = [self locationFromTouches:touches];
	CCLOG(@"touch moved to: %.0f, %.0f", location.x, location.y);
}

-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	// the scene we want to see next
	CCScene* scene = [MenuScene scene];
	
	CCTransitionFade* transitionScene = [CCTransitionFade transitionWithDuration:3 scene:scene withColor:ccRED];
	//CCFadeTRTransition* transitionScene = [CCFadeTRTransition transitionWithDuration:3 scene:scene];
	//CCRotoZoomTransition* transitionScene = [CCRotoZoomTransition transitionWithDuration:3 scene:scene];
	//CCShrinkGrowTransition* transitionScene = [CCShrinkGrowTransition transitionWithDuration:3 scene:scene];
	//CCTurnOffTilesTransition* transitionScene = [CCTurnOffTilesTransition transitionWithDuration:3 scene:scene];
	[[CCDirector sharedDirector] replaceScene:transitionScene];

	
	// Alternatives:
	
	// not using any transition scene at all:
	//[[CCDirector sharedDirector] replaceScene:scene];
	
	// note: you can also reload the current scene
	// just don't use "self", you have to create a new scene!
	//[[CCDirector sharedDirector] replaceScene:[HelloWorld scene]];
}

-(void) ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	
}

// Accelerometer Input Events
-(void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
	CCLOG(@"acceleration: x:%f / y:%f / z:%f", acceleration.x, acceleration.y, acceleration.z);
}

-(void) dealloc
{
	CCLOG(@"dealloc: %@", self);
	
	// always call [super dealloc] at the end of every dealloc method
	[super dealloc];
}
@end
