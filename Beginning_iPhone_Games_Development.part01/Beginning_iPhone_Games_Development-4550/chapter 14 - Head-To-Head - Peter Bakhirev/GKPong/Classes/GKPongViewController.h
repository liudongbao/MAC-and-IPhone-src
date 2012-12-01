#import <UIKit/UIKit.h>
#import "Ball.h"
#import "Paddle.h"
#import "AnnouncementLabel.h"

typedef enum {
  gameStateLaunched,
  gameStateWaitingToServeBall,
  gameStatePlaying
} GameState;

@interface GKPongViewController : UIViewController <BallDelegate> {
  Paddle *topPaddle;
  Paddle *bottomPaddle; 
  float paddleGrabOffset;

  Ball *ball;
  float initialBallDirection;

  AnnouncementLabel *announcementLabel;

  BOOL didWeWinLastRound;
  NSTimer *gameLoopTimer;
  GameState gameState;
}

@property (retain, nonatomic) NSTimer *gameLoopTimer;

- (void)showAnnouncement:(NSString*)announcementText;
- (void)hideAnnouncement;
- (void)startGame;
- (void)resetBall;
@end