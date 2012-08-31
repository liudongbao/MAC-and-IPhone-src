/*********************************************************************
 *	
 *	cpShapeNode.m
 *
 *	Provide Drawing for Shapes
 *
 *	http://www.mobile-bros.com
 *
 *	Created by Robert Blackwood on 02/22/2009.
 *	Copyright 2009 Mobile Bros. All rights reserved.
 *
 **********************************************************************/

#import "cpShapeNode.h"
#import "CCDrawingPrimitives.h"

#define CP_CIRCLE_PT_COUNT 26
#define CP_SEG_PT_COUNT 26

static const int SMGR_sPtCount = CP_SEG_PT_COUNT;
static const GLfloat SMGR_sPt[CP_SEG_PT_COUNT+CP_SEG_PT_COUNT] = {
	0.0000,  1.0000,
	0.2588,  0.9659,
	0.5000,  0.8660,
	0.7071,  0.7071,
	0.8660,  0.5000,
	0.9659,  0.2588,
	1.0000,  0.0000,
	0.9659, -0.2588,
	0.8660, -0.5000,
	0.7071, -0.7071,
	0.5000, -0.8660,
	0.2588, -0.9659,
	0.0000, -1.0000,
	
	0.0000, -1.0000,
	-0.2588, -0.9659,
	-0.5000, -0.8660,
	-0.7071, -0.7071,
	-0.8660, -0.5000,
	-0.9659, -0.2588,
	-1.0000, -0.0000,
	-0.9659,  0.2588,
	-0.8660,  0.5000,
	-0.7071,  0.7071,
	-0.5000,  0.8660,
	-0.2588,  0.9659,
	0.0000,  1.0000,
};

static const int SMGR_cPtCount = CP_CIRCLE_PT_COUNT;
static const GLfloat SMGR_cPt[CP_CIRCLE_PT_COUNT+CP_CIRCLE_PT_COUNT] = {
	0.0000,  1.0000,
	0.2588,  0.9659,
	0.5000,  0.8660,
	0.7071,  0.7071,
	0.8660,  0.5000,
	0.9659,  0.2588,
	1.0000,  0.0000,
	0.9659, -0.2588,
	0.8660, -0.5000,
	0.7071, -0.7071,
	0.5000, -0.8660,
	0.2588, -0.9659,
	0.0000, -1.0000,
	-0.2588, -0.9659,
	-0.5000, -0.8660,
	-0.7071, -0.7071,
	-0.8660, -0.5000,
	-0.9659, -0.2588,
	-1.0000, -0.0000,
	-0.9659,  0.2588,
	-0.8660,  0.5000,
	-0.7071,  0.7071,
	-0.5000,  0.8660,
	-0.2588,  0.9659,
	0.0000,  1.0000,
	0.0f, 0.45f, // For an extra line to see the rotation.
};

@interface cpShapeNode (Private)
- (void) preDrawState;
- (void) postDrawState;

- (void) drawCircleShape;
- (void) drawPolyShape;
- (void) drawSegmentShape;

- (void) cacheSentinel:(int)count;
- (void) cacheCircle;
- (void) cachePoly;
- (void) cacheSegment;
@end


@implementation cpShapeNode

@synthesize color = _color;
@synthesize opacity = _opacity;
@synthesize pointSize = _pointSize;
@synthesize lineWidth = _lineWidth;
@synthesize smoothDraw = _smoothDraw;
@synthesize fillShape = _fillShape;
@synthesize drawDecoration = _drawDecoration;
@synthesize cacheDraw = _cacheDraw;

- (id) initWithShape:(cpShape*)shape;
{
	[super initWithShape:shape];
	
	_color = ccBLACK;
	_opacity = 255;
	_pointSize = 3;
	_lineWidth = 1;
	_smoothDraw = NO;	
	_fillShape = YES;
	_drawDecoration = YES;
	_cacheDraw = YES;
	_vertices = nil;
	
	//Invalid type, force initial cache
	_lastType = CP_NUM_SHAPES;
	
	//Set internals
	self.contentSize = CGSizeMake(shape->bb.r - shape->bb.l, shape->bb.b - shape->bb.t);
	self.anchorPoint = ccp(0.0f, 0.0f);
		
	return self;
}

