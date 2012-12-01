//
//  ColladaFile.h
//  OpenGLES14
//
//  Created by Simon Maurice on 4/06/09.
//  Copyright 2009 Simon Maurice. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ColladaModel : NSObject {

	NSInteger elementCount;
	NSInteger commentCount;
	NSMutableArray *uniqueElements;
	
	NSXMLParser *colladaXML;
}

- (id)initWithFilename:(NSString *)filename;

@end
