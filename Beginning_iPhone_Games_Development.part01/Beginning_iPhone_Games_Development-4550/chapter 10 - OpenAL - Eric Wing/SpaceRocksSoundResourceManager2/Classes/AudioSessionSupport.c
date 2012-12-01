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
#include <ctype.h> /* isprint */
#include <arpa/inet.h> /* htonl */

bool InitAudioSession(UInt32 session_category, AudioSessionInterruptionListener interruption_callback, void* user_data, Float64 sample_rate)
{
	// setup our audio session
	OSStatus the_error = AudioSessionInitialize(NULL, NULL, interruption_callback, user_data);
	if(noErr != the_error)
	{
		printf("Error initializing audio session! %s\n", FourCCToString(the_error));
		return false;
	}
	the_error = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(session_category), &session_category);
	if(noErr != the_error)
	{
		printf("Error setting audio session category! %s\n", FourCCToString(the_error));
		return false;
	}
	SetPreferredSampleRate(sample_rate);
	the_error = AudioSessionSetActive(true);
	if(noErr != the_error)
	{
		printf("Error setting audio session active! %s\n", FourCCToString(the_error));
		return false;
	}
	return true;
}

/* Audio Session queries must be made after the session is setup */
Float64 GetPreferredSampleRate()
{
	OSStatus the_error;
	Float64 preferred_sample_rate = 0.0;
	UInt32 the_size = sizeof(preferred_sample_rate);
	the_error = AudioSessionGetProperty(kAudioSessionProperty_PreferredHardwareSampleRate, &the_size, &preferred_sample_rate);
	if(noErr != the_error)
	{
		printf("Error setting PreferredHardwareSampleRate! %s\n", FourCCToString(the_error));
	}
	printf("preferredSampleRate: %lf\n", preferred_sample_rate);
	return preferred_sample_rate;
}

/* Audio Session queries must be made after the session is setup */
void SetPreferredSampleRate(Float64 preferred_sample_rate)
{
	OSStatus the_error;
	UInt32 the_size = sizeof(preferred_sample_rate);
	the_error = AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareSampleRate, the_size, &preferred_sample_rate);
	if(noErr != the_error)
	{
		printf("Error setting PreferredHardwareSampleRate! %s\n", FourCCToString(the_error));
	}
}

/* Audio Session queries must be made after the session is setup */
Float64 GetCurrentHardwareSampleRate()
{
	OSStatus the_error;
	Float64 current_sample_rate = 0.0;
	UInt32 the_size = sizeof(current_sample_rate);
	the_error = AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareSampleRate, &the_size, &current_sample_rate);
	if(noErr != the_error)
	{
		printf("Error getting CurrentHardwareSampleRate! %s\n", FourCCToString(the_error));
	}
	printf("currentHardwareSampleRate: %lf\n", current_sample_rate);
	return current_sample_rate;
}

/* Audio Session queries must be made after the session is setup */
bool IsInputAvailable()
{
	OSStatus the_error;
	UInt32 input_available = 0;
	UInt32 the_size = sizeof(input_available);
	the_error = AudioSessionGetProperty(kAudioSessionProperty_AudioInputAvailable, &the_size, &input_available);
	if(noErr != the_error)
	{
		printf("Error getting AudioInputAvailable! %s\n", FourCCToString(the_error));
	}
	printf("Input available? : %d\n", input_available);
	return (bool)input_available;
}

const char* FourCCToString(int32_t error_code)
{
	static char return_string[16];
	uint32_t big_endian_code = htonl(error_code);
	char* big_endian_str = (char*)&big_endian_code;
	// see if it appears to be a 4-char-code
	if(isprint(big_endian_str[0])
	   && isprint(big_endian_str[1])
	   && isprint(big_endian_str[2])
	   && isprint (big_endian_str[3]))
	{
		return_string[0] = '\'';
		return_string[1] = big_endian_str[0];
		return_string[2] = big_endian_str[1];
		return_string[3] = big_endian_str[2];
		return_string[4] = big_endian_str[3];
		return_string[5] = '\'';
		return_string[6] = '\0';
	}
	else if(error_code > -200000 && error_code < 200000)
	{
		// no, format it as an integer
		snprintf(return_string, 16, "%d", error_code);
	}
	else
	{
		// no, format it as an integer but in hex
		snprintf(return_string, 16, "0x%x", error_code);
	}
	return return_string;
}

