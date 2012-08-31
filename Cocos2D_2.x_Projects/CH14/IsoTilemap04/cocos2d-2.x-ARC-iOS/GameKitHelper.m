//
//  GameKitHelper.m
//
//  Created by Steffen Itterheim on 05.10.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "GameKitHelper.h"
#import "AppDelegate.h"

@interface GameKitHelper (Private)
-(void) registerForLocalPlayerAuthChange;
-(void) setLastError:(NSError*)error;
@end

@implementation GameKitHelper

#pragma mark Singleton stuff

+(GameKitHelper*) sharedGameKitHelper
{
	static dispatch_once_t once;
	static GameKitHelper* sharedGameKitHelper;
    dispatch_once(&once, ^{ sharedGameKitHelper = [[self alloc] init]; });
    return sharedGameKitHelper;
}

#pragma mark Init & Dealloc

@synthesize delegate;
@synthesize isGameCenterAvailable, matchStarted;
@synthesize lastError;
@synthesize achievements;
@synthesize currentMatch;

-(id) init
{
	if ((self = [super init]))
	{
		// Test for Game Center availability
		Class gameKitLocalPlayerClass = NSClassFromString(@"GKLocalPlayer");
		BOOL isLocalPlayerAvailable = (gameKitLocalPlayerClass != nil);
		
		// Test if device is running iOS 4.1 or higher
		NSString* reqSysVer = @"4.1";
		NSString* currSysVer = [UIDevice currentDevice].systemVersion;
		BOOL isOSVer41 = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
		
		isGameCenterAvailable = (isLocalPlayerAvailable && isOSVer41);
		NSLog(@"GameCenter available = %@", isGameCenterAvailable ? @"YES" : @"NO");
		
		[self registerForLocalPlayerAuthChange];
	}
	
	return self;
}

