/*********************************************************************
 *	
 *	Space Manager
 *
 *	SpaceManager.m
 *
 *	Manage the space for the application
 *
 *	http://www.mobile-bros.com
 *
 *	Created by Robert Blackwood on 02/22/2009.
 *	Copyright 2009 Mobile Bros. All rights reserved.
 *
 **********************************************************************/

#import "SpaceManager.h"
#import "chipmunk_unsafe.h"
#import "cpSpaceSerializer.h"

/* Private Method Declarations */
@interface SpaceManager (PrivateMethods)
-(void) setupDefaultShape:(cpShape*)s;
-(void) removeAndMaybeFreeShape:(cpShape*)shape freeShape:(BOOL)freeShape;
@end

@interface RayCastInfoValue : NSValue
@end
@implementation RayCastInfoValue
- (void) dealloc
{
	cpSegmentQueryInfo *info = (cpSegmentQueryInfo*)[self pointerValue];
	free(info);
	
	[super dealloc];
}
@end

typedef struct ExplosionQueryContext {
	cpLayers layers;
	cpGroup group;
	cpVect at;
	float radius;
	float maxForce;
} ExplosionQueryContext;

class cpSSDelegate : public cpSpaceSerializerDelegate 
{
public:
	
	cpSSDelegate(NSObject<SpaceManagerSerializeDelegate>* delegate) : _delegate(delegate){}
	
	long makeId(cpShape* shape) 
	{
		if ([_delegate respondsToSelector:@selector(makeShapeId:)])
			return [_delegate makeShapeId:shape];		
		else
			return CPSS_DEFAULT_MAKE_ID(shape);
	}
	
	long makeId(cpBody* body) 
	{
		if ([_delegate respondsToSelector:@selector(makeBodyId:)])
			return [_delegate makeBodyId:body];		
		else
			return CPSS_DEFAULT_MAKE_ID(body);
	}
	
	long makeId(cpConstraint* constraint) 
	{
		if ([_delegate respondsToSelector:@selector(makeConstraintId:)])
			return [_delegate makeConstraintId:constraint];		
		else
			return CPSS_DEFAULT_MAKE_ID(constraint);
	}
	
	bool writing(cpShape *shape, long shapeId) 
	{
		if ([_delegate respondsToSelector:@selector(aboutToWriteShape:shapeId:)])
			return [_delegate aboutToWriteShape:shape shapeId:shapeId];		
		else
			return true;
	}
	
	bool writing(cpBody *body, long bodyId) 
	{
		if ([_delegate respondsToSelector:@selector(aboutToWriteBody:bodyId:)])
			return [_delegate aboutToWriteBody:body bodyId:bodyId];		
		else
			return true;
	}
	
	bool writing(cpConstraint *constraint, long constraintId) 
	{
		if ([_delegate respondsToSelector:@selector(aboutToWriteConstraint:constraintId:)])
			return [_delegate aboutToWriteConstraint:constraint constraintId:constraintId];		
		else
			return true;
	}
	
	bool reading(cpShape *shape, long shapeId) 
	{
		if ([_delegate respondsToSelector:@selector(aboutToReadShape:shapeId:)])
			return [_delegate aboutToReadShape:shape shapeId:shapeId];		
		else
			return true;
		
	}
	bool reading(cpBody *body, long bodyId) 
	{
		if ([_delegate respondsToSelector:@selector(aboutToReadBody:bodyId:)])
			return [_delegate aboutToReadBody:body bodyId:bodyId];		
		else
			return true;
	}
	bool reading(cpConstraint *constraint, long constraintId) 
	{
		if ([_delegate respondsToSelector:@selector(aboutToReadConstraint:constraintId:)])
			return [_delegate aboutToReadConstraint:constraint constraintId:constraintId];		
		else
			return true;
	}
	
private:
	NSObject<SpaceManagerSerializeDelegate>* _delegate;
};

static void ExplosionQueryHelper(cpBB *bb, cpShape *shape, ExplosionQueryContext *context)
{
	if (!(shape->group && context->group == shape->group) && 
		(context->layers&shape->layers) &&
		cpBBintersects(*bb, shape->bb))
	{
		//incredibly cheesy explosion effect (works decent with small objects)
		cpVect dxdy = cpvsub(shape->body->p, context->at);
		float distsq = cpvlengthsq(dxdy);
		
		// [Factor] = [Distance]/[Explosion Radius] 
		// [Force] = (1.0 - [Factor]) * [Total Force]
		// Apply -> [Direction] * [Force]
		if (distsq <= context->radius*context->radius)
		{
			//Distance
			float dist = cpfsqrt(distsq);
			
			//normalize for direction
			dxdy = cpvmult(dxdy, 1.0f/dist);
			cpBodyApplyImpulse(shape->body, cpvmult(dxdy, context->maxForce*(1.0f - (dist/context->radius))), cpvzero);
		}
	}
}

static int handleInvocations(CollisionMoment moment, cpArbiter *arb, struct cpSpace *space, void *data)
{
	NSInvocation *invocation = (NSInvocation*)data;
	
	@try {
		[invocation setArgument:&moment atIndex:2];
		[invocation setArgument:&arb atIndex:3];
		[invocation setArgument:&space atIndex:4];
	}
	@catch (NSException *e) {
		//No biggie, continue!
	}
	
	[invocation invoke];
	
	//default is yes, thats what it is in chipmunk
	BOOL retVal = YES;
	
	//not sure how heavy these methods are...
	if ([[invocation methodSignature]  methodReturnLength] > 0)
		[invocation getReturnValue:&retVal];
	
	return retVal;
}

static int collBegin(cpArbiter *arb, struct cpSpace *space, void *data)
{
	return handleInvocations(COLLISION_BEGIN, arb, space, data);
}

static int collPreSolve(cpArbiter *arb, struct cpSpace *space, void *data)
{
	return handleInvocations(COLLISION_PRESOLVE, arb, space, data);
}

static void collPostSolve(cpArbiter *arb, struct cpSpace *space, void *data)
{
	handleInvocations(COLLISION_POSTSOLVE, arb, space, data);
}

static void collSeparate(cpArbiter *arb, struct cpSpace *space, void *data)
{
	handleInvocations(COLLISION_SEPARATE, arb, space, data);
}


static int collIgnore(cpArbiter *arb, struct cpSpace *space, void *data)
{
	return 0;
}

static void collectAllShapes(cpShape *shape, NSMutableArray *outShapes)
{
	[outShapes addObject:[NSValue valueWithPointer:shape]];
}

