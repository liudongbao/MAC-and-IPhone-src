// - ------------------------------------------------------------------------------------------ - //
#include <SDL/SDL.h>
#include <math.h>
// ---------------------------------------------------------------------------------------------- //
#include <GL/gl.h>
#include <GL/glu.h>
#include <GL/glext.h>
// - ------------------------------------------------------------------------------------------ - //
#include "game.h"
// - ------------------------------------------------------------------------------------------ - //
#ifdef WINDOWS_BUILD
#include "WindowsTime.h"
#else
#include "UnixTime.h"
#endif // WINDOWS_BUILD //
// - ------------------------------------------------------------------------------------------ - //

// - ------------------------------------------------------------------------------------------ - //
// Implementation Specific Variables //
// - ------------------------------------------------------------------------------------------ - //
extern int ScreenWidth;
extern int ScreenHeight;
extern int ScreenScalar;
int ScreenWidth;
int ScreenHeight;
int ScreenScalar;

int CloseButtonPressed;
SDL_Surface* Buffer;
int MouseWheel;
#define PI 3.1415926535897932384626433832795f
// - ------------------------------------------------------------------------------------------ - //

// - ------------------------------------------------------------------------------------------ - //
// Common variables, defined here because they're used here //
// - ------------------------------------------------------------------------------------------ - //
Vector2D TouchPos;
Vector2D Orientation;

int TouchOldValue;
int TouchValue;
// - ------------------------------------------------------------------------------------------ - //
TIMEVALUE WorkTime;
// - ------------------------------------------------------------------------------------------ - //

// - ------------------------------------------------------------------------------------------ - //
// Familiar Functions //
// - ------------------------------------------------------------------------------------------ - //
void Update_Input() {
	int x, y;
	int Button = SDL_GetMouseState( &x, &y );

	TouchPos.x = ((x / ScreenScalar) - (ScreenWidth>>1));
	TouchPos.y = ((y / ScreenScalar) - (ScreenHeight>>1));

	TouchOldValue = TouchValue;
	TouchValue = Button;
	
	float Angle = ((float)MouseWheel * 0.05f);
	Orientation.x = -sin( Angle * 2.0f * PI );
	Orientation.y = cos( Angle * 2.0f * PI );
}
// - ------------------------------------------------------------------------------------------ - //

// - ------------------------------------------------------------------------------------------ - //
int TouchChanged() {
	return (TouchValue ^ TouchOldValue);
}
// - ------------------------------------------------------------------------------------------ - //
int TouchIsDown() {
	return (TouchValue ^ TouchOldValue) & TouchValue;
}
// - ------------------------------------------------------------------------------------------ - //
int TouchIsUp() {
	return (TouchValue ^ TouchOldValue) & TouchOldValue;
}
// - ------------------------------------------------------------------------------------------ - //
int Touching() {
	return TouchValue;
}
// - ------------------------------------------------------------------------------------------ - //


// - ------------------------------------------------------------------------------------------ - //
// One way SDL can cooperate with an event driven operating system //
// - ------------------------------------------------------------------------------------------ - //
void PollEvents() {
	int IsActive = 1;
	
	SDL_Event event;
    while ( SDL_PollEvent( &event ) ) {
	    switch( event.type ) {
			case SDL_ACTIVEEVENT: {
				IsActive = event.active.gain != 0;
		    	
		    	break;
		    }
		    case SDL_KEYDOWN: {
			    switch(event.key.keysym.sym){
			    	case SDLK_ESCAPE: {
			    		CloseButtonPressed = 1;
			    		break;
					}
					
					case SDLK_LEFT: {
						MouseWheel--;
						if ( MouseWheel < 0 )
	    					MouseWheel = 19;
						break;	
					}
					
					case SDLK_RIGHT: {
		    			MouseWheel++;
		    			if ( MouseWheel > 19 )
		    				MouseWheel = 0;
		    			break;
					}
			    }
			    break;
			}
	    	case SDL_MOUSEBUTTONDOWN: {
	    		if ( event.button.button == 4 ) {
	    			MouseWheel--;
	    			if ( MouseWheel < 0 )
	    				MouseWheel = 19;
	    		}
	    		else if ( event.button.button == 5 ) {
	    			MouseWheel++;
	    			if ( MouseWheel > 19 )
	    				MouseWheel = 0;
	    		}
	    		
	    		break;
	    	}

		case SDL_QUIT:
			CloseButtonPressed = 1;
		    break;

		default:
		    break;
		}
	}
	
}
// - ------------------------------------------------------------------------------------------ - //

// - ------------------------------------------------------------------------------------------ - //
int main( int argc, char* argv[] ) {
	// Initialize SDL with Video Support //
	SDL_Init( SDL_INIT_VIDEO );
	
	// Set system dimensions //
	ScreenWidth = 320;
	ScreenHeight = 480;
	
	ScreenScalar = 2;

	{
		// Get information about our video hardware //    
		const SDL_VideoInfo* VideoInfo = SDL_GetVideoInfo();
		
		// In the incredibly unlikely case that we have no video hardware... //  
		if ( VideoInfo ) {
			// Construct our list of SDL video options //
			int VideoFlags = SDL_OPENGL | SDL_GL_DOUBLEBUFFER | SDL_HWPALETTE; 
			
//			VideoFlags |= SDL_RESIZABLE;
//			VideoFlags |= SDL_FULLSCREEN;
			
			// Depeding on if our hardware supports a hardware framebuffer //
		    if ( VideoInfo->hw_available )
				VideoFlags |= SDL_HWSURFACE;
		    else
				VideoFlags |= SDL_SWSURFACE;

			// Hardware blitting support (a good thing) //
		    if ( VideoInfo->blit_hw )
				VideoFlags |= SDL_HWACCEL;

			int ColorDepth = 32;
			
			// Pre window creation GL Attributes //
			SDL_GL_SetAttribute( SDL_GL_RED_SIZE, 8 );
			SDL_GL_SetAttribute( SDL_GL_GREEN_SIZE, 8 );
			SDL_GL_SetAttribute( SDL_GL_BLUE_SIZE, 8 );
			SDL_GL_SetAttribute( SDL_GL_ALPHA_SIZE, 8 );
		
			SDL_WM_SetCaption( "Physics Sample", NULL );
			
			// Create our Screen //
			Buffer = SDL_SetVideoMode( 
				ScreenWidth * ScreenScalar, 
				ScreenHeight * ScreenScalar,
				ColorDepth, 
				VideoFlags
				);	
		}
	}
	
	CloseButtonPressed = 0;
	MouseWheel = 0;

	// - Game Loop ---------------------------------------------------------- //
	Game_Initialize();

	SetFramesPerSecond( 60 );
	WorkTime = GetTimeNow();

	while( !CloseButtonPressed ) {	
		TIMEVALUE TimeDiff = SubtractTime( GetTimeNow(), WorkTime );
		int WorkFrames = GetFrames( &TimeDiff );

		while ( WorkFrames-- ) {
			PollEvents();
			Update_Input();
			Game_Work();
			AddFrame( &WorkTime );
		}
				
		Game_Draw();
		SDL_GL_SwapBuffers();
	}
	
	Game_Exit();
	// ---------------------------------------------------------------------- //
	
	SDL_FreeSurface( Buffer );
	
	SDL_Quit();
	return 0;
}
// - ---------------------------------------------------------------------- - //

