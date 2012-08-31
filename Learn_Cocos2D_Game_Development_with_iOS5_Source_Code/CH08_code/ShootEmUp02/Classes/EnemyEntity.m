//
//  EnemyEntity.m
//  ShootEmUp
//
//  Created by Steffen Itterheim on 20.08.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "EnemyEntity.h"
#import "GameScene.h"
#import "StandardMoveComponent.h"
#import "StandardShootComponent.h"

@interface EnemyEntity (PrivateMethods)
-(void) initSpawnFrequency;
@end

@implementation EnemyEntity

-(id) initWithType:(EnemyTypes)enemyType
{
	type = enemyType;
	
	NSString* enemyFrameName;
	NSString* bulletFrameName;
	float shootFrequency = 6.0f;
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
			break;
		case EnemyTypeBoss:
			enemyFrameName = @"monster-c.png";
			bulletFrameName = @"shot-c.png";
			shootFrequency = 2.0f;
			break;
			
		default:
			[NSException exceptionWithName:@"EnemyEntity Exception" reason:@"unhandled enemy type" userInfo:nil];
	}

	if ((self = [super initWithSpriteFrameName:enemyFrameName]))
	{
		// Create the game logic components
		[self addChild:[StandardMoveComponent node]];
		
		StandardShootComponent* shootComponent = [StandardShootComponent node];
		shootComponent.shootFrequency = shootFrequency;
		shootComponent.bulletFrameName = bulletFrameName;
		[self addChild:shootComponent];

		// enemies start invisible
		self.visible = NO;

		[self initSpawnFrequency];
	}
	
	return self;
}

+(id) enemyWithType:(EnemyTypes)enemyType
{
	return [[[self alloc] initWithType:enemyType] autorelease];
}

static CCArray* spawnFrequency;

-(void) initSpawnFrequency
{
	// initialize how frequent the enemies will spawn
	if (spawnFrequency == nil)
	{
		spawnFrequency = [[CCArray alloc] initWithCapacity:EnemyType_MAX];
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
	return [number intValue];
}

-(void) dealloc
{
	[spawnFrequency release];
	spawnFrequency = nil;
	
	[super dealloc];
}


-(void) spawn
{
	CCLOG(@"spawn enemy");
	
	// Select a spawn location just outside the right side of the screen, with random y position
	CGRect screenRect = [GameScene screenRect];
	CGSize spriteSize = [self contentSize];
	float xPos = screenRect.size.width + spriteSize.width * 0.5f;
	float yPos = CCRANDOM_0_1() * (screenRect.size.height - spriteSize.height) + spriteSize.height * 0.5f;
	self.position = CGPointMake(xPos, yPos);
	
	// Finally set yourself to be visible, this also flag the enemy as "in use"
	self.visible = YES;
}

@end