static void collectAllCollidingShapes(cpShape *shape, cpContactPointSet *points, NSMutableArray *outShapes)
{
	[outShapes addObject:[NSValue valueWithPointer:shape]];	
}

static void collectAllSegmentQueryInfos(cpShape *shape, cpFloat t, cpVect n, NSMutableArray *outInfos)
{
	cpSegmentQueryInfo *info = (cpSegmentQueryInfo*)malloc(sizeof(cpSegmentQueryInfo));
	info->shape = shape;
	info->t = t;
	info->n = n;
	[outInfos addObject:[RayCastInfoValue valueWithPointer:info]];
}

static void collectAllSegmentQueryShapes(cpShape *shape, cpFloat t, cpVect n, NSMutableArray *outShapes)
{
	[outShapes addObject:[NSValue valueWithPointer:shape]];
}

static void updateBBCache(cpShape *shape, void *unused)
{
	cpShapeCacheBB(shape);
}

static void removeShape(cpSpace *space, void *obj, void *data)
{
	[(SpaceManager*)(data) removeAndMaybeFreeShape:(cpShape*)(obj) freeShape:NO];
}

static void removeAndFreeShape(cpSpace *space, void *shape, void *data)
{
	[(SpaceManager*)(data) removeAndMaybeFreeShape:(cpShape*)(shape) freeShape:YES];
}

static void freeStaticBodyHelper(void *ptr, void *data)
{
	cpSpace *space = (cpSpace*)data;
	cpShape *shape = (cpShape*)ptr;
	if (shape && shape->body && shape->body != &space->staticBody)
	{
		cpBody* body = shape->body;
		
		//clear refs from all shapes
		for(cpShape *sh = body->shapesList; sh; sh=sh->next)
			sh->body = NULL;
		
		cpBodyFree(body);
	}
}

static void addShape(cpSpace *space, void *obj, void *data)
{
	cpShape *shape = (cpShape*)(obj);
	
	if (shape->body->m != STATIC_MASS)
	{
		cpSpaceAddBody(space, shape->body);
		cpSpaceAddShape(space, shape);
	}
	else
		cpSpaceAddStaticShape(space, shape);
}

static void removeCollision(cpSpace *space, void *collision, void *inv_list)
{
	cpCollisionHandler *pair = (cpCollisionHandler*)collision;
	
	unsigned int ids[] = {pair->a, pair->b};
	unsigned int hash = CP_HASH_PAIR(pair->a, pair->b);
	
	//delete the invocation (invocation can be null)
	id invocation = (id)pair->data;
	
	NSMutableArray *invocations = (NSMutableArray*)inv_list;
	[invocations removeObject:invocation];

	//Remove the collision callback
	cpCollisionHandler *old_pair = (cpCollisionHandler*)cpHashSetRemove(space->collFuncSet, hash, ids);
	free(old_pair);	

}

@interface RayCastInfoArray : NSMutableArray
@end

@implementation SpaceManager

@synthesize space = _space;
@synthesize topWall,bottomWall,rightWall,leftWall;
@synthesize steps = _steps;
@synthesize lastDt = _lastDt;
@synthesize iterateStatic = _iterateStatic;
@synthesize rehashStaticEveryStep = _rehashStaticEveryStep;
@synthesize iterateFunc = _iterateFunc;
@synthesize constantDt = _constantDt;
@synthesize cleanupBodyDependencies = _cleanupBodyDependencies;
@synthesize constraintCleanupDelegate = _constraintCleanupDelegate;
//gravity and damping are written out manually

+(id) spaceManager
{
	return [[[self alloc] init] autorelease];
}

+(id) spaceManagerWithSize:(int)size count:(int)count;
{
	return [[[self alloc] initWithSize:size count:count] autorelease];
}

+(id) spaceManagerWithSpace:(cpSpace*)space;
{
	return [[[self alloc] initWithSpace:space] autorelease];	
}

-(id) init
{
	//totally arbitrary initialization values
	return [self initWithSize:20 count:50];
}

-(id) initWithSize:(int)size count:(int)count
{
	id me = [self initWithSpace:cpSpaceNew()];
	
	cpSpaceResizeStaticHash(_space, size, count);
	cpSpaceResizeActiveHash(_space, size, count);
	
	return me;
}

-(id) initWithSpace:(cpSpace*)space
{	
	[super init];
	
	static BOOL initialized = NO;	
	if (!initialized)
	{
		cpInitChipmunk();
		initialized = YES;
	}
	
	_space = space;
	
	//hmmm this gravity is silly.... sorry -rkb
	_space->gravity = cpv(0, -9.8*10);
	_space->elasticIterations = _space->iterations;
	_space->sleepTimeThreshold = .4;	//this is actually a "large" value
	//_space->idleSpeedThreshold = 0;	//default is zero, chipmunk decides best speed
	
	topWall = bottomWall = rightWall = leftWall = nil;
	_steps = 2;
	_iterateStatic = YES;
	_rehashStaticEveryStep = NO;
	_cleanupBodyDependencies = YES;
	_constantDt = 0.0f;
	_timeAccumulator = 0.0f;
	
	_iterateFunc = NULL;
	_invocations = [[NSMutableArray alloc] init];
	
	return self;
}

-(void) dealloc
{		
	if (_space != nil)
	{
		//Clear all "unowned" static bodies
		cpSpaceHashEach(_space->staticShapes, freeStaticBodyHelper, _space);
		
		cpSpaceFreeChildren(_space);
		cpSpaceFree(_space);
	}	
	
	[_invocations release];
	
	[super dealloc];
}

- (cpBody*) staticBody
{
	if (_space)
		return &_space->staticBody;
	else
		return nil;
}

- (BOOL) loadSpaceFromUserDocs:(NSString*)file delegate:(NSObject<SpaceManagerSerializeDelegate>*)delegate
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:file];
	
	return [self loadSpaceFromPath:path delegate:delegate];
}

- (BOOL) saveSpaceToUserDocs:(NSString*)file delegate:(NSObject<SpaceManagerSerializeDelegate>*)delegate
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:file];	
	
	return [self saveSpaceToPath:path delegate:delegate];
}

- (BOOL) loadSpaceFromPath:(NSString*)path delegate:(NSObject<SpaceManagerSerializeDelegate>*)delegate
{
	if ([[NSFileManager defaultManager] fileExistsAtPath:path])
	{
		cpSSDelegate cpssdel(delegate);
		
		cpSpaceSerializer reader(&cpssdel);
		reader.load(_space, [path cStringUsingEncoding:NSASCIIStringEncoding]);
		
		return YES;
	}
	else
		return NO;
}

