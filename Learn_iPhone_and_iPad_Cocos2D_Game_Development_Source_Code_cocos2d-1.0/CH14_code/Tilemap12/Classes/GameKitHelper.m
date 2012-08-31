//
//  GameKitHelper.m
//
//  Created by Steffen Itterheim on 05.10.10.
//  Copyright 2010 Steffen Itterheim. All rights reserved.
//

#import "GameKitHelper.h"

@interface GameKitHelper (Private)
-(void) registerForLocalPlayerAuthChange;
-(void) setLastError:(NSError*)error;
-(UIViewController*) getRootViewController;
@end

@implementation GameKitHelper

static GameKitHelper *instanceOfGameKitHelper;

#pragma mark Singleton stuff
+(id) alloc
{
	@synchronized(self)	
	{
		NSAssert(instanceOfGameKitHelper == nil, @"Attempted to allocate a second instance of the singleton: GameKitHelper");
		instanceOfGameKitHelper = [[super alloc] retain];
		return instanceOfGameKitHelper;
	}
	
	// to avoid compiler warning
	return nil;
}

+(GameKitHelper*) sharedGameKitHelper
{
	@synchronized(self)
	{
		if (instanceOfGameKitHelper == nil)
		{
			[[GameKitHelper alloc] init];
		}
		
		return instanceOfGameKitHelper;
	}
	
	// to avoid compiler warning
	return nil;
}

#pragma mark Init & Dealloc

@synthesize delegate;
@synthesize isGameCenterAvailable;
@synthesize lastError;

-(id) init
{
	if ((self = [super init]))
	{
		// Test for Game Center availability
		Class gameKitLocalPlayerClass = NSClassFromString(@"GKLocalPlayer");
		bool isLocalPlayerAvailable = (gameKitLocalPlayerClass != nil);
		
		// Test if device is running iOS 4.1 or higher
		NSString* reqSysVer = @"4.1";
		NSString* currSysVer = [[UIDevice currentDevice] systemVersion];
		bool isOSVer41 = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
		
		isGameCenterAvailable = (isLocalPlayerAvailable && isOSVer41);
		NSLog(@"GameCenter available = %@", isGameCenterAvailable ? @"YES" : @"NO");

		[self registerForLocalPlayerAuthChange];
	}
	
	return self;
}

-(void) dealloc
{
	CCLOG(@"dealloc %@", self);
	
	[instanceOfGameKitHelper release];
	instanceOfGameKitHelper = nil;
	
	[lastError release];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[super dealloc];
}

#pragma mark setLastError

-(void) setLastError:(NSError*)error
{
	[lastError release];
	lastError = [error copy];
	
	if (lastError)
	{
		NSLog(@"GameKitHelper ERROR: %@", [[lastError userInfo] description]);
	}
}

#pragma mark Player Authentication

-(void) authenticateLocalPlayer
{
	if (isGameCenterAvailable == NO)
		return;

	GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
	if (localPlayer.authenticated == NO)
	{
		// Authenticate player, using a block object. See Apple's Block Programming guide for more info about Block Objects:
		// http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/Blocks/Articles/00_Introduction.html
		[localPlayer authenticateWithCompletionHandler:^(NSError* error)
		{
			[self setLastError:error];
			
			if (error == nil)
			{
			}
		}];
		
		/*
		 // NOTE: bad example ahead!
		 
		 // If you want to modify a local variable inside a block object, you have to prefix it with the __block keyword.
		 __block bool success = NO;
		 
		 [localPlayer authenticateWithCompletionHandler:^(NSError* error)
		 {
		 	success = (error == nil);
		 }];
		 
		 // CAUTION: success will always be NO here! The block isn't run until later, when the authentication call was
		 // confirmed by the Game Center server. Set a breakpoint inside the block to see what is happening in what order.
		 if (success)
		 	NSLog(@"Local player logged in!");
		 else
		 	NSLog(@"Local player NOT logged in!");
		 */
	}
}

-(void) onLocalPlayerAuthenticationChanged
{
	[delegate onLocalPlayerAuthenticationChanged];
}

-(void) registerForLocalPlayerAuthChange
{
	if (isGameCenterAvailable == NO)
		return;

	// Register to receive notifications when local player authentication status changes
	NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
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
	
	GKLocalPlayer* localPlayer = [GKLocalPlayer localPlayer];
	if (localPlayer.authenticated)
	{
		// First, get the list of friends (player IDs)
		[localPlayer loadFriendsWithCompletionHandler:^(NSArray* friends, NSError* error)
		{
			[self setLastError:error];
			[delegate onFriendListReceived:friends];
		}];
	}
}

-(void) getPlayerInfo:(NSArray*)playerList
{
	if (isGameCenterAvailable == NO)
		return;

	// Get detailed information about a list of players
	if ([playerList count] > 0)
	{
		[GKPlayer loadPlayersForIdentifiers:playerList withCompletionHandler:^(NSArray* players, NSError* error)
		{
			[self setLastError:error];
			[delegate onPlayerInfoReceived:players];
		}];
	}
}

#pragma mark Scores & Leaderboard

-(void) submitScore:(int64_t)score category:(NSString*)category
{
	if (isGameCenterAvailable == NO)
		return;

	GKScore* gkScore = [[[GKScore alloc] initWithCategory:category] autorelease];
	gkScore.value = score;

	[gkScore reportScoreWithCompletionHandler:^(NSError* error)
	{
		[self setLastError:error];
		
		bool success = (error == nil);
		[delegate onScoresSubmitted:success];
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
	if ([players count] > 0)
	{
		leaderboard = [[[GKLeaderboard alloc] initWithPlayerIDs:players] autorelease];
	}
	else
	{
		leaderboard = [[[GKLeaderboard alloc] init] autorelease];
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
			[delegate onScoresReceived:scores];
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

#pragma mark Views (Leaderboard, Achievements)

// Helper methods

-(UIViewController*) getRootViewController
{
	return [UIApplication sharedApplication].keyWindow.rootViewController;
}

-(void) presentViewController:(UIViewController*)vc
{
	UIViewController* rootVC = [self getRootViewController];
	[rootVC presentModalViewController:vc animated:YES];
}

-(void) dismissModalViewController
{
	UIViewController* rootVC = [self getRootViewController];
	[rootVC dismissModalViewControllerAnimated:YES];
}

// Leaderboards

-(void) showLeaderboard
{
	if (isGameCenterAvailable == NO)
		return;
	
	GKLeaderboardViewController* leaderboardVC = [[[GKLeaderboardViewController alloc] init] autorelease];
	if (leaderboardVC != nil)
	{
		leaderboardVC.leaderboardDelegate = self;
		[self presentViewController:leaderboardVC];
	}
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController*)viewController
{
	[self dismissModalViewController];
	[delegate onLeaderboardViewDismissed];
}

@end
