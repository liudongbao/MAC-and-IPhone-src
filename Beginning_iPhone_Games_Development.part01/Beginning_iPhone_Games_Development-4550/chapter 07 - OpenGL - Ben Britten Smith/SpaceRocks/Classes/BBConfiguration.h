// this is the config file
// it holds all the constants and other various and sundry items that
// we need and dont want to hardcode in the code


#define RANDOM_SEED() srandom(time(NULL))
#define RANDOM_INT(__MIN__, __MAX__) ((__MIN__) + random() % ((__MAX__+1) - (__MIN__)))

// will draw the circles around the collision radius
// for debugging
#define DEBUG_DRAW_COLLIDERS 0

// the explosive force applied to the smaller rocks after a big rock has been smashed
#define SMASH_SPEED_FACTOR 0.75

#define TURN_SPEED_FACTOR 3.0
#define THRUST_SPEED_FACTOR 0.02

// a handy constant to keep around
#define BBRADIANS_TO_DEGREES 57.2958