//
//  DataSampleProtocol.h
//  OpenALCaptureMac
//
//  Created by Eric Wing on 7/8/09.
//  Copyright 2009 PlayControl Software, LLC. All rights reserved.
//

#import "DataSampleProtocol.h"


@protocol DataSampleProtocol

@optional
- (size_t) dataArray:(void*)data_array maxArrayLength:(size_t)max_array_length getBytesPerSample:(size_t*)bytes_per_sample;

@end
