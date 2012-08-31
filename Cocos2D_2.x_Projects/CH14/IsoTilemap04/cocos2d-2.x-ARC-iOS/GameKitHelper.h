//
//  GameKitHelper.h
//
//  Created by Steffen Itterheim on 05.10.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "cocos2d.h"
#import <GameKit/GameKit.h>

@protocol GameKitHelperProtocol <NSObject>
@optional
-(void) onLocalPlayerAuthenticationChanged;
-(void) onFriendListReceived:(NSArray*)friends;
-(void) onPlayerInfoReceived:(NSArray*)players;

-(void) onScoresSubmitted:(BOOL)success;
-(void) onScoresReceived:(NSArray*)scores;
-(void) onLeaderboardViewDismissed;

-(void) onAchievementReported:(GKAchievement*)achievement;
-(void) onAchievementsLoaded:(NSDictionary*)achievements;
-(void) onResetAchievements:(BOOL)success;
-(void) onAchievementsViewDismissed;

-(void) onMatchFound:(GKMatch*)match;
-(void) onPlayersAddedToMatch:(BOOL)success;
-(void) onReceivedMatchmakingActivity:(NSInteger)activity;
-(void) onPlayerConnected:(NSString*)playerID;
-(void) onPlayerDisconnected:(NSString*)playerID;
-(void) onStartMatch;
-(void) onReceivedData:(NSData*)data fromPlayer:(NSString*)playerID;
-(void) onMatchmakingViewDismissed;
-(void) onMatchmakingViewError;
@end

@interface GameKitHelper : NSObject <GKLeaderboardViewControllerDelegate, GKAchievementViewControllerDelegate, GKMatchDelegate, GKMatchmakerViewControllerDelegate>
{
	id<GameKitHelperProtocol> delegate;
	BOOL isGameCenterAvailable;
	NSError* lastError;
	
	NSMutableDictionary* achievements;
	
	GKMatch* currentMatch;
	BOOL matchStarted;
}

@property (nonatomic, retain) id<GameKitHelperProtocol> delegate;
@property (nonatomic, readonly) BOOL isGameCenterAvailable;
@property (nonatomic, readonly) NSError* lastError;
@property (nonatomic, readonly) NSMutableDictionary* achievements;
@property (nonatomic, readonly) GKMatch* currentMatch;
@property (nonatomic, readonly) BOOL matchStarted;

/** returns the singleton object, like this: [GameKitHelper sharedGameKitHelper] */
+(GameKitHelper*) sharedGameKitHelper;

// Player authentication, info
-(void) authenticateLocalPlayer;
-(void) getLocalPlayerFriends;
-(void) getPlayerInfo:(NSArray*)players;

// Scores
-(void) submitScore:(int64_t)score category:(NSString*)category;

-(void) retrieveScoresForPlayers:(NSArray*)players
						category:(NSString*)category 
						   range:(NSRange)range
					 playerScope:(GKLeaderboardPlayerScope)playerScope 
					   timeScope:(GKLeaderboardTimeScope)timeScope;
-(void) retrieveTopTenAllTimeGlobalScores;
-(void) showLeaderboard;

// Achievements
-(GKAchievement*) getAchievementByID:(NSString*)identifier;
-(void) reportAchievementWithID:(NSString*)identifier percentComplete:(float)percent;
-(void) resetAchievements;
-(void) showAchievements;

// Matchmaking
-(void) disconnectCurrentMatch;
-(void) findMatchForRequest:(GKMatchRequest*)request;
-(void) addPlayersToMatch:(GKMatchRequest*)request;
-(void) cancelMatchmakingRequest;
-(void) queryMatchmakingActivity;
-(void) sendDataToAllPlayers:(void*)data sizeInBytes:(NSUInteger)sizeInBytes;
-(void) showMatchmakerWithInvite:(GKInvite*)invite;
-(void) showMatchmakerWithRequest:(GKMatchRequest*)request;

@end


@interface GKLeaderboardViewController (OrientationFix)
-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
@end

@interface GKAchievementViewController (OrientationFix)
-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
@end

@interface GKMatchmakerViewController (OrientationFix)
-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
@end
