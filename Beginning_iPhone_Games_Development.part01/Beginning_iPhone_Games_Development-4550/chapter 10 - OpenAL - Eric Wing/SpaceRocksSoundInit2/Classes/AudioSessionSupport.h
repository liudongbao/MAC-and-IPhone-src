/*
 *  AudioSessionSupport.h
 *  OpenALCapture
 *
 *  Created by Eric Wing on 7/8/09.
 *  Copyright 2009 PlayControl Software, LLC. All rights reserved.
 *
 */

#ifndef AUDIO_SESSION_SUPPPORT_H
#define AUDIO_SESSION_SUPPPORT_H

#ifdef __cplusplus
extern "C" {
#endif

#include <AudioToolbox/AudioToolbox.h>
#include <stdbool.h>
#include <stdint.h>

bool InitAudioSession(UInt32 session_category, AudioSessionInterruptionListener interruption_callback, void* user_data);

Float64 GetPreferredSampleRate(void);
void SetPreferredSampleRate(Float64 preferred_sample_rate);
Float64 GetCurrentHardwareSampleRate(void);
bool IsInputAvailable(void);
const char* FourCCToString(int32_t error_code);

/* Ends C function definitions when using C++ */
#ifdef __cplusplus
}
#endif

#endif /* AUDIO_SESSION_SUPPPORT_H */
