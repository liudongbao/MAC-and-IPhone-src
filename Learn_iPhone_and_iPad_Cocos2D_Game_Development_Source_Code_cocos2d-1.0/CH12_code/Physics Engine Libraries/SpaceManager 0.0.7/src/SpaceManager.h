/*********************************************************************
 *	
 *	Space Manager
 *
 *	SpaceManager.h
 *
 *	Manage the space for the application
 *
 *	http://www.mobile-bros.com
 *
 *	Created by Robert Blackwood on 02/22/2009.
 *	Copyright 2009 Mobile Bros. All rights reserved.
 *
 **********************************************************************/

/*
	ATTENTION! COCOS2D USERS
 
	Large change: Include and use SpaceManagerCocos2d class now found
	in the ccExtras folder. This design change gives a better seperation
	and will prove much more flexible in the long run, thanks for
	understanding.
 
	p.s. You may need to add the ccExtras folder path to your
	"Header Search Paths" found under your Target Info->Build area.
 */

// 0x00 HI ME LO
// 00   00 00 06
#define SPACE_MANAGER_VERSION 0x00000007

#import "chipmunk.h"

//cp extras
#import "cpExtras/cpPulleyJoint.h"

//A more definitive sounding define
#define STATIC_MASS	INFINITY

void defaultEachShape(void *ptr, void* data);

/*! Collision Moments */
typedef enum { 
	COLLISION_BEGIN = 1, 
	COLLISION_PRESOLVE, 
	COLLISION_POSTSOLVE, 
	COLLISION_SEPARATE
} CollisionMoment;

/*! Delegate for handling constraints that will be free'd by
	the method: removeAndFreeConstraintsOnBody */
@protocol cpConstraintCleanupDelegate<NSObject>
-(void) aboutToFreeConstraint:(cpConstraint*)constraint;
@end

/*! Delegate for handling I/O
 
	These functions are events that get fired when saving/loading
	a space, they enable you to use a specific id system (if you choose)
	as well as record any UI specific data at time of writing; the reading
	events will let you hook up your UI when an object has just been read,
	but not added to the space yet.
 */
@protocol SpaceManagerSerializeDelegate
@optional
-(long) makeShapeId:(cpShape*)shape;
-(long) makeBodyId:(cpBody*)body;
-(long) makeConstraintId:(cpConstraint*)constraint;

-(BOOL) aboutToWriteShape:(cpShape*)shape shapeId:(long)id;
-(BOOL) aboutToWriteBody:(cpBody*)body bodyId:(long)id;
-(BOOL) aboutToWriteConstraint:(cpConstraint*)constraint constraintId:(long)id;

-(BOOL) aboutToReadShape:(cpShape*)shape shapeId:(long)id;
-(BOOL) aboutToReadBody:(cpBody*)body bodyId:(long)id;
-(BOOL) aboutToReadConstraint:(cpConstraint*)constraint constraintId:(long)id;
@end

/*! The SpaceManager */
@interface SpaceManager : NSObject
{
	
@protected
	/* our chipmunk space! */
	cpSpace			*_space;
	
	/* Internal devices (dev: Consider revamping) */
	NSMutableArray	*_invocations;

	/* Helpful Shapes/Bodies */
	cpShape			*topWall,*bottomWall,*rightWall,*leftWall;
	
	/* Number of steps (across dt) perform on each step call */
	int		_steps;
	
	/* The dt used last within step */
	cpFloat	_lastDt;
	
	/* If constant dt used, then this accumulates left over */
	cpFloat _timeAccumulator;
		
	/* Options:
		-cleanupBodyDependencies will also free contraints connected to a free'd shape
		-constraintCleanupDelegate is the delegate that will be called when the above variable is true
		-iterateStatic will call _iterateFunc on static shapes
		-rehashStaticEveryStep will rehash static shapes at the end of every step
		-iterateFunc; default will update cocosnodes for pos and rotation
		-constantDt; set this to a non-zero number to always step the simulation with that dt
	*/
	BOOL							_cleanupBodyDependencies;
	id<cpConstraintCleanupDelegate>	_constraintCleanupDelegate;
	BOOL							_iterateStatic;
	BOOL							_rehashStaticEveryStep;
	cpSpaceHashIterator				_iterateFunc;
	cpFloat							_constantDt;
}

/*! The actual chipmunk space */
@property (readonly) cpSpace* space;

