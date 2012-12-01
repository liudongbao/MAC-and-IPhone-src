//
//  Model.m
//  GLGravity
//
//  Created by Joe Hogue on 7/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

//we can't muck around with the pvrt code without going into objective-c++ mode, thus the .mm extension on Model.
#import "PVRTModelPOD.h"
#import "PVRTResourceFile.h" //for CPVRTResourceFile::SetReadPath and model loading
#import "PVRTTextureAPI.h" //for PVRTTextureLoadFromPVR

#import "Model.h"


@implementation Model

//called by draw for each chunk of geometry in the model
- (void)drawMesh:(SPODNode&)node withModelView:(PVRTMat4)view{
	unsigned int meshid = node.nIdx;
	SPODMesh& mesh = ((CPVRTModelPOD*)model)->pMesh[meshid];
	glBindBuffer(GL_ARRAY_BUFFER, vbo[meshid]);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexvbo[meshid]);
	
	bool bskinning = mesh.sBoneWeight.pData != 0;
#if TARGET_IPHONE_SIMULATOR
	bskinning = false; //skinning is done in hardware, and the simulator doesn't have that hardware.
#endif

	if(bskinning){
		glEnableClientState(GL_MATRIX_INDEX_ARRAY_OES);
		glEnableClientState(GL_WEIGHT_ARRAY_OES);
	}
	
	glVertexPointer(mesh.sVertex.n, GL_FLOAT, mesh.sVertex.nStride, mesh.sVertex.pData);
	//DebugLog(@"mesh[%d].nnumstrips %d", meshid, mesh.nNumStrips);
	
	if(mesh.nNumUVW){
		//NSLog(@"textures hai, count %d, texdata 0x%x, count[0] %d", mesh.nNumUVW, mesh.psUVW[0].pData, mesh.psUVW[0].n);
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		glTexCoordPointer(mesh.psUVW[0].n, VERTTYPEENUM, mesh.psUVW[0].nStride, mesh.psUVW[0].pData);
	}
	
	if(mesh.sNormals.n){
		glEnableClientState(GL_NORMAL_ARRAY);
		glNormalPointer(VERTTYPEENUM, mesh.sNormals.nStride, mesh.sNormals.pData);
	}
	
	/*if(mesh.sVtxColours.n){
		//glColor4ub(<#GLubyte red#>, <#GLubyte green#>, <#GLubyte blue#>, <#GLubyte alpha#>)
		glEnableClientState(GL_COLOR_ARRAY);
		glColorPointer(4, GL_UNSIGNED_BYTE, mesh.sVtxColours.nStride, mesh.sVtxColours.pData);
	}*/
	
	//NSLog(@"glerr 0x%x", glGetError());//501 GL_INVALID_VALUE here
	
	if(bskinning){
		glMatrixIndexPointerOES(mesh.sBoneIdx.n, GL_UNSIGNED_BYTE, mesh.sBoneIdx.nStride, mesh.sBoneIdx.pData);
		glWeightPointerOES(mesh.sBoneWeight.n, VERTTYPEENUM, mesh.sBoneWeight.nStride, mesh.sBoneWeight.pData);
		//todo: vertex colors here.
		for(int batch=0;batch<mesh.sBoneBatches.nBatchCnt; batch++){
			
			//if(bskinning)
			{
				glEnable(GL_MATRIX_PALETTE_OES);
				glMatrixMode(GL_MATRIX_PALETTE_OES);
				
				PVRTMat4 boneworld;
				int nodeid;
				for(int j=0;j<mesh.sBoneBatches.pnBatchBoneCnt[batch]; j++){
					glCurrentPaletteMatrixOES(j);
					nodeid = mesh.sBoneBatches.pnBatches[batch*mesh.sBoneBatches.nBatchBoneMax +j];
					((CPVRTModelPOD*)model)->GetBoneWorldMatrix(boneworld, node, ((CPVRTModelPOD*)model)->pNode[nodeid]);
					boneworld = view * boneworld; //todo: replace m_view here with a local define, set per sprite
					myglLoadMatrix(boneworld.f);
				}
				
			} /*else {
				if(extensions_available) glDisable(GL_MATRIX_PALETTE_OES);
			}*/
			
			glMatrixMode(GL_MODELVIEW);
			
			int tris;
			if(batch+1 < mesh.sBoneBatches.nBatchCnt)
				tris=mesh.sBoneBatches.pnBatchOffset[batch+1] - mesh.sBoneBatches.pnBatchOffset[batch];
			else
				tris=mesh.nNumFaces - mesh.sBoneBatches.pnBatchOffset[batch];
			
			if(mesh.nNumStrips == 0){
				if(indexvbo[meshid]){
					glDrawElements(GL_TRIANGLES, tris*3, GL_UNSIGNED_SHORT, &((unsigned short*)0)[3*mesh.sBoneBatches.pnBatchOffset[batch]]); //this is currently used.  indexed triangle list
				} else {
					DebugLog(@"using non-indexed triangle list.");
					glDrawArrays(GL_TRIANGLES, 0, mesh.nNumFaces*3); //non-indexed triangle list
				}
			} else {
				int offset=0;
				for(int i=0; i<(int)mesh.nNumStrips;i++){
					if(indexvbo[meshid]){
						DebugLog(@"using indexed triangle strips.");
						glDrawElements(GL_TRIANGLE_STRIP, mesh.pnStripLength[i]+2, GL_UNSIGNED_SHORT, &((GLshort*)0)[offset]); //indexed triangle strips
					} else {
						DebugLog(@"using non-indexed triangle strips.");
						glDrawArrays(GL_TRIANGLE_STRIP, offset, mesh.pnStripLength[i]+2); //non-indexed triangle strips
					}
					offset += mesh.pnStripLength[i]+2;
				}
			}
		}
		
		glDisableClientState(GL_MATRIX_INDEX_ARRAY_OES);
		glDisableClientState(GL_WEIGHT_ARRAY_OES);
		glDisable(GL_MATRIX_PALETTE_OES);
	} else {
		//todo: this chunk of code is duped from above, refactor it.
		if(mesh.nNumStrips == 0){
			if(indexvbo[meshid]){
				glDrawElements(GL_TRIANGLES, mesh.nNumFaces*3, GL_UNSIGNED_SHORT, &((unsigned short*)0)[0]); //this is currently used.  indexed triangle list
			} else {
				DebugLog(@"using non-indexed triangle list.");
				glDrawArrays(GL_TRIANGLES, 0, mesh.nNumFaces*3); //non-indexed triangle list
			}
		} else {
			int offset=0;
			for(int i=0; i<(int)mesh.nNumStrips;i++){
				if(indexvbo[meshid]){
					DebugLog(@"using indexed triangle strips.");
					glDrawElements(GL_TRIANGLE_STRIP, mesh.pnStripLength[i]+2, GL_UNSIGNED_SHORT, &((GLshort*)0)[offset]); //indexed triangle strips
				} else {
					DebugLog(@"using non-indexed triangle strips.");
					glDrawArrays(GL_TRIANGLE_STRIP, offset, mesh.pnStripLength[i]+2); //non-indexed triangle strips
				}
				offset += mesh.pnStripLength[i]+2;
			}
		}
	}
	
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
	
	if(mesh.sNormals.n){
		glDisableClientState(GL_NORMAL_ARRAY);
	}
	
	if(mesh.nNumUVW){
		glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	}
	
	/*if(mesh.sVtxColours.n){
		glDisableClientState(GL_COLOR_ARRAY);
	}*/
}

