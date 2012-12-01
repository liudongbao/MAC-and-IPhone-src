//
//  ViewHighScoresAppDelegate.h
//  ViewHighScores
//
//  Created by PJ Cabrera on 1/13/09.
//  Copyright PJ Cabrera 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface ViewHighScoresAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;

	NSMutableData *responseData;
	NSXMLParser *highScoresParser;
	NSMutableArray *highScores;
	NSMutableDictionary *newScore;
	NSString *currentKey;
	NSMutableString *currentStringValue;

	RootViewController *rootViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@property (nonatomic, retain) NSMutableArray *highScores;
@property (nonatomic, retain) IBOutlet RootViewController *rootViewController;

- (void)getHighScores;
- (void)getHighScoresFromWebService:(NSString *)URLstr;
- (void)parseHighScores:(NSData *)highScoresXMLData;

@end

