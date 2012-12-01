//
//  LevelMap.m
//  OpenGLES13
//
//  Created by Simon Maurice on 6/06/09.
//  Copyright 2009 Simon Maurice. All rights reserved.
//

#import "LevelMap.h"


@implementation LevelMap

- (id)initWithMapFileName:(NSString *)mapFileName {
	
	if (self = [super init]) {
		NSString *filePath = [[NSBundle mainBundle] pathForResource:mapFileName ofType:@"bsp"];
		NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:filePath];
		
		[handle seekToEndOfFile];
		NSLog(@"Filesize: %d", [handle offsetInFile]);
		[handle seekToFileOffset:0];
		
		// First read the header
		[[handle readDataOfLength:sizeof(MapHeader)] getBytes:&header];
		
		
		
		// Skip the header, go striaght for the dir entries
		
		NSArray *entryNames = [NSArray arrayWithObjects:@"Entities", @"Textures", @"Planes", @"Nodes", @"Leafs",
							   @"Leaf Faces", @"Leaf Brushes", @"Models", @"Brushes", @"Brushsides", @"Vertices", @"MeshVerts", @"Effects",
							   @"Faces", @"Lightmaps", @"LightVols", @"VisData", nil];
		
		for (int i = 0; i < 17; i++) {
			
			NSLog(@"Dir Entry %@: OFFSET: %d   LENGTH: %d", [entryNames objectAtIndex:i], header.direntries[i].offset,
				  header.direntries[i].length);
			
		}
		
		// Output the entities
		char *entitiesPtr = malloc(header.direntries[0].length);
		[handle seekToFileOffset:header.direntries[0].offset];
		[[handle readDataOfLength:header.direntries[0].length] getBytes:entitiesPtr];
		NSArray *entities = [NSArray arrayWithArray:[[NSString stringWithCString:entitiesPtr] componentsSeparatedByString:@"\n"]];
		if (entities == nil) {
			NSLog(@"Didn't work");
		} else {
			for (NSString *s in entities) {
				NSLog(@"Entity: '%@'", s);
			}
		}
		free(entitiesPtr);
		
		// Textures
		BSPTexture *textures = malloc(header.direntries[1].length);
		[handle seekToFileOffset:header.direntries[1].offset];
		[[handle readDataOfLength:header.direntries[1].length] getBytes:textures];
		// Minor sanity check
		int textureCount = header.direntries[1].length / sizeof(BSPTexture);
		for (int i = 0; i < textureCount; i++) {
			NSLog(@"Texture %d: '%s'", i, &textures[i].name[0]);
		}
		free(textures);
		
		
		
	}
	return self;
}


@end
