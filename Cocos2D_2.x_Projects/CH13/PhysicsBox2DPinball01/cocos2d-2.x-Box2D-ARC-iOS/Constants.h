//
//  Constants.h
//  PhysicsBox2DPinball01
//
//  Created by Steffen Itterheim on 23.05.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#ifndef PhysicsBox2DPinball01_Constants_h
#define PhysicsBox2DPinball01_Constants_h

#import "GB2ShapeCache.h"

// Pixel to metres ratio. Box2D uses meters as the unit for measurement.
// This ratio defines how many pixels correspond to 1 Box2D "meter"
// Box2D is optimized for objects of 1x1 meters therefore it makes sense
// to define the ratio so that your most common object type is 1x1 meter.
#define PTM_RATIO ([GB2ShapeCache sharedShapeCache].ptmRatio * 0.5f)

#define TILESIZE 32
#define TILESET_COLUMNS 9
#define TILESET_ROWS 19


#endif
