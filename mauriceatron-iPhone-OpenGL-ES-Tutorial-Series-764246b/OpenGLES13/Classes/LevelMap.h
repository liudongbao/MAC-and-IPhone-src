//
//  LevelMap.h
//  OpenGLES13
//
//  Created by Simon Maurice on 6/06/09.
//  Copyright 2009 Simon Maurice. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct __MapDirEntry {
	int offset;
	int length;
} MapDirEntry;

typedef struct __MapHeader {
	char magic[4];
	int version;
	MapDirEntry direntries[17];
} MapHeader;

typedef struct __BSPVertex {
	float position[3];
	float textureST[2];
	float lightMapCoordinates[2];
	float normal[3];
	unsigned char colour[4];
} BSPVertex;

typedef struct __BSPTexture {
	char name[64];
	int flags;
	int contents;
} BSPTexture;

@interface LevelMap : NSObject {

	MapHeader header;
	
	
}

- (id)initWithMapFileName:(NSString *)mapFileName;

@end
