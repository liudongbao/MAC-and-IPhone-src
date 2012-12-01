#import "GKPongViewController.h"

#define INITIAL_BALL_SPEED 4.5
#define INITIAL_BALL_DIRECTION (0.3 * M_PI)

@implementation GKPongViewController

@synthesize gameLoopTimer;

- (void)processOneFrameComputerPlayer {
  float distance = ball.center.x - topPaddle.center.x;
  static const float kMaxComputerDistance = 10.0;

  if ( fabs(distance) > kMaxComputerDistance ) {
    distance = kMaxComputerDistance * (fabs(distance) / distance);
  }
    
  [topPaddle moveHorizontallyByDistance:distance inViewFrame:self.view.frame];
}

- (void)gameLoop {
  if ( gameState != gameStatePlaying ) {
    return;
  }
  [bottomPaddle processOneFrame];
  [topPaddle processOneFrame];
  [self processOneFrameComputerPlayer];
  [ball processOneFrame];
}

- (void)ballMissedPaddle:(Paddle*)paddle {
  if ( paddle == topPaddle ) {
    didWeWinLastRound = YES;
    gameState = gameStateWaitingToServeBall;
    [self showAnnouncement:@"Your opponent missed!\n\nTap to serve the ball."];
  }
  else {
    didWeWinLastRound = NO;    
    gameState = gameStateWaitingToServeBall;
    [self showAnnouncement:@"Looks like you missed...\n\nTap to serve the ball."];
  }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  if ( gameState == gameStatePlaying ) {
    UITouch *touch = [[event allTouches] anyObject];
    paddleGrabOffset = bottomPaddle.center.x - [touch locationInView:touch.view].x;
  }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  if ( gameState == gameStatePlaying ) {
    UITouch *touch = [[event allTouches] anyObject];
    float distance = ([touch locationInView:touch.view].x + paddleGrabOffset) - bottomPaddle.center.x;
    [bottomPaddle moveHorizontallyByDistance:distance inViewFrame:self.view.frame];
  }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [[event allTouches] anyObject];
  
  if ( gameState == gameStateLaunched && touch.tapCount > 0 ) {
    [self hideAnnouncement];
    gameState = gameStatePlaying;
    [self startGame];
  }
  else if ( gameState == gameStateWaitingToServeBall && touch.tapCount > 0 ) {
    [self hideAnnouncement];
    gameState = gameStatePlaying;
    [self resetBall];
  }
}

- (void)startGame {
  topPaddle.center = CGPointMake(self.view.frame.size.width/2, topPaddle.frame.size.height);
  bottomPaddle.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height - bottomPaddle.frame.size.height);
  [self resetBall];
  
  [self.view addSubview:topPaddle.view];
  [self.view addSubview:bottomPaddle.view];
  [self.view addSubview:ball.view];
  
  self.gameLoopTimer = [NSTimer scheduledTimerWithTimeInterval:0.033 target:self selector:@selector(gameLoop) userInfo:nil repeats:YES];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  sranddev();

  announcementLabel = [[AnnouncementLabel alloc] initWithFrame:self.view.frame];
  announcementLabel.center = CGPointMake(announcementLabel.center.x, announcementLabel.center.y - 23.0);

  topPaddle = [[Paddle alloc] init];
  bottomPaddle = [[Paddle alloc] init];

  ball = [[Ball alloc] initWithField:self.view.frame topPaddle:topPaddle bottomPaddle:bottomPaddle];
  ball.delegate = self;

  [self showAnnouncement:@"Welcome to GKPong!\n\nPlease tap to begin."];
  didWeWinLastRound = NO;
  gameState = gameStateLaunched;
}

- (void)showAnnouncement:(NSString*)announcementText {
  announcementLabel.text = announcementText;
  [self.view addSubview:announcementLabel];
}

- (void)hideAnnouncement {
  [announcementLabel removeFromSuperview];
}

- (void)resetBall {
  [ball reset];
  ball.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);    
  ball.direction = INITIAL_BALL_DIRECTION + ((didWeWinLastRound)? 0: M_PI);
  ball.speed = INITIAL_BALL_SPEED;
}

- (void)dealloc {
  [topPaddle release];
  [bottomPaddle release];
  [ball release];
  [announcementLabel removeFromSuperview];
  [gameLoopTimer invalidate];
  [super dealloc];  
}
@end