//
//  HelloWorldLayer.m
//  cocos2d-2.x-ARC
//
//  Created by Steffen Itterheim on 01.04.12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"
#import "MenuScene.h"

#pragma mark - HelloWorldLayer

// private methods are declared in this manner to avoid "may not respond to ..." compiler warnings
@interface HelloWorldLayer (PrivateMethods)
-(void) moreBlocksExamples;
-(void) onCallFunc;
-(void) onCallFuncN:(id)sender;
-(void) onCallFuncO:(id)object;
-(void) onCallFuncND:(id)sender data:(void*)data;
-(void) createLabelWithOffset:(int)offset;
@end

// HelloWorldLayer implementation
@implementation HelloWorldLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
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

		// Using same action on two sprite nodes to show that the action only runs on one node.
		// To have both sprites move, you'd have to create one CCMoveTo action for each node.
		CCSprite* icon1 = [CCSprite spriteWithFile:@"Icon.png"];
		icon1.color = ccGREEN;
		[self addChild:icon1];
		CCSprite* icon2 = [CCSprite spriteWithFile:@"Icon.png"];
		icon2.color = ccBLUE;
		[self addChild:icon2];
		
		id moveTo = [CCMoveTo actionWithDuration:10.0f position:CGPointMake(480, 320)];
		[icon1 runAction:moveTo];  // won't move
		[icon2 runAction:moveTo];  // will move
					 
		
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
		CCCallFuncO* funcO = [CCCallFuncO actionWithTarget:self selector:@selector(onCallFuncO:) object:background];
		
		// WARNING: It's crucial to use CCCallFuncO or CCCallBlockO instead if you are passing an NSObject (id) type, 
		// since (bridge) casting an id to void* can lead to crashes or leaks under ARC.
		void* someDataPointer = nil;
		CCCallFuncND* funcND = [CCCallFuncND actionWithTarget:self 
													 selector:@selector(onCallFuncND:data:) 
														 data:(void*)someDataPointer];
		
		// Blocks are like anonymous, inline C functions that can access surrounding variables
		CCCallBlock* blockA = [CCCallBlock actionWithBlock:^void(){
			CCLOG(@"action with block got called");
		}];
		// The ^{} is shorthand for ^void(){}
		CCCallBlock* blockB = [CCCallBlock actionWithBlock:^{
			CCLOG(@"action with block got called");
		}];
		CCCallBlockN* blockN = [CCCallBlockN actionWithBlock:^void(CCNode* node){
			CCLOG(@"action with block got called with node %@", node);
		}];
		CCCallBlockO* blockO = [CCCallBlockO actionWithBlock:^void(id object){
			CCLOG(@"action with block got called with object %@", object);
			[label setString:@"label string changed by block"];
		}											
													  object:background];

		// This may be syntactically easier to read:
		void (^callBlock)(id object) = ^void(id object){
			CCLOG(@"action with block got called with object %@", object);
			[label setString:@"label string changed by block"];
		};
		CCCallBlockO* blockO2 = [CCCallBlockO actionWithBlock:callBlock
													   object:background];

		[self moreBlocksExamples];
		
		CCSequence* sequence = [CCSequence actions:
								tint1, func, blockA, blockB,
								tint2, funcN, blockN, 
								tint3, funcO, blockO, blockO2, funcND, nil];
		[label runAction:sequence];
	}
	return self;
}

-(void) moreBlocksExamples
{
	// Storing a block function taking two int as parameters and returning int in a variable named Multiply.
	// The return type is inferred in this case, you can also write: ^int(int num1, int num2) {..};
	// Taken straight from Apple's blocks guide: http://developer.apple.com/library/ios/#featuredarticles/Short_Practical_Guide_Blocks/_index.html
	int (^Multiply)(int, int) = ^(int num1, int num2){
		return num1 * num2;	
	};
	int result = Multiply(7, 4); // result is 28
	CCLOG(@"result from Multiply block is: %i", result);
	
	// This is how you declare the same block but not returning a value (void)
	// As above, the return type (here: void) is inferred by the variable declaration.
	void (^Multiply2)(int, int) = ^(int num1, int num2){
		CCLOG(@"result from Multiply2 block is: %i", num1 * num2);
	};
	Multiply2(9, -7);
	
	// Same block again, this time returning a BOOL. But the return type can not be inferred,
	// so it must be specified after the caret character (^BOOL)
	// Notice how variable declaration reads "BOOL (^name)(..)" while implementation uses "^BOOL(..)".
	// This is probably the single most confusing aspect when using blocks. Well, now that you know ... :)
	BOOL (^PositiveNumbers)(int, int) = ^BOOL(int num1, int num2){
		return (num1 >= 0 && num2 >= 0);
	};
	BOOL positive = PositiveNumbers(9, -7);
	CCLOG(@"result from PositiveNumbers block is: %@", positive ? @"YES" : @"NO");
	
	// The simplest type of block taking no parameters and returning no values:
	void (^JustAMethod)() = ^void(){
		CCLOG(@"method block got called");
	};
	JustAMethod();

	// There's also a short style that omits the return type and the brackets.
	// Omitting the brackets is legal if the function takes no parameters:
	void (^JustAnotherMethod)() = ^{
		CCLOG(@"method block got called");
	};
	JustAnotherMethod();
	
	// Use a typedef to declare a block type that you want to re-use often. You can then use the
	// NegateBlock type just like any other data type to declare the block variable, ie: NegateBlock Negate = ...
	// Also very useful for properties: @property (copy) NegateBlock theNegateBlock;
	// This avoids repeating the "BOOL(^name)(BOOL)" block declaration over and over again and prevents typos.
	typedef BOOL(^NegateBlock)(BOOL);
	
	// And to really simplify the block definition, you can create a preprocessor macro
	// as a placeholder for the actual block implementation:
	#define NegateBlockImp ^BOOL(BOOL input)

	// Both typedef and macro greatly improve readability and reliability of repeated uses of the same block.
	// Well, readability is a double-edged sword here because the actual function parameters and return values are hidden.
	NegateBlock Negate = NegateBlockImp{
		return !input;
	};
	NegateBlock DoubleNegate = NegateBlockImp{
		return !!input;
	};
	NegateBlock TripleNegate = NegateBlockImp{
		return !!!input;
	};
	CCLOG(@"Negate block returned %@", Negate(NO) ? @"YES" : @"NO");
	CCLOG(@"DoubleNegate block returned %@", DoubleNegate(NO) ? @"YES" : @"NO");
	CCLOG(@"TripleNegate block returned %@", TripleNegate(NO) ? @"YES" : @"NO");
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
-(void) onCallFuncO:(id)object
{
    // object is the object you passed to CCCallFuncO
    CCLOG(@"callFuncO called! With object: %@", object);
}
-(void) onCallFuncND:(id)sender data:(void*)data
{
	CCLOG(@"callFuncND called with sender: %@ data: %p", sender, data);
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
	//CCTransitionFadeTR* transitionScene = [CCTransitionFadeTR transitionWithDuration:3 scene:scene];
	//CCTransitionRotoZoom* transitionScene = [CCTransitionRotoZoom transitionWithDuration:3 scene:scene];
	//CCTransitionShrinkGrow* transitionScene = [CCTransitionShrinkGrow transitionWithDuration:3 scene:scene];
	//CCTransitionTurnOffTiles* transitionScene = [CCTransitionTurnOffTiles transitionWithDuration:3 scene:scene];
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
}

@end
