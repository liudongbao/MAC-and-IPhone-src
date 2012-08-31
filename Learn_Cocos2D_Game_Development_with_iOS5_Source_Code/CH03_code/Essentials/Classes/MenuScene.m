//
//  MenuScene.m
//  Essentials
//
//  Created by Steffen Itterheim on 16.07.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "MenuScene.h"

#import "HelloWorldScene.h"

// private methods are declared in this manner to avoid "may not respond to ..." compiler warnings
@interface MenuScene (PrivateMethods)
-(void) createMenu:(ccTime)delta;
-(void) goBackToPreviousScene;
-(void) changeScene:(id)sender;
-(void) menuItem1Touched:(id)sender;
-(void) menuItem2Touched:(id)sender;
-(void) menuItem3Touched:(id)sender;
@end

@implementation MenuScene
+(id) scene
{
	CCScene* scene = [CCScene node];
	CCLayer* layer = [MenuScene node];
	[scene addChild:layer];
	return scene;
}

-(id) init
{
	if ((self = [super init]))
	{
		CCLOG(@"init %@", self);
		
		// wait a short moment before creating the menu so we can see it scroll in
		[self schedule:@selector(createMenu:) interval:2];
	}
	return self;
}

-(void) createMenu:(ccTime)delta
{
	// unschedule the selector, we only want this method to be called once
	[self unschedule:_cmd];
	
	CGSize size = [[CCDirector sharedDirector] winSize];
	
	// set CCMenuItemFont default properties
	[CCMenuItemFont setFontName:@"Helvetica-BoldOblique"];
	[CCMenuItemFont setFontSize:40];
	
	// create a few labels with text and selector
	CCMenuItemFont* item1 = [CCMenuItemFont itemFromString:@"Back..." target:self selector:@selector(menuItem1Touched:)];
	
	// create a menu item using existing sprites
	CCSprite* normal = [CCSprite spriteWithFile:@"Icon.png"];
	normal.color = ccRED;
	CCSprite* selected = [CCSprite spriteWithFile:@"Icon.png"];
	selected.color = ccGREEN;
	CCMenuItemSprite* item2 = [CCMenuItemSprite itemFromNormalSprite:normal selectedSprite:selected target:self selector:@selector(menuItem2Touched:)];
	
	// create a toggle item using two other menu items (toggle works with images, too)
	[CCMenuItemFont setFontName:@"STHeitiJ-Light"];
	[CCMenuItemFont setFontSize:40];
	CCMenuItemFont* toggleOn = [CCMenuItemFont itemFromString:@"Toggle me, I'm ON!"];
	CCMenuItemFont* toggleOff = [CCMenuItemFont itemFromString:@"Toggle me, I'm OFF!"];
	CCMenuItemToggle* item3 = [CCMenuItemToggle itemWithTarget:self selector:@selector(menuItem3Touched:) items:toggleOn, toggleOff, nil];
	
	// create the menu using the items
	CCMenu* menu = [CCMenu menuWithItems:item1, item2, item3, nil];
	menu.position = CGPointMake(-(size.width / 2), size.height / 2);
	menu.tag = 100;
	[self addChild:menu];
	
	// calling one of the align methods is important, otherwise all labels will occupy the same location
	[menu alignItemsVerticallyWithPadding:40];
	
	// use an action for a neat initial effect - moving the whole menu at once!
	CCMoveTo* move = [CCMoveTo actionWithDuration:3 position:CGPointMake(size.width / 2, size.height / 2)];
	CCEaseElasticOut* ease = [CCEaseElasticOut actionWithAction:move period:0.8f];
	[menu runAction:ease];
}

-(void) goBackToPreviousScene
{
	// get the menu back
	CCNode* node = [self getChildByTag:100];
	NSAssert([node isKindOfClass:[CCMenu class]], @"node is not a CCMenu!");

	CCMenu* menu = (CCMenu*)node;

	// lets move the menu out using a sequence
	CGSize size = [[CCDirector sharedDirector] winSize];
	CCMoveTo* move = [CCMoveTo actionWithDuration:1 position:CGPointMake(-(size.width / 2), size.height / 2)];
	CCEaseBackInOut* ease = [CCEaseBackInOut actionWithAction:move];
	CCCallFunc* func = [CCCallFunc actionWithTarget:self selector:@selector(changeScene:)];
	CCSequence* sequence = [CCSequence actions:ease, func, nil];
	[menu runAction:sequence];
}

-(void) changeScene:(id)sender
{
	[[CCDirector sharedDirector] replaceScene:[HelloWorld scene]];
}

-(void) menuItem1Touched:(id)sender
{
	CCLOG(@"item 1 touched: %@", sender);
	[self goBackToPreviousScene];
}

-(void) menuItem2Touched:(id)sender
{
	CCLOG(@"item 2 touched: %@", sender);
}

-(void) menuItem3Touched:(id)sender
{
	// sender is a CCMenuItemToggle in this case
	CCMenuItemToggle* toggleItem = (CCMenuItemToggle*)sender;
	int index = [toggleItem selectedIndex];
	
	CCLOG(@"item 3 touched: %@ - selected index: %i", sender, index);
}

-(void) dealloc
{
	CCLOG(@"dealloc: %@", self);
	
	// always call [super dealloc] at the end of every dealloc method
	[super dealloc];
}

@end
