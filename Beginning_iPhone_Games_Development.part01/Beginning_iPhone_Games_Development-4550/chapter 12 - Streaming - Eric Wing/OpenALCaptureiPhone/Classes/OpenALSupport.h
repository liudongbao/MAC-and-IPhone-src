/*
 *  OpenALSupport.h
 *  OpenALCapture
 *
 *  Created by Eric Wing on 7/8/09.
 *  Copyright 2009 PlayControl Software, LLC. All rights reserved.
 *
 */

#ifndef OPENAL_SUPPPORT_H
#define OPENAL_SUPPPORT_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdbool.h>

// OpenAL header locations are not defined by the spec.
#ifdef __APPLE__
	#include <OpenAL/al.h>
	#include <OpenAL/alc.h>
#elif defined(_WIN32)
	#include "al.h"
	#include "alc.h"
#else
	#include <AL/al.h>
	#include <AL/alc.h>
#endif


bool IsOpenALCaptureExtensionAvailable(void);
// Device is hard-coded to default
ALCdevice* InitOpenALCaptureDevice(ALCuint sample_frequency, ALCenum al_format, ALCsizei max_buffer_size);


/* Ends C function definitions when using C++ */
#ifdef __cplusplus
}
#endif

#endif /* AUDIO_SESSION_SUPPPORT_H */