- (BOOL) saveSpaceToPath:(NSString*)path delegate:(NSObject<SpaceManagerSerializeDelegate>*)delegate
{
	cpSSDelegate cpssdel(delegate);
	cpSpaceSerializer writer(&cpssdel);	
	return writer.save(_space, [path cStringUsingEncoding:NSASCIIStringEncoding]);
}

-(void) setGravity:(cpVect)gravity
{
	_space->gravity = gravity;
}

-(cpVect) gravity
{
	return _space->gravity;
}

-(void) setDamping:(cpFloat)damping
{
	_space->damping = damping;
}

-(cpFloat) damping
{
	return _space->damping;
}

-(void) addWindowContainmentWithFriction:(cpFloat)friction elasticity:(cpFloat)elasticity size:(CGSize)wins inset:(cpVect)inset radius:(cpFloat)radius
{	
	
	bottomWall = [self addSegmentAtWorldAnchor:cpv(inset.x,inset.y) 
								 toWorldAnchor:cpv(wins.width-inset.x,inset.y) 
										  mass:STATIC_MASS 
										radius:radius];
	
	topWall = [self addSegmentAtWorldAnchor:cpv(inset.x,wins.height-inset.y) 
							  toWorldAnchor:cpv(wins.width-inset.x,wins.height-inset.y)
									   mass:STATIC_MASS 
									 radius:radius];
	
	leftWall = [self addSegmentAtWorldAnchor:cpv(inset.x,inset.y)
							   toWorldAnchor:cpv(inset.x,wins.height-inset.y)
										mass:STATIC_MASS
									  radius:radius];
	
	rightWall = [self addSegmentAtWorldAnchor:cpv(wins.width-inset.x,inset.y)
								toWorldAnchor:cpv(wins.width-inset.x,wins.height-inset.y)
										 mass:STATIC_MASS 
									   radius:radius];
	
	bottomWall->e = topWall->e = leftWall->e = rightWall->e = elasticity;
	bottomWall->u = topWall->u = leftWall->u = rightWall->u = friction;
}

-(void) step: (cpFloat) delta
{		
	//re-calculate static shape positions if this is set
	if (_rehashStaticEveryStep)
		cpSpaceRehashStatic(_space);
	
	_lastDt = delta;
	
	if (!_constantDt)
	{	
		cpFloat dt = delta/_steps;
		for(int i=0; i<_steps; i++)
			cpSpaceStep(_space, dt);
	}
	else 
	{
		cpFloat dt = _constantDt/_steps;
		delta += _timeAccumulator;
		while(delta >= _constantDt) 
		{
			for(int i=0; i<_steps; i++)
				cpSpaceStep(_space, dt);
			
			delta -= _constantDt;
		}
		
		_timeAccumulator = delta > 0 ? delta : 0.0f;
	}
	
	if (_iterateFunc)
	{
		cpSpaceHashEach(_space->activeShapes, _iterateFunc, self);

		//Since static shapes are stationary, you do not really need this (only for the first sync)
		if (_iterateStatic)
			cpSpaceHashEach(_space->staticShapes, _iterateFunc, self);
	}
}

-(void) removeAndMaybeFreeShape:(cpShape*)shape freeShape:(BOOL)freeShape
{	
	if (shape->body->m == STATIC_MASS)
		cpSpaceRemoveStaticShape(_space, shape);
	else		
		cpSpaceRemoveShape(_space, shape);
	
	//Make sure it's not our static body
	if (shape->body != &_space->staticBody)
	{
		//Checking if this body is shared....!
		BOOL shared = NO;
		
		//anyone else have this body?
		for(cpShape *sh = shape->body->shapesList; sh && !shared; sh=sh->next)
			shared = (sh != shape);
			
		//if not then get rid of it
		if (!shared)
		{
			//in this space?
			if (shape->body->space == _space)
				cpSpaceRemoveBody(_space, shape->body);
			
			//Free it
			if (freeShape)
			{
				//cleanup any constraints
				if (_cleanupBodyDependencies)
					[self removeAndFreeConstraintsOnBody:shape->body];
				
				cpBodyFree(shape->body);
			}
		}
		
	}
	
	if (freeShape)
		cpShapeFree(shape);	
}

-(cpShape*) removeShape:(cpShape*)shape
{
	if (_space->locked)
		cpSpaceAddPostStepCallback(_space, removeShape, shape, self);
	else
		[self removeAndMaybeFreeShape:shape freeShape:NO];
	
	return shape;
}

-(void) removeAndFreeShape:(cpShape*)shape
{
	if (_space->locked)
		cpSpaceAddPostStepCallback(_space, removeAndFreeShape, shape, self);
	else
		[self removeAndMaybeFreeShape:shape freeShape:YES];
}

-(void) setupDefaultShape:(cpShape*) s
{
	//Remember to set these later, if you want different values
	s->e = .5; 
	s->u = .5;
	s->collision_type = 0;
	s->data = nil;
}

-(cpShape*) addCircleAt:(cpVect)pos mass:(cpFloat)mass radius:(cpFloat)radius
{
	cpShape* shape;
	cpFloat moment = STATIC_MASS;
	
	if (mass != STATIC_MASS)
		moment = cpMomentForCircle(mass, radius, radius, cpvzero);
	
	shape = cpCircleShapeNew(cpBodyNew(mass, moment), radius, cpvzero);
	cpBodySetPos(shape->body, pos);
	
	[self setupDefaultShape:shape];
	[self addShape:shape];
	
	return shape;
}

-(cpShape*) addRectAt:(cpVect)pos mass:(cpFloat)mass width:(cpFloat)width height:(cpFloat)height rotation:(cpFloat)r 
{	
	const cpFloat halfHeight = height/2.0f;
	const cpFloat halfWidth = width/2.0f;
	return [self addPolyAt:pos mass:mass rotation:r numPoints:4 points:		
																	cpv(-halfWidth, halfHeight),	/* top-left */ 
																	cpv( halfWidth, halfHeight),	/* top-right */
																	cpv( halfWidth,-halfHeight),	/* bottom-right */
																	cpv(-halfWidth,-halfHeight)];	/* bottom-left */
}

-(cpShape*) addPolyAt:(cpVect)pos mass:(cpFloat)mass rotation:(cpFloat)r numPoints:(int)numPoints points:(cpVect)pt, ...
{
	cpShape* shape = nil;
	
	va_list args;
	va_start(args,pt);
		
	//Setup our vertices
	cpVect verts[numPoints];
	verts[0] = pt;
	for (int i = 1; i < numPoints; i++)
		verts[i] = va_arg(args, cpVect);
		
	shape = [self addPolyAt: pos mass: mass rotation: r numPoints: numPoints pointsArray:verts];
		
	va_end(args);
	
	return shape;	
}

