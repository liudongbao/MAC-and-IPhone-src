/*
 *  AudioSessionSupport.c
 *  OpenALCapture
 *
 *  Created by Eric Wing on 7/8/09.
 *  Copyright 2009 PlayControl Software, LLC. All rights reserved.
 *
 */

#include "AudioSessionSupport.h"
#include <AudioToolbox/AudioToolbox.h>
#include <stdio.h> /* printf */

bool InitAudioSession(UInt32 session_category, AudioSessionInterruptionListener interruption_callback, void* user_data)
{
	// setup our audio session
	OSStatus the_error = AudioSessionInitialize(NULL, NULL, interruption_callback, user_data);
	if(0 != the_error)
	{
		printf("Error initializing audio session! %d\n", the_error);
		return false;
	}
	the_error = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(session_category), &session_category);
	if(0 != the_error)
	{
		printf("Error setting audio session category! %d\n", the_error);
		return false;
	}
	the_error = AudioSessionSetActive(true);
	if(0 != the_error)
	{
		printf("Error setting audio session active! %d\n", the_error);
		return false;
	}
	return true;
}

/* Audio Session queries must be made after the session is setup */
Float64 GetPreferredSampleRate()
{
	Float64 preferred_sample_rate = 0.0;
	UInt32 the_size = sizeof(preferred_sample_rate);
	AudioSessionGetProperty(kAudioSessionProperty_PreferredHardwareSampleRate, &the_size, &preferred_sample_rate);
	printf("preferredSampleRate: %lf\n", preferred_sample_rate);
	return preferred_sample_rate;
}

/* Audio Session queries must be made after the session is setup */
void SetPreferredSampleRate(Float64 preferred_sample_rate)
{
	UInt32 the_size = sizeof(preferred_sample_rate);
	AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareSampleRate, the_size, &preferred_sample_rate);
}

/* Audio Session queries must be made after the session is setup */
Float64 GetCurrentHardwareSampleRate()
{
	Float64 current_sample_rate = 0.0;
	UInt32 the_size = sizeof(current_sample_rate);
	AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareSampleRate, &the_size, &current_sample_rate);
	printf("currentHardwareSampleRate: %lf\n", current_sample_rate);
	return current_sample_rate;
}

/* Audio Session queries must be made after the session is setup */
bool IsInputAvailable()
{
	UInt32 input_available = 0;
	UInt32 the_size = sizeof(input_available);
	AudioSessionGetProperty(kAudioSessionProperty_AudioInputAvailable, &the_size, &input_available);
	printf("Input available? : %d\n", input_available);
	return (bool)input_available;
}
