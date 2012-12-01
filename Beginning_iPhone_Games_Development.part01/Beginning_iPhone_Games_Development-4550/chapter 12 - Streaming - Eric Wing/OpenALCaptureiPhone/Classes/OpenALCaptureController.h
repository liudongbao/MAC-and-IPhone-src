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


@interface OpenALCaptureController : NSObject
{
	ALCdevice* alCaptureDevice;
}

@end