/*! The segment shapes that form the bounds of the window*/
@property (readwrite, assign) cpShape *topWall,*bottomWall,*rightWall,*leftWall;
 
/*! Number of steps (across dt) perform on each step call */
@property (readwrite, assign) int steps;

/*! The dt value that was used in step last */
@property (readonly) cpFloat lastDt;

/*! The gravity of the space */
@property (readwrite, assign) cpVect gravity;

/*! The damping of the space (viscousity in "air") */
@property (readwrite, assign) cpFloat damping;

/*! If this is set to YES/TRUE then step will call iterateFunc on static shapes */
@property (readwrite, assign) BOOL iterateStatic;

/*! If this is set to YES/TRUE then step will call rehashStatic before stepping */
@property (readwrite, assign) BOOL rehashStaticEveryStep;

/*! Set the iterateFunc; the default will update cocosnodes for pos and rotation */
@property (readwrite, assign) cpSpaceHashIterator iterateFunc;

/*! A staticBody for any particular reusable purpose */
@property (readonly) cpBody *staticBody;

/*! If this is set to anything other than zero, the step routine will use its
 value as the dt (constant) */
@property (readwrite, assign) cpFloat constantDt;

/*! Setting this to YES/TRUE will also free contraints connected to a free'd shape */
@property (readwrite, assign) BOOL cleanupBodyDependencies;

/*! This will be called from all methods that auto-free constraints dependent on bodies being freed */
@property (readwrite, retain) id<cpConstraintCleanupDelegate> constraintCleanupDelegate;

/*! Default creation method */
+(id) spaceManager;

/*! Creation method
 @param size The average size of shapes in space
 @param count The expected number of shapes in a space (larger is better)
 */
+(id) spaceManagerWithSize:(int)size count:(int)count;

/* Creation method that takes a precreated space */
+(id) spaceManagerWithSpace:(cpSpace*)space;

/*! Initialization method
	@param size The average size of shapes in space
	@param count The expected number of shapes in a space (larger is better)
 */
-(id) initWithSize:(int)size count:(int)count;

/* Initialization method that takes a precreated space */
-(id) initWithSpace:(cpSpace*)space;

/*! load a cpSerializer file from a user docs file, delegate can be nil */
-(BOOL) loadSpaceFromUserDocs:(NSString*)file delegate:(NSObject<SpaceManagerSerializeDelegate>*)delegate;

/*! save a cpSerializer file to a user docs file, delegate can be nil */
-(BOOL) saveSpaceToUserDocs:(NSString*)file delegate:(NSObject<SpaceManagerSerializeDelegate>*)delegate;

/*! load a cpSerializer file from a file (path), delegate can be nil */
-(BOOL) loadSpaceFromPath:(NSString*)path delegate:(NSObject<SpaceManagerSerializeDelegate>*)delegate;

/*! save a cpSerializer file to a resource file (path), delegate can be nil */
-(BOOL) saveSpaceToPath:(NSString*)path delegate:(NSObject<SpaceManagerSerializeDelegate>*)delegate;

-(void) addWindowContainmentWithFriction:(cpFloat)friction elasticity:(cpFloat)elasticity size:(CGSize)wins inset:(cpVect)inset radius:(cpFloat)radius;

/*! Manually advance time within the space */
-(void) step: (cpFloat) delta;

/*! add a circle shape */
-(cpShape*) addCircleAt:(cpVect)pos mass:(cpFloat)mass radius:(cpFloat)radius;

/*! add a rectangle shape */
-(cpShape*) addRectAt:(cpVect)pos mass:(cpFloat)mass width:(cpFloat)width height:(cpFloat)height rotation:(cpFloat)r;

/*! add a polygon shape */
-(cpShape*) addPolyAt:(cpVect)pos mass:(cpFloat)mass rotation:(cpFloat)r numPoints:(int)numPoints points:(cpVect)pt, ... ;

/*! Alternative, add a polygon shape */
-(cpShape*) addPolyAt:(cpVect)pos mass:(cpFloat)mass rotation:(cpFloat)r points:(NSArray*)points;

/*! Alternative, add a polygon shape */
-(cpShape*) addPolyAt:(cpVect)pos mass:(cpFloat)mass rotation:(cpFloat)r numPoints:(int)numPoints pointsArray:(cpVect*)points;

/* add a segment shape using world coordinates */
-(cpShape*) addSegmentAtWorldAnchor:(cpVect)fromPos toWorldAnchor:(cpVect)toPos mass:(cpFloat)mass radius:(cpFloat)radius;

