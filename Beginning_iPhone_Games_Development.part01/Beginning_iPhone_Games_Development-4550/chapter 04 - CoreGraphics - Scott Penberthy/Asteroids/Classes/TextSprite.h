//
//  TextSprite.h
//  Asteroids
//
//  Created by Scott Penberthy on 3/12/10.
//  Copyright 2010 North Highland Partners, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sprite.h"
#import "Defs.h"

@interface TextSprite : Sprite {
	NSString *text;
	NSString *font;
	uint fontSize;
	uint textLength;
	
	char *charFont;
	char *charText;
}

@property (assign) NSString *text;
@property (assign) NSString *font;
@property (assign) uint fontSize;

+ (TextSprite *) withString: (NSString *) label;
- (void) moveUpperLeftTo: (CGPoint) p;
- (void) newText: (NSString *) val;

@end
