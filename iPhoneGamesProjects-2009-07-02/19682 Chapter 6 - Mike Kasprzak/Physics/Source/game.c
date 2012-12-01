// -------------------------------------------------------------------------- //
#include <math.h>
#include "Graphics.h"
#include "game.h"
// -------------------------------------------------------------------------- //

// -------------------------------------------------------------------------- //
typedef struct {
	Vector2D Pos, Old;
	float Radius;
} tBall;

#define BALL_X 10
#define BALL_Y 10
#define BALL_MAX (BALL_X * BALL_Y)

tBall Ball[BALL_MAX];

int SelectedBall;
Vector2D SelectedOffset;

Vector2D GravityVector;
// -------------------------------------------------------------------------- //

// -------------------------------------------------------------------------- //
void InitBallPhysics() {
	int x, y;
	int Offset = 0;
	
	// Populate our Balls list //
	for ( y = 0; y < BALL_Y; y++ ) {
		for ( x = 0; x < BALL_X; x++ ) {
			int idx = x + (y * BALL_X);
			
			Ball[idx].Pos.x = ((x-(BALL_X>>1)) * 32) + 16 + Offset - 4;
			Ball[idx].Pos.y = ((y-(BALL_Y>>1)) * 32) + 16;

			Ball[idx].Old.x = Ball[idx].Pos.x;
			Ball[idx].Old.y = Ball[idx].Pos.y;
			
			Ball[idx].Radius = 10 + Offset;
			
			Offset++;
			Offset &= 7;
		}
	}
}
// -------------------------------------------------------------------------- //
void StepBallPhysics() {
	int idx, idx2;
	
	// Move Balls (Verlet physics simulation) //
	for ( idx = 0; idx < BALL_MAX; idx++ ) {
		float Velocity_x = Ball[idx].Pos.x - Ball[idx].Old.x;
		float Velocity_y = Ball[idx].Pos.y - Ball[idx].Old.y;
		
		Ball[idx].Old.x = Ball[idx].Pos.x;
		Ball[idx].Old.y = Ball[idx].Pos.y;
		
		Ball[idx].Pos.x += Velocity_x * 0.99f + GravityVector.x;
		Ball[idx].Pos.y += Velocity_y * 0.99f + GravityVector.y;
	}
	
	// Solve collisions between balls //
	for ( idx = 0; idx < BALL_MAX; idx++ ) {
		for ( idx2 = idx+1; idx2 < BALL_MAX; idx2++ ) {
			float Line_x = Ball[idx2].Pos.x - Ball[idx].Pos.x;
			float Line_y = Ball[idx2].Pos.y - Ball[idx].Pos.y;
			
			float Magnitude = sqrt( (Line_x * Line_x) + (Line_y * Line_y) );
//			float Magnitude = fabs(Line_x) + fabs(Line_y);
			
			if ( Magnitude <= 0.0f )
				continue;
			
			Line_x /= Magnitude;
			Line_y /= Magnitude;
			
			float RadiusSum = Ball[idx2].Radius + Ball[idx].Radius;
			
			float Diff = Magnitude - RadiusSum;
			
			if ( Diff < 0.0f ) {
				Ball[idx].Pos.x += Diff * Line_x * 0.5f;
				Ball[idx].Pos.y += Diff * Line_y * 0.5f;
				
				Ball[idx2].Pos.x -= Diff * Line_x * 0.5f;
				Ball[idx2].Pos.y -= Diff * Line_y * 0.5f;
			}	
		}
	}
	
	// Constrain Balls to Walls //
	for ( idx = 0; idx < BALL_MAX; idx++ ) {
		if ( Ball[idx].Pos.x - Ball[idx].Radius < -160.0f )
			Ball[idx].Pos.x = -160.0f + Ball[idx].Radius;
			
		if ( Ball[idx].Pos.y - Ball[idx].Radius < -240.0f )
			Ball[idx].Pos.y = -240.0f + Ball[idx].Radius;

		if ( Ball[idx].Pos.x + Ball[idx].Radius > 160.0f )
			Ball[idx].Pos.x = 160.0f - Ball[idx].Radius;
			
		if ( Ball[idx].Pos.y + Ball[idx].Radius > 240.0f )
			Ball[idx].Pos.y = 240.0f - Ball[idx].Radius;
	}
}
// -------------------------------------------------------------------------- //
void DoInput() {
    // Tilting //
    GravityVector.x = 0.1f * Orientation.x;
    GravityVector.y = 0.1f * Orientation.y;

    // Grabbing //
    if ( TouchIsDown() ) {
        int idx;
        
        for ( idx = 0; idx < BALL_MAX; idx++ ) {
            float Line_x = TouchPos.x - Ball[idx].Pos.x;
            float Line_y = TouchPos.y - Ball[idx].Pos.y;
            
            float MagnitudeSquared = (Line_x * Line_x) + (Line_y * Line_y);
            
            if ( (Ball[idx].Radius * Ball[idx].Radius) > MagnitudeSquared ) {
                SelectedBall = idx;
                
                SelectedOffset.x = Ball[idx].Pos.x - TouchPos.x;
                SelectedOffset.y = Ball[idx].Pos.y - TouchPos.y;
            
                break;    
            }
        }
    }
    if ( TouchIsUp() ) { 
        SelectedBall = -1;
    }
    
    if ( SelectedBall != -1 ) {
        Ball[SelectedBall].Pos.x +=
        	((TouchPos.x + SelectedOffset.x) - Ball[SelectedBall].Pos.x) * 0.15f;
        Ball[SelectedBall].Pos.y +=
        	((TouchPos.y + SelectedOffset.y) - Ball[SelectedBall].Pos.y) * 0.15f;
    }
}
// -------------------------------------------------------------------------- //
void DrawBalls() {
	int idx;
	
	for ( idx = 0; idx < BALL_MAX; idx++ ) {
		DrawBall( Ball[idx].Pos.x, Ball[idx].Pos.y, Ball[idx].Radius );
	}
}
// -------------------------------------------------------------------------- //

// -------------------------------------------------------------------------- //
void Game_Initialize() {
	InitGraphics();
	LoadBallGraphic();
	
	InitBallPhysics();
	SelectedBall = -1;
}
// -------------------------------------------------------------------------- //
void Game_Exit() {
    FreeBallGraphic();
}
// -------------------------------------------------------------------------- //
void Game_Work() {
    DoInput();
    StepBallPhysics();
}
// -------------------------------------------------------------------------- //
void Game_Draw() {
	ClearBackground();
	
    DrawBalls();
    
    DrawArrow();
}
// -------------------------------------------------------------------------- //
