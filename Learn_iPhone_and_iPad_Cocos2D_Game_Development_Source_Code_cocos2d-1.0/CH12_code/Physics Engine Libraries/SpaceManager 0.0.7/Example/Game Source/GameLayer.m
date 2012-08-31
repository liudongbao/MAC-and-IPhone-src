//
//  GameLayer.m
//  Example For SpaceManager
//
//  Created by Rob Blackwood on 5/11/09.
//

#import "GameLayer.h"
#import "cpConstraintNode.h"

#define kBallCollisionType		1
#define kCircleCollisionType	2
#define kRectCollisionType		3
#define kFragShapeCollisionType	4

@interface GameLayer (PrivateMethods)
- (void) setupExample;
- (void) setupMergedShapes;
- (void) setupStaticShapes;
- (void) setupBallSlider;
- (void) setupSawHorse;
- (void) setupFragmentShape;

- (BOOL) handleCollisionWithRect:(CollisionMoment)moment arbiter:(cpArbiter*)arb space:(cpSpace*)space;
- (BOOL) handleCollisionWithCircle:(CollisionMoment)moment arbiter:(cpArbiter*)arb space:(cpSpace*)space;
- (void) handleCollisionWithFragmentingRect:(CollisionMoment)moment arbiter:(cpArbiter*)arb space:(cpSpace*)space;
@end

@implementation GameLayer

@synthesize label;

- (id) init
{
	[super init];
	
	self.isTouchEnabled = YES;
	
	//add a background
	CCSprite *background = [CCSprite spriteWithFile:@"splash_developed_by.png"];
	background.position = ccp(240,160);
	[self addChild:background];
	
	//do our example
	[self setupExample];

	return self;
}


- (void) dealloc
{	
	[self removeAllChildrenWithCleanup:YES];
	
	[smgr release];
	[super dealloc];
}

- (void) setupExample
{
	//allocate our space manager
	smgr = [[SpaceManagerCocos2d alloc] init];
	
	//add four walls to our screen
	[smgr addWindowContainmentWithFriction:1.0 elasticity:1.0 inset:cpvzero];
	
	//Constant dt is recommended for chipmunk
	smgr.constantDt = 1.0/55.0;

	//active shape, ball shape
	cpShape *ball = [smgr addCircleAt:cpv(240,160) mass:1.0 radius:10];
	ball->collision_type = kBallCollisionType;
	ballSprite = [cpCCSprite spriteWithShape:ball file:@"ball.png"];
	[self addChild:ballSprite];
	ballSprite.ignoreRotation = YES;
	
	//collisions will change label text
	label = [CCLabelTTF labelWithString:@"" fontName:@"Helvetica" fontSize:20];
	label.position = ccp(240,280);
	[self addChild:label];
	
	//Experiment by commenting out these lines
	[self setupStaticShapes];
	[self setupBallSlider];
	[self setupSawHorse];
	[self setupFragmentShape];
	[self setupMergedShapes];
	
	//start the manager!
	[smgr start]; 	
}

- (void) setupMergedShapes
{
	cpShape *sh1 = [smgr addCircleAt:cpv(300,190) mass:0.25 radius:10];
	cpCCSprite *s1 = [cpCCSprite spriteWithShape:sh1 file:@"ball.png"];
	[self addChild:s1];
	
	cpShape *sh2 = [smgr addCircleAt:cpv(340,160) mass:3.0 radius:10];
	cpShapeNode *s2 = [SpaceManagerCocos2d createShapeNode:sh2];
	[self addChild:s2];
	
	cpShape *sh3 = [smgr addRectAt:cpv(310,100) mass:1.0 width:20 height:20 rotation:1];
	cpShapeNode *s3 = [SpaceManagerCocos2d createShapeNode:sh3];
	[self addChild:s3];
	
	cpShape *sh4 = [smgr addSegmentAtWorldAnchor:cpv(305,100) toWorldAnchor:cpv(330,180) mass:1 radius:2];
	cpShapeNode *s4 = [cpShapeNode nodeWithShape:sh4];
	s4.color = ccMAGENTA;
	[self addChild:s4];

	[smgr combineShapes:sh1,sh2,sh3,sh4,nil];
}

