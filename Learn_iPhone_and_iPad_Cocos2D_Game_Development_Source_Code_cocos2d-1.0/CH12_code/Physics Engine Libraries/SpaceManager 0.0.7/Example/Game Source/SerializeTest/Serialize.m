//
//  Serialize.m
//  Example For SpaceManager
//
//  Created by Rob Blackwood on 5/30/10.
//

#import "Serialize.h"
#import "cpCCSprite.h"
#import "cpShapeNode.h"
#import "cpConstraintNode.h"

@interface Serialize (PrivateMethods)
- (void) setupTest;
@end

@implementation Serialize

- (id) init
{
	[super init];
	
	self.isTouchEnabled = YES;
	balls = [[NSMutableArray alloc] init];
	
	//add a background
	CCSprite *background = [CCSprite spriteWithFile:@"splash_developed_by.png"];
	background.position = ccp(240,160);
	[self addChild:background];
	
	//do our example
	[self setupTest];

	return self;
}

- (void) onExit
{
	[smgr stop];
	[self save];
	[super onExit];
}

-(void)save
{
	[smgr saveSpaceToUserDocs:@"cpSerializeTest.xml" delegate:self];
}

- (void) dealloc
{	
	[smgr release];
	[super dealloc];
}

- (void) setupTest
{
	//allocate our space manager
	smgr = [[SpaceManagerCocos2d alloc] init];
	
	//Constant dt is recommended for chipmunk
	smgr.constantDt = 1.0/55.0;
	
	//Try to load it from file, if not create from scratch
	if (![smgr loadSpaceFromUserDocs:@"cpSerializeTest.xml" delegate:self])
	{
		//add four walls to our screen
		[smgr addWindowContainmentWithFriction:1.0 elasticity:1.0 inset:cpvzero];
	
		for (int i = 0; i < 12; i++)
		{
			cpShape *ball = [smgr addCircleAt:cpv(40+i*25,100+i*5) mass:1.0 radius:10];
			cpCCSprite *ballSprite = [cpCCSprite spriteWithShape:ball file:@"ball.png"];
			[self addChild:ballSprite z:100];
			
			[balls addObject:ballSprite];
		}
		
		cpCCSprite *one = [balls objectAtIndex:0];
		cpCCSprite *two = [balls objectAtIndex:11];
		cpConstraint *pin = [smgr addPinToBody:one.shape->body fromBody:two.shape->body];
		cpConstraintNode *pinn = [cpConstraintNode nodeWithConstraint:pin];
		pinn.color = ccGREEN;
		[self addChild:pinn];
		
		/*cpCCSprite *three = [balls objectAtIndex:1];
		cpCCSprite *four = [balls objectAtIndex:10];
		cpConstraint *pulley = [smgr addPulleyToBody:three.shape->body fromBody:four.shape->body 
										toBodyAnchor:cpvzero fromBodyAnchor:cpvzero
									  toPulleyWorldAnchor:cpv(200,270) fromPulleyWorldAnchor:cpv(300,270) ratio:1];
		cpConstraintNode *pulleyn = [cpConstraintNode nodeWithConstraint:pulley];
		pulleyn.color = ccORANGE;
		[self addChild:pulleyn];*/
	}
		
	//start the manager!
	[smgr start]; 	
}

-(BOOL) aboutToReadShape:(cpShape*)shape shapeId:(long)id
{
	//If its static mass, then its the walls, just ignore them
	if (shape->body->m != STATIC_MASS)
	{
		//We know it has to be a ball
		cpCCSprite *ballSprite = [cpCCSprite spriteWithShape:shape file:@"ball.png"];
		[self addChild:ballSprite];
		
		[balls addObject:ballSprite];
	}
	
	return YES; //This just means accept the reading of this shape
}

-(BOOL) aboutToReadConstraint:(cpConstraint*)constraint constraintId:(long)id
{
	cpConstraintNode *pinn = [cpConstraintNode nodeWithConstraint:constraint];
	pinn.color = ccGREEN;
	[self addChild:pinn];
	
	return YES;
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{	
	//Calculate a vector based on where we touched and where the ball is
	CGPoint pt = [self convertTouchToNodeSpace:[touches anyObject]];
	
	for (cpCCSprite *ballSprite in balls)
	{
		CGPoint forceVect = ccpSub(pt, ballSprite.position);
		
		//This applys a one-time force, pretty much like firing a bullet
		[ballSprite applyImpulse:ccpMult(forceVect, 1)];
	}
}
@end

