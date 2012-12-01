//
//  TwentyFourViewController.h
//  TwentyFour
//
//  Created by Peter Bakhyryev on 8/6/09.
//  Copyright ByteClub LLC 2009. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TwentyFourViewController : UIViewController {
  UIButton *buttonPlus;
  UIButton *buttonMinus;
  UIButton *buttonMultiply;
  UIButton *buttonDivide;
  
  UIButton *buttonCorrect;
  UIButton *buttonIncorrect;
  
  UILabel *labelOutput;
  UILabel *labelTimer;
  
  NSMutableArray *numberButtons;
  NSMutableArray *undoBuffer;

  NSDate *startTime;
  NSTimer *timerTimer;
  float timeForRound;

  NSMutableArray *numbers;
  int currentState;
  float lastNumberEntered;
  int lastOperationEntered;
  NSString *lastOperationString;
  NSString *committedOutput;
}

@property (nonatomic, retain) IBOutlet UIButton *buttonPlus;
@property (nonatomic, retain) IBOutlet UIButton *buttonMinus;
@property (nonatomic, retain) IBOutlet UIButton *buttonMultiply;
@property (nonatomic, retain) IBOutlet UIButton *buttonDivide;

@property (nonatomic, retain) IBOutlet UIButton *buttonCorrect;
@property (nonatomic, retain) IBOutlet UIButton *buttonIncorrect;

@property (nonatomic, retain) IBOutlet UILabel *labelOutput;
@property (nonatomic, retain) IBOutlet UILabel *labelTimer;

@property (nonatomic, retain) NSDate *startTime;
@property (nonatomic, retain) NSTimer *timerTimer;

@property (nonatomic, retain) NSMutableArray *numberButtons;
@property (nonatomic, retain) NSMutableArray *undoBuffer;
@property (nonatomic, retain) NSMutableArray *numbers;
@property (nonatomic, retain) NSString *lastOperationString;
@property (nonatomic, retain) NSString *committedOutput;

- (IBAction)operationPressed:(id)sender;
- (IBAction)giveUpPressed;
- (IBAction)undoPressed;
- (IBAction)correctPressed;
- (IBAction)incorrectPressed;
- (IBAction)exitPressed;
- (void)startRoundWithChallenge:(NSArray*)challenge secondsToPlay:(float)seconds;
- (void)stopRound;

@end

