// -------------------------------------------------------------------------- //
#ifndef __WINDOWSTIME_H__
#define __WINDOWSTIME_H__
// -------------------------------------------------------------------------- //
typedef int TIMEVALUE;
// -------------------------------------------------------------------------- //
TIMEVALUE GetTimeNow();
TIMEVALUE AddTime( TIMEVALUE a, TIMEVALUE b );
TIMEVALUE SubtractTime( TIMEVALUE a, TIMEVALUE b );

void SetFramesPerSecond( const int Ticks );
int GetFrames( TIMEVALUE* tv );
void AddFrame( TIMEVALUE* tv );
void ResetTime();
// -------------------------------------------------------------------------- //
#endif // __WINDOWSTIME_H__ //
// -------------------------------------------------------------------------- //
