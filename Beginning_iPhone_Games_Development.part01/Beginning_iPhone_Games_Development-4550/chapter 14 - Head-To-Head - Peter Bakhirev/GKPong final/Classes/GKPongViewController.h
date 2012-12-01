#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "Ball.h"
#import "Paddle.h"
#import "AnnouncementLabel.h"

typedef enum {
  gameStateLaunched,
  gameStateLookingForOpponent,
  gameStateRollingDice,
  gameStateWaitingForOpponentToServeBall,
  gameStateWaitingToServeBall,
  gameStatePlaying
} GameState;

@interface GKPongViewController : UIViewController <BallDelegate,
    GKPeerPickerControllerDelegate, GKSessionDelegate> {

  Paddle *topPaddle;
  Paddle *bottomPaddle; 
  float paddleGrabOffset;

  Ball *ball;
  float initialBallDirection;

  AnnouncementLabel *announcementLabel;

  BOOL didWeWinLastRound;
  NSTimer *gameLoopTimer;
  GameState gameState;

  NSString *gkPeerID;
  GKSession *gkSession;

  int myDiceRoll;
  int myLastPaddleUpdateID;
  int peerLastPaddleUpdateID;
}

@property (retain, nonatomic) NSTimer *gameLoopTimer;
@property (retain, nonatomic) NSString *gkPeerID;
@property (retain, nonatomic) GKSession *gkSession;

- (void)showAnnouncement:(NSString*)announcementText;
- (void)hideAnnouncement;
- (void)startGame;
- (void)resetBall;
@end