//called by drawview for each model.  calls drawmesh for each chunk of geometry in the model.
-(void) draw {
	CPVRTModelPOD* scene = (CPVRTModelPOD*)model;
	PVRTMat4 view;
	glGetFloatv(GL_MODELVIEW_MATRIX, view.f); //we need to store the modelview matrix for bone animation later.
	for(int i=0;i<(int)scene->nNumMeshNode;i++){
		SPODNode& Node = scene->pNode[i];
		
		glPushMatrix();
		glMultMatrixf(scene->GetWorldMatrix(Node).f);
		
		//note that materials have no effect unless GL_LIGHTING is enabled.
		if(Node.nIdxMaterial == -1){
			glBindTexture(GL_TEXTURE_2D, 0);
			myglMaterialv(GL_FRONT_AND_BACK, GL_AMBIENT, PVRTVec4(f2vt(1.0f)).ptr());
			myglMaterialv(GL_FRONT_AND_BACK, GL_DIFFUSE, PVRTVec4(f2vt(1.0f)).ptr());
		} else {
			glBindTexture(GL_TEXTURE_2D, texture[Node.nIdxMaterial]);
			SPODMaterial& mat = scene->pMaterial[Node.nIdxMaterial];
			myglMaterialv(GL_FRONT_AND_BACK, GL_AMBIENT, PVRTVec4(mat.pfMatAmbient, f2vt(1.0f)).ptr());
			myglMaterialv(GL_FRONT_AND_BACK, GL_DIFFUSE, PVRTVec4(mat.pfMatDiffuse, f2vt(1.0f)).ptr());
		}
		[self drawMesh:Node withModelView:view];
		glPopMatrix();
	}
}

