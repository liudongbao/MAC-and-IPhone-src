//
//  Level1SceneController.h
//  Raiders
//
//  Created by James Sugrue on 21/09/11.
//  Copyright (c) 2011 SoftwareX Ltd. All rights reserved.
//

#import "AbstractSceneController.h"
#import "PlayerSprite.h"
#import "ActionItem.h"
#import "EnemySprite.h"

@interface Level1SceneController : AbstractSceneController<UIAccelerometerDelegate, StrafingFinishedDelegate> {
    
    PlayerSprite *playerSprite;    
    UIAccelerometer *accelerometer;
    
    ActionItem *leftJoystick;
    ActionItem *rightJoystick;
    
    int itemStrafing;
}

@end
