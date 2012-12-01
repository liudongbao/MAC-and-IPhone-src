#import "GKPongViewController.h"

#define INITIAL_BALL_SPEED 4.5
#define INITIAL_BALL_DIRECTION (0.3 * M_PI)

enum {
  gkMessageDiceRolled,
  gkMessageBallServed,
  gkMessageBallMissed,
  gkMessageBallBounced,
  gkMessagePaddleMoved
};

typedef struct {
  CGPoint position;
  float direction;
  float speed;
} BallInfo;

@implementation GKPongViewController

@synthesize gameLoopTimer;
@synthesize gkPeerID, gkSession;

- (void)gameLoop {
  if ( gameState != gameStatePlaying ) {
    return;
  }
  [bottomPaddle processOneFrame];
  [topPaddle processOneFrame];
  [ball processOneFrame];
}

- (void)ballMissedPaddle:(Paddle*)paddle {
  didWeWinLastRound = NO;    
  gameState = gameStateWaitingToServeBall;
  [self showAnnouncement:@"Looks like you missed...\n\nTap to serve the ball."];
  
  char messageType = gkMessageBallMissed;
  [gkSession sendDataToAllPeers:[NSData dataWithBytes:&messageType length:1]
    withDataMode:GKSendDataReliable error:nil];
}

- (void)ballBounced {  
  NSMutableData *data = [NSMutableData dataWithCapacity:1+sizeof(BallInfo)];
  char messageType = gkMessageBallBounced;
  [data appendBytes:&messageType length:1];

  BallInfo message;
  message.position = ball.center;
  message.direction = ball.direction;
  message.speed = ball.speed;
  [data appendBytes:&message length:sizeof(BallInfo)];
  
  [gkSession sendDataToAllPeers:data withDataMode:GKSendDataReliable error:nil];
}

- (void)paddleMoved {
  NSMutableData *data = [NSMutableData dataWithCapacity:1+sizeof(int)+
    sizeof(float)];
  char messageType = gkMessagePaddleMoved;
  [data appendBytes:&messageType length:1];
  myLastPaddleUpdateID++;
  [data appendBytes:&myLastPaddleUpdateID length:sizeof(int)];
  float x = bottomPaddle.center.x;
  [data appendBytes:&x length:sizeof(float)];

  [gkSession sendDataToAllPeers:data withDataMode:GKSendDataUnreliable error:nil];
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
    float distance = ([touch locationInView:touch.view].x + paddleGrabOffset) -
      bottomPaddle.center.x;

    float previousX = bottomPaddle.center.x;
    [bottomPaddle moveHorizontallyByDistance:distance inViewFrame:self.view.frame];
    if ( bottomPaddle.center.x != previousX ) {
      [self paddleMoved];
    }
  }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  UITouch *touch = [[event allTouches] anyObject];
  
  if ( gameState == gameStateLaunched && touch.tapCount > 0 ) {
    [self hideAnnouncement];
    gameState = gameStateLookingForOpponent;
    
    GKPeerPickerController *picker;
    picker = [[GKPeerPickerController alloc] init];
    picker.delegate = self;
    [picker show];
  }
  else if ( gameState == gameStateWaitingToServeBall && touch.tapCount > 0 ) {
    [self hideAnnouncement];
    gameState = gameStatePlaying;
    [self resetBall];
    
    char messageType = gkMessageBallServed;
    [gkSession sendDataToAllPeers:[NSData dataWithBytes:&messageType length:1]
      withDataMode:GKSendDataReliable error:nil];
  }
}

- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker {
	picker.delegate = nil;
  [picker autorelease];
  
  [self showAnnouncement:@"Welcome to GKPong!\n\nPlease tap to begin."];
  gameState = gameStateLaunched;
} 

- (void)diceRolled {
  NSMutableData *data = [NSMutableData dataWithCapacity:1+sizeof(int)];
  char messageType = gkMessageDiceRolled;
  [data appendBytes:&messageType length:1];
  myDiceRoll = rand();
  [data appendBytes:&myDiceRoll length:sizeof(int)];

  [gkSession sendDataToAllPeers:data withDataMode:GKSendDataReliable error:nil];
}

- (void)peerPickerController:(GKPeerPickerController *)picker
    didConnectPeer:(NSString *)peerID toSession:(GKSession *)session {

  self.gkPeerID = peerID;
  self.gkSession = session;
  [gkSession setDataReceiveHandler:self withContext:NULL];
  gkSession.delegate = self;
	
  [picker dismiss];
  picker.delegate = nil;
  [picker autorelease];
  
  gameState = gameStateRollingDice;
  [self diceRolled];
}

