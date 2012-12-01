// - ------------------------------------------------------------------------------------------ - //
#ifndef __PVRTexture_H__
#define __PVRTexture_H__
// - ------------------------------------------------------------------------------------------ - //

// - ------------------------------------------------------------------------------------------ - //
typedef struct {
	int HeaderSize;			// Always 52 (bytes) //
	int Height;
	int Width;
	int MipMapCount;		// Number of MipMaps (does not count main texture) //
	int Flags;				// Flags (see defines below).  0xFF is type.  Everything else is bits //
	int DataSize;			// Total Data Size in Bytes //
	int BitsPerPixel;		// Number of bits per pixel (8, 16, 24, 32, etc...)
	int RBitMask;
	int GBitMask;
	int BBitMask;
	int AlphaBitMask;
	unsigned int PVR;		// Magic Number "PVR!" //
	int NumSurfs;			// Number of slices/layers for volumetric textures and skyboxes //
	
	unsigned char Data[0];	// Everything following is Data //
} PVRTexture;
// - ------------------------------------------------------------------------------------------ - //

// - ------------------------------------------------------------------------------------------ - //
#define PVR_TYPE_MASK		0x00FF
// - ------------------------------------------------------------------------------------------ - //
#define PVR_RGBA_4444		0x0010
#define PVR_RGBA_5551		0x0011
#define PVR_RGBA_8888		0x0012
#define PVR_RGB_565			0x0013
#define PVR_RGB_555			0x0014
#define PVR_RGB_888			0x0015
#define PVR_I_8				0x0016
#define PVR_AI_88			0x0017
#define PVR_PVRTC2			0x0018
#define PVR_PVRTC4			0x0019
#define PVR_BGRA_8888		0x001A
// - ------------------------------------------------------------------------------------------ - //
#define PVR_DXT1			0x0020
#define PVR_DXT2			0x0021
#define PVR_DXT3			0x0022
#define PVR_DXT4			0x0023
#define PVR_DXT5			0x0024
// - ------------------------------------------------------------------------------------------ - //
#define PVR_MIPMAPS			0x0100
#define PVR_TWIDDLED		0x0200
#define PVR_NORMALMAP		0x0400
#define PVR_BORDER			0x0800
#define PVR_CUBEMAP			0x1000
#define PVR_FALSEMIPMAP		0x2000
#define PVR_VOLUME			0x4000
#define PVR_ALPHA			0x8000
// - ------------------------------------------------------------------------------------------ - //

// - ------------------------------------------------------------------------------------------ - //
#endif // __PVRTexture_H__ //
// - ------------------------------------------------------------------------------------------ - //
