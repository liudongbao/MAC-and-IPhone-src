//
//  Tile.h
//  Chapter3 Framework
//
//  Created by Joe Hogue on 5/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	UNWALKABLE = 1,
	WATER = 2,
	EMUTEARS = 4,
} PhysicsFlags;

@interface Tile : NSObject {
	@public
	PhysicsFlags flags;

	NSString* textureName;
	CGRect frame;
}

@property (nonatomic, retain) NSString* textureName;
@property (nonatomic) CGRect frame;

- (void) drawInRect:(CGRect)rect;
- (Tile*) initWithTexture:(NSString*)texture withFrame:(CGRect) _frame;

@end
