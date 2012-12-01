//
//  TwentyFourViewController.m
//  TwentyFour
//

#import "TwentyFourViewController.h"
#import "TwentyFourAppDelegate.h"

@implementation TwentyFourViewController

@synthesize buttonPlus, buttonMinus, buttonMultiply, buttonDivide;
@synthesize buttonCorrect, buttonIncorrect;
@synthesize labelOutput, numberButtons, numbers;
@synthesize lastOperationString, committedOutput, undoBuffer;
@synthesize labelTimer, startTime, timerTimer;

#define BTN_PADDING 13.0
#define BTN_WIDTH 60.0
#define BTN_HEIGHT 37.0
#define BTN_Y_COORD 296.0

enum {
  OpNone,
  OpPlus,
  OpMinus,
  OpMultiply,
  OpDivide
};

enum {
  StateFirstNumber,
  StateOperation,
  StateSecondNumber,
  StateRoundOver
};

- (void)updateOutputByAppending:(NSString*)text {
  labelOutput.text = [committedOutput stringByAppendingString:text];
}

- (void)commitOutputByAppending:(NSString*)text {
  self.committedOutput = [committedOutput stringByAppendingString:text];
  labelOutput.text = committedOutput;
}

- (void)addUndoState {
  NSArray *undoState = [NSArray arrayWithObjects:
      [NSMutableArray arrayWithArray:numbers],
      [NSNumber numberWithInt:currentState],
      [NSNumber numberWithFloat:lastNumberEntered],
      [NSNumber numberWithInt:lastOperationEntered],
      (lastOperationString)?lastOperationString:@"",
      (committedOutput)?committedOutput:@"",
      (labelOutput.text)?labelOutput.text:@"",
      nil];

  [undoBuffer addObject:undoState];
}

- (void)makeNewButtons {
  NSMutableArray *newButtons = [NSMutableArray arrayWithCapacity:[numbers count]];
  
  float totalButtonWidth = 0;
  
  for( int i = 0; i < [numbers count]; i++ ) {
    NSString *title = [NSString stringWithFormat:@"%@", [numbers objectAtIndex:i]];

    // Make button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(0.0, BTN_Y_COORD, BTN_WIDTH, BTN_HEIGHT);
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:@selector(numberButtonPressed:)
        forControlEvents:UIControlEventTouchUpInside];

    // Add to our array
    [newButtons addObject:button];

    // Keep track of width
    totalButtonWidth += button.frame.size.width;
  }
  
  // Include padding between buttons
  totalButtonWidth += BTN_PADDING * ([newButtons count] - 1);
  
  float nextButtonEdge = (self.view.frame.size.width - totalButtonWidth) / 2;
  
  // Remove old buttons
  if ( numberButtons ) {
    [numberButtons makeObjectsPerformSelector:@selector(removeFromSuperview)];
  }
  
  // Position buttons
  for( int i = 0; i < [newButtons count]; i++ ) {
    UIButton *button = [newButtons objectAtIndex:i];
    button.center = CGPointMake(nextButtonEdge + button.frame.size.width/2,
        button.center.y);
    [self.view addSubview:button];
    
    nextButtonEdge += button.frame.size.width + BTN_PADDING;
  }
  
  self.numberButtons = newButtons;
}

- (void)startRoundWithChallenge:(NSArray*)challenge secondsToPlay:(float)seconds {
  self.numbers = [NSMutableArray arrayWithArray:challenge];

  buttonIncorrect.hidden = YES;
  buttonCorrect.hidden = YES;

  self.undoBuffer = [NSMutableArray arrayWithCapacity:9];
  currentState = StateFirstNumber;
  lastNumberEntered = MAXFLOAT;
  lastOperationEntered = OpNone;
  self.committedOutput = @"";

  [self makeNewButtons];

  timeForRound = seconds;
  labelOutput.text = @"Go!";
  labelTimer.text = [NSString stringWithFormat:@"%.2f seconds", timeForRound];

  self.startTime = [NSDate date];

  if ( timerTimer ) {
    [timerTimer invalidate];
  }
  self.timerTimer = [NSTimer scheduledTimerWithTimeInterval:0.11 target:self
      selector:@selector(updateTimerLabel) userInfo:nil repeats:YES];
}

- (void)stopRound {
  [timerTimer invalidate];
  self.timerTimer = nil;
  currentState = StateRoundOver;  
}

- (void)updateTimerLabel {
  NSDate *now = [NSDate date];
  NSTimeInterval timeLeft = timeForRound - [now timeIntervalSinceDate:startTime];
  if ( timeLeft <= 0.0 ) {
    // Round is over
    timeLeft = 0.0;
    [self stopRound];
    currentState = StateRoundOver;
    [[TwentyFourAppDelegate getInstance] submitResultFailure:@"Ran out of time"];

    [self performSelector:@selector(switchToResultsScreen) withObject:nil
        afterDelay:1.0];
  }
  labelTimer.text = [NSString stringWithFormat:@"%.2f seconds left", timeLeft];
}

