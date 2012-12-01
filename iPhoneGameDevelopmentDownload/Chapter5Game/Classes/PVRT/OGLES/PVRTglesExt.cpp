/******************************************************************************

 @File         PVRTglesExt.cpp

 @Title        Miscellaneous functions used in 3D rendering.

 @Copyright    Copyright (C)  Imagination Technologies Limited.

 @Platform     Independant

 @Description  OGLES extensions.

******************************************************************************/
#include <string.h>
#include "PVRTContext.h"

#include "PVRTglesExt.h"

/****************************************************************************
** Macros
****************************************************************************/

/****************************************************************************
** Defines
****************************************************************************/

/****************************************************************************
** Structures
****************************************************************************/

/****************************************************************************
** Declarations
****************************************************************************/

/****************************************************************************
** Constants
****************************************************************************/

/****************************************************************************
** Globals
****************************************************************************/

/****************************************************************************
** Local code
****************************************************************************/

/****************************************************************************
** Class: CPVRTglesExt
****************************************************************************/

/*!***************************************************************************
 @Function			LoadExtensions
 @Description		Initialises IMG extensions
*****************************************************************************/
void CPVRTglesExt::LoadExtensions()
{
#ifndef __APPLE__
	const GLubyte *pszGLExtensions;

	/* Retrieve GL extension string */
    pszGLExtensions = glGetString(GL_EXTENSIONS);

	/* GL_OES_matrix_palette */
	if (strstr((char *)pszGLExtensions, "GL_OES_matrix_palette"))
	{
		glCurrentPaletteMatrixOES			= (PFNGLCURRENTPALETTEMATRIXOES)eglGetProcAddress("glCurrentPaletteMatrixOES");
		glLoadPaletteFromModelViewMatrixOES	= (PFNGLLOADPALETTEFROMMODELVIEWMATRIXOES)eglGetProcAddress("glLoadPaletteFromModelViewMatrixOES");
		glMatrixIndexPointerOES				= (PFNGLMATRIXINDEXPOINTEROES)eglGetProcAddress("glMatrixIndexPointerOES");
		glWeightPointerOES					= (PFNGLWEIGHTPOINTEROES)eglGetProcAddress("glWeightPointerOES");
	}
	/* GL_IMG_user_clip_plane */
	if (strstr((char *)pszGLExtensions, "GL_IMG_user_clip_plane"))
	{
		/* glClipPlanexIMG and glClipPlanefIMG */
		glClipPlanexIMG = (PFNGLCLIPPLANEXIMG)eglGetProcAddress("glClipPlanexIMG");
		glClipPlanefIMG = (PFNGLCLIPPLANEFIMG)eglGetProcAddress("glClipPlanefIMG");
	}

	/* GL_IMG_vertex_program */
	if (strstr((char *)pszGLExtensions, "GL_IMG_vertex_program"))
	{
		/* glVertexAttribPointerARB */
		glVertexAttribPointerARB = (PFNGLVERTEXATTRIBPOINTERARB)eglGetProcAddress("glVertexAttribPointerARB");

		/* glEnableVertexAttribArrayARB */
		glEnableVertexAttribArrayARB = (PFNGLENABLEVERTEXATTRIBARRAYARB)eglGetProcAddress("glEnableVertexAttribArrayARB");

		/* glDisableVertexAttribArrayARB */
		glDisableVertexAttribArrayARB = (PFNGLDISABLEVERTEXATTRIBARRAYARB)eglGetProcAddress("glDisableVertexAttribArrayARB");

		/* glProgramStringARB */
		glProgramStringARB = (PFNGLPROGRAMSTRINGARB)eglGetProcAddress("glProgramStringARB");

		/* glBindProgramARB */
		glBindProgramARB = (PFNGLBINDPROGRAMARB)eglGetProcAddress("glBindProgramARB");

		/* glDeleteProgramsARB */
		glDeleteProgramsARB = (PFNGLDELETEPROGRAMSARB)eglGetProcAddress("glDeleteProgramsARB");

		/* glIsProgramARB */
		glIsProgramARB = (PFNGLISPROGRAMARB)eglGetProcAddress("glIsProgramARB");

		/* glGenProgramsARB */
		glGenProgramsARB = (PFNGLGENPROGRAMSARB)eglGetProcAddress("glGenProgramsARB");

		/* glVertexAttrib4fvARB */
		glVertexAttrib4fvARB = (PFNGLVERTEXATTRIB4FVARB)eglGetProcAddress("glVertexAttrib4fvARB");

		/* glVertexAttrib4xvIMG */
		glVertexAttrib4xvIMG = (PFNGLVERTEXATTRIB4XVIMG)eglGetProcAddress("glVertexAttrib4xvIMG");

		/* glProgramLocalParameter4xIMG */
		glProgramLocalParameter4xIMG = (PFNGLPROGRAMLOCALPARAMETER4XIMG)eglGetProcAddress("glProgramLocalParameter4xIMG");

		/* glProgramLocalParameter4xvIMG */
		glProgramLocalParameter4xvIMG = (PFNGLPROGRAMLOCALPARAMETER4XVIMG)eglGetProcAddress("glProgramLocalParameter4xvIMG");

		/* glProgramEnvParameter4xIMG */
		glProgramEnvParameter4xIMG = (PFNGLPROGRAMENVPARAMETER4XIMG)eglGetProcAddress("glProgramEnvParameter4xIMG");

		/* glProgramEnvParameter4xvIMG */
		glProgramEnvParameter4xvIMG = (PFNGLPROGRAMENVPARAMETER4XVIMG)eglGetProcAddress("glProgramEnvParameter4xvIMG");

		/* glProgramEnvParameter4fARB */
		glProgramEnvParameter4fARB = (PFNGLPROGRAMENVPARAMETER4FARB)eglGetProcAddress("glProgramEnvParameter4fARB");

		/* glProgramEnvParameter4fvARB */
		glProgramEnvParameter4fvARB = (PFNGLPROGRAMENVPARAMETER4FVARB)eglGetProcAddress("glProgramEnvParameter4fvARB");

		/* glProgramLocalParameter4fARB */
		glProgramLocalParameter4fARB = (PFNGLPROGRAMLOCALPARAMETER4FARB)eglGetProcAddress("glProgramLocalParameter4fARB");

		/* glProgGL_OES_draw_textureramLocalParameter4fvARB */
		glProgramLocalParameter4fvARB = (PFNGLPROGRAMLOCALPARAMETER4FVARB)eglGetProcAddress("glProgramLocalParameter4fvARB");
	}

	/* GL_OES_draw_texture */
	if (strstr((char *)pszGLExtensions, "GL_OES_draw_texture"))
	{
		/* glDrawTexiOES */
		glDrawTexiOES = (PFNGLDRAWTEXIOES)eglGetProcAddress("glDrawTexiOES");
		/* glDrawTexivOES */
		glDrawTexivOES = (PFNGLDRAWTEXIVOES)eglGetProcAddress("glDrawTexivOES");
		/* glDrawTexsOES */
		glDrawTexsOES = (PFNGLDRAWTEXSOES)eglGetProcAddress("glDrawTexsOES");
		/* glDrawTexsvOES */
		glDrawTexsvOES = (PFNGLDRAWTEXSVOES)eglGetProcAddress("glDrawTexsvOES");
		/* glDrawTexxOES */
		glDrawTexxOES = (PFNGLDRAWTEXXOES)eglGetProcAddress("glDrawTexxOES");
		/* glDrawTexxvOES */
		glDrawTexxvOES = (PFNGLDRAWTEXXVOES)eglGetProcAddress("glDrawTexxvOES");
		/* glDrawTexfOES */
		glDrawTexfOES = (PFNGLDRAWTEXFOES)eglGetProcAddress("glDrawTexfOES");
		/* glDrawTexfvOES */
		glDrawTexfvOES = (PFNGLDRAWTEXFVOES)eglGetProcAddress("glDrawTexfvOES");
	}

	/* IMG_texture_stream */
	if (strstr((char *)pszGLExtensions, "GL_IMG_texture_stream"))
	{
		glGetTexStreamDeviceAttribivIMG = (PFNGLGETTEXSTREAMDEVICEATTRIBIVIMG)eglGetProcAddress("glGetTexStreamDeviceAttribivIMG");
		glTexBindStreamIMG = (PFNGLTEXBINDSTREAMIMG)eglGetProcAddress("glTexBindStreamIMG");
		glGetTexStreamDeviceNameIMG = (PFNGLGETTEXSTREAMDEVICENAMEIMG)eglGetProcAddress("glGetTexStreamDeviceNameIMG");
	}

	/* GL_EXT_multi_draw_arrays */
	if (strstr((char *)pszGLExtensions, "GL_EXT_multi_draw_arrays"))
	{
		glMultiDrawElementsEXT = (PFNGLMULTIDRAWELEMENTS)eglGetProcAddress("glMultiDrawElementsEXT");
	}

    /* GL_EXT_multi_draw_arrays */
	if (strstr((char *)pszGLExtensions, "GL_OES_mapbuffer"))
	{
        glMapBufferOES = (PFNGLMAPBUFFEROES)eglGetProcAddress("glMapBufferOES");
        glUnmapBufferOES = (PFNGLUNMAPBUFFEROES)eglGetProcAddress("glUnmapBufferOES");
        glGetBufferPointervOES = (PFNGLGETBUFFERPOINTERVOES)eglGetProcAddress("glGetBufferPointervOES");
	}

    /* GL_OES_Framebuffer_object*/
	if (strstr((char *)pszGLExtensions, "GL_OES_framebuffer_object"))
	{
        glIsRenderbufferOES = (PFNGLISRENDERBUFFEROES)eglGetProcAddress("glIsRenderbufferOES") ;
        glBindRenderbufferOES = (PFNGLBINDRENDERBUFFEROES)eglGetProcAddress("glBindRenderbufferOES");
        glDeleteRenderbuffersOES = (PFNGLDELETERENDERBUFFERSOES)eglGetProcAddress("glDeleteRenderbuffersOES");
        glGenRenderbuffersOES = (PFNGLGENRENDERBUFFERSOES)eglGetProcAddress("glGenRenderbuffersOES");
        glRenderbufferStorageOES = (PFNGLRENDERBUFFERSTORAGEOES)eglGetProcAddress("glRenderbufferStorageOES");
        glGetRenderbufferParameterivOES = (PFNGLGETRENDERBUFFERPARAMETERIVOES)eglGetProcAddress("glGetRenderbufferParameterivOES");
        glIsFramebufferOES = (PFNGLISFRAMEBUFFEROES)eglGetProcAddress("glIsFramebufferOES");
        glBindFramebufferOES = (PFNGLBINDFRAMEBUFFEROES)eglGetProcAddress("glBindFramebufferOES");
        glDeleteFramebuffersOES = (PFNGLDELETEFRAMEBUFFERSOES)eglGetProcAddress("glDeleteFramebuffersOES");
        glGenFramebuffersOES = (PFNGLGENFRAMEBUFFERSOES)eglGetProcAddress("glGenFramebuffersOES");
        glCheckFramebufferStatusOES = (PFNGLCHECKFRAMEBUFFERSTATUSOES)eglGetProcAddress("glCheckFramebufferStatusOES");
        glFramebufferTexture2DOES = (PFNGLFRAMEBUFFERTEXTURE2DOES)eglGetProcAddress("glFramebufferTexture2DOES");
        glFramebufferRenderbufferOES = (PFNGLFRAMEBUFFERRENDERBUFFEROES)eglGetProcAddress("glFramebufferRenderbufferOES");
        glGetFramebufferAttachmentParameterivOES = (PFNGLGETFRAMEBUFFERATTACHMENTPARAMETERIVOES)eglGetProcAddress("glGetFramebufferAttachmentParameterivOES");
        glGenerateMipmapOES = (PFNGLGENERATEMIPMAPOES)eglGetProcAddress("glGetFramebufferAttachmentParameterivOES");
	}

	/* GL_OES_point_size_array */
	if (strstr((char *)pszGLExtensions, "GL_OES_point_size_array"))
	{
		glPointSizePointerOES = (PFNGLPOINTSIZEPOINTEROES)eglGetProcAddress("glPointSizePointerOES");
	}



#endif
}

/*!***********************************************************************
@Function			IsGLExtensionSupported
@Input				extension extension to query for
@Returns			True if the extension is supported
@Description		Queries for support of an extension
*************************************************************************/
bool CPVRTglesExt::IsGLExtensionSupported(const char *extension)
{
	// The recommended technique for querying OpenGL extensions;
	// from http://opengl.org/resources/features/OGLextensions/
    const GLubyte *extensions = NULL;
    const GLubyte *start;
    GLubyte *where, *terminator;

    /* Extension names should not have spaces. */
    where = (GLubyte *) strchr(extension, ' ');
    if (where || *extension == '\0')
        return 0;

    extensions = glGetString(GL_EXTENSIONS);

    /* It takes a bit of care to be fool-proof about parsing the
    OpenGL extensions string. Don't be fooled by sub-strings, etc. */
    start = extensions;
    for (;;) {
        where = (GLubyte *) strstr((const char *) start, extension);
        if (!where)
            break;
        terminator = where + strlen(extension);
        if (where == start || *(where - 1) == ' ')
            if (*terminator == ' ' || *terminator == '\0')
                return true;
        start = terminator;
    }
    return false;
}

/*****************************************************************************
 End of file (PVRTglesExt.cpp)
*****************************************************************************/
