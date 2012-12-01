// -------------------------------------------------------------------------- //
#include "UnixTime.h"
// -------------------------------------------------------------------------- //
int FrameRateConstant;
TIMEVALUE OneFrameConstant;
// -------------------------------------------------------------------------- //

// -------------------------------------------------------------------------- //
TIMEVALUE GetTimeNow() {
	TIMEVALUE tv;
	gettimeofday( &tv, 0 );
	return tv;
}
// -------------------------------------------------------------------------- //

// -------------------------------------------------------------------------- //
TIMEVALUE AddTime( TIMEVALUE a, TIMEVALUE b ) {
	TIMEVALUE tv;
	tv.tv_usec = a.tv_usec + b.tv_usec;
	tv.tv_sec = a.tv_sec + b.tv_sec + (tv.tv_usec / 1000000);
	tv.tv_usec %= 1000000;
	return tv;
}
// -------------------------------------------------------------------------- //
TIMEVALUE SubtractTime( TIMEVALUE a, TIMEVALUE b ) {
	TIMEVALUE tv;
	tv.tv_usec = a.tv_usec - b.tv_usec;
	tv.tv_sec = a.tv_sec - b.tv_sec + (tv.tv_usec / 1000000);
	tv.tv_usec %= 1000000;
	return tv;
}
// -------------------------------------------------------------------------- //

// -------------------------------------------------------------------------- //
int GetFrames( TIMEVALUE* tv ) {
	return (tv->tv_sec * FrameRateConstant) +
		(tv->tv_usec / OneFrameConstant.tv_usec);
}
// -------------------------------------------------------------------------- //
void AddFrame( TIMEVALUE* tv ) {
	*tv = AddTime( *tv, OneFrameConstant );
}
// -------------------------------------------------------------------------- //
void SetFramesPerSecond( const int Ticks ) {
	FrameRateConstant = Ticks;
	OneFrameConstant.tv_sec = 0;
	OneFrameConstant.tv_usec = (1000000 / Ticks);
}
// -------------------------------------------------------------------------- //
