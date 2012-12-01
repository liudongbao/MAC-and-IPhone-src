//
//  Player.m
//  TwentyFour
//

#import "Player.h"

@implementation Player

@synthesize name, status, lastResult, isPlaying;

- (void)startPlayingWithStatus:(NSString*)s {
  self.status = s;
  lastResult = MAXFLOAT;
  isPlaying = YES;
}

- (void)setDidntAnswerLastRound {
  lastResult = MAXFLOAT;
}

- (BOOL)didAnswerLastRound {
  return (lastResult != MAXFLOAT);
}

- (NSComparisonResult)compare:(Player*)anotherPlayer {
  if ( ![self didAnswerLastRound] && [anotherPlayer didAnswerLastRound] ) {
    return NSOrderedDescending;
  }
  else if ( [self didAnswerLastRound] && ![anotherPlayer didAnswerLastRound] ) {
    return NSOrderedAscending;
  }
  else if ( ![self didAnswerLastRound] && ![anotherPlayer didAnswerLastRound] ) {
    return [name localizedCaseInsensitiveCompare:anotherPlayer.name];
  }
  else {
    if ( lastResult > anotherPlayer.lastResult ) {
      return NSOrderedDescending;
    }
    else if ( lastResult < anotherPlayer.lastResult ) {
      return NSOrderedAscending;
    }
    else {
      return NSOrderedSame;
    }
  }
}

- (NSString*)describeResult {
  if ( lastResult != MAXFLOAT ) {
    return [NSString stringWithFormat:@"%@: %.2f seconds", name, lastResult];
  }
  else {
    return [NSString stringWithFormat:@"%@: %@", name, status];
  }
}

- (void)dealloc {
  self.name = nil;
  self.status = nil;

  [super dealloc];
}

@end
