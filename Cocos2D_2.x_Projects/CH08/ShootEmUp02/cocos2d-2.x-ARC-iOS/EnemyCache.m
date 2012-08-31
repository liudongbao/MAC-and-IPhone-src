//
//  EnemyCache.m
//  ShootEmUp
//
//  Created by Steffen Itterheim on 20.08.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "EnemyCache.h"
#import "Enemy.h"


@interface EnemyCache (PrivateMethods)
-(void) initEnemies;
@end


@implementation EnemyCache

+(id) cache
{
	return [[self alloc] init];
}

-(id) init
{
	if ((self = [super init]))
	{
		// get any image from the Texture Atlas we're using
		CCSpriteFrame* frame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"monster-a.png"];
		batch = [CCSpriteBatchNode batchNodeWithTexture:frame.texture];
		[self addChild:batch];
		
		[self initEnemies];
		[self scheduleUpdate];
	}
	
	return self;
}

-(void) initEnemies
{
	// create the enemies array containing further arrays for each type
	enemies = [NSMutableArray arrayWithCapacity:EnemyType_MAX];
	
	// create the arrays for each type
	for (NSUInteger i = 0; i < EnemyType_MAX; i++)
	{
		// depending on enemy type the array capacity is set to hold the desired number of enemies
		NSUInteger capacity;
		switch (i)
		{
			case EnemyTypeUFO:
				capacity = 6;
				break;
			case EnemyTypeCruiser:
				capacity = 3;
				break;
			case EnemyTypeBoss:
				capacity = 1;
				break;
				
			default:
				[NSException exceptionWithName:@"EnemyCache Exception" reason:@"unhandled enemy type" userInfo:nil];
				break;
		}
		
		NSMutableArray* enemiesOfType = [NSMutableArray arrayWithCapacity:capacity];
		[enemies addObject:enemiesOfType];
		
		for (NSUInteger j = 0; j < capacity; j++)
		{
			Enemy* enemy = [Enemy enemyWithType:i];
			[batch addChild:enemy z:0 tag:i];
			[enemiesOfType addObject:enemy];
		}
	}
}


-(void) spawnEnemyOfType:(EnemyTypes)enemyType
{
	NSMutableArray* enemiesOfType = [enemies objectAtIndex:enemyType];
	for (Enemy* enemy in enemiesOfType)
	{
		// find the first free enemy and respawn it
		if (enemy.visible == NO)
		{
			//CCLOG(@"spawn enemy type %i", enemyType);
			[enemy spawn];
			break;
		}
	}
}

-(void) update:(ccTime)delta
{
	updateCount++;

	for (int i = (EnemyType_MAX - 1); i >= 0; i--)
	{
		int spawnFrequency = [Enemy getSpawnFrequencyForEnemyType:i];
		
		if (updateCount % spawnFrequency == 0)
		{
			[self spawnEnemyOfType:i];
			break;
		}
	}
}

@end
