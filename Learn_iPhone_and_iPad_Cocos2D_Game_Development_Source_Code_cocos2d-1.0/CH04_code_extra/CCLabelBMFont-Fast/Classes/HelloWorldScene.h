//
//  HelloWorldLayer.h
//  CCLabel-FastAndSlow
//
//  Created by Steffen Itterheim on 22.07.10.
//  Copyright Steffen Itterheim 2010. All rights reserved.
//

// ===============================================================

// Visit http://www.learn-cocos2d.com for the Bitmap Font Tutorial

// ===============================================================


#import "cocos2d.h"

@interface HelloWorld : CCLayer
{
	CCLabelBMFont* scoreLabel;
	int mode;
	int score;
}

+(id) scene;

@end
