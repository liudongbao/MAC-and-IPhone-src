//
//  CheckMarkRecognizer.h
//  CheckPlease
//
//  Created by Dave Mark on 12/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CheckMarkRecognizer : UIGestureRecognizer {
    CGPoint     lastPreviousPoint;
    CGPoint     lastCurrentPoint;
    CGFloat     lineLengthSoFar;
}
@end