-(cpShape*) addPolyAt:(cpVect)pos mass:(cpFloat)mass rotation:(cpFloat)r points:(NSArray*)points
{	
	//Setup our vertices
	int numPoints = [points count];
	cpVect verts[numPoints];
	for (int i = 0; i < numPoints; i++)
	{
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		verts[i] = [[points objectAtIndex:i] CGPointValue];
#else
		verts[i] = [[points objectAtIndex:i] pointValue];	
#endif
	}
	return [self addPolyAt: pos mass: mass rotation: r numPoints: numPoints pointsArray:verts];	
}

//patch submitted by ja...@nuts.pl for c-style arrays
-(cpShape*) addPolyAt:(cpVect)pos mass:(cpFloat)mass rotation:(cpFloat)r numPoints:(int)numPoints pointsArray:(cpVect*)points
{
	cpShape* shape = nil;
	
	if (numPoints >= 3)
	{		
		//Setup our poly shape
		cpFloat moment = STATIC_MASS;
		if (mass != STATIC_MASS)
			moment = cpMomentForPoly(mass, numPoints, points, cpvzero);
		
		shape = cpPolyShapeNew(cpBodyNew(mass, moment), numPoints, points, cpvzero);
		cpBodySetPos(shape->body, pos);
		
		[self setupDefaultShape:shape];
		cpBodySetAngle(shape->body, r);	
		[self addShape:shape];
	}
	
	return shape;
}

-(cpShape*) addSegmentAtWorldAnchor:(cpVect)fromPos toWorldAnchor:(cpVect)toPos mass:(cpFloat)mass radius:(cpFloat)radius
{
	cpVect pos = cpvmult(cpvsub(toPos,fromPos), .5);
	return [self addSegmentAt:cpvadd(fromPos,pos) fromLocalAnchor:cpvmult(pos,-1) toLocalAnchor:pos mass:mass radius:radius];
}

-(cpShape*) addSegmentAt:(cpVect)pos fromLocalAnchor:(cpVect)fromPos toLocalAnchor:(cpVect)toPos mass:(cpFloat)mass radius:(cpFloat)radius
{
	cpShape* shape;
	cpFloat moment = STATIC_MASS;
	
	if (mass != STATIC_MASS)
		moment = cpMomentForSegment(mass, fromPos, toPos);
	
	shape = cpSegmentShapeNew(cpBodyNew(mass, moment), fromPos, toPos, radius);
	cpBodySetPos(shape->body, pos);
	
	[self setupDefaultShape:shape];
	[self addShape:shape];
	
	return shape;
}

-(cpShape*) getShapeAt:(cpVect)pos layers:(cpLayers)layers group:(cpLayers)group
{
	return cpSpacePointQueryFirst(_space, pos, layers, group);
}

-(cpShape*) getShapeAt:(cpVect)pos
{
	return [self getShapeAt:pos layers:CP_ALL_LAYERS group:CP_NO_GROUP];
}

-(void) rehashActiveShapes
{
	cpSpaceHashEach(_space->activeShapes, (cpSpaceHashIterator)&updateBBCache, NULL);
	cpSpaceHashRehash(_space->activeShapes);
}

-(void) rehashStaticShapes
{
	cpSpaceRehashStatic(_space);
}

-(void) rehashShape:(cpShape*)shape
{
	//############# Code taken from Chipmunk repo
	cpShapeCacheBB(shape);
	
	// attempt to rehash the shape in both hashes
	cpSpaceHashRehashObject(_space->activeShapes, shape, shape->hashid);
	cpSpaceHashRehashObject(_space->staticShapes, shape, shape->hashid);
}

-(NSArray*) getShapesAt:(cpVect)pos layers:(cpLayers)layers group:(cpLayers)group
{
	NSMutableArray *shapes = [[[NSMutableArray alloc] init] autorelease];
	cpSpacePointQuery(_space, pos, layers, group, (cpSpacePointQueryFunc)collectAllShapes, shapes);
		
	return shapes;
}

-(NSArray*) getShapesAt:(cpVect)pos
{
	return [self getShapesAt:pos layers:CP_ALL_LAYERS group:CP_NO_GROUP];
}

-(NSArray*) getShapesAt:(cpVect)pos radius:(float)radius layers:(cpLayers)layers group:(cpLayers)group;
{
	NSMutableArray *shapes = [[[NSMutableArray alloc] init] autorelease];
	
	cpCircleShape circle;
	cpCircleShapeInit(&circle, [self staticBody], radius, pos);
	circle.shape.layers = layers;
	circle.shape.group = group;
	
	cpSpaceShapeQuery(_space, (cpShape*)(&circle), (cpSpaceShapeQueryFunc)collectAllCollidingShapes, shapes);
	
	return shapes;
}

-(NSArray*) getShapesAt:(cpVect)pos radius:(float)radius
{
	return [self getShapesAt:pos radius:radius layers:CP_ALL_LAYERS group:CP_NO_GROUP];
}

-(cpShape*) getShapeFromRayCastSegment:(cpVect)start end:(cpVect)end layers:(cpLayers)layers group:(cpGroup)group
{
	return cpSpaceSegmentQueryFirst(_space, start, end, layers, group, NULL);
}

-(cpShape*) getShapeFromRayCastSegment:(cpVect)start end:(cpVect)end
{
	return [self getShapeFromRayCastSegment:start end:end layers:CP_ALL_LAYERS group:CP_NO_GROUP];
}

-(cpSegmentQueryInfo) getInfoFromRayCastSegment:(cpVect)start end:(cpVect)end layers:(cpLayers)layers group:(cpGroup)group
{
	cpSegmentQueryInfo info;
	cpSpaceSegmentQueryFirst(_space, start, end, layers, group, &info);
	
	return info;
}
	 
-(cpSegmentQueryInfo) getInfoFromRayCastSegment:(cpVect)start end:(cpVect)end
{
	return [self getInfoFromRayCastSegment:start end:end layers:CP_ALL_LAYERS group:CP_NO_GROUP];
}

-(NSArray*) getShapesFromRayCastSegment:(cpVect)start end:(cpVect)end layers:(cpLayers)layers group:(cpGroup)group
{
	NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
	
	cpSpaceSegmentQuery(_space, start, end, layers, group, (cpSpaceSegmentQueryFunc)collectAllSegmentQueryShapes, array);
	
	return array;
}