/* add a segment shape using local coordinates */
-(cpShape*) addSegmentAt:(cpVect)pos fromLocalAnchor:(cpVect)fromPos toLocalAnchor:(cpVect)toPos mass:(cpFloat)mass radius:(cpFloat)radius;

/*! Retrieve the first shape found at this position matching layers and group */
-(cpShape*) getShapeAt:(cpVect)pos layers:(cpLayers)layers group:(cpLayers)group;

/*! Retrieve the first shape found at this position */
-(cpShape*) getShapeAt:(cpVect)pos;

/*! Use if you need to call getShapes before you've actually started simulating */
-(void) rehashActiveShapes;

/*! Use if you move static shapes during simulation */
-(void) rehashStaticShapes;

/*! Use to only rehash one shape */
-(void) rehashShape:(cpShape*)shape;

/*! Given a point, return an array of NSValues with a pointer to a cpShape */
-(NSArray*) getShapesAt:(cpVect)pos layers:(cpLayers)layers group:(cpLayers)group;
/*! @see getShapesAt:layers:group: */
-(NSArray*) getShapesAt:(cpVect)pos;

/*! Given a point and a radius, return an array of NSValues with a pointer to a cpShape */
-(NSArray*) getShapesAt:(cpVect)pos radius:(float)radius layers:(cpLayers)layers group:(cpLayers)group;
/*! @see getShapesAt:radius:layers:group: */
-(NSArray*) getShapesAt:(cpVect)pos radius:(float)radius;

/*! Return first shape hit by the given raycast */
-(cpShape*) getShapeFromRayCastSegment:(cpVect)start end:(cpVect)end layers:(cpLayers)layers group:(cpGroup)group;
/*! see getShapeFromRayCastSegment:end:layers:group: */
-(cpShape*) getShapeFromRayCastSegment:(cpVect)start end:(cpVect)end;

/*! Return the info on the first shape hit by the given raycast */
-(cpSegmentQueryInfo) getInfoFromRayCastSegment:(cpVect)start end:(cpVect)end layers:(cpLayers)layers group:(cpGroup)group;
/*! see getInfoFromRayCastSegment:end:layers:group: */
-(cpSegmentQueryInfo) getInfoFromRayCastSegment:(cpVect)start end:(cpVect)end;

/*! Return an array of NSValues with a pointer to a cpShape that intersects the raycast */
-(NSArray*) getShapesFromRayCastSegment:(cpVect)start end:(cpVect)end layers:(cpLayers)layers group:(cpGroup)group;
/*! see getShapesFromRayCastSegment:end:layers:group: */
-(NSArray*) getShapesFromRayCastSegment:(cpVect)start end:(cpVect)end;

/*! Return an array of NSValues with a pointer to a cpSegmentQueryInfo, this array will clean up the infos when released */
-(NSArray*) getInfosFromRayCastSegment:(cpVect)start end:(cpVect)end layers:(cpLayers)layers group:(cpGroup)group;
/*! see getInfosFromRayCastSegment:end:layers:group: */
-(NSArray*) getInfosFromRayCastSegment:(cpVect)start end:(cpVect)end;

/*! Explosion, applied linear force to objects within radius */
-(void) applyLinearExplosionAt:(cpVect)at radius:(cpFloat)radius maxForce:(cpFloat)maxForce;
/*! Explosion, applied linear force to objects within radius given a group and layer(s) */
-(void) applyLinearExplosionAt:(cpVect)at radius:(cpFloat)radius maxForce:(cpFloat)maxForce layers:(cpLayers)layers group:(cpGroup)group;

/*! Queries the space as to whether these two shapes are in persistent contact */
-(BOOL) isPersistentContactOnShape:(cpShape*)shape contactShape:(cpShape*)shape2;

/*! Queries the space as to whether this shape has a persistent contact, returns the first arbiter info */
-(cpArbiter*) persistentContactInfoOnShape:(cpShape*)shape;

/*! Queries the space as to whether this shape has ANY persistent contact, It will return
 the first shape it finds or NULL if nothing is found*/
-(cpShape*) persistentContactOnShape:(cpShape*)shape;

/*! Will return an array of NSValues that point to the cpConstraints */
-(NSArray*) getConstraints;

/*! Will return an array of NSValues that point to the cpConstraints on given body */
-(NSArray*) getConstraintsOnBody:(cpBody*)body;