- (void)session:(GKSession *)session peer:(NSString *)peerID
    didChangeState:(GKPeerConnectionState)state {

  if ( [gkPeerID isEqualToString:peerID] && state == GKPeerStateDisconnected ) {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Disconnection"
      message:@"Your opponent seems to have disconnected. Game is over."
      delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alertView show];
    
    [gkSession disconnectFromAllPeers];
    gkSession.delegate = nil;
    self.gkSession = nil;
    self.gkPeerID = nil;
    
    [bottomPaddle.view removeFromSuperview];
    [topPaddle.view removeFromSuperview];
    [ball.view removeFromSuperview];
    [gameLoopTimer invalidate];
    
    [self showAnnouncement:@"Welcome to GKPong!\n\nPlease tap to begin."];
    gameState = gameStateLaunched;
  }
}

- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer
    inSession:(GKSession *)session context:(void *)context {

  const char *incomingPacket = (const char *)[data bytes];
  char messageType = incomingPacket[0];

  switch (messageType) {
    case gkMessageDiceRolled: {
      int peerDiceRoll = *(int *)(incomingPacket + 1);
      if ( peerDiceRoll == myDiceRoll ) {
        [self diceRolled];
        return;
      }
      else if ( myDiceRoll > peerDiceRoll ) {            
        [self showAnnouncement:@"The game is about to begin.\n\nTap to serve the ball!"];
        gameState = gameStateWaitingToServeBall;
        didWeWinLastRound = NO;
      }
      else {
        [self showAnnouncement:@"The game is about to begin.\n\nWaiting for the opponent..."];
        gameState = gameStateWaitingForOpponentToServeBall;
        didWeWinLastRound = YES;
      }

      [self startGame];
      break;
    }
    
    case gkMessageBallServed:
      didWeWinLastRound = YES;
      [self resetBall];
      [self hideAnnouncement];
      gameState = gameStatePlaying;
      break;
      
    case gkMessageBallMissed:
      didWeWinLastRound = YES;
      [self showAnnouncement:@"You won the last round!\n\nWaiting for the opponent..."];
      gameState = gameStateWaitingForOpponentToServeBall;
      break;
      
    case gkMessageBallBounced: {
      BallInfo ballInfo = *(BallInfo *)(incomingPacket + 1);
      ball.direction = ballInfo.direction + M_PI;
      ball.speed = ballInfo.speed;
      ball.center = CGPointMake(self.view.frame.size.width - ballInfo.position.x,
        self.view.frame.size.height - ballInfo.position.y);
      break;
    }
      
    case gkMessagePaddleMoved: {
      int paddleUpdateID = *(int *)(incomingPacket + 1);
      if ( paddleUpdateID <= peerLastPaddleUpdateID ) {
        return;
      }
      peerLastPaddleUpdateID = paddleUpdateID;
      
      float x = *(float *)(incomingPacket + 1 + sizeof(int));
      topPaddle.center = CGPointMake(self.view.frame.size.width - x,
        topPaddle.center.y);
      break;
    }
  }
}

- (void)startGame {
  topPaddle.center = CGPointMake(self.view.frame.size.width/2,
    topPaddle.frame.size.height);
  bottomPaddle.center = CGPointMake(self.view.frame.size.width/2,
    self.view.frame.size.height - bottomPaddle.frame.size.height);
  [self resetBall];
  
  myLastPaddleUpdateID = 0;
  peerLastPaddleUpdateID = 0;
  
  [self.view addSubview:topPaddle.view];
  [self.view addSubview:bottomPaddle.view];
  [self.view addSubview:ball.view];
  
  self.gameLoopTimer = [NSTimer scheduledTimerWithTimeInterval:0.033 target:self
    selector:@selector(gameLoop) userInfo:nil repeats:YES];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  sranddev();

  announcementLabel = [[AnnouncementLabel alloc] initWithFrame:self.view.frame];
  announcementLabel.center = CGPointMake(announcementLabel.center.x,
    announcementLabel.center.y - 23.0);

  topPaddle = [[Paddle alloc] init];
  bottomPaddle = [[Paddle alloc] init];

  ball = [[Ball alloc] initWithField:self.view.frame topPaddle:topPaddle
    bottomPaddle:bottomPaddle];
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
  ball.center = CGPointMake(self.view.frame.size.width/2,
    self.view.frame.size.height/2);    
  ball.direction = INITIAL_BALL_DIRECTION + ((didWeWinLastRound)? 0: M_PI);
  ball.speed = INITIAL_BALL_SPEED;
}

- (void)dealloc {
  [topPaddle release];
  [bottomPaddle release];
  [ball release];
  [announcementLabel removeFromSuperview];
  [announcementLabel release];
  [gameLoopTimer invalidate];
  self.gameLoopTimer = nil;
  [super dealloc];  
}
@end