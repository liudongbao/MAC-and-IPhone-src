//
//  OpenALCaptureController.h
//  OpenALCapture
//
//  Created by Eric Wing on 7/7/09.
//  Copyright 2009 PlayControl Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenAL/al.h>
#import <OpenAL/alc.h>
#import "DataSampleProtocol.h"

@interface OpenALCaptureController : NSObject <DataSampleProtocol>
{
	ALCdevice* alCaptureDevice;
}

- (size_t) dataArray:(void*)data_array maxArrayLength:(size_t)max_array_length getBytesPerSample:(size_t*)return_bytes_per_sample;

@end
