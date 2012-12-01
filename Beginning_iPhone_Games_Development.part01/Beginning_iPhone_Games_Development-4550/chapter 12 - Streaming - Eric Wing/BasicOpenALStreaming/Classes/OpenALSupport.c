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
//		printf("ALC_EXT_CAPTURE not available\n");
		return false;
	}
	else
	{
//		printf("ALC_EXT_CAPTURE is available\n");
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
	
	al_capture_device = alcCaptureOpenDevice(NULL, sample_frequency, al_format, max_buffer_size);
	if(NULL == al_capture_device)
	{
		printf("Failed to get capture device\n");
		return NULL;
	}
	
	//	printf("Finished initializing AL capture\n");
	return al_capture_device;
}

ALvoid alBufferDataStatic(ALint buffer_id, ALenum al_format, const ALvoid* pcm_data, ALsizei buffer_size, ALsizei sample_rate)
{
    static alBufferDataStaticProcPtr the_proc = NULL;
    
    if(NULL == the_proc)
	{
		the_proc = (alBufferDataStaticProcPtr) alGetProcAddress((const ALCchar*) "alBufferDataStatic");
    }

    if(NULL != the_proc)
	{
        the_proc(buffer_id, al_format, pcm_data, buffer_size, sample_rate);		
	}
	
    return;
}

ALvoid alcMacOSXMixerOutputRate(const ALdouble sample_rate)
{
    static alcMacOSXMixerOutputRateProcPtr the_proc = NULL;
    
    if(NULL == the_proc)
	{
		the_proc = (alcMacOSXMixerOutputRateProcPtr) alGetProcAddress((const ALCchar*) "alcMacOSXMixerOutputRate");
    }
	
    if(NULL != the_proc)
	{
        the_proc(sample_rate);		
	}
	
    return;
}

ALdouble alcMacOSXGetMixerOutputRate()
{
    static alcMacOSXGetMixerOutputRateProcPtr the_proc = NULL;
    
    if(NULL == the_proc)
	{
		the_proc = (alcMacOSXGetMixerOutputRateProcPtr) alGetProcAddress((const ALCchar*) "alcMacOSXGetMixerOutputRate");
    }
	
    if(NULL != the_proc)
	{
        return the_proc();		
	}
	
    return 0.0;
}


/**
 * @note This function returns by reference an open file reference (ExtAudioFileRef). You are responsbile for releasing this
 * this reference yourself when you are finished with it by calling ExtAudioFileDispose().
 */
ExtAudioFileRef MyGetExtAudioFileRef(CFURLRef file_url, AudioStreamBasicDescription* audio_description)
{
	OSStatus error_status = noErr;
	AudioStreamBasicDescription	file_format;
	UInt32 property_size = sizeof(file_format);
	ExtAudioFileRef	ext_file_ref = NULL;
	AudioStreamBasicDescription output_format;
	
	/* Open a file with ExtAudioFileOpen() */
	error_status = ExtAudioFileOpenURL(file_url, &ext_file_ref);
	if(noErr != error_status)
	{
		printf("MyGetExtAudioFileRef: ExtAudioFileOpenURL failed, Error = %ld\n", error_status);
		if(NULL != ext_file_ref)
		{
			ExtAudioFileDispose(ext_file_ref);
		}
		return NULL;
	}
	
	/* Get the audio data format */
	error_status = ExtAudioFileGetProperty(ext_file_ref, kExtAudioFileProperty_FileDataFormat, &property_size, &file_format);
	if(noErr != error_status)
	{
		printf("MyGetExtAudioFileRef: ExtAudioFileGetProperty(kExtAudioFileProperty_FileDataFormat) failed, Error = %ld\n", error_status);
		ExtAudioFileDispose(ext_file_ref);
		return NULL;
	}
	
	/* Don't know how to handle sounds with more than 2 channels (i.e. stereo)
	 * Remember that OpenAL sound effects must be mono to be spatialized anyway.
	 */
	if(file_format.mChannelsPerFrame > 2) 
	{
		printf("MyGetExtAudioFileRef: Unsupported Format, channel count (=%d) is greater than stereo\n", file_format.mChannelsPerFrame); 
		ExtAudioFileDispose(ext_file_ref);
		return NULL;
	}
	
	/* The output format must be linear PCM because that's the only type OpenAL knows how to deal with.
	 * Set the client format to 16 bit signed integer (native-endian) data because that is the most
	 * optimal format on iPhone/iPod Touch hardware.
	 * Maintain the channel count and sample rate of the original source format.
	 */
	output_format.mSampleRate = file_format.mSampleRate; // preserve the original sample rate
	output_format.mChannelsPerFrame = file_format.mChannelsPerFrame; // preserve the number of channels
	output_format.mFormatID = kAudioFormatLinearPCM; // We want linear PCM data
	output_format.mFormatFlags = kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger;
	output_format.mFramesPerPacket = 1; // We know for linear PCM, the definition is 1 frame per packet
	output_format.mBitsPerChannel = 16; // We know we want 16-bit
	output_format.mBytesPerPacket = 2 * output_format.mChannelsPerFrame; // We know we are using 16-bit, so 2-bytes per channel per frame
	output_format.mBytesPerFrame = 2 * output_format.mChannelsPerFrame; // For PCM, since 1 frame is 1 packet, it is the same as mBytesPerPacket
	
	/* Set the desired client (output) data format */
	error_status = ExtAudioFileSetProperty(ext_file_ref, kExtAudioFileProperty_ClientDataFormat, sizeof(output_format), &output_format);
	if(noErr != error_status)
	{
		printf("MyGetExtAudioFileRef: ExtAudioFileSetProperty(kExtAudioFileProperty_ClientDataFormat) failed, Error = %ld\n", error_status);
		ExtAudioFileDispose(ext_file_ref);
		return NULL;
	}	
	
	/* Copy the output format to the audio_description that was passed in so the 
	 * info will be returned to the user.
	 */
	memcpy(audio_description, &output_format, sizeof(output_format));
	return ext_file_ref;
}


