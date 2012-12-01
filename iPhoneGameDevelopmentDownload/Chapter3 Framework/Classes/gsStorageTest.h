#import <Foundation/Foundation.h>
#import "GameState.h"

@interface gsStorageTest : GameState {
	IBOutlet UIView* subview;
	IBOutlet UISwitch* toggle;
}


- (void) runTests;
- (IBAction) toggled;
- (IBAction) back;

@end
