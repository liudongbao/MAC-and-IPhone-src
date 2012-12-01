//
//  ScopeView.h
//  OpenALCaptureMac
//
//  Created by Eric Wing on 7/8/09.
//  Copyright 2009 PlayControl Software, LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FancyOpenGLView.h"
#import "DataSampleProtocol.h"

@interface ScopeView : FancyOpenGLView
{
	IBOutlet id<NSObject,DataSampleProtocol> dataDelegate;
	int8_t* scopeData;
	size_t scopeDataMaxArrayLength;
	GLuint lineVBO;
	float* scopeDataConverted;
	size_t scopeDataConvertedMaxArrayLength;
	size_t currentNumberOfSamples;

}

@property(nonatomic, retain) id<NSObject, DataSampleProtocol> dataDelegate;

- (void) renderScene;


@end