- (void) dealloc
{
	free(_vertices);

	[super dealloc];
}

- (void) cacheSentinel:(int)count
{
	if (_vertices_count != count)
	{
		free(_vertices);
		_vertices = nil;
	}
	
	if (_vertices == nil)
	{
		_vertices = malloc(sizeof(GLfloat)*2*count);
		_vertices_count = count;
	}
}

- (void) cacheCircle
{	
	[self cacheSentinel:SMGR_cPtCount];
	
	cpFloat radius = cpCircleShapeGetRadius(_implementation.shape);
	for (int i = 0; i < SMGR_cPtCount; i++)
	{		
		_vertices[i*2] = SMGR_cPt[i*2] * radius * CC_CONTENT_SCALE_FACTOR();
		_vertices[i*2+1] = SMGR_cPt[i*2+1] * radius * CC_CONTENT_SCALE_FACTOR();
	}
}

- (void) cachePoly
{
	cpShape* poly = _implementation.shape;
	int count = cpPolyShapeGetNumVerts(poly);

	[self cacheSentinel:count];
		
	for(int i=0; i<count; i++)
	{
		cpVect v = cpPolyShapeGetVert(poly, i);
	
		_vertices[2*i] = v.x * CC_CONTENT_SCALE_FACTOR();
		_vertices[2*i+1] = v.y * CC_CONTENT_SCALE_FACTOR();
	}
}

- (void) cacheSegment
{	
	cpShape *seg = _implementation.shape;
	cpVect a = cpSegmentShapeGetA(seg);
	cpVect b = cpSegmentShapeGetB(seg);
	cpFloat radius = cpSegmentShapeGetRadius(seg);
	
	if (radius)
	{
		[self cacheSentinel:SMGR_sPtCount];
		
		cpVect delta = cpvsub(b, a);
		cpVect pos = cpvmult(cpvadd(a,b), .5);
		cpFloat len = cpvlength(delta);
		cpFloat half = len/2;
		cpVect norm = cpvmult(delta, 1/len);
		cpVect pt;
		
		for (int i = 0; i < SMGR_sPtCount; i++)
		{
			pt.x = SMGR_sPt[i*2]*radius;
			pt.y = SMGR_sPt[i*2+1]*radius;
			
			if (i < SMGR_sPtCount/2)
				pt.x += half;
			else
				pt.x -= half;
			
			pt = cpvrotate(pt, norm);
			
			pt = cpvadd(pt, pos);
			
			_vertices[i*2] = pt.x * CC_CONTENT_SCALE_FACTOR();
			_vertices[i*2+1] = pt.y * CC_CONTENT_SCALE_FACTOR();
		}
						
	} else 
	{
		[self cacheSentinel:2];
		
		_vertices[0] = a.x;
		_vertices[1] = a.y;
		_vertices[2] = b.x;
		_vertices[3] = b.y;
	}
}

#define RENDER_IN_SUBPIXEL

- (void) preDrawState
{
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisable(GL_TEXTURE_2D);
}

- (void) postDrawState
{
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glEnable(GL_TEXTURE_2D);
}

