//
//  AtlasSprite.h
//  Asteroids
//
//  Created by Scott Penberthy on 3/1/10.
//  Copyright 2010 North Highland Partners, Inc.. All rights reserved.
//

#import "Sprite.h"

@interface AtlasSprite : Sprite {
	CGFloat w2;						// half width, for caching
	CGFloat h2;						// half height, for caching
	CGFloat atlasWidth;				// as it says
	CGFloat atlasHeight;
	UIImage *atlas;					// atlas containing all images of this sprite
	CGImageRef image;				// a Quartz reference to the image, for drawing
	CGRect clipRect;				// a clip rectangle
	int rows;						// how many rows are in the atlas
	int columns;					// how many columns are in the atlas
}

@property (assign) CGFloat w2, h2, atlasWidth, atlasHeight;
@property (assign) CGRect clipRect;
@property (assign) int rows, columns;
@property (retain, nonatomic) UIImage *atlas;
@property (assign) CGImageRef image;

+ (AtlasSprite *) fromFile: (NSString *) fname withRows: (int) rows withColumns: (int) columns;
+ (NSMutableDictionary *) sharedSpriteAtlas;
+ (UIImage *) getSpriteAtlas: (NSString *) name;

@end