/*! Use when removing & freeing shapes */
-(void) removeAndFreeShape:(cpShape*)shape;

/*! Use when removing shapes, will pass ownership to caller */
-(cpShape*) removeShape:(cpShape*)shape;

/*! Manually add a shape to the space */
-(void) addShape:(cpShape*)shape;

/*! This will force a shape into a static shape */
-(cpShape*) morphShapeToStatic:(cpShape*)shape;

/*! This will force a shape active and give it the given mass */
-(cpShape*) morphShapeToActive:(cpShape*)shape mass:(cpFloat)mass;

/*! This will force a shape to be kinematic (body will not simulate) */
-(cpShape*) morphShapeToKinematic:(cpShape*)shape;

/*! This will take a shape (any) and split it into the number of pieces you specify,
	@return An NSArray* of NSValues* with cpShape* as the value (the fragments) or nil if failed
 */
-(NSArray*) fragmentShape:(cpShape*)shape piecesNum:(int)pieces eachMass:(float)mass;

/*! This will take a rect and split it into the number of pieces (Rows x Cols) you specify,
 @return An NSArray* of NSValues* with cpShape* as the value (the fragments) or nil if failed
 */
-(NSArray*) fragmentRect:(cpPolyShape*)poly rowPiecesNum:(int)rows colPiecesNum:(int)cols eachMass:(float)mass;

/*! This will take a circle and split it into the number of pieces you specify,
 @return An NSArray* of NSValues* with cpShape* as the value (the fragments) or nil if failed
 */
-(NSArray*) fragmentCircle:(cpCircleShape*)circle piecesNum:(int)pieces eachMass:(float)mass;

/*! This will take a segment and split it into the number of pieces you specify,
 @return An NSArray* of NSValues* with cpShape* as the value (the fragments) or nil if failed
 */
-(NSArray*) fragmentSegment:(cpSegmentShape*)segment piecesNum:(int)pieces eachMass:(float)mass;

/*! Combine two shapes together by combining their bodies into one */
-(void) combineShapes:(cpShape*)shape, ... NS_REQUIRES_NIL_TERMINATION;

/*! Offset shape from body using (circle:center, segment:endpoints, poly:vertices) */
-(void) offsetShape:(cpShape*)shape offset:(cpVect)offset;

/*! Unique Collision: will ignore the effects a collsion between types */
-(void) ignoreCollionBetweenType:(unsigned int)type1 otherType:(unsigned int)type2;

/*! Register a collision callback between types */
-(void) addCollisionCallbackBetweenType:(unsigned int)type1 otherType:(unsigned int)type2 target:(id)target selector:(SEL)selector;

/*! Register a collision callback between types for the given collision moments */
-(void) addCollisionCallbackBetweenType:(unsigned int)type1 
							  otherType:(unsigned int)type2 
								 target:(id)target 
							   selector:(SEL)selector
								moments:(CollisionMoment)moment, ... NS_REQUIRES_NIL_TERMINATION;

/*! Unregister a collision callback between types */
-(void) removeCollisionCallbackBetweenType:(unsigned int)type1 otherType:(unsigned int)type2;

/*! Use when removing constraints, ownership is given to caller*/
-(cpConstraint*) removeConstraint:(cpConstraint*)constraint;

/*! This will remove and free the constraint */
-(void) removeAndFreeConstraint:(cpConstraint*)constraint;

/*! This will calculate all constraints on a body and remove & free them */
-(void) removeAndFreeConstraintsOnBody:(cpBody*)body;

/*! Add a spring to two bodies at the body anchor points */
-(cpConstraint*) addSpringToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody toBodyAnchor:(cpVect)anchr1 fromBodyAnchor:(cpVect)anchr2 restLength:(cpFloat)rest stiffness:(cpFloat)stiff damping:(cpFloat)damp;
/*! Add a spring to two bodies at the body anchor points */
-(cpConstraint*) addSpringToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody restLength:(cpFloat)rest stiffness:(cpFloat)stiff damping:(cpFloat)damp;
/*! Add a spring to two bodies at the body anchor points */
-(cpConstraint*) addSpringToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody stiffness:(cpFloat)stiff;

