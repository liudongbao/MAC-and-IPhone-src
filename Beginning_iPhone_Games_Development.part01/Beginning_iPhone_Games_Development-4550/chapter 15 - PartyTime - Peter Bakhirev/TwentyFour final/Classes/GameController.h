//
//  GameController.h
//  TwentyFour
//

#import <Foundation/Foundation.h>


@protocol GameControllerDelegate
- (void)gameControllerStarted;
- (void)gameControllerDidNotStart;
- (void)gameControllerTerminated;
- (void)startRoundWithChallenge:(NSArray*)challenge secondsToPlay:(float)seconds;
- (void)showGameResultsScreen;
- (void)updateGameStatus:(NSString*)status;
- (void)updateGameResults:(NSArray*)results;
@end


@interface GameController : NSObject {
  NSObject<GameControllerDelegate> *delegate;
  NSTimer *nextRoundTimer;
  NSString *playerName;
}

@property (nonatomic, retain) NSObject<GameControllerDelegate> *delegate;
@property (nonatomic, retain) NSTimer *nextRoundTimer;
@property (nonatomic, retain) NSString *playerName;

- (NSMutableArray*)makeNewChallenge;
- (void)submitResultSuccess:(float)seconds;
- (void)submitResultFailure:(NSString*)reason;
- (void)startWithPlayerName:(NSString*)playerName;
- (void)stop;

@end
