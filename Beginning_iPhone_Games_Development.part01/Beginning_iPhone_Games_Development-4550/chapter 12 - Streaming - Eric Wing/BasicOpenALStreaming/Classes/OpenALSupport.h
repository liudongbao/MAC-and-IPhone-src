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

#import <AudioToolbox/AudioToolbox.h>

bool IsOpenALCaptureExtensionAvailable(void);
// Device is hard-coded to default
ALCdevice* InitOpenALCaptureDevice(ALCuint sample_frequency, ALCenum al_format, ALCsizei max_buffer_size);

typedef ALvoid AL_APIENTRY (*alBufferDataStaticProcPtr) (ALint buffer_id, ALenum al_format, const ALvoid* pcm_data, ALsizei buffer_size, ALsizei sample_rate);
ALvoid alBufferDataStatic(ALint buffer_id, ALenum al_format, const ALvoid* pcm_data, ALsizei buffer_size, ALsizei sample_rate);

typedef ALvoid (*alcMacOSXMixerOutputRateProcPtr) (const ALdouble sample_rate);
ALvoid alcMacOSXMixerOutputRate(const ALdouble sample_rate);

typedef ALdouble (*alcMacOSXGetMixerOutputRateProcPtr) ();
ALdouble alcMacOSXGetMixerOutputRate(void);
	
ExtAudioFileRef MyGetExtAudioFileRef(CFURLRef file_url, AudioStreamBasicDescription* audio_description);
	
OSStatus MyGetDataFromExtAudioRef(ExtAudioFileRef ext_file_ref, const AudioStreamBasicDescription* restrict output_format, ALsizei max_buffer_size, void** data_buffer, ALsizei* data_buffer_size, ALenum* al_format, ALsizei* sample_rate);
void* MyGetOpenALAudioDataAll(CFURLRef file_url, ALsizei* data_buffer_size, ALenum* al_format, ALsizei* sample_rate);
	
void MyRewindExtAudioData(ExtAudioFileRef ext_ref);
	

/* Ends C function definitions when using C++ */
#ifdef __cplusplus
}
#endif

#endif /* AUDIO_SESSION_SUPPPORT_H */