-(NSArray*) getShapesFromRayCastSegment:(cpVect)start end:(cpVect)end
{
	return [self getShapesFromRayCastSegment:start end:end layers:CP_ALL_LAYERS group:CP_NO_GROUP];
}

-(NSArray*) getInfosFromRayCastSegment:(cpVect)start end:(cpVect)end layers:(cpLayers)layers group:(cpGroup)group
{
	NSMutableArray *array = [[[NSMutableArray alloc] init] autorelease];
	
	cpSpaceSegmentQuery(_space, start, end, layers, group, (cpSpaceSegmentQueryFunc)collectAllSegmentQueryInfos, array);
	
	return array;
}

-(NSArray*) getInfosFromRayCastSegment:(cpVect)start end:(cpVect)end
{
	return [self getInfosFromRayCastSegment:start end:end layers:CP_ALL_LAYERS group:CP_NO_GROUP];
}

-(void) applyLinearExplosionAt:(cpVect)at radius:(cpFloat)radius maxForce:(cpFloat)maxForce
{	
	[self applyLinearExplosionAt:at radius:radius maxForce:maxForce layers:CP_ALL_LAYERS group:CP_NO_GROUP];
}

-(void) applyLinearExplosionAt:(cpVect)at radius:(cpFloat)radius maxForce:(cpFloat)maxForce layers:(cpLayers)layers group:(cpGroup)group;
{
	cpBB bb = {at.x-radius, at.y-radius, at.x+radius, at.y+radius};
	ExplosionQueryContext context = {layers, group, at, radius, maxForce};
	cpSpaceHashQuery(_space->activeShapes, &bb, bb, (cpSpaceHashQueryFunc)ExplosionQueryHelper, &context);
}

-(BOOL) isPersistentContactOnShape:(cpShape*)shape contactShape:(cpShape*)shape2
{
	cpShape *shape_pair[] = {shape, shape2};
	long id1 = (long)shape;
	long id2 = (long)shape2;
	
	//Try and find the the persistent contact
	cpArbiter *arb = (cpArbiter *)cpHashSetFind(_space->contactSet, CP_HASH_PAIR(id1, id2), shape_pair);
	
	//check its there, chipmunk keeps them around for cp_contact_persistence "3" times
	return (arb != NULL);
}

-(cpShape*) persistentContactOnShape:(cpShape*)shape
{
	cpShape *contactShape = NULL;
	cpArbiter *arb = [self persistentContactInfoOnShape:shape];
	
	if (arb)
	{
		CP_ARBITER_GET_SHAPES(arb, a, b)
		contactShape = (a == shape) ? b : a;
	}
	return contactShape;
}

-(cpArbiter*) persistentContactInfoOnShape:(cpShape*)shape
{
	cpArbiter *retArb = NULL;
	cpHashSet *contactSet = _space->contactSet;
	const int size = contactSet->size;
	for(int i=0; i < size && !retArb; i++)
	{
		cpHashSetBin *bin = contactSet->table[i];
		while(bin && !retArb)
		{
			cpHashSetBin *next = bin->next;
			cpArbiter *arb = (cpArbiter *)bin->elt;
			
			if (arb)
			{	
				CP_ARBITER_GET_SHAPES(arb, a, b)
				
				if ((a == shape || b == shape))
					retArb = arb;
			}
			
			bin = next;
		}
	}
	
	return retArb;
}

-(NSArray*) getConstraints
{
	NSMutableArray *constraints = [[[NSMutableArray alloc] init] autorelease];
	const int num = _space->constraints->num;
	void** constraintArr = _space->constraints->arr;
	
	for (int i = 0; i < num; i++)
		[constraints addObject:[NSValue valueWithPointer:constraintArr]];
	
	return constraints;
}

-(NSArray*) getConstraintsOnBody:(cpBody*)body
{
	NSMutableArray *constraints = [[[NSMutableArray alloc] init] autorelease];
	cpConstraint* constraint;
	const int num = _space->constraints->num;
	void** constraintArr = _space->constraints->arr;

	for (int i = 0; i < num; i++)
	{
		constraint = (cpConstraint*)constraintArr[i];
		
		if (body == constraint->a || body == constraint->b)
			[constraints addObject:[NSValue valueWithPointer:constraint]];
	}
	
	return constraints;
}

-(void) addShape:(cpShape*)shape
{
	if (_space->locked)
		cpSpaceAddPostStepCallback(_space, addShape, shape, self);
	else
		addShape(_space, shape, self);	
}

-(cpShape*) morphShapeToStatic:(cpShape*)shape
{
	return [self morphShapeToActive:shape mass:STATIC_MASS];
}

-(cpShape*) morphShapeToActive:(cpShape*)shape mass:(cpFloat)mass
{
	[self removeShape:shape];
	cpBodySetMass(shape->body, mass);
	
	if (mass == STATIC_MASS)
		cpBodySetMoment(shape->body, mass);
	else
	{
		switch(shape->klass->type)
		{
			case CP_CIRCLE_SHAPE:
				cpBodySetMoment(shape->body, 
								cpMomentForCircle(mass, cpCircleShapeGetRadius(shape), cpCircleShapeGetRadius(shape), cpvzero));
				break;
			case CP_SEGMENT_SHAPE:
				cpBodySetMoment(shape->body, 
								cpMomentForSegment(mass, cpSegmentShapeGetA(shape), cpSegmentShapeGetB(shape)));
				break;
			case CP_POLY_SHAPE:
				cpBodySetMoment(shape->body,
								cpMomentForPoly(mass, cpPolyShapeGetNumVerts(shape), ((cpPolyShape*)shape)->verts, cpvzero));
				break;
			default:
				break;
		}
	}
	
	[self addShape:shape];
	
	return shape;
}

-(cpShape*) morphShapeToKinematic:(cpShape*)shape
{
	cpSpaceRemoveBody(_space, shape->body);
	return shape;
}

-(NSArray*) fragmentShape:(cpShape*)shape piecesNum:(int)pieces eachMass:(float)mass;
{
	cpShapeType type = shape->klass->type;
	NSArray* fragments = nil;
	
	if (type == CP_CIRCLE_SHAPE)
	{
		cpCircleShape *circle = (cpCircleShape*)shape;
		fragments = [self fragmentCircle:circle piecesNum:pieces eachMass:mass];
	}
	else if (type == CP_SEGMENT_SHAPE)
	{
		cpSegmentShape *segment = (cpSegmentShape*)shape;
		fragments = [self fragmentSegment:segment piecesNum:pieces eachMass:mass];
	}
	else if (type == CP_POLY_SHAPE)
	{
		cpPolyShape *poly = (cpPolyShape*)shape;
		
		//get a square grid size number
		pieces = (int)sqrt((double)pieces);
		
		//only support rects right now
		fragments = [self fragmentRect:poly rowPiecesNum:pieces colPiecesNum:pieces eachMass:mass];
	}
	
	return fragments;
}

