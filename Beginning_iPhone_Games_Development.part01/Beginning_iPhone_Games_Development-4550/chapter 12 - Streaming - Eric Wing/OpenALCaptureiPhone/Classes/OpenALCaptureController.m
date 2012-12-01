//
//  OpenALCaptureController
//  OpenALCapture
//
//  Created by Eric Wing on 7/7/09.
//  Copyright 2009 PlayControl Software, LLC. All rights reserved.
//

#import "OpenALCaptureController.h"
#include "AudioSessionSupport.h"
#include "OpenALSupport.h"

void MyInterruptionCallback(void* user_data, UInt32 interruption_state)
{
}

@implementation OpenALCaptureController

- (id) init
{
	self = [super init];
	if(nil != self)
	{
		// Audio Session queries must be made after the session is setup
		InitAudioSession(kAudioSessionCategory_RecordAudio, MyInterruptionCallback, self);
		if(!IsInputAvailable())
		{
			printf("No audio input device is available");
		}

		// Keep in mind that the number of sample frames is requires x2 bytes internally because of MONO16
		// We could set to the microphone rate determined from an Audio Session query.
		// But for consistency with the Mac version, I will hardcode it. OpenAL will generally upsample.
//		alCaptureDevice = InitOpenALCaptureDevice(GetCurrentHardwareSampleRate(), AL_FORMAT_MONO16, 32768);
		alCaptureDevice = InitOpenALCaptureDevice(22050.0, AL_FORMAT_MONO16, 32768);
		alcCaptureStart(alCaptureDevice);
		ALCenum alc_error = alcGetError(alCaptureDevice);
		if(ALC_NO_ERROR != alc_error)
		{
			printf("alcCaptureStart error: %s", alcGetString(alCaptureDevice, alc_error));
		}
	}
	return self;
}

- (void) dealloc
{
	alcCaptureStop(alCaptureDevice);
	alcCloseDevice(alCaptureDevice);
	[super dealloc];
}



// Example: Array length is 2048
// Bytes per sample=2 (MONO16)
// This means we can fit at most 1024 samples in the array.
// Returns the number of bytes actually captured and copied into the array
- (size_t) dataArray:(void*)data_array maxArrayLength:(size_t)max_array_length getBytesPerSample:(size_t*)return_bytes_per_sample
{
	ALCenum alc_error;
	
	ALCint number_of_samples = 0;
	ALCint target_number_of_samples = 0;
	
	// We chose the format AL_FORMAT_MONO16 so we know it is 2-bytes per sample.
	// AL_FORMAT_MONO8 would be 1-byte per sample
	// AL_FORMAT_MONO_FLOAT32 (an extension) would be 4-bytes per sample
	// AL_FORMAT_STEREO_MONO16 would be 4-bytes per sample (if stereo recording was available). 2-bytes per channel for 2 channels.
	*return_bytes_per_sample = 2;
	size_t bytes_per_sample = *return_bytes_per_sample; // copy the value to make it easier to use in this function
	
	
	alcGetIntegerv(alCaptureDevice, ALC_CAPTURE_SAMPLES, 1, &number_of_samples);
	alc_error = alcGetError(alCaptureDevice);
	if(ALC_NO_ERROR != alc_error)
	{
		printf("alcCaptureStop error: %s\n", alcGetString(alCaptureDevice, alc_error));
		return 0;
	}
	if(0 == number_of_samples)
	{
		return 0;
	}
	
	// Since the OpenAL API works in samples instead of bytes, we need to find out how many
	// samples will fit in our array.
	target_number_of_samples = max_array_length / bytes_per_sample;
	
	
	if(number_of_samples < target_number_of_samples)
	{
		// We're going to make life easy and not retrieve the samples in the OpenAL input buffer
		// until it has enough data to fill our buffer.
		return 0;
	}
	else if(number_of_samples > max_array_length / bytes_per_sample)
	{
		// In this case, we got more samples than we have space in the array.
		// So we need to make sure we don't try to retrive more than we can handle.
		number_of_samples = target_number_of_samples;
	}
	
	
	// Remember: number of samples is not the same as number of bytes. 
	alcCaptureSamples(alCaptureDevice, data_array, number_of_samples);
	alc_error = alcGetError(alCaptureDevice);
	if(ALC_NO_ERROR != alc_error)
	{
		printf("alcCaptureSamples error: %s\n", alcGetString(alCaptureDevice, alc_error));
		return 0;
	}
	
	// returns the actual number of bytes
	return number_of_samples * bytes_per_sample;
	
}

@end
