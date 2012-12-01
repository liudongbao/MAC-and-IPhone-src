//
//  SpaceHikeAppDelegate.h
//  SpaceHike
//
//  Created by AaronF on 14/12/2008.
//  Copyright Strange Flavour Ltd 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

#define FPS 30
// handy value to convert degrees to radians
#define RAD_DEGREE 0.01745


enum {
	SPR_VIEWSCREEN = 0,
	SPR_LONGRANGESCREEN,
	SPR_COMBATSCREEN,
	SPR_COMBATLASERS,
	SPR_COMBATMISSILES,
	SPR_COMBATWON,
	SPR_COMBATWHOOP,
	SPR_STARBASE1,
	SPR_STARBASE2,
	SPR_COLONY1,
	SPR_COLONY2,
	SPR_WIN,
	SPR_LOST,
	SPR_OUTOFPOWER,
	SPR_OUTOFSNACKS,
	SPR_STATS,
	SPR_STATS2,
	SPR_BUTTONS,
	SPR_BUTTON0,
	SPR_BUTTON1,
	SPR_BUTTON2,
	SPR_BUTTON3,
	SPR_BUTTON4,
	SPR_BUTTON5,
	SPR_BUTTON6,
	SPR_BUTTON7,
	SPR_ICONS,
	SPR_ICON0,
	SPR_ICON1,
	SPR_ICON2,
	SPR_ICON3,
	SPR_DIGITS,
	SPR_DIGITS0,
	SPR_DIGITS1,
	SPR_DIGITS2,
	SPR_DIGITS3,
	SPR_DIGITS4,
	SPR_DIGITS5,
	SPR_DIGITS6,
	SPR_DIGITS7,
	SPR_DIGITS8,
	SPR_DIGITS9,
	
	};

enum {
	MODE_MAP = 0,
	MODE_BATTLE,
	MODE_ALERT
};


#define MAP_BASE		2
#define MAP_COLONY		3
#define MAP_EMPTYBASE	6
#define MAP_EMPTYCOLONY	7

#define GO_DEFEATED		1
#define	GO_OUTOFSNACKS	2
#define	GO_OUTOFPOWER	3
#define	GO_WON			4

#define NUM_MINGONS	30
#define	NUM_COLONIES 8
#define NUM_BASES 3
#define NUM_PLANETS	5

#define COMBAT_LASERS	1
#define COMBAT_MISSILES	2
#define COMBAT_WON		3
#define COMBAT_WHOOP	4

#define MAP_SIZE 25

typedef struct {
	int x;
	int y;
	int armour;
} evilspacealien_type;

typedef struct {
	int x;
	int y;
	int used;
	int sprite;
} colony_type;

typedef struct
	{
		int check; 
		int gameactive;
		int mode;
		int alert;
		int scanactive;
		colony_type colonies[NUM_COLONIES];
		evilspacealien_type mingons[NUM_MINGONS];
		int snacks;
		int batteries;
		int armour;
		int missiles;
		int locationx;
		int locationy;
		
	} savegame_type;



extern savegame_type gSaveGame;
extern int gCombatPage;
extern int gGameOver;

int rnd(int a);
int min(int a,int b);
int max(int a,int b);
void CheckNewLocation(void);

void DrawMap(int locx,int locy);
void InitGame();
void ResumeGame();
void StashGame();

@class EAGLView;

@interface SpaceHikeAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    EAGLView *glView;
	NSTimer*				mTimer;   // Rendering Timer

}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet EAGLView *glView;

-(void)renderScene;
-(void)LoadPrefs;
-(void)SavePrefs;

@end

