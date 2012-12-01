// -------------------------------------------------------------------------- //
#ifndef __UNIXTIME_H__
#define __UNIXTIME_H__
// -------------------------------------------------------------------------- //
#include <sys/time.h>
// -------------------------------------------------------------------------- //
typedef struct timeval TIMEVALUE;
// -------------------------------------------------------------------------- //
TIMEVALUE GetTimeNow();
TIMEVALUE AddTime( TIMEVALUE a, TIMEVALUE b );
TIMEVALUE SubtractTime( TIMEVALUE a, TIMEVALUE b );

void SetFramesPerSecond( const int Ticks );
int GetFrames( TIMEVALUE* tv );
void AddFrame( TIMEVALUE* tv );
void ResetTime();
// -------------------------------------------------------------------------- //
#endif // __UNIXTIME_H__ //
// -------------------------------------------------------------------------- //
