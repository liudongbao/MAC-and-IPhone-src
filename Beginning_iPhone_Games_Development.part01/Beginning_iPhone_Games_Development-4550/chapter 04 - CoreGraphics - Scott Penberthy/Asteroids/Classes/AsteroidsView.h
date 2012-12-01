//
//  AsteroidsView.h
//  Asteroids
//
//  Created by Scott Penberthy on 2/26/10.
//  Copyright 2010 North Highland Partners, Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "AtlasSprite.h"
#import "VectorSprite.h"
#import "AsteroidsModel.h"

@interface AsteroidsView : UIView {
	AsteroidsModel *model;
	BOOL ready;
}

@property (retain,nonatomic) AsteroidsModel *model;

- (void) useModel: (AsteroidsModel *) model;
- (void) tic: (NSTimeInterval) dt;

@end
