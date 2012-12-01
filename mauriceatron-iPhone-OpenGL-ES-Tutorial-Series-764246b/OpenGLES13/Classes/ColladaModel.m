//
//  ColladaFile.m
//  OpenGLES14
//
//  Created by Simon Maurice on 4/06/09.
//  Copyright 2009 Simon Maurice. All rights reserved.
//

#import "ColladaModel.h"


@implementation ColladaModel

- (id)initWithFilename:(NSString *)filename {
	
	if (self = [super init]) {
		
		// Load up the file and turn it into a NSData
		NSString *filePath = [[NSBundle mainBundle] pathForResource:filename ofType:@"dae"];
		NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:filePath];
		if (handle == nil) {
			NSLog(@"Error opening file");
		}
		NSData *colladaData = [handle readDataToEndOfFile];
		
		colladaXML = [[NSXMLParser alloc] initWithData:colladaData];
		colladaXML.delegate = self;
		uniqueElements = [[NSMutableArray alloc] init];
		
		BOOL success = [colladaXML parse];
		
		if (!success) NSLog(@"Something didn't work...");
		
		NSLog(@"Element Count: %d", elementCount);
		NSLog(@"Comment Count: %d", commentCount);
		
		NSLog(@"\n\nUnique Elements: %d", [uniqueElements count]);
	}
	return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	
	elementCount++;
	
//	NSLog(@"Started element: %@", elementName);
//	NSLog(@"Attributes (%d total):", [attributeDict count]);
	
//	NSArray *keys = [attributeDict allKeys];
//	for (NSString *s in keys) {
//		NSLog(@"Key: %@   Value: %@", s, [attributeDict objectForKey:s]);
//	}
	
	NSArray *recognisedElements = [NSArray arrayWithObjects:@"COLLADA", nil];

	
	for (NSString *s in recognisedElements) {
		if ([s compare:elementName] == NSOrderedSame) {
			NSLog(@"processElement%@", [elementName capitalizedString]);
		} else {
			NSLog(@"'%@'", [elementName capitalizedString]);
			if ([elementName rangeOfString:@" "].location != NSNotFound) {
				NSLog(@"***** Element has a SPACE: %@", elementName);
			}
		}
//			SEL selector = NSSelectorFromString([NSString stringWithFormat:@"processElement%@", [elementName capitalizedString]]);
//		}
		BOOL found = NO;
		for (NSString *s in uniqueElements) {
			if ([s compare:elementName] == NSOrderedSame) {
				found = YES;
			}
		}
		
		if (!found) {
			[uniqueElements addObject:elementName];
		}
		
	}
}


- (void)parser:(NSXMLParser *)parser foundComment:(NSString *)comment {
	NSLog(@"COMMENT: %@", comment);
	commentCount++;
}



@end
