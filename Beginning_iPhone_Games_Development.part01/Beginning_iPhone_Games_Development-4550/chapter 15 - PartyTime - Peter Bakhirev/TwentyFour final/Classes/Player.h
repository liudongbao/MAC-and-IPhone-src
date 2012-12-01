//
//  Player.h
//  TwentyFour
//

#import <Foundation/Foundation.h>


@interface Player : NSObject {
  NSString *name;
  NSString *status;
  float lastResult;
  BOOL isPlaying;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *status;
@property (nonatomic, assign) float lastResult;
@property (nonatomic, assign) BOOL isPlaying;

- (void)startPlayingWithStatus:(NSString*)status;
- (void)setDidntAnswerLastRound;
- (BOOL)didAnswerLastRound;
- (NSComparisonResult)compare:(Player*)anotherPlayer;
- (NSString*)describeResult;

@end
