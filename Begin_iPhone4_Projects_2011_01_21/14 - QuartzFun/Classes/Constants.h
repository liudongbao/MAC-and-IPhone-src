/*
 *  Constants.h
 *  QuartzFun
 *
 *  Created by Dave Mark on 12/11/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

typedef enum {
    kLineShape = 0,
    kRectShape,
    kEllipseShape,
    kImageShape
} ShapeType;

typedef enum {
    kRedColorTab = 0,
    kBlueColorTab,
    kYellowColorTab,
    kGreenColorTab,
    kRandomColorTab
} ColorTabIndex;

#define degreesToRadian(x) (M_PI * (x) / 180.0)