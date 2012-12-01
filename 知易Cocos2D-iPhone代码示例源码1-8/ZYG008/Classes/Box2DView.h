//
//  Box2DView.h
//  Box2D OpenGL View
//
//  Box2D iPhone port by Simon Oliver - http://www.simonoliver.com - http://www.handcircus.com
//

//
// File heavily modified for cocos2d integration
// http://www.cocos2d-iphone.org
//


#import <UIKit/UIKit.h>

#import "cocos2d.h"

#import "iPhoneTest.h"


@interface MenuLayer : CCLayer
{    
	int		entryID;	
	CCLabelTTF *lbInfo;	// ZY++ for DrawDebug string drawing.	
    CCMenuItemToggle * m_bomb; 
}
+(id) menuWithEntryID:(int)entryId;
-(id) initWithEntryID:(int)entryId;

@property(nonatomic,readonly) CCMenuItemToggle * Bomb;

@end

@interface Box2DView : CCLayer {
    
	TestEntry* entry;
	Test* test;
	int		entryID;	

}
+(id) viewWithEntryID:(int)entryId;
-(id) initWithEntryID:(int)entryId;
-(NSString*) title;

// ZY++
-(void)DoKey:(unichar)chr;
-(void)DoBomb;

-(Test *)GetTestObj;

@end
