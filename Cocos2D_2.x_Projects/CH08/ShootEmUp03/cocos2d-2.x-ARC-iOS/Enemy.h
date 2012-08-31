//
//  EnemyEntity.h
//  ShootEmUp
//
//  Created by Steffen Itterheim on 20.08.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "cocos2d.h"

typedef enum
{
	EnemyTypeUFO = 0,
	EnemyTypeCruiser,
	EnemyTypeBoss,
	
	EnemyType_MAX,
} EnemyTypes;

@interface Enemy : CCSprite
{
	EnemyTypes type;
	int initialHitPoints;
	int hitPoints;
}

@property (readonly, nonatomic) int initialHitPoints;
@property (readonly, nonatomic) int hitPoints;

+(id) enemyWithType:(EnemyTypes)enemyType;
+(int) getSpawnFrequencyForEnemyType:(EnemyTypes)enemyType;
-(void) spawn;
-(void) gotHit;

@end
