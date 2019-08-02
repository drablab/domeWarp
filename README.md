# domeWarp

In the ```physicalModel``` folder we have code for warping image that based on the physics of projection optics. The first file 
```findWarpForModel.py``` reads several inputs (key them in in the first 20-30 lines), including:

```python
desiredVirtualImageWidth = 1080 # the bigger this parameter is, the more mapping f(i,j) = u,v is found within regoin of interest
R = 150 # radius of the dome
r = 33 # radius of the spherical mirror in cm
mx, my, mz  = (0,-18*sin(ang),-18*cos(ang)) # mirror coordinates
px, py, pz = 0, 65, -20
```

Optional: 
```python
aspect = 4.0/3.0
throw = 2.2
domeCoverRatio = 1 # 1 means 100% or the projection covers the entire dome
```

```findWarpForModel.py``` runtime is porportional to desiredVirtualImageWidth^2, and when desiredVirtualImageWidth = 500, the runtime is about 4 mins, and it will save the resulting mapping in a numpy array into ```mapping.npy```,
which is required to run the next program ```imageWarping.py```.

Image ```imageWarping.py``` takes inputs 
1) desiredVirtualImageWidth (this has to match the value in ```findWarpForModel.py```)
2) ```mapping.npy``` (loacted in the same folder) generated by the previous program
3) a image saved in the same folder
4) a selected circular region of interest defined by its center and radius in pixels. The program helps you visualize the ROI selected, so can run the program several times to find the desried ROI. 

e.g. 
```python
# load image
img = cv2.imread('image115.jpg',1)

#find fisheye image ROI(Region of Interest)
roiCenter = (300,255) #(600,510)
roiX,roiY = roiCenter
roiRadius = 250

```
