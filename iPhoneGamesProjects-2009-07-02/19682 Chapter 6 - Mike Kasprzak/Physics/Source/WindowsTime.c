// -------------------------------------------------------------------------- //
#include <windows.h>
#include "WindowsTime.h"
// -------------------------------------------------------------------------- //
int FrameRateConstant;
TIMEVALUE OneFrameConstant;
// -------------------------------------------------------------------------- //

// -------------------------------------------------------------------------- //
TIMEVALUE GetTimeNow() {
	return timeGetTime();
}
// -------------------------------------------------------------------------- //

// -------------------------------------------------------------------------- //
TIMEVALUE AddTime( TIMEVALUE a, TIMEVALUE b ) {
	return a + b;
}
// -------------------------------------------------------------------------- //
TIMEVALUE SubtractTime( TIMEVALUE a, TIMEVALUE b ) {
	return a - b;
}
// -------------------------------------------------------------------------- //

// -------------------------------------------------------------------------- //
int GetFrames( TIMEVALUE* tv ) {
	return *tv / OneFrameConstant;
}
// -------------------------------------------------------------------------- //
void AddFrame( TIMEVALUE* tv ) {
	*tv = AddTime( *tv, OneFrameConstant );
}
// -------------------------------------------------------------------------- //
void SetFramesPerSecond( const int Ticks ) {
	FrameRateConstant = Ticks;
	OneFrameConstant = (1000 / Ticks);
}
// -------------------------------------------------------------------------- //
