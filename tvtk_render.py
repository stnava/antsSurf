from tvtk.api import tvtk 
from mayavi import mlab 

reader = tvtk.STLReader()
reader = tvtk.STLReader()
reader.file_name = 'brainSurface.stl'
reader.update()
surf1 = reader.output 
reader.file_name = 'brainSurf2.stl'
reader.update()
surf2 = reader.output 
mlab.pipeline.surface(surf1)
normals = mlab.pipeline.poly_data_normals(surf2)
mlab.pipeline.surface(normals)
mlab.show()