/*! Add a groove (aka sliding pin) between two bodies */
-(cpConstraint*) addGrooveToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody grooveAnchor1:(cpVect)groove1 grooveAnchor2:(cpVect)groove2 fromBodyAnchor:(cpVect)anchor2;
/*! Add a groove (aka sliding pin) between two bodies */
-(cpConstraint*) addGrooveToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody grooveLength:(cpFloat)length isHorizontal:(bool)horiz fromBodyAnchor:(cpVect)anchor2;
/*! Add a groove (aka sliding pin) between two bodies */
-(cpConstraint*) addGrooveToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody grooveLength:(cpFloat)length isHorizontal:(bool)horiz;

/*! Add a sliding joint between two bodies */
-(cpConstraint*) addSlideToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody toBodyAnchor:(cpVect)anchr1 fromBodyAnchor:(cpVect)anchr2 minLength:(cpFloat)min maxLength:(cpFloat)max;
/*! Add a sliding joint between two bodies */
-(cpConstraint*) addSlideToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody minLength:(cpFloat)min maxLength:(cpFloat)max;

/*! Create a pin (rod) between two bodies */
-(cpConstraint*) addPinToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody toBodyAnchor:(cpVect)anchr1 fromBodyAnchor:(cpVect)anchr2;
/*! Create a pin (rod) between two bodies */
-(cpConstraint*) addPinToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody;

/*! Add a shared point between two bodies that they may rotate around */
-(cpConstraint*) addPivotToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody toBodyAnchor:(cpVect)anchr1 fromBodyAnchor:(cpVect)anchr2;
/*! Add a shared point between two bodies that they may rotate around */
-(cpConstraint*) addPivotToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody worldAnchor:(cpVect)anchr;
/*! Add a shared point between two bodies that they may rotate around */
-(cpConstraint*) addPivotToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody;

/*! Add a motor that applys torque to a specified body(s) */
-(cpConstraint*) addMotorToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody rate:(cpFloat)rate;
/*! Add a motor that applys torque to a specified body(s) */
-(cpConstraint*) addMotorToBody:(cpBody*)toBody rate:(cpFloat)rate;

/*! Add gears between two bodies */
-(cpConstraint*) addGearToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody phase:(cpFloat)phase ratio:(cpFloat)ratio;
/*! Add gears between two bodies */
-(cpConstraint*) addGearToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody ratio:(cpFloat)ratio;

/*! This does not work yet */
-(cpConstraint*) addBreakableToConstraint:(cpConstraint*)breakConstraint maxForce:(cpFloat)max;

/*! Specify a min and a max a body can rotate relative to another body */
-(cpConstraint*) addRotaryLimitToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody min:(cpFloat)min max:(cpFloat)max;
/*! Specify a min and a max a body can rotate */
-(cpConstraint*) addRotaryLimitToBody:(cpBody*)toBody min:(cpFloat)min max:(cpFloat)max;

/*! Add a ratchet between two bodies */
-(cpConstraint*) addRatchetToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody phase:(cpFloat)phase rachet:(cpFloat)ratchet;
/*! Add a ratchet to a body */
-(cpConstraint*) addRatchetToBody:(cpBody*)toBody phase:(cpFloat)phase rachet:(cpFloat)ratchet;

/*! Add a rotary spring between two bodies */
-(cpConstraint*) addRotarySpringToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody restAngle:(cpFloat)restAngle stiffness:(cpFloat)stiff damping:(cpFloat)damp;
/*! Add a rotary spring to a body */
-(cpConstraint*) addRotarySpringToBody:(cpBody*)toBody restAngle:(cpFloat)restAngle stiffness:(cpFloat)stiff damping:(cpFloat)damp;

/*! Add a pulley between two bodies and another body which is the actual pulley */
-(cpConstraint*) addPulleyToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody pulleyBody:(cpBody*)pulleyBody
					toBodyAnchor:(cpVect)anchor1 fromBodyAnchor:(cpVect)anchor2
				  toPulleyAnchor:(cpVect)anchor3a fromPulleyAnchor:(cpVect)anchor3b
						   ratio:(cpFloat)ratio;
/*! Add a pulley between two bodies */
-(cpConstraint*) addPulleyToBody:(cpBody*)toBody fromBody:(cpBody*)fromBody
					toBodyAnchor:(cpVect)anchor1 fromBodyAnchor:(cpVect)anchor2
				  toPulleyWorldAnchor:(cpVect)anchor3a fromPulleyWorldAnchor:(cpVect)anchor3b
						   ratio:(cpFloat)ratio;
@end