-(NSArray*) fragmentRect:(cpPolyShape*)poly rowPiecesNum:(int)rows colPiecesNum:(int)cols eachMass:(float)mass;
{
	NSMutableArray* fragments = nil;
	cpBody *body = ((cpShape*)poly)->body;
	
	if (poly->numVerts == 4)
	{
		fragments = [[[NSMutableArray alloc] init] autorelease];
		cpShape *fragment;
		
		//use the opposing endpoints (diagonal) to calc width & height
		float w = fabs(poly->verts[0].x - poly->verts[2].x);
		float h = fabs(poly->verts[0].y - poly->verts[2].y);
		
		float fw = w/cols;
		float fh = h/rows;
		
		for (int i = 0; i < cols; i++)
		{
			for (int j = 0; j < rows; j++)
			{
				cpVect pt = cpvadd(cpv(fw/2.0f,fh/2.0f), cpv((i*fw)-w/2.0f,(j*fh)-h/2.0f));
		
				pt = cpBodyLocal2World(body, pt);
				
				fragment = [self addRectAt:pt mass:mass width:fw height:fh rotation:body->a];
				
				[fragments addObject:[NSValue valueWithPointer:fragment]];
			}
		}
		
		[self removeAndFreeShape:(cpShape*)poly];
	}
	
	return fragments;
}

-(NSArray*) fragmentCircle:(cpCircleShape*)circle piecesNum:(int)pieces eachMass:(float)mass
{
	NSMutableArray* fragments = [[[NSMutableArray alloc] init] autorelease];
	
	cpBody *body = ((cpShape*)circle)->body;
	float radius = circle->r;
	
	
	cpShape *fragment;
	float radians = 2*M_PI/pieces;
	float a = radians;
	cpVect pt1, pt2, pt3, avg;
	
	pt1 = cpv(radius, 0);
	
	for (int i = 0; i < pieces; i++)
	{		
		pt2 = cpvmult(cpvforangle(a), radius);
		
		//get the centroid
		avg = cpvmult(cpvadd(pt1,pt2), 1.0/3.0f);
		pt3 = cpvadd(body->p, avg);
		
		fragment = [self addPolyAt:pt3 mass:mass rotation:0 numPoints:3 points:cpvsub(cpvzero,avg),cpvsub(pt2,avg),cpvsub(pt1,avg)];
		[fragments addObject:[NSValue valueWithPointer:fragment]];
		
		pt1 = pt2;
		a += radians;
	}
	
	[self removeAndFreeShape:(cpShape*)circle];
	
	return fragments;
}

-(NSArray*) fragmentSegment:(cpSegmentShape*)segment piecesNum:(int)pieces eachMass:(float)mass
{
	NSMutableArray* fragments = [[[NSMutableArray alloc] init] autorelease];
	
	cpBody *body = ((cpShape*)segment)->body;
	
	cpShape *fragment;
	cpVect pt = segment->a;
	cpVect diff = cpvsub(segment->b, segment->a);
	cpVect dxdy = cpvmult(diff, 1.0f/(float)pieces);
	float len = cpvlength(dxdy);
	float rad = cpvtoangle(diff);
	
	for (int i = 0; i < pieces; i++)
	{
		fragment = [self addRectAt:cpBodyLocal2World(body,pt) mass:mass width:len height:segment->r*2 rotation:rad];
		[fragments addObject:[NSValue valueWithPointer:fragment]];
		pt = cpvadd(pt, dxdy);
	}
	
	[self removeAndFreeShape:(cpShape*)segment];
	
	return fragments;	
}

-(void) combineShapes:(cpShape*)shapes, ...
{
	cpArray *ss = cpArrayNew(2);
	va_list args;
	va_start(args, shapes);
	
	cpShape *shape = shapes;
	cpBody *body = shape->body; 
	
	//Setup initial data
	cpVect mr = cpvmult(body->p, body->m);
	cpFloat total_mass = body->m;
	cpArrayPush(ss, shape);
	
	while ((shape = va_arg(args, cpShape*)))
	{
		body = shape->body;
		
		//Calculate the sum of the "first mass moments"
		//Treating each shape/body as a particle
		mr = cpvadd(mr, cpvmult(body->p, body->m));
		total_mass += body->m;
		
		cpArrayPush(ss, shape);
	}
	va_end(args);
	
	//Make sure no funny business
	if (ss->num > 1)
	{
	
		//Calculate the center of mass
		cpVect cm = cpvmult(mr, 1.0f/(total_mass));
		cpFloat moi = 0;
		
		//Grab first shape
		cpShape *first_shape = (cpShape*)ss->arr[0];
		
		//Calculate the new moment of inertia
		for(int i=0; i < ss->num; i++)
		{
			shape = (cpShape*)ss->arr[i];
			body = shape->body;
			
			cpVect offset = cpvsub(body->p, cm);
			
			//apply the offset (based off type)
			[self offsetShape:shape offset:offset];
			
			//summation of inertia
			moi += (body->i + body->m*cpvdot(offset, offset));
			
			//Remove all but first body (for reuse)
			if (i)
			{
				if (body->space == _space)
					cpSpaceRemoveBody(_space, body);
				
				if (body != &_space->staticBody)
					cpBodyFree(body);
					
				
				//New body for this shape
				shape->body = first_shape->body;
			}
			
		}
		
		//New mass and moment of inertia
		cpBodySetMass(first_shape->body, total_mass);
		cpBodySetMoment(first_shape->body, moi);
		
		//New pos
		cpBodySetPos(first_shape->body, cm);
	}
	
	//free the array
	cpArrayFree(ss);
}

