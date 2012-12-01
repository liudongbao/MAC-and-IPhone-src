//
//  AnnouncementLabel.m
//  GKPong
//
//  Created by Peter Bakhyryev on 7/1/09.
//  Copyright 2009 ByteClub LLC. All rights reserved.
//

#import "AnnouncementLabel.h"


@implementation AnnouncementLabel

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
      self.textAlignment =  UITextAlignmentCenter;
      self.lineBreakMode = UILineBreakModeWordWrap;
      self.numberOfLines = 10;
      self.userInteractionEnabled = NO;
      self.opaque = NO;
      self.textColor = [UIColor whiteColor];
      self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

@end
