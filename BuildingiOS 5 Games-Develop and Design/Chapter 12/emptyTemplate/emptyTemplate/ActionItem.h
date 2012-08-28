//
//  ActionItem.h
//  Raiders
//
//  Created by James Sugrue on 21/09/11.
//  Copyright (c) 2011 SoftwareX Ltd. All rights reserved.
//

#import "Sprite.h"

@interface ActionItem : Sprite {
    
}

- (BOOL)hasBeenTapped:(CGPoint)touchPoint;

- (void)tapAction:(SEL)method target:(id)target;

@end