- (void) setupStaticShapes
{
	//static shapes, STATIC_MASS is the key concept here
	cpShape *staticCircle = [smgr addCircleAt:cpv(100,60) mass:STATIC_MASS radius:25];
	cpShape *staticRect = [smgr addRectAt:cpv(380,160) mass:STATIC_MASS width:50 height:50 rotation:0];
	
	//We need to assign a type for recognizing specific collisions
	staticRect->collision_type = kRectCollisionType;
	staticCircle->collision_type = kCircleCollisionType;
	
	//Connect our shapes to sprites
	cpCCSprite *sCircleSprite = [cpCCSprite spriteWithShape:staticCircle file:@"staticcircle.png"];
	cpCCSprite *sRectSprite = [cpCCSprite spriteWithShape:staticRect file:@"staticrect.png"];
	
	//Add our sprites
	[self addChild:sCircleSprite];
	[self addChild:sRectSprite];
	
	//Lets get our staticRect moving
	[sRectSprite runAction:[CCRepeatForever actionWithAction:[CCSequence actions:
															[CCMoveBy actionWithDuration:2 position:ccp(60,0)],
															[CCMoveBy actionWithDuration:2 position:ccp(-60,0)], nil]]];
	
	// This will cause the rectangle to update it's velocity based on the movement we're giving it
	// It's important to set the spacemanger here, as static shapes need to report when they've
	// changed, whereas active shapes do not, alternatively you could set this:
	//
	//  smgr.rehashStaticEveryStep = YES;
	//
	// Setting this would make the smgr recalculate all static shapes positions every step
	sRectSprite.integrationDt = 1.0/50.0;
	sRectSprite.spaceManager = smgr;
	
	//set up collisions
	[smgr addCollisionCallbackBetweenType:kRectCollisionType 
								otherType:kBallCollisionType 
								   target:self 
								 selector:@selector(handleCollisionWithRect:arbiter:space:)];
	[smgr addCollisionCallbackBetweenType:kCircleCollisionType 
								otherType:kBallCollisionType 
								   target:self 
								 selector:@selector(handleCollisionWithCircle:arbiter:space:)];
	
	//add a segment in for good measure
	cpShape* seg = [smgr addSegmentAtWorldAnchor:cpv(100,260) toWorldAnchor:cpv(380,260) mass:STATIC_MASS radius:6];
	cpShapeNode *segn = [cpShapeNode nodeWithShape:seg];
	segn.color = ccBLUE;
	segn.fillShape = NO;
	segn.smoothDraw = YES;
	[self addChild:segn];
}

- (void) setupBallSlider
{
	//Our dangling rect on the slide joint
	cpShape *weight = [smgr addRectAt:cpv(240,230) mass:2 width:10 height:60 rotation:0];
	cpCCSprite *weightNode = [cpCCSprite spriteWithShape:weight file:@"rect.png"];
	
	cpConstraint *joint = [smgr addSpringToBody:weight->body fromBody:ballSprite.shape->body toBodyAnchor:cpv(0,-30) fromBodyAnchor:cpv(0,0) restLength:0.0f stiffness:1.0f damping:0.0f];
	cpConstraint *grooveJoint = [smgr addGrooveToBody:smgr.staticBody fromBody:weight->body grooveAnchor1:cpv(80,250) grooveAnchor2:cpv(400, 250) fromBodyAnchor:cpv(0,50)];	
	
	[self addChild:weightNode];
	[self addChild:[SpaceManagerCocos2d createConstraintNode:joint]];
	[self addChild:[SpaceManagerCocos2d createConstraintNode:grooveJoint]];
}

- (void) setupSawHorse
{	
	//Set up two legs that'll form our sawhorse thing
	cpShape *leg1 = [smgr addRectAt:cpv(220,80) mass:.5 width:10 height:60 rotation:CC_DEGREES_TO_RADIANS(-35.5)];
	cpShape *leg2 = [smgr addRectAt:cpv(260,80) mass:.5 width:10 height:60 rotation:CC_DEGREES_TO_RADIANS(35.5)];
	
	//Shapes in a group do not affect each other
	leg1->group = 1;
	leg2->group = 1;
	cpCCSprite *leg1s = [cpCCSprite spriteWithShape:leg1 file:@"rect.png"];
	cpCCSprite *leg2s = [cpCCSprite spriteWithShape:leg2 file:@"rect.png"];

	//Set up our joints
	cpConstraint *joint1 = [smgr addPinToBody:leg1->body fromBody:leg2->body toBodyAnchor:cpv(5,30) fromBodyAnchor:cpv(-5,30)];
	cpConstraint *joint2 = [smgr addSlideToBody:leg1->body fromBody:leg2->body minLength:30.0f maxLength:45.0f];	
	
	//Fun part, these babies will draw themselves depending on what joint type
	cpConstraintNode *jn1 = [SpaceManagerCocos2d createConstraintNode:joint1];
	cpConstraintNode *jn2 = [SpaceManagerCocos2d createConstraintNode:joint2];
	
	//Add all the CocosNodes
	[self addChild:leg1s];
	[self addChild:leg2s];
	
	[self addChild:jn1];
	[self addChild:jn2];
}	

