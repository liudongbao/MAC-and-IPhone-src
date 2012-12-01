//
//  Entity.h
//  Chapter3 Framework
//
//  Created by Joe Hogue on 5/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Sprite;
@class TileWorld;

@interface Entity : NSObject {
	CGPoint worldPos; //specifies origin for physical representation in the game world.  in pixels.
	Sprite* sprite;
	TileWorld* world; //set when this entity is added to a TileWorld via addEntity.  used for tile collision detection.
}

@property (nonatomic, retain) Sprite* sprite;
@property (nonatomic) CGPoint position;

- (id) initWithPos:(CGPoint) pos sprite:(Sprite*)sprite;
- (void) drawAtPoint:(CGPoint) offset;
- (void) update:(CGFloat) time;
- (void) setWorld:(TileWorld*) newWorld;
- (void) forceToPos:(CGPoint) pos;

@end
