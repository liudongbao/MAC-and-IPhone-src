/*
 *  OpenALSupport.c
 *  OpenALCapture
 *
 *  Created by Eric Wing on 7/8/09.
 *  Copyright 2009 PlayControl Software, LLC. All rights reserved.
 *
 */

#include "OpenALSupport.h"
#include <stddef.h> /* NULL */
#include <stdio.h> /* printf */

bool IsOpenALCaptureExtensionAvailable()
{
	if(!alcIsExtensionPresent(NULL, "ALC_EXT_CAPTURE"))
	{
		printf("ALC_EXT_CAPTURE not available\n");
		return false;
	}
	else
	{
		printf("ALC_EXT_CAPTURE is available\n");
		return true;
	}
}

ALCdevice* InitOpenALCaptureDevice(ALCuint sample_frequency, ALCenum al_format, ALCsizei max_buffer_size)
{
	ALCdevice* al_capture_device;
	
	if(!IsOpenALCaptureExtensionAvailable())
	{
		return NULL;
	}
	const char* default_device = alcGetString(NULL, ALC_CAPTURE_DEFAULT_DEVICE_SPECIFIER);
	fprintf(stderr, "default device=%s", default_device);
	al_capture_device = alcCaptureOpenDevice(default_device, sample_frequency, al_format, max_buffer_size);
	if(NULL == al_capture_device)
	{
		printf("Failed to get capture device\n");
		return NULL;
	}
	
	//	printf("Finished initializing AL capture\n");
	return al_capture_device;
}
