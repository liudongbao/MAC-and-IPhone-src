//
//  SettingsLayer.m
//  G03
//
//  Created by Mac Admin on 18/08/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SettingsLayer.h"
#import "SysMenu.h"

@implementation SettingsLayer
-(id) init
{
	[super init];
	
	// Set label font
	[CCMenuItemFont setFontName: @"American Typewriter"];
	[CCMenuItemFont setFontSize:18];
		
	
	CCMenuItemFont *title1 = [CCMenuItemFont itemFromString: @"音效"];
    [title1 setIsEnabled:NO];
	[CCMenuItemFont setFontName: @"Marker Felt"];
	[CCMenuItemFont setFontSize:26];
    CCMenuItemToggle *item1 = [CCMenuItemToggle itemWithTarget:self selector:@selector(menuCallback:) items:
                             [CCMenuItemFont itemFromString: @"开"],
                             [CCMenuItemFont itemFromString: @"关"],
                             nil];
    
	[CCMenuItemFont setFontName: @"American Typewriter"];
	[CCMenuItemFont setFontSize:18];
	CCMenuItemFont *title2 = [CCMenuItemFont itemFromString: @"音乐"];
    [title2 setIsEnabled:NO];
	[CCMenuItemFont setFontName: @"Marker Felt"];
	[CCMenuItemFont setFontSize:26];
    CCMenuItemToggle *item2 = [CCMenuItemToggle itemWithTarget:self selector:@selector(menuCallback:) items:
                             [CCMenuItemFont itemFromString: @"开"],
                             [CCMenuItemFont itemFromString: @"关"],
                             nil];
    
	[CCMenuItemFont setFontName: @"American Typewriter"];
	[CCMenuItemFont setFontSize:18];
	CCMenuItemFont *title3 = [CCMenuItemFont itemFromString: @"AI设置"];
    [title3 setIsEnabled:NO];
	[CCMenuItemFont setFontName: @"Marker Felt"];
	[CCMenuItemFont setFontSize:26];
    CCMenuItemToggle *item3 = [CCMenuItemToggle itemWithTarget:self selector:@selector(menuCallback:) items:
                             [CCMenuItemFont itemFromString: @"攻击型"],
                             [CCMenuItemFont itemFromString: @"保守型"],
                             nil];
    
	[CCMenuItemFont setFontName: @"American Typewriter"];
	[CCMenuItemFont setFontSize:18];
	CCMenuItemFont *title4 = [CCMenuItemFont itemFromString: @"难度"];
    [title4 setIsEnabled:NO];
	[CCMenuItemFont setFontName: @"Marker Felt"];
	[CCMenuItemFont setFontSize:26];
    CCMenuItemToggle *item4 = [CCMenuItemToggle itemWithTarget:self selector:@selector(menuCallback:) items:
                             [CCMenuItemFont itemFromString: @"妈妈的宝贝"], nil];
	
	NSArray *more_items = [NSArray arrayWithObjects:
						   [CCMenuItemFont itemFromString: @"菜鸟"],
						   [CCMenuItemFont itemFromString: @"高手"],
						   [CCMenuItemFont itemFromString: @"骨灰级"],
						   nil];
	// TIP: you can manipulate the items like any other NSMutableArray
	[item4.subItems addObjectsFromArray: more_items];
	
    // you can change the one of the items by doing this
    item4.selectedIndex = 0;
    
    [CCMenuItemFont setFontName: @"Marker Felt"];
	[CCMenuItemFont setFontSize:26];
	
	CCBitmapFontAtlas *label = [CCBitmapFontAtlas bitmapFontAtlasWithString:@"Go back" fntFile:@"font01.fnt"];
	CCMenuItemLabel *back = [CCMenuItemLabel itemWithLabel:label target:self selector:@selector(backCallback:)];
	back.scale = 0.8;
    
	CCMenu *menu = [CCMenu menuWithItems:
                  title1, title2,
                  item1, item2,
                  title3, title4,
                  item3, item4,
                  back, nil]; // 9 items.
    [menu alignItemsInColumns:
     [NSNumber numberWithUnsignedInt:2],
     [NSNumber numberWithUnsignedInt:2],
     [NSNumber numberWithUnsignedInt:2],
     [NSNumber numberWithUnsignedInt:2],
     [NSNumber numberWithUnsignedInt:1],
     nil
	 ]; // 2 + 2 + 2 + 2 + 1 = total count of 9.
    
	[self addChild: menu];
	
	return self;
}

- (void) dealloc
{
	[super dealloc];
}

-(void) menuCallback: (id) sender
{
	NSLog(@"selected item: %@ index:%d", [sender selectedItem], [sender selectedIndex] );
}

-(void) backCallback: (id) sender
{
	CCScene *sc = [CCScene node];
	[sc addChild:[SysMenu node]];
	
	[[CCDirector sharedDirector] replaceScene:  [CCShrinkGrowTransition transitionWithDuration:1.2f scene:sc]];	
}
@end