- (void) setupFragmentShape
{
	//Fragmenting Shapes... will fragment on collision
	
	/* Since it's only one node, the batch isn't really necessary; real world would be > 1 most likely tho */
	cpShapeTextureBatchNode *batch = [cpShapeTextureBatchNode nodeWithFile:@"texture.png"];
	[self addChild:batch];
		
	cpShape *fragShape = [smgr addRectAt:cpv(100, 180) mass:STATIC_MASS width:60 height:60 rotation:-CC_DEGREES_TO_RADIANS(45)];
	//cpShape *fragShape = [smgr addCircleAt:cpv(100,180) mass:STATIC_MASS radius:30];
	//cpShape *fragShape = [smgr addSegmentAt:cpv(100,180) fromLocalAnchor:cpv(-30,-30) toLocalAnchor:cpv(30,30) mass:STATIC_MASS radius:5];
	fragShape->collision_type = kFragShapeCollisionType;
	cpShapeTextureNode *fragShapeNode = [cpShapeTextureNode nodeWithShape:fragShape batchNode:batch];
	fragShapeNode.textureOffset = ccp(.5,.5);
	fragShapeNode.textureRotation = -45;
	fragShapeNode.spaceManager = smgr;

	[batch addChild:fragShapeNode];
	
	[smgr addCollisionCallbackBetweenType:kFragShapeCollisionType 
								otherType:kBallCollisionType 
								   target:self 
								 selector:@selector(handleCollisionWithFragmentingRect:arbiter:space:)];
}


#pragma mark Touch Functions
- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{	
	//Calculate a vector based on where we touched and where the ball is
	CGPoint pt = [self convertTouchToNodeSpace:[touches anyObject]];
	//CGPoint forceVect = ccpSub(pt, ballSprite.position);
	
	//cpFloat len = cpvlength(forceVect);
	//cpVect normalized = cpvnormalize(forceVect);
	
	//This applys a one-time force, pretty much like firing a bullet
	//[ballSprite applyImpulse:ccpMult(forceVect, 1)];
	
	//Lets apply an explosion instead
	[smgr applyLinearExplosionAt:pt radius:240 maxForce:200];
	
	
	//Reset Scene
	//CCScene *scene = [CCScene node];
	//[scene addChild:[GameLayer node]];
	//[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:.4 scene:scene  withColor:ccBLUE]];
}

- (BOOL) handleCollisionWithRect:(CollisionMoment)moment arbiter:(cpArbiter*)arb space:(cpSpace*)space
{
	if (moment == COLLISION_BEGIN)
		[label setString:@"You hit the Rectangle!"];
	
	return YES;
}

- (BOOL) handleCollisionWithCircle:(CollisionMoment)moment arbiter:(cpArbiter*)arb space:(cpSpace*)space
{
	if (moment == COLLISION_BEGIN)
	{
		[label setString:@"You hit the Circle!"];
		
		//Test removal of collision
		//[smgr removeCollisionCallbackBetweenType:kCircleCollisionType otherType:kBallCollisionType];
	}
	return YES;
}

- (void) handleCollisionWithFragmentingRect:(CollisionMoment)moment arbiter:(cpArbiter*)arb space:(cpSpace*)space
{	
	if (moment == COLLISION_POSTSOLVE)
	{
		[label setString:@"You hit the Fragmenting Shape!"];
		
		CP_ARBITER_GET_SHAPES(arb,a,b);
		
		cpShapeNode *fragShapeNode = (cpShapeNode*)(a->data);
		
		//fragment our shape
		NSArray *frags = [fragShapeNode.spaceManager fragmentShape:fragShapeNode.shape piecesNum:16 eachMass:1];
		fragShapeNode.shape = NULL;
		
		//step over all pieces
		for (NSValue *fVal in frags)
		{
			//retrieve the shape and attach it to a cocosnode
			cpShape *fshape = [fVal pointerValue];
			cpShapeNode *fnode = [SpaceManagerCocos2d createShapeNode:fshape];
			[self addChild:fnode];
		}
		
		//cleanup old shape
		[fragShapeNode.parent removeChild:fragShapeNode cleanup:YES];
	}
}

@end