- (void) draw
{
	//[super draw];
	cpShape *shape = _implementation.shape;
	cpShapeType type = shape->klass->type;
	
	//need to update verts?
	BOOL update = (type != _lastType) || _cacheDraw;
	_lastType = type;
	
	[self preDrawState];
	
	glPointSize(_pointSize);
	glLineWidth(_lineWidth);
	if (_smoothDraw && _lineWidth <= 1) //OpenGL ES 1.1 doesn't support smooth lineWidths > 1
	{
		glEnable(GL_LINE_SMOOTH);
		glEnable(GL_POINT_SMOOTH);
	}
	else
	{
		glDisable(GL_LINE_SMOOTH);
		glDisable(GL_POINT_SMOOTH);
	}
	
	if( _opacity != 255 )
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		
	glColor4ub(_color.r, _color.g, _color.b, _opacity);
	
	switch(type)
	{
		case CP_CIRCLE_SHAPE:
		{
			//Circle's are somewhat unique with this offset variable
			cpVect offset = cpCircleShapeGetOffset(shape);
			BOOL pushpop =  (offset.x != 0 && offset.y != 0);
			
			if (pushpop)
			{
				glPushMatrix();
				glTranslatef(RENDER_IN_SUBPIXEL(offset.x), RENDER_IN_SUBPIXEL(offset.y), 0);
			}
			
			if (update)
				[self cacheCircle];
			[self drawCircleShape];

			if (pushpop)
				glPopMatrix();
			break;
		}
		case CP_SEGMENT_SHAPE:
			if (update)
				[self cacheSegment];
			[self drawSegmentShape];
			break;
		case CP_POLY_SHAPE:
			if (update)
				[self cachePoly];
			[self drawPolyShape];
			break;
		default:
			break;
	}
	
	if( _opacity != 255 )
		glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);
	
	[self postDrawState];
}

- (void) drawCircleShape
{
	int extraPtOffset = _drawDecoration ? 0 : 1;
	
	glVertexPointer(2, GL_FLOAT, 0, _vertices);
	
	if (_fillShape)
		glDrawArrays(GL_TRIANGLE_FAN, 0, _vertices_count-extraPtOffset-1);
	else
		glDrawArrays(GL_LINE_STRIP, 0, _vertices_count-extraPtOffset);
}

-(void)drawSegmentShape
{
	glVertexPointer(2, GL_FLOAT, 0, _vertices);
	
	if (_fillShape)
		glDrawArrays(GL_TRIANGLE_FAN, 0, _vertices_count);
	else
		glDrawArrays(GL_LINE_LOOP, 0, _vertices_count);
}

- (void) drawPolyShape
{
	glVertexPointer(2, GL_FLOAT, 0, _vertices);

	if (_fillShape)
		glDrawArrays(GL_TRIANGLE_FAN, 0, _vertices_count);
	else
		glDrawArrays(GL_LINE_LOOP, 0, _vertices_count);
}

@end

@interface cpShapeTextureNode (Private)
-(void) cacheCoordsAndColors;
-(int) getTextureWidth;
-(int) getTextureHeight;
@end

@implementation cpShapeTextureNode
@synthesize texture = _texture;
@synthesize textureOffset = _textureOffset;
@synthesize textureRotation = _textureRotation;

+ (id) nodeWithShape:(cpShape *)shape file:(NSString*)file
{
	return [[[self alloc] initWithShape:shape file:file] autorelease];
}

+ (id) nodeWithShape:(cpShape*)shape texture:(CCTexture2D*)texture
{
	return [[[self alloc] initWithShape:shape texture:texture] autorelease];
}

+ (id) nodeWithShape:(cpShape*)shape batchNode:(cpShapeTextureBatchNode*)batchNode
{
	return [[[self alloc] initWithShape:shape batchNode:batchNode] autorelease];
}

- (id) initWithShape:(cpShape *)shape file:(NSString*)file
{
	return [self initWithShape:shape texture:[[CCTextureCache sharedTextureCache] addImage:file]];
}

- (id) initWithShape:(cpShape*)shape texture:(CCTexture2D*)texture
{
	[super initWithShape:shape];
	
	_color = ccWHITE;
	_textureOffset = ccp(0,0);
	_textureRotation = 0;
	self.texture = texture;
	
	//set texture to repeat
	ccTexParams params = {GL_LINEAR,GL_LINEAR,GL_REPEAT,GL_REPEAT};
	[_texture setTexParameters:&params];
	
	return self;
}

- (id) initWithShape:(cpShape*)shape batchNode:(cpShapeTextureBatchNode*)batchNode
{
	[self initWithShape:shape texture:nil];
	_batchNode = batchNode;
	
	return self;
}

