//
//  MenuLayer.h
//  MenuLayer
//
//  Created by MajorTom on 9/7/10.
//  Copyright iphonegametutorials.com 2010. All rights reserved.
//

#import "cocos2d.h"

#import "SceneManager.h"
#import "PlayLayer.h"
#import "CreditsLayer.h"

#import "BaseLayer.h"

@interface MenuLayer : BaseLayer {
}

- (void)onNewGame:(id)sender;
- (void)onCredits:(id)sender;
@end