-(void) offsetShape:(cpShape*)shape offset:(cpVect)offset;
{
	switch(shape->klass->type)
	{
		case CP_CIRCLE_SHAPE:
			cpCircleShapeSetOffset(shape, offset);
			break;
		case CP_SEGMENT_SHAPE:
		{
			cpVect a = cpSegmentShapeGetA(shape);
			cpVect b = cpSegmentShapeGetB(shape);
			
			cpSegmentShapeSetEndpoints(shape, cpvadd(a, offset), cpvadd(b, offset));
			break;
		}
		case CP_POLY_SHAPE:
		{
			int numVerts = cpPolyShapeGetNumVerts(shape);
			cpVect *verts = (cpVect*)malloc(sizeof(cpVect)*numVerts);
			
			//have to copy... oh well
			for (int i = 0; i < numVerts; i++)
				verts[i] = cpPolyShapeGetVert(shape, i);
			
			cpPolyShapeSetVerts(shape, numVerts, verts, offset);
			
			free(verts);
			break;
		}
		default:
			break;
	}	
}

-(cpConstraint*) removeConstraint:(cpConstraint*)constraint
{
	cpSpaceRemoveConstraint(_space, constraint);	
	return constraint;
}

-(void) removeAndFreeConstraint:(cpConstraint*)constraint
{
	[self removeConstraint:constraint];
	cpConstraintFree(constraint);
}

-(void) removeAndFreeConstraintsOnBody:(cpBody*)body
{
	cpConstraint *constraint;
	cpArray *array = _space->constraints;

	for (int i = 0; i < array->num; i++)
	{
		constraint = (cpConstraint*)array->arr[i];
			
		if (body == constraint->a || body == constraint->b)
		{
			//Callback for about to free constraint
			//reason: it's the only thing that may be deleted arbitrarily
			//because of the cleanupBodyDependencies
			[_constraintCleanupDelegate aboutToFreeConstraint:constraint];
			
			//more efficient to use this method of deletion
			cpArrayDeleteIndex(array, i);
			cpConstraintFree(constraint);
			i--;
		}
	}
}

-(cpConstraint*) addSpringToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody toBodyAnchor:(cpVect)anchr1 fromBodyAnchor:(cpVect)anchr2 restLength:(cpFloat)rest stiffness:(cpFloat)stiff damping:(cpFloat)damp
{
	cpConstraint *spring = cpDampedSpringNew(toBody, fromBody, anchr1, anchr2, rest, stiff, damp);
	return cpSpaceAddConstraint(_space, spring);
}

-(cpConstraint*) addSpringToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody restLength:(cpFloat)rest stiffness:(cpFloat)stiff damping:(cpFloat)damp
{
	return [self addSpringToBody:toBody fromBody:fromBody toBodyAnchor:cpvzero fromBodyAnchor:cpvzero restLength:rest stiffness:stiff damping:damp];
}

-(cpConstraint*) addSpringToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody stiffness:(cpFloat)stiff
{	
	return [self addSpringToBody:toBody fromBody:fromBody restLength:0.0 stiffness:stiff damping:1.0f];
}

-(cpConstraint*) addGrooveToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody grooveAnchor1:(cpVect)groove1 grooveAnchor2:(cpVect)groove2 fromBodyAnchor:(cpVect)anchor2
{
	cpConstraint *groove = cpGrooveJointNew(toBody, fromBody, groove1, groove2, anchor2);
	return cpSpaceAddConstraint(_space, groove);
}

-(cpConstraint*) addGrooveToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody grooveLength:(cpFloat)length isHorizontal:(bool)horiz fromBodyAnchor:(cpVect)anchor2
{
	cpVect diff = cpvzero;
	
	if (horiz)
		diff = cpv(length/2.0,0.0);
	else
		diff = cpv(0.0,length/2.0);
	
	return [self addGrooveToBody:toBody fromBody:fromBody grooveAnchor1:cpvsub(toBody->p, diff) grooveAnchor2:cpvadd(toBody->p, diff) fromBodyAnchor:anchor2];
}

-(cpConstraint*) addGrooveToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody grooveLength:(cpFloat)length isHorizontal:(bool)horiz
{
	return [self addGrooveToBody:toBody fromBody:fromBody grooveLength:length isHorizontal:horiz fromBodyAnchor:cpvzero];
}

-(cpConstraint*) addSlideToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody toBodyAnchor:(cpVect)anchr1 fromBodyAnchor:(cpVect)anchr2 minLength:(cpFloat)min maxLength:(cpFloat)max;
{	
	cpConstraint *slide = cpSlideJointNew(toBody, fromBody, anchr1, anchr2, min, max);
	return cpSpaceAddConstraint(_space, slide);
}

-(cpConstraint*) addSlideToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody minLength:(cpFloat)min maxLength:(cpFloat)max
{
	return [self addSlideToBody:toBody fromBody:fromBody toBodyAnchor:cpvzero fromBodyAnchor:cpvzero minLength:min maxLength:max];
}

-(cpConstraint*) addPinToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody toBodyAnchor:(cpVect)anchr1 fromBodyAnchor:(cpVect)anchr2
{
	cpConstraint *pin = cpPinJointNew(toBody, fromBody, anchr1, anchr2);
	return cpSpaceAddConstraint(_space, pin);
}

-(cpConstraint*) addPinToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody
{
	return [self addPinToBody:toBody fromBody:fromBody toBodyAnchor:cpvzero fromBodyAnchor:cpvzero];
}

-(cpConstraint*) addPivotToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody toBodyAnchor:(cpVect)anchr1 fromBodyAnchor:(cpVect)anchr2
{
	cpConstraint *pin = cpPivotJointNew2(toBody, fromBody, anchr1, anchr2);
	return cpSpaceAddConstraint(_space, pin);
}

-(cpConstraint*) addPivotToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody worldAnchor:(cpVect)anchr
{
	cpConstraint *pin = cpPivotJointNew(toBody, fromBody, anchr);
	return cpSpaceAddConstraint(_space, pin);	
}

-(cpConstraint*) addPivotToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody
{
	return [self addPivotToBody:toBody fromBody:fromBody toBodyAnchor:cpvzero fromBodyAnchor:cpvzero];
}

-(cpConstraint*) addMotorToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody rate:(cpFloat)rate
{
	cpConstraint *motor = cpSimpleMotorNew(toBody, fromBody, rate);
	return cpSpaceAddConstraint(_space, motor);
}

-(cpConstraint*) addMotorToBody:(cpBody*)toBody rate:(cpFloat)rate
{
	return [self addMotorToBody:toBody fromBody:&_space->staticBody rate:rate];
}

-(cpConstraint*) addGearToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody phase:(cpFloat)phase ratio:(cpFloat)ratio
{
	cpConstraint *gear = cpGearJointNew(toBody, fromBody, phase, ratio);
	return cpSpaceAddConstraint(_space, gear);
}

