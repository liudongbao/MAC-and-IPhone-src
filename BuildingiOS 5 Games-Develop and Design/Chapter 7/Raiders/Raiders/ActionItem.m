//
//  ActionItem.m
//  Raiders
//
//  Created by James Sugrue on 21/09/11.
//  Copyright (c) 2011 SoftwareX Ltd. All rights reserved.
//

#import "ActionItem.h"

@implementation ActionItem


- (BOOL)hasBeenTapped:(CGPoint)touchPoint {
    return CGRectContainsPoint(self.bounds, touchPoint);
}

- (void)tapAction:(SEL)method target:(id)target {
    
    [target performSelector:method];
}

@end