-(void) dealloc
{
	CCLOG(@"dealloc %@", self);
	
	lastError = nil;	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark setLastError

-(void) setLastError:(NSError*)error
{
	lastError = error.copy;
	if (lastError != nil)
	{
		NSLog(@"GameKitHelper ERROR: %@", lastError.userInfo.description);
	}
}

#pragma mark Player Authentication

-(void) authenticateLocalPlayer
{
	if (isGameCenterAvailable == NO)
		return;

	GKLocalPlayer* localPlayer = GKLocalPlayer.localPlayer;
	if (localPlayer.authenticated == NO)
	{
		// Authenticate player, using a block object. See Apple's Block Programming guide for more info about Block Objects:
		// http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/Blocks/Articles/00_Introduction.html
		[localPlayer authenticateWithCompletionHandler:^(NSError* error)
		{
			[self setLastError:error];
			
			if (error == nil)
			{
				[self loadAchievements];
			}
		}];
	}
}

-(void) onLocalPlayerAuthenticationChanged
{
	if ([delegate respondsToSelector:@selector(onLocalPlayerAuthenticationChanged)])
	{
		[delegate onLocalPlayerAuthenticationChanged];
	}
}

-(void) registerForLocalPlayerAuthChange
{
	if (isGameCenterAvailable == NO)
		return;
	
	// Register to receive notifications when local player authentication status changes
	NSNotificationCenter* nc = NSNotificationCenter.defaultCenter;
	[nc addObserver:self
		   selector:@selector(onLocalPlayerAuthenticationChanged)
			   name:GKPlayerAuthenticationDidChangeNotificationName
			 object:nil];
}

#pragma mark Friends & Player Info

-(void) getLocalPlayerFriends
{
	if (isGameCenterAvailable == NO)
		return;
	
	GKLocalPlayer* localPlayer = GKLocalPlayer.localPlayer;
	if (localPlayer.authenticated)
	{
		// First, get the list of friends (player IDs)
		[localPlayer loadFriendsWithCompletionHandler:^(NSArray* friends, NSError* error)
		{
			[self setLastError:error];
			if ([delegate respondsToSelector:@selector(onFriendListReceived:)])
			{
				[delegate onFriendListReceived:friends];
			}
		}];
	}
}

-(void) getPlayerInfo:(NSArray*)playerList
{
	if (isGameCenterAvailable == NO)
		return;

	if (playerList.count > 0)
	{
		// Get detailed information about a list of players
		[GKPlayer loadPlayersForIdentifiers:playerList withCompletionHandler:^(NSArray* players, NSError* error)
		 {
			 [self setLastError:error];
			 if ([delegate respondsToSelector:@selector(onPlayerInfoReceived:)])
			 {
				 [delegate onPlayerInfoReceived:players];
			 }
		 }];
	}
}

#pragma mark Scores & Leaderboard

-(void) submitScore:(int64_t)score category:(NSString*)category
{
	if (isGameCenterAvailable == NO)
		return;
	
	GKScore* gkScore = [[GKScore alloc] initWithCategory:category];
	gkScore.value = score;
	
	[gkScore reportScoreWithCompletionHandler:^(NSError* error)
	{
		[self setLastError:error];
		 
		BOOL success = (error == nil);
		if ([delegate respondsToSelector:@selector(onScoresSubmitted:)])
		{
			[delegate onScoresSubmitted:success];
		}
	}];
}

-(void) retrieveScoresForPlayers:(NSArray*)players
						category:(NSString*)category 
						   range:(NSRange)range
					 playerScope:(GKLeaderboardPlayerScope)playerScope 
					   timeScope:(GKLeaderboardTimeScope)timeScope 
{
	if (isGameCenterAvailable == NO)
		return;
	
	GKLeaderboard* leaderboard = nil;
	if (players.count > 0)
	{
		leaderboard = [[GKLeaderboard alloc] initWithPlayerIDs:players];
	}
	else
	{
		leaderboard = [[GKLeaderboard alloc] init];
		leaderboard.playerScope = playerScope;
	}
	
	if (leaderboard != nil)
	{
		leaderboard.timeScope = timeScope;
		leaderboard.category = category;
		leaderboard.range = range;
		[leaderboard loadScoresWithCompletionHandler:^(NSArray* scores, NSError* error)
		 {
			 [self setLastError:error];
			 if ([delegate respondsToSelector:@selector(onScoresReceived:)])
			 {
				 [delegate onScoresReceived:scores];
			 }
		 }];
	}
}

-(void) retrieveTopTenAllTimeGlobalScores
{
	[self retrieveScoresForPlayers:nil
						  category:nil 
							 range:NSMakeRange(1, 10)
					   playerScope:GKLeaderboardPlayerScopeGlobal 
						 timeScope:GKLeaderboardTimeScopeAllTime];
}

#pragma mark Achievements

-(void) loadAchievements
{
	if (isGameCenterAvailable == NO)
		return;
	
	[GKAchievement loadAchievementsWithCompletionHandler:^(NSArray* loadedAchievements, NSError* error)
	 {
		 [self setLastError:error];
		 
		 if (achievements == nil)
		 {
			 achievements = [[NSMutableDictionary alloc] init];
		 }
		 else
		 {
			 [achievements removeAllObjects];
		 }
		 
		 for (GKAchievement* achievement in loadedAchievements)
		 {
			 [achievements setObject:achievement forKey:achievement.identifier];
		 }
		 
		 if ([delegate respondsToSelector:@selector(onAchievementsLoaded:)])
		 {
			 [delegate onAchievementsLoaded:achievements];
		 }
	 }];
}

-(GKAchievement*) getAchievementByID:(NSString*)identifier
{
	if (isGameCenterAvailable == NO)
		return nil;
	
	// Try to get an existing achievement with this identifier
	GKAchievement* achievement = [achievements objectForKey:identifier];
	
	if (achievement == nil)
	{
		// Create a new achievement object
		achievement = [[GKAchievement alloc] initWithIdentifier:identifier];
		[achievements setObject:achievement forKey:achievement.identifier];
	}
	
	return achievement;
}

-(void) reportAchievementWithID:(NSString*)identifier percentComplete:(float)percent
{
	if (isGameCenterAvailable == NO)
		return;
	
	GKAchievement* achievement = [self getAchievementByID:identifier];
	if (achievement != nil && achievement.percentComplete < percent)
	{
		achievement.percentComplete = percent;
		[achievement reportAchievementWithCompletionHandler:^(NSError* error)
		 {
			 [self setLastError:error];
			 if ([delegate respondsToSelector:@selector(onAchievementReported:)])
			 {
				 [delegate onAchievementReported:achievement];
			 }
		 }];
	}
}

-(void) resetAchievements
{
	if (isGameCenterAvailable == NO)
		return;
	
	[achievements removeAllObjects];
	
	[GKAchievement resetAchievementsWithCompletionHandler:^(NSError* error)
	 {
		 [self setLastError:error];
		 BOOL success = (error == nil);
		 if ([delegate respondsToSelector:@selector(onResetAchievements:)])
		 {
			 [delegate onResetAchievements:success];
		 }
	 }];
}

#pragma mark Matchmaking

-(void) disconnectCurrentMatch
{
	[currentMatch disconnect];
	currentMatch.delegate = nil;
	currentMatch = nil;
}

-(void) setCurrentMatch:(GKMatch*)match
{
	if ([currentMatch isEqual:match] == NO)
	{
		[self disconnectCurrentMatch];
		currentMatch = match;
		currentMatch.delegate = self;
	}
}

-(void) initMatchInvitationHandler
{
	if (isGameCenterAvailable == NO)
		return;
	
	[GKMatchmaker sharedMatchmaker].inviteHandler = ^(GKInvite* acceptedInvite, NSArray* playersToInvite)
	{
		[self disconnectCurrentMatch];
		
		if (acceptedInvite)
		{
			[self showMatchmakerWithInvite:acceptedInvite];
		}
		else if (playersToInvite)
		{
			GKMatchRequest* request = [[GKMatchRequest alloc] init];
			request.minPlayers = 2;
			request.maxPlayers = 4;
			request.playersToInvite = playersToInvite;
			
			[self showMatchmakerWithRequest:request];
		}
	};
}

-(void) findMatchForRequest:(GKMatchRequest*)request
{
	if (isGameCenterAvailable == NO)
		return;
	
	[[GKMatchmaker sharedMatchmaker] findMatchForRequest:request 
								   withCompletionHandler:^(GKMatch* match, NSError* error)
	 {
		 [self setLastError:error];
		 
		 if (match != nil)
		 {
			 [self setCurrentMatch:match];
			 if ([delegate respondsToSelector:@selector(onMatchFound:)])
			 {
				 [delegate onMatchFound:match];
			 }
		 }
	 }];
}

-(void) cancelMatchmakingRequest
{
	if (isGameCenterAvailable == NO)
		return;
	
	[[GKMatchmaker sharedMatchmaker] cancel];
}

-(void) addPlayersToMatch:(GKMatchRequest*)request
{
	if (isGameCenterAvailable == NO)
		return;
	
	if (currentMatch == nil)
		return;
	
	[[GKMatchmaker sharedMatchmaker] addPlayersToMatch:currentMatch 
										  matchRequest:request 
									 completionHandler:^(NSError* error)
	 {
		 [self setLastError:error];
		 
		 BOOL success = (error == nil);
		 if ([delegate respondsToSelector:@selector(onPlayersAddedToMatch:)])
		 {
			 [delegate onPlayersAddedToMatch:success];
		 }
	 }];
}

-(void) queryMatchmakingActivity
{
	if (isGameCenterAvailable == NO)
		return;
	
	[[GKMatchmaker sharedMatchmaker] queryActivityWithCompletionHandler:^(NSInteger activity, NSError* error)
	 {
		 [self setLastError:error];
		 
		 if (error == nil)
		 {
			 [delegate onReceivedMatchmakingActivity:activity];
		 }
	 }];
}

#pragma mark Match Connection

-(void) match:(GKMatch*)match player:(NSString*)playerID didChangeState:(GKPlayerConnectionState)state
{
	switch (state)
	{
		case GKPlayerStateConnected:
			if ([delegate respondsToSelector:@selector(onPlayerConnected:)])
			{
				[delegate onPlayerConnected:playerID];
			}
			break;
		case GKPlayerStateDisconnected:
			if ([delegate respondsToSelector:@selector(onPlayerDisconnected:)])
			{
				[delegate onPlayerDisconnected:playerID];
			}
			break;
	}
	
	if (matchStarted == NO && match.expectedPlayerCount == 0)
	{
		matchStarted = YES;
		if ([delegate respondsToSelector:@selector(onStartMatch)])
		{
			[delegate onStartMatch];
		}
	}
}

-(void) sendDataToAllPlayers:(void*)data sizeInBytes:(NSUInteger)sizeInBytes
{
	if (isGameCenterAvailable == NO)
		return;
	
	NSError* error = nil;
	NSData* packet = [NSData dataWithBytes:data length:sizeInBytes];
	[currentMatch sendDataToAllPlayers:packet withDataMode:GKMatchSendDataUnreliable error:&error];
	[self setLastError:error];
}

-(void) match:(GKMatch*)match didReceiveData:(NSData*)data fromPlayer:(NSString*)playerID
{
	if ([delegate respondsToSelector:@selector(onReceivedData:fromPlayer:)])
	{
		[delegate onReceivedData:data fromPlayer:playerID];
	}
}

-(void) match:(GKMatch*)match connectionWithPlayerFailed:(NSString*)playerID withError:(NSError*)error
{
	CCLOG(@"match:connectionWithPlayerFailed: %@", playerID);
	[self setLastError:error];
}

-(void) match:(GKMatch*)match didFailWithError:(NSError*)error
{
	CCLOG(@"match:didFailWithError");
	[self setLastError:error];
}

#pragma mark Views (Leaderboard, Achievements)

// Helper methods

-(UINavigationController*) appNavigationController
{
	AppController* app = (AppController*)[UIApplication sharedApplication].delegate;
	return app.navController;
}

-(void) presentViewController:(UIViewController*)vc
{
	UINavigationController* navController = [self appNavigationController];
	[navController presentModalViewController:vc animated:YES];
}

-(void) dismissModalViewController
{
	UINavigationController* navController = [self appNavigationController];
	[navController dismissModalViewControllerAnimated:YES];
}

// Leaderboards

-(void) showLeaderboard
{
	if (isGameCenterAvailable == NO)
		return;
	
	GKLeaderboardViewController* leaderboardVC = [[GKLeaderboardViewController alloc] init];
	if (leaderboardVC != nil)
	{
		leaderboardVC.leaderboardDelegate = (id<GKLeaderboardViewControllerDelegate>)self;
		[self presentViewController:leaderboardVC];
	}
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController*)viewController
{
	[self dismissModalViewController];
	if ([delegate respondsToSelector:@selector(onLeaderboardViewDismissed)])
	{
		[delegate onLeaderboardViewDismissed];
	}
}

// Achievements

-(void) showAchievements
{
	if (isGameCenterAvailable == NO)
		return;
	
	GKAchievementViewController* achievementsVC = [[GKAchievementViewController alloc] init];
	if (achievementsVC != nil)
	{
		achievementsVC.achievementDelegate = self;
		[self presentViewController:achievementsVC];
	}
}

-(void) achievementViewControllerDidFinish:(GKAchievementViewController*)viewController
{
	[self dismissModalViewController];
	if ([delegate respondsToSelector:@selector(onAchievementsViewDismissed)])
	{
		[delegate onAchievementsViewDismissed];
	}
}

// Matchmaking

-(void) showMatchmakerWithInvite:(GKInvite*)invite
{
	GKMatchmakerViewController* inviteVC = [[GKMatchmakerViewController alloc] initWithInvite:invite];
	if (inviteVC != nil)
	{
		inviteVC.matchmakerDelegate = self;
		[self presentViewController:inviteVC];
	}
}

-(void) showMatchmakerWithRequest:(GKMatchRequest*)request
{
	GKMatchmakerViewController* hostVC = [[GKMatchmakerViewController alloc] initWithMatchRequest:request];
	if (hostVC != nil)
	{
		hostVC.matchmakerDelegate = self;
		[self presentViewController:hostVC];
	}
}

-(void) matchmakerViewControllerWasCancelled:(GKMatchmakerViewController*)viewController
{
	[self dismissModalViewController];
	if ([delegate respondsToSelector:@selector(onMatchmakingViewDismissed)])
	{
		[delegate onMatchmakingViewDismissed];
	}
}

-(void) matchmakerViewController:(GKMatchmakerViewController*)viewController 
				didFailWithError:(NSError*)error
{
	[self dismissModalViewController];
	[self setLastError:error];
	if ([delegate respondsToSelector:@selector(onMatchmakingViewError)])
	{
		[delegate onMatchmakingViewError];
	}
}

-(void) matchmakerViewController:(GKMatchmakerViewController*)viewController 
					didFindMatch:(GKMatch*)match
{
	[self dismissModalViewController];
	[self setCurrentMatch:match];
	if ([delegate respondsToSelector:@selector(onMatchFound:)])
	{
		[delegate onMatchFound:match];
	}
}

-(void) matchmakerViewController:(GKMatchmakerViewController*)viewController 
				  didFindPlayers:(NSArray*)playerIDs
{
	[self dismissModalViewController];
	CCLOG(@"matchmakerViewController:didFindPlayers not implemented!");
}

@end


@implementation GKLeaderboardViewController (OrientationFix)
-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}
@end

@implementation GKAchievementViewController (OrientationFix)
-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}
@end

@implementation GKMatchmakerViewController (OrientationFix)
-(BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}
@end
