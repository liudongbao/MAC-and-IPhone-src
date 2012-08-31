//
//  HelloWorldLayer.h
//  cocos2d-2.x-ARC-iOS
//
//  Created by Steffen Itterheim on 27.04.12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "cocos2d.h"

@interface CCGLView (hittest)
-(UIView*) hitTest:(CGPoint)point withEvent:(UIEvent*)event;
@end


@interface HelloWorldLayer : CCLayer <UIAlertViewDelegate, UITextFieldDelegate>
{
}

+(CCScene *) scene;

@end