-(cpConstraint*) addGearToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody ratio:(cpFloat)ratio
{
	return [self addGearToBody:toBody fromBody:fromBody phase:0.0 ratio:ratio];
}

-(cpConstraint*) addBreakableToConstraint:(cpConstraint*)breakConstraint maxForce:(cpFloat)max
{
	//cpConstraint *breakable = cpBreakableJointNew(breakConstraint, _space);
	//breakable->maxForce = max;
	//return cpSpaceAddConstraint(_space, breakable);
	return NULL;
}

-(cpConstraint*) addRotaryLimitToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody min:(cpFloat)min max:(cpFloat)max
{
	cpConstraint* rotaryLimit = cpRotaryLimitJointNew(toBody, fromBody, min, max);
	return cpSpaceAddConstraint(_space, rotaryLimit);
}

-(cpConstraint*) addRotaryLimitToBody:(cpBody*)toBody min:(cpFloat)min max:(cpFloat)max
{
	return [self addRotaryLimitToBody:toBody fromBody:&_space->staticBody min:min max:max];
}

-(cpConstraint*) addRatchetToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody phase:(cpFloat)phase rachet:(cpFloat)ratchet
{
	cpConstraint *rachet = cpRatchetJointNew(toBody, fromBody, phase, ratchet);
	return cpSpaceAddConstraint(_space, rachet);
}

-(cpConstraint*) addRatchetToBody:(cpBody*)toBody phase:(cpFloat)phase rachet:(cpFloat)ratchet
{
	return [self addRatchetToBody:toBody fromBody:&_space->staticBody phase:phase rachet:ratchet];
}

-(void) ignoreCollionBetweenType:(unsigned int)type1 otherType:(unsigned int)type2
{
	cpSpaceAddCollisionHandler(_space, type1, type2, NULL, collIgnore, NULL, NULL, NULL);
}

-(cpConstraint*) addRotarySpringToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody restAngle:(cpFloat)restAngle stiffness:(cpFloat)stiff damping:(cpFloat)damp
{
	cpConstraint* rotarySpring = cpDampedRotarySpringNew(toBody, fromBody, restAngle, stiff, damp);
	return cpSpaceAddConstraint(_space, rotarySpring);
}

-(cpConstraint*) addRotarySpringToBody:(cpBody*)toBody restAngle:(cpFloat)restAngle stiffness:(cpFloat)stiff damping:(cpFloat)damp
{
	return [self addRotarySpringToBody:toBody fromBody:&_space->staticBody restAngle:restAngle stiffness:stiff damping:damp];
}

-(cpConstraint*) addPulleyToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody pulleyBody:(cpBody*)pulleyBody
					toBodyAnchor:(cpVect)anchor1 fromBodyAnchor:(cpVect)anchor2
				  toPulleyAnchor:(cpVect)anchor3a fromPulleyAnchor:(cpVect)anchor3b
						   ratio:(cpFloat)ratio
{
	cpConstraint* pulley = cpPulleyJointNew(toBody, fromBody, pulleyBody, anchor1, anchor2, anchor3a, anchor3b, ratio);
	return cpSpaceAddConstraint(_space, pulley);
}

-(cpConstraint*) addPulleyToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody
					toBodyAnchor:(cpVect)anchor1 fromBodyAnchor:(cpVect)anchor2
			 toPulleyWorldAnchor:(cpVect)anchor3a fromPulleyWorldAnchor:(cpVect)anchor3b
						   ratio:(cpFloat)ratio
{
	return [self addPulleyToBody:toBody fromBody:fromBody pulleyBody:&_space->staticBody 
					toBodyAnchor:anchor1 fromBodyAnchor:anchor2
			 toPulleyAnchor:anchor3a fromPulleyAnchor:anchor3b ratio:ratio];
}

-(void) addCollisionCallbackBetweenType:(unsigned int)type1 otherType:(unsigned int) type2 target:(id)target selector:(SEL)selector
{
	//set up the invocation
	NSMethodSignature * sig = [[target class] instanceMethodSignatureForSelector:selector];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
	
	[invocation setTarget:target];
	[invocation setSelector:selector];
	
	//add the callback to chipmunk
	cpSpaceAddCollisionHandler(_space, type1, type2, collBegin, collPreSolve, collPostSolve, collSeparate, invocation);
	
	//we'll keep a ref so it won't disappear, prob could just retain and clear hash later
	[_invocations addObject:invocation];
}

-(void) addCollisionCallbackBetweenType:(unsigned int)type1 
							  otherType:(unsigned int)type2 
								 target:(id)target 
							   selector:(SEL)selector
								moments:(CollisionMoment)moment, ...
{
	//set up the invocation
	NSMethodSignature * sig = [[target class] instanceMethodSignatureForSelector:selector];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
	
	[invocation setTarget:target];
	[invocation setSelector:selector];
	
	cpCollisionBeginFunc begin = NULL;
	cpCollisionPreSolveFunc preSolve = NULL;
	cpCollisionPostSolveFunc postSolve = NULL;
	cpCollisionSeparateFunc separate = NULL;
	
	va_list args;
	va_start(args, moment);
	
	while (moment != 0)
	{
		switch (moment) 
		{
			case COLLISION_BEGIN:
				begin = collBegin;
				break;
			case COLLISION_PRESOLVE:
				preSolve = collPreSolve;
				break;
			case COLLISION_POSTSOLVE:
				postSolve = collPostSolve;
				break;
			case COLLISION_SEPARATE:
				separate = collSeparate;
				break;
			default:
				break;
		}
		moment = (CollisionMoment)va_arg(args, int);
	}

	va_end(args);
		
	//add the callback to chipmunk
	cpSpaceAddCollisionHandler(_space, type1, type2, begin, preSolve, postSolve, separate, invocation);
	
	//we'll keep a ref so it won't disappear, prob could just retain and clear hash later
	[_invocations addObject:invocation];
}

-(void) removeCollisionCallbackBetweenType:(unsigned int)type1 otherType:(unsigned int)type2
{
	//Chipmunk hashes the invocation for us, we must pull it out
	unsigned int ids[] = {type1, type2};
	unsigned int hash = CP_HASH_PAIR(type1, type2);
	cpCollisionHandler *pair = (cpCollisionHandler*)cpHashSetFind(_space->collFuncSet, hash, ids);
	
	//delete the invocation, if there is one
	if (pair != NULL)
	{
		if (_space->locked)
			cpSpaceAddPostStepCallback(_space, removeCollision, pair, _invocations);
		else
			removeCollision(_space, pair, _invocations);
	}
}

@end