OSStatus MyGetDataFromExtAudioRef(ExtAudioFileRef ext_file_ref, const AudioStreamBasicDescription* restrict output_format, ALsizei max_buffer_size, void** data_buffer, ALsizei* data_buffer_size, ALenum* al_format, ALsizei* sample_rate)
{
	OSStatus error_status = noErr;	
	SInt64 buffer_size_in_frames = 0;
	
	/* Compute how many frames will fit into our max buffer size */
	buffer_size_in_frames = max_buffer_size / output_format->mBytesPerFrame;
	
	if(*data_buffer)
	{
		AudioBufferList audio_buffer_list;
		audio_buffer_list.mNumberBuffers = 1;
		audio_buffer_list.mBuffers[0].mDataByteSize = max_buffer_size;
		audio_buffer_list.mBuffers[0].mNumberChannels = output_format->mChannelsPerFrame;
		audio_buffer_list.mBuffers[0].mData = *data_buffer;
		
		/* Read the data into an AudioBufferList */
		error_status = ExtAudioFileRead(ext_file_ref, (UInt32*)&buffer_size_in_frames, &audio_buffer_list);
		if(error_status == noErr)
		{
			/* Success */
			/* Note: 0 == buffer_size_in_frames is a legitimate value meaning we are EOF. */
			 
			 /* ExtAudioFileRead returns the number of frames actually read. Need to convert back to bytes. */
			*data_buffer_size = (ALsizei)(buffer_size_in_frames * output_format->mBytesPerFrame);
			
			*al_format = (output_format->mChannelsPerFrame > 1) ? AL_FORMAT_STEREO16 : AL_FORMAT_MONO16;
			*sample_rate = (ALsizei)output_format->mSampleRate;
		}
		else 
		{
			printf("MyGetDataFromExtAudioRef: ExtAudioFileRead failed, Error = %ld\n", error_status);
		}	
	}
	return error_status;
}

/**
 * @return Returns a pointer to a buffer containing all the pcm data. This memory was allocated in this function by using malloc.
 * You are responsible for freeing this memory yourself.
 */
void* MyGetOpenALAudioDataAll(CFURLRef file_url, ALsizei* data_buffer_size, ALenum* al_format, ALsizei* sample_rate)
{
	OSStatus error_status = noErr;	
	SInt64 file_length_in_frames = 0;
	UInt32 property_size;
	AudioStreamBasicDescription	output_format;
	ALsizei max_buffer_size;
	void* pcm_data;
	ExtAudioFileRef ext_file_ref = MyGetExtAudioFileRef(file_url, &output_format);
	if(NULL == ext_file_ref)
	{
		return NULL;
	}
	
	/* Get the total frame count */
	property_size = sizeof(file_length_in_frames);
	error_status = ExtAudioFileGetProperty(ext_file_ref, kExtAudioFileProperty_FileLengthFrames, &property_size, &file_length_in_frames);
	if(noErr != error_status)
	{
		printf("MyGetOpenALAudioDataAll: ExtAudioFileGetProperty(kExtAudioFileProperty_FileLengthFrames) failed, Error = %ld\n", error_status);
		ExtAudioFileDispose(ext_file_ref);
		return NULL;
	}
	
	/* Compute the number of bytes needed to hold all the data in the file. */
	max_buffer_size = file_length_in_frames * output_format.mBytesPerFrame;
	/* Allocate memory to hold all the decoded PCM data. */
	pcm_data = malloc(max_buffer_size);
	if(NULL == pcm_data)
	{
		printf("MyGetOpenALAudioDataAll: memory allocation failed\n");
		ExtAudioFileDispose(ext_file_ref);
		return NULL;
	}
	error_status = MyGetDataFromExtAudioRef(ext_file_ref, &output_format, max_buffer_size, &pcm_data, data_buffer_size, al_format, sample_rate);
//	assert(max_buffer_size == *data_buffer_size);
	if(noErr != error_status)
	{
		free(pcm_data);
		ExtAudioFileDispose(ext_file_ref);
		return NULL;
	}
		
	/* Don't need file ref any more. */
	ExtAudioFileDispose(ext_file_ref);
	return pcm_data;
}

void MyRewindExtAudioData(ExtAudioFileRef ext_file_ref)
{
	OSStatus error_status = noErr;
	error_status = ExtAudioFileSeek(ext_file_ref, 0);
	if(error_status != noErr)
	{
		printf("MyRewindExtAudioData: ExtAudioFileSeek FAILED, Error = %ld\n", error_status);
	}
}