- (void) load:(NSString*)filename {
	//NSString* path = [[NSBundle mainBundle] pathForResource:filename ofType:nil];
	//DebugLog(@" pod path %@", path);
	//DebugLog(@" bundle path %@", [[NSBundle mainBundle] resourcePath]);
	
	const char* cpath = [ [NSString stringWithFormat:@"%@/", [[NSBundle mainBundle] resourcePath]] cStringUsingEncoding: NSASCIIStringEncoding];
	
	//printf("cpath %s\n", cpath);
	
	model = new CPVRTModelPOD(); //todo: dealloc, also check if already alloc'd
	CPVRTModelPOD* scene = (CPVRTModelPOD*)model;
	
	CPVRTResourceFile::SetReadPath(cpath);
	if(scene->ReadFromFile([filename cStringUsingEncoding:NSASCIIStringEncoding]) != PVR_SUCCESS)
	{
		DebugLog(@"ERROR: Couldn't load 'hate.pod'.");
		delete scene;
		model = NULL;
		return;
	} else {
		DebugLog(@"LOADZOR");
		vbo = new GLuint[scene->nNumMesh];
		indexvbo = new GLuint[scene->nNumMesh];
		glGenBuffers(scene->nNumMesh, vbo);
		for(unsigned int i=0;i<scene->nNumMesh;i++){
			SPODMesh& mesh = scene->pMesh[i];
			unsigned int size = mesh.nNumVertex * mesh.sVertex.nStride;
			
			assert(mesh.pInterleaved);
			assert(mesh.sFaces.pData);
			DebugLog(@"size %d, interleaved 0x%x", size, mesh.pInterleaved); 
			
			//shove vertex data into a vertex buffer object
			glBindBuffer(GL_ARRAY_BUFFER, vbo[i]);
			glBufferData(GL_ARRAY_BUFFER, size, mesh.pInterleaved, GL_STATIC_DRAW);
			
			//shove index data into a vertex buffer object
			indexvbo[i] = 0;
			if(mesh.sFaces.pData){
				glGenBuffers(1, &indexvbo[i]);
				size = PVRTModelPODCountIndices(mesh) * sizeof(GLshort);
				glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexvbo[i]);
				glBufferData(GL_ELEMENT_ARRAY_BUFFER, size, mesh.sFaces.pData, GL_STATIC_DRAW);
			}
		}
		glBindBuffer(GL_ARRAY_BUFFER, 0);
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
		
		//load any textures for the scene's materials.
		texture = new GLuint[scene->nNumMaterial];
		for(unsigned int i=0;i<scene->nNumMaterial;i++){
			texture[i] = 0;
			SPODMaterial* mat = &scene->pMaterial[i];
			if(mat->nIdxTexDiffuse != -1){
				//load the texture file.
				CPVRTString filename = scene->pTexture[mat->nIdxTexDiffuse].pszName;
				//todo: global buffer of textures.
				if(PVRTTextureLoadFromPVR(filename.c_str(), &texture[i], NULL, true, 0) != PVR_SUCCESS){
					DebugLog(@"texture load failed for file %s", filename.c_str());
				}
			}
		}
	}
}

- (void) setFrame:(float) frame{
	((CPVRTModelPOD*)model)->SetFrame(frame);
}

- (int) numFrames{
	return ((CPVRTModelPOD*)model)->nNumFrame;
}

+ (Model*) modelFromFile:(NSString*) filename {
	Model* retval = [[Model alloc] init];
	[retval load:filename];
	return [retval autorelease];
}

- (void) dealloc {
	if(model){
		CPVRTModelPOD* scene = (CPVRTModelPOD*)model;
		//todo: global buffer of textures
		glDeleteTextures(scene->nNumMaterial, texture);
		glDeleteBuffers(scene->nNumMesh, vbo);
		glDeleteBuffers(scene->nNumMesh, indexvbo); //note that not all the indexvbos will be non-zero, but glDeleteBuffers silently ignores those, per http://www.opengl.org/sdk/docs/man/xhtml/glDeleteBuffers.xml
		delete vbo;
		delete indexvbo;
		delete texture;
		delete scene;
	}
	[super dealloc];
}

@end
