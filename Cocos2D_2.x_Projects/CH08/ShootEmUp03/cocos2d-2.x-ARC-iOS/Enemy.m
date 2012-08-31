//
//  EnemyEntity.m
//  ShootEmUp
//
//  Created by Steffen Itterheim on 20.08.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "Enemy.h"
#import "GameLayer.h"
#import "StandardMoveComponent.h"
#import "StandardShootComponent.h"
#import "HealthbarComponent.h"

@interface Enemy (PrivateMethods)
-(void) initSpawnFrequency;
@end

@implementation Enemy

@synthesize hitPoints, initialHitPoints;

-(id) initWithType:(EnemyTypes)enemyType
{
	type = enemyType;
	
	NSString* enemyFrameName;
	NSString* bulletFrameName;
	float shootFrequency = 6.0f;
	initialHitPoints = 1;
	
	// HACK: always spawn bosses
	//type = EnemyTypeBoss;
	
	switch (type)
	{
		case EnemyTypeUFO:
			enemyFrameName = @"monster-a.png";
			bulletFrameName = @"shot-a.png";
			break;
		case EnemyTypeCruiser:
			enemyFrameName = @"monster-b.png";
			bulletFrameName = @"shot-b.png";
			shootFrequency = 1.0f;
			initialHitPoints = 3;
			break;
		case EnemyTypeBoss:
			enemyFrameName = @"monster-c.png";
			bulletFrameName = @"shot-c.png";
			shootFrequency = 2.0f;
			initialHitPoints = 15;
			break;
			
		default:
			[NSException exceptionWithName:@"EnemyEntity Exception"
									reason:@"unhandled enemy type"
								  userInfo:nil];
	}
	
	self = [super initWithSpriteFrameName:enemyFrameName];
	if (self)
	{
		// Create the game logic components
		[self addChild:[StandardMoveComponent node]];
		
		StandardShootComponent* shootComponent = [StandardShootComponent node];
		shootComponent.shootFrequency = shootFrequency;
		shootComponent.bulletFrameName = bulletFrameName;
		[self addChild:shootComponent];
		
		if (type == EnemyTypeBoss)
		{
			HealthbarComponent* healthbar = [HealthbarComponent spriteWithSpriteFrameName:@"healthbar.png"];
			[self addChild:healthbar];
		}
		
		// enemies start invisible
		self.visible = NO;
		
		[self initSpawnFrequency];
	}
	
	return self;
}

+(id) enemyWithType:(EnemyTypes)enemyType
{
	return [[self alloc] initWithType:enemyType];
}

static NSMutableArray* spawnFrequency = nil;

-(void) initSpawnFrequency
{
	// initialize how frequent the enemies will spawn
	if (spawnFrequency == nil)
	{
		spawnFrequency = [NSMutableArray arrayWithCapacity:EnemyType_MAX];
		[spawnFrequency insertObject:[NSNumber numberWithInt:80] atIndex:EnemyTypeUFO];
		[spawnFrequency insertObject:[NSNumber numberWithInt:260] atIndex:EnemyTypeCruiser];
		[spawnFrequency insertObject:[NSNumber numberWithInt:1500] atIndex:EnemyTypeBoss];
		
		// spawn one enemy immediately
		[self spawn];
	}
}

+(int) getSpawnFrequencyForEnemyType:(EnemyTypes)enemyType
{
	NSAssert(enemyType < EnemyType_MAX, @"invalid enemy type");
	NSNumber* number = [spawnFrequency objectAtIndex:enemyType];
	return number.intValue;
}

-(void) spawn
{
	CCLOG(@"spawn enemy");
	
	// Select a spawn location just outside the right side of the screen, with random y position
    CGSize screenSize = [CCDirector sharedDirector].winSize;
	CGSize spriteSize = self.contentSize;
	float xPos = screenSize.width + spriteSize.width * 0.5f;
	float yPos = CCRANDOM_0_1() * (screenSize.height - spriteSize.height) + spriteSize.height * 0.5f;
	self.position = CGPointMake(xPos, yPos);
	
	// reset health
	hitPoints = initialHitPoints;

	// Finally set yourself to be visible, this also flag the enemy as "in use"
	self.visible = YES;
	
	// reset certain components
    for (CCNode* node in self.children)
    {
        if ([node isKindOfClass:[HealthbarComponent class]])
        {
            HealthbarComponent* healthbar = (HealthbarComponent*)node;
            [healthbar reset];
        }
    }
}

-(void) gotHit
{
	hitPoints--;
	if (hitPoints <= 0)
	{
		self.visible = NO;
	}
}

@end
