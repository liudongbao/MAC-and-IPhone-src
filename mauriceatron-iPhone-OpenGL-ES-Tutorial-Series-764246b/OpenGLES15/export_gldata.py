#!BPY

import struct
import bpy
import Blender

def newFileName(ext):
    return '.'.join(Blender.Get('filename').split('.')[:-1] + [ext])

def saveAllMeshes(filename):
    for object in Blender.Object.Get():
        if object.getType() == 'Mesh':
            mesh = object.getData()
            if (len(mesh.verts) > 0):
                saveMesh(filename, mesh)
                return

def saveMesh(filename, mesh):
    file = open(filename, "w")
    file.write(struct.pack("<I", len(mesh.verts)))
    file.write(struct.pack("<H", len(mesh.faces)))
    
    # Write an interleaved vertex array containing vertex coordinates and normals
    for vertex in mesh.verts:
        file.write(struct.pack("<fff", *vertex.co))
        file.write(struct.pack("<fff", *vertex.no))
        
    # Write the index for each triangle coordinates
    for face in mesh.faces:
        assert len(face.v) == 3
        for vertex in face.v:
            file.write(struct.pack("<H", vertex.index))
            
Blender.Window.FileSelector(saveAllMeshes, "Export for iPhone", newFileName("gldata"))
