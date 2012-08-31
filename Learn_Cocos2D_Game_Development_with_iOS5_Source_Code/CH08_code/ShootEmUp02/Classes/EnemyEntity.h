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
	EnemyTypeUFO = 0,
	EnemyTypeCruiser,
	EnemyTypeBoss,
	
	EnemyType_MAX,
} EnemyTypes;

@interface EnemyEntity : Entity 
{
	EnemyTypes type;
}

+(id) enemyWithType:(EnemyTypes)enemyType;

+(int) getSpawnFrequencyForEnemyType:(EnemyTypes)enemyType;

-(void) spawn;

@end
