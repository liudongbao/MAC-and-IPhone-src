//
//  EnemyEntity.h
//  ShootEmUp
//
//  Created by Steffen Itterheim on 20.08.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Entity.h"

typedef enum
{
	EnemyTypeBreadman = 0,
	EnemyTypeSnake,
	EnemyTypeBoss,
	
	EnemyType_MAX,
} EnemyTypes;


@interface EnemyEntity : Entity
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
