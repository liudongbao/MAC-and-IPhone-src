// this is the config file
// it holds all the constants and other various and sundry items that
// we need and dont want to hardcode in the code


#define RANDOM_SEED() srandom(time(NULL))
#define RANDOM_INT(__MIN__, __MAX__) ((__MIN__) + random() % ((__MAX__+1) - (__MIN__)))

// will draw the circles around the collision radius
// for debugging
#define DEBUG_DRAW_COLLIDERS 0

// the explosive force applied to the smaller rocks after a big rock has been smashed
#define SMASH_SPEED_FACTOR 40

#define TURN_SPEED_FACTOR 3.0
#define THRUST_SPEED_FACTOR 1.2

// a handy constant to keep around
#define BBRADIANS_TO_DEGREES 57.2958

// material import settings
#define BB_CONVERT_TO_4444 0


// for particles
#define BB_MAX_PARTICLES 100

#define BB_FPS 30.0

// Laser1.wav
#define LASER1 @"laser1"

// explosion1.wav
#define EXPLOSION1 @"explosion1"

// explosion2.wav
#define EXPLOSION2 @"explosion2"

// explosion3.wav
#define EXPLOSION3 @"explosion3"

// thrust1.wav
#define THRUST1 @"thrust1"

// UFO
#define UFO_ENGINE @"UFO_engine"

// UFO missile
// Originally from Tow Missile Launch from
// http://www.freesound.org/samplesViewSingle.php?id=67541
// under public domain, but modified by me (EW).
#define UFO_MISSILE @"missile_launch"

// Music by Michael Shaieb
// © Copyright 2009 FatLab Music
// From "Snowferno" for iPhone/iPod Touch
#define BACKGROUND_MUSIC @"D-ay-Z-ray_mix_090502"
//#define BACKGROUND_MUSIC @"The Mist 090521"

// annoying game over speech
#define GAME_OVER_SPEECH @"gameover"