- (void)numberButtonPressed:(id)sender {
  // Are we still playing?
  if ( currentState == StateRoundOver ) {
    return;
  }

  // Find out which button it was
  int numberIndex = [numberButtons indexOfObjectIdenticalTo:sender];
  if ( numberIndex == NSNotFound ) {
    return;
  }
  
  float n = [[numbers objectAtIndex:numberIndex] floatValue];

  // First number?
  if ( currentState == StateFirstNumber ) {
    // Are we replacing existing number?
    if ( lastNumberEntered != MAXFLOAT ) {
      [numbers removeObjectAtIndex:numberIndex];
      [numbers addObject:[NSNumber numberWithFloat:lastNumberEntered]];
    }
    else {
      [self addUndoState];
      [numbers removeObjectAtIndex:numberIndex];
    }
    
    lastNumberEntered = n;
    [self updateOutputByAppending:[NSString stringWithFormat:@" %.3g",
        lastNumberEntered]];
    [self makeNewButtons];
  }

  // Second number?
  if ( currentState == StateOperation ) {
    // Make sure no division by 0!!!
    if ( n == 0 && lastOperationEntered == OpDivide ) {
      return;
    }
    
    // Calculate result and commit it
    float result;
    
    switch( lastOperationEntered ) {
      case OpPlus:
        result = lastNumberEntered + n;
        break;
        
      case OpMinus:
        result = lastNumberEntered - n;
        break;
        
      case OpMultiply:
        result = lastNumberEntered * n;
        break;
        
      case OpDivide:
        result = lastNumberEntered / n;
        break;
    }
    
    // Update output
    [self addUndoState];
    [self commitOutputByAppending:[NSString stringWithFormat:@" %@ %.3g = %.3g\n",
        lastOperationString, n, result]];
    lastNumberEntered = MAXFLOAT;
    currentState = StateFirstNumber;

    [numbers removeObjectAtIndex:numberIndex];

    // Round over?
    if ( [numbers count] > 0 ) {
      [numbers addObject:[NSNumber numberWithFloat:result]];
    }
    else {
      // Correct?
      if ( result == 24 ) {
        NSDate *now = [NSDate date];
        [[TwentyFourAppDelegate getInstance] submitResultSuccess:
            [now timeIntervalSinceDate:startTime]];
        [self stopRound];
        
        buttonCorrect.hidden = NO;
        
        [self performSelector:@selector(switchToResultsScreen) withObject:nil
            afterDelay:3.0];
      }
      else {
        buttonIncorrect.hidden = NO;
      }
    }
    
    [self makeNewButtons];
  }
}

- (void)operationPressed:(id)sender {
  // Are we still playing?
  if ( currentState == StateRoundOver ) {
    return;
  }

  // We can't be entering second number, sorry
  if ( currentState == StateSecondNumber ) {
    return;
  }

  // Can't do if no numbers have been entered yet
  if ( currentState == StateFirstNumber && lastNumberEntered == MAXFLOAT ) {
    return;
  }

  if ( currentState == StateFirstNumber ) {
    [self addUndoState];
    [self commitOutputByAppending:[NSString stringWithFormat:@" %.3g",
        lastNumberEntered]];
    currentState = StateOperation;
  }

  if ( sender == buttonPlus ) {
    lastOperationEntered = OpPlus;
    self.lastOperationString = @" +";
  }
  else if ( sender == buttonMinus ) {
    lastOperationEntered = OpMinus;
    self.lastOperationString = @" -";
  }
  else if ( sender == buttonMultiply ) {
    lastOperationEntered = OpMultiply;
    self.lastOperationString = @" *";
  }
  else if ( sender == buttonDivide ) {
    lastOperationEntered = OpDivide;
    self.lastOperationString = @" /";
  }
  else {
    // Shouldn't be here
    return;
  }
  
  [self updateOutputByAppending:lastOperationString];
}

- (IBAction)undoPressed {
  // Are we still playing?
  if ( currentState == StateRoundOver ) {
    return;
  }

  // Do we have anything in the buffer?
  if ( [undoBuffer count] < 1 ) {
    return;
  }
  
  buttonCorrect.hidden = YES;
  buttonIncorrect.hidden = YES;
  
  NSArray *undoState = [undoBuffer lastObject];
  self.numbers = [undoState objectAtIndex:0];
  currentState = [[undoState objectAtIndex:1] intValue];
  lastNumberEntered = [[undoState objectAtIndex:2] floatValue];
  lastOperationEntered = [[undoState objectAtIndex:3] intValue];
  self.lastOperationString = [undoState objectAtIndex:4];
  self.committedOutput = [undoState objectAtIndex:5];
  labelOutput.text = [undoState objectAtIndex:6];
  
  // Done with it
  [undoBuffer removeLastObject];
  
  // Update UI
  [self makeNewButtons];
}

- (IBAction)giveUpPressed {
  // Are we still playing?
  if ( currentState == StateRoundOver ) {
    return;
  }

  [self stopRound];
  [[TwentyFourAppDelegate getInstance] submitResultFailure:@"Gave up!"];

  [self performSelector:@selector(switchToResultsScreen) withObject:nil
      afterDelay:0.5];
}

- (void)switchToResultsScreen {
  [[TwentyFourAppDelegate getInstance] showGameResultsScreen];
}

- (IBAction)correctPressed {
  [self switchToResultsScreen];
}

- (IBAction)incorrectPressed {
  buttonIncorrect.hidden = YES;
  [self undoPressed];
}

- (IBAction)exitPressed {
  [self stopRound];
  [[TwentyFourAppDelegate getInstance] exitGame];
}

- (void)dealloc {
  self.buttonPlus = nil;
  self.buttonMinus = nil;
  self.buttonMultiply = nil;
  self.buttonDivide = nil;

  self.buttonCorrect = nil;
  self.buttonIncorrect = nil;

  self.labelOutput = nil;
  self.labelTimer = nil;

  self.startTime = nil;
  [self.timerTimer invalidate];
  self.timerTimer = nil;

  [self.numberButtons makeObjectsPerformSelector:@selector(removeFromSuperview)];
  self.numberButtons = nil;
  self.undoBuffer = nil;
  self.numbers = nil;
  self.lastOperationString = nil;
  self.committedOutput = nil;

  [super dealloc];
}

@end
