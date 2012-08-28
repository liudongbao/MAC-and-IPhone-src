//
//  MenuSceneController.h
//  Raiders
//
//  Created by James Sugrue on 26/05/11.
//  Copyright 2011 SoftwareX. All rights reserved.
//
#import "AbstractSceneController.h"

@class Sprite;
@class ActionItem;

@interface MenuSceneController : AbstractSceneController {
    Sprite *background;
}

@property (nonatomic, retain) ActionItem *playButton;

@end
