// BBPoint is a 3d point struct.  
// this is the definition of that struct and a hand ful of inline functions for manipulating the point.

// A 3D point
typedef struct {
	CGFloat			x, y, z;
} BBPoint;

typedef BBPoint* BBPointPtr;

static inline BBPoint BBPointMake(CGFloat x, CGFloat y, CGFloat z)
{
	return (BBPoint) {x, y, z};
}

static inline NSString * NSStringFromBBPoint(BBPoint p)
{
	return [NSString stringWithFormat:@"{%3.2f, %3.2f, %3.2f}",p.x,p.y,p.z];
}

static inline NSString * NSStringFromMatrix(CGFloat * m)
{
	return [NSString stringWithFormat:@"%3.2f %3.2f %3.2f %3.2f\n%3.2f %3.2f %3.2f %3.2f\n%3.2f %3.2f %3.2f %3.2f\n%3.2f %3.2f %3.2f %3.2f\n",m[0],m[4],m[8],m[12],m[1],m[5],m[9],m[13],m[2],m[6],m[10],m[14],m[3],m[7],m[11],m[15]];
}

static inline BBPoint BBPointMatrixMultiply(BBPoint p, CGFloat* m)
{
	CGFloat x = (p.x*m[0]) + (p.y*m[4]) + (p.z*m[8]) + m[12];
	CGFloat y = (p.x*m[1]) + (p.y*m[5]) + (p.z*m[9]) + m[13];
	CGFloat z = (p.x*m[2]) + (p.y*m[6]) + (p.z*m[10]) + m[14];
	
	return (BBPoint) {x, y, z};
}

static inline float BBPointDistance(BBPoint p1, BBPoint p2)
{
	return sqrt(((p1.x - p2.x) * (p1.x - p2.x)) + 
							((p1.y - p2.y)  * (p1.y - p2.y)) + 
							((p1.z - p2.z) * (p1.z - p2.z)));
}