- (void) dealloc
{
	free(_coordinates);
	free(_colors);
	self.texture = nil;
	[super dealloc];
}

-(int) getTextureWidth
{
	if (_batchNode)
		return _batchNode.texture.pixelsWide;
	else
		return _texture.pixelsWide;
}

-(int) getTextureHeight
{
	if (_batchNode)
		return _batchNode.texture.pixelsHigh;
	else
		return _texture.pixelsHigh;	
}

- (void) draw
{
	if (!_batchNode && _texture)
		glBindTexture(GL_TEXTURE_2D, _texture.name);

	[super draw];
}

- (void) preDrawState
{
	//override to do nothing		
}

- (void) postDrawState
{
	//override to do nothing
}

- (void) drawCircleShape
{	
	[self drawPolyShape];
}

- (void) drawSegmentShape
{
	[self drawPolyShape];
}

- (void) drawPolyShape;
{
	glVertexPointer(2, GL_FLOAT, 0, _vertices);
	glColorPointer(4, GL_UNSIGNED_BYTE, 0, _colors);
	glTexCoordPointer(2, GL_FLOAT, 0, _coordinates);
	
	glDrawArrays(GL_TRIANGLE_FAN, 0, _vertices_count);
}

- (void) cacheSentinel:(int)count
{	
	if (_vertices_count != count)
	{
		free(_colors);
		free(_coordinates);
		
		_colors = nil;
		_coordinates = nil;
	}
	
	if (_colors == nil)
		_colors = malloc(sizeof(ccColor4B)*2*count);
	if (_coordinates == nil)
		_coordinates = malloc(sizeof(GLfloat)*2*count);
	
	[super cacheSentinel:count];
}

- (void) cacheCircle
{
	[super cacheCircle];
	[self cacheCoordsAndColors];
}

- (void) cachePoly
{
	[super cachePoly];
	[self cacheCoordsAndColors];	
}

- (void) cacheSegment
{
	[super cacheSegment];
	[self cacheCoordsAndColors];
}

-(void) cacheCoordsAndColors
{
	ccColor4B color = ccc4(_color.r, _color.g, _color.b, _opacity);
	
	const float width = [self getTextureWidth];	
	const float height = [self getTextureHeight];
	CGPoint t_rot = ccpForAngle(-CC_DEGREES_TO_RADIANS(_textureRotation));
	
	for (int i = 0; i < _vertices_count; i++)
	{	
		CGPoint coord = ccp(_vertices[i*2]/width, -_vertices[i*2+1]/height);
		if (_textureRotation)
			coord = ccpRotate(coord, t_rot);
		
		_coordinates[i*2] = coord.x + _textureOffset.x;
		_coordinates[i*2+1] = coord.y + _textureOffset.y;
		
		_colors[i*2] = color;
		_colors[i*2+1] = color;
	}	
}

@end

@implementation cpShapeTextureBatchNode
@synthesize texture = _texture;

+ (id) nodeWithFile:(NSString*)file
{
	return [[[self alloc] initWithFile:file] autorelease];
}

+ (id) nodeWithTexture:(CCTexture2D*)texture;
{
	return [[[self alloc] initWithTexture:texture] autorelease];
}

- (id) initWithFile:(NSString*)file;
{
	return [self initWithTexture:[[CCTextureCache sharedTextureCache] addImage:file]];
}

- (id) initWithTexture:(CCTexture2D*)texture;
{
	[super init];
	
	self.texture = texture;
	
	//set texture to repeat
	ccTexParams params = {GL_LINEAR,GL_LINEAR,GL_REPEAT,GL_REPEAT};
	[_texture setTexParameters:&params];
	
	return self;
}

- (void) dealloc
{
	self.texture = nil;
	[super dealloc];
}

- (void) visit
{
	//cheap way to batch... not as efficient as CC implementation
	glBindTexture(GL_TEXTURE_2D, _texture.name);

	[super visit];
}

@end


