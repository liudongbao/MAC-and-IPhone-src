//
//  SpaceHikeAppDelegate.m
//  SpaceHike
//
//  Created by AaronF on 14/12/2008.
//  Copyright Strange Flavour Ltd 2008. All rights reserved.
//

#import "SpaceHikeAppDelegate.h"
#import "EAGLView.h"
#import "Texture2D.h"

int gLocationX,gLocationY; // your ship's current location
int gDestinationX,gDestinationY; // desired destination
int gGameMode; // current game mode

evilspacealien_type gMingon[NUM_MINGONS];
colony_type gColony[NUM_COLONIES];
int gMingonCount;

int gArmour;
int gBatteries;
int gMissiles;
int gSnacks;
int gScanActive;
float gPulse;
int gAlert;
int gAttacker;
int gGameOver;
int gCombatPage;
int gShipPulse;

savegame_type gSaveGame;
int gResetStats;

@implementation SpaceHikeAppDelegate

@synthesize window;
@synthesize glView;


// some basic functions that we could include from elsewhere, but are easier to have our own versions of

// rnd(n) returns random number range 0 - (n-1)
int rnd(int a)
{
	
	return rand() % a;
}

// min(a,b) returns minimum of 2 values
int min(int a,int b)
{
	if(a < b)
		return a;
	return b;
}

// max(a,b) returns the maximum of 2 values

int max(int a,int b)
{
	if(a > b)
		return a;
	return b;
}

// sgn(n) returns the sign (-1, 0 or 1) of a value
int sgn(int a)
{
	if(a < 0)
		return -1;
	if(a > 0)
		return 1;
	return 0;
}

// CheckNewLocation : checks the map square we've landed on to see what's there and deal with it.

void CheckNewLocation(void)
{
	int a;
	int dx,dy;
	int f;
	// check to see if we've landed on a colony
	f = 0; // if f is still 0 at the end of this loop, we didn't land anywhere that had its own snacks
	for(a = 0; a < NUM_COLONIES;a++)
	{
		if(gColony[a].x == gLocationX && gColony[a].y == gLocationY)
		{
			// we're on a colony or base
			if(gColony[a].used == 0) // not landed here before, so resupply
			{
				f = 1; // set to indicate we've landed somewhere so don't need to eat snacks
				gGameMode = MODE_ALERT;
				
				gColony[a].used = 1; // set it as used
				
				if(gColony[a].sprite == SPR_ICON0 + MAP_BASE) // space base
				{
					gAlert = SPR_STARBASE1;
					gBatteries = 100;
					gSnacks = min(20,gSnacks + 2);
					gMissiles = 10;
				}
				else // colony planet
				{
					gAlert = SPR_COLONY1;
					gBatteries = min(100,gBatteries + 50);
					gSnacks = min(20,gSnacks + 5);
					gMissiles = min(10,gMissiles + 2);
				}
					
			}
			else
			{
				// already landed here before, so don't resupply
				gGameMode = MODE_ALERT;
				if(gColony[a].sprite == SPR_ICON0 + MAP_BASE) // space base
				{
					gAlert = SPR_STARBASE2;
				}
				else  // colony planet
				{
					gAlert = SPR_COLONY2;
				}
				
				
			}
		}
	}

	if(f == 0)
	{
		gSnacks--;
		if(gSnacks <= 0)
		{
		
			gGameOver = GO_OUTOFSNACKS;
		}
	}
	
	
	// move some of the mingon ships
	for(a = 0; a < NUM_MINGONS;a++)
	{
		if(gMingon[a].armour > 0)
		{
			
			if(rnd(10) < 3)
			{
				// move Mingon a bit closer to the Expendible
				if(gMingon[a].x != gLocationX && (rnd(10) < 5 || gMingon[a].y == gLocationY))
				{
					dx = sgn(gLocationX - gMingon[a].x);
					if(abs(gMingon[a].x - gLocationX) > 12)
						dx = -dx;
					gMingon[a].x = (gMingon[a].x + dx + MAP_SIZE) % MAP_SIZE;
					
				}
				else
				{
					dy = sgn(gLocationY - gMingon[a].y);
					if(abs(gMingon[a].y - gLocationY) > 12)
						dy = -dy;
					gMingon[a].y = (gMingon[a].y + dy + MAP_SIZE) % MAP_SIZE;
				}
			}
			
		}
	}
	
	// check for landing on mingon ships
	gMingonCount = 0;
	for(a = 0; a < NUM_MINGONS;a++)
	{
		if(gMingon[a].armour > 0)
		{
			gMingonCount++;
			if(gMingon[a].x == gLocationX && gMingon[a].y == gLocationY)
			{
				gAttacker = a;
				gGameMode = MODE_BATTLE;
				return;
			}
		
		}
	}
	if(gMingonCount == 0)
	{
		gGameOver = GO_WON;
	}
	
}

// DrawMap(int locx,int locy) : Draws the current viewscreen (9x9 squares) area of the map

void DrawMap(int locx,int locy)
{
	int a;
	int x,y;
	
	// update map icons
	
	// draw the colony planets and space stations
	for(a = 0; a < NUM_COLONIES;a++)
	{
		x = gColony[a].x - locx;
		y = gColony[a].y - locy;
		
		if(abs(x) < 5 && abs(y)< 5) // check to see if colony is within the current scan area
		{
			
			if(gColony[a].used == 1) // if colony has been used to restock, draw it shaded
			{
				glColor4f(0.5,0.5,0.5,1);
			}
			else
			{
				glColor4f(1,1,1,1);
			}
			DrawSpriteAt(gColony[a].sprite, x * 32,80 - y * 32);
			
		}
	}
	
	// draw Mingons
	glColor4f(1,1,1,1);
	for(a = 0; a < NUM_MINGONS;a++)
	{
		if(gMingon[a].armour > 0)  // if <=0 it's been destroyed
		{
			
			x = gMingon[a].x - locx;
			y = gMingon[a].y - locy;
			if(abs(x) < 5 && abs(y)< 5)
			{
				DrawSpriteAt(SPR_ICON1,x * 32, 80 - y * 32);
			}
		}
	}
	
	// draw the Expendible in the centre
	
	DrawSpriteAt(SPR_ICON0,0,80);
	
	
}

// DrawScannedMap(int locx,int locy) : draw a long range scan of the whole map, with Expendible in the centre

void DrawScannedMap(int locx,int locy)
{
	float tilesize;
	float spritesize;
	int a;
	int x,y;
	
	spritesize = 9.0 / MAP_SIZE;
	
	tilesize = 288.0 / MAP_SIZE; // based on view screen being 288x288
	
	// draw the colony planets and space stations
	for(a = 0; a < NUM_COLONIES;a++)
	{
		x = gColony[a].x ;
		y = gColony[a].y;
		
		if(gColony[a].used == 1) // if colony has been used to restock, draw it shaded
		{
			glColor4f(0.5,0.5,0.5,1);
		}
		else
		{
			glColor4f(1,1,1,1);
		}
		DrawSpriteScaledAt(gColony[a].sprite, x * tilesize - MAP_SIZE / 2 * tilesize,80 - y * tilesize + MAP_SIZE / 2 * tilesize ,spritesize,spritesize);
		
	}
	
	// draw Mingons
	glColor4f(1,1,1,1);
	for(a = 0; a < NUM_MINGONS;a++)
	{
	
		if(gMingon[a].armour > 0)
		{
			x = gMingon[a].x ;
			y = gMingon[a].y ;
		
			DrawSpriteScaledAt(SPR_ICON1,x * tilesize -  MAP_SIZE / 2 * tilesize, 80 - y * tilesize + MAP_SIZE / 2 * tilesize,spritesize,spritesize);
		}
	}
	
	// draw the Expendible in the centre, pulse its scale so we can see it :)
	
	spritesize = (9.0 / MAP_SIZE) * (sin(gShipPulse * RAD_DEGREE) * 0.2 + 0.8);

	DrawSpriteScaledAt(SPR_ICON0,locx * tilesize - MAP_SIZE / 2 * tilesize,80 - locy * tilesize + MAP_SIZE / 2 * tilesize,spritesize,spritesize);
	
	gShipPulse = fmod(gShipPulse + 16.0f,360.0f);
	
}

// InitGame()  : Initialises a new game, sets up map, resets supplies etc.

void InitGame()
{
	int x,y;
	int a;
	int map[MAP_SIZE][MAP_SIZE];
	
	gGameOver = 0;
	gGameMode = MODE_MAP;
	// set Expendable's location to 12,12
	gLocationX = 12;
	gLocationY = 12;
	gDestinationX = 12;
	gDestinationY = 12;
	
	// set full armour, missiles and snacks
	gMissiles = 10;
	gBatteries = 100;
	gSnacks = 20;
	gArmour = 100;
	// clear the map array. we use this to tag where we've placed items so we don't place 2 on one space
	for(x = 0; x < MAP_SIZE;x++)
	{
		for(y = 0;y< MAP_SIZE;y++)
		{
			map[x][y] = 0;
		}
	}
	// place 3 bases
	
	for(a = 0; a < NUM_BASES;a++)
	{
		x = rnd(MAP_SIZE);
		y = rnd(MAP_SIZE);
		while((x == 0 && y == 0) || map[x][y] != 0)
		{
			x =	rnd(MAP_SIZE);
			y = rnd(MAP_SIZE);
		}
		map[x][y] = 1;
		gColony[a].x = x;
		gColony[a].y = y;
		gColony[a].used = 0;
		gColony[a].sprite = SPR_ICON2;
	}
	
	// place 5 colonies
	
	for(a = 0;a < NUM_PLANETS;a++)
	{
		x = rnd(MAP_SIZE);
		y = rnd(MAP_SIZE);
		while((x == 0 && y == 0) || map[x][y] != 0)
		{
			x =	rnd(MAP_SIZE);
			y = rnd(MAP_SIZE);
		}
		map[x][y] = 1;
		gColony[a + NUM_BASES].x = x;
		gColony[a + NUM_BASES].y = y;
		gColony[a + NUM_BASES].used = 0;
		gColony[a + NUM_BASES].sprite = SPR_ICON3;
	}
	
	// place 30 Mingon battlecruisers
	for(a = 0; a < NUM_MINGONS;a++)
	{
		x = rnd(MAP_SIZE);
		y = rnd(MAP_SIZE);
		while((x == 0 && y == 0) || map[x][y] != 0)
		{
			x =	rnd(MAP_SIZE);
			y = rnd(MAP_SIZE);
		}
		map[x][y] = 1;
		gMingon[a].x = x;
		gMingon[a].y = y;
		gMingon[a].armour = 100;
		
	}
	
	
	
	
	
	
}

// ResumeGame() : resumes a game that was saved on exit

void ResumeGame()
{
	int a;
	
	gGameOver = 0;
	gGameMode = gSaveGame.mode;
	gAlert = gSaveGame.alert;
	gScanActive = gSaveGame.scanactive;
	gSnacks = gSaveGame.snacks;
	gBatteries = gSaveGame.batteries;
	gArmour = gSaveGame.armour;
	gMissiles = gSaveGame.missiles;
	gLocationX = gSaveGame.locationx;
	gLocationY = gSaveGame.locationy;
	
	for(a = 0; a < NUM_COLONIES;a++)
	{
		gColony[a] = gSaveGame.colonies[a];
	}
	for(a = 0; a < NUM_MINGONS;a++)
	{
		gMingon[a] = gSaveGame.mingons[a];
	}
	
	
	
}

// StashGame() : check to see if there's an active game (ie not game over) and if so, copy all the data to gSaveGame

void StashGame()
{
	int a;
	if(gGameOver == 0)
	{
		gSaveGame.gameactive = 1;
		gSaveGame.mode = gGameMode;
		gSaveGame.alert = gAlert;
		gSaveGame.scanactive = gScanActive;
		gSaveGame.snacks = gSnacks;
		gSaveGame.batteries = gBatteries;
		gSaveGame.armour = gArmour;
		gSaveGame.missiles = gMissiles;
		gSaveGame.locationx = gLocationX;
		gSaveGame.locationy = gLocationY;
		for(a = 0; a < NUM_COLONIES;a++)
		{
			gSaveGame.colonies[a] = gColony[a];
		}
		for(a = 0; a < NUM_MINGONS;a++)
		{
			gSaveGame.mingons[a] = gMingon[a];
		}
		
	}
	else
	{
		gSaveGame.gameactive = 0;
	}
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    	
	LoadTextureImage(CFSTR("ViewScreen"),CFSTR("png"),SPR_VIEWSCREEN);
	LoadTextureImage(CFSTR("LongRangeScan"),CFSTR("png"),SPR_LONGRANGESCREEN);
	LoadTextureImage(CFSTR("CombatView"),CFSTR("png"),SPR_COMBATSCREEN);
	LoadTextureImage(CFSTR("CombatLasers"),CFSTR("png"),SPR_COMBATLASERS);
	LoadTextureImage(CFSTR("CombatMissiles"),CFSTR("png"),SPR_COMBATMISSILES);
	LoadTextureImage(CFSTR("CombatWin"),CFSTR("png"),SPR_COMBATWON);
	LoadTextureImage(CFSTR("CombatWhoop"),CFSTR("png"),SPR_COMBATWHOOP);

	LoadTextureImage(CFSTR("sbsupply"),CFSTR("png"),SPR_STARBASE1);
	LoadTextureImage(CFSTR("sboutofsupplies"),CFSTR("png"),SPR_STARBASE2);
	LoadTextureImage(CFSTR("cplanetsupply"),CFSTR("png"),SPR_COLONY1);
	LoadTextureImage(CFSTR("cpoutofsupplies"),CFSTR("png"),SPR_COLONY2);
	LoadTextureImage(CFSTR("GameWin"),CFSTR("png"),SPR_WIN);
	LoadTextureImage(CFSTR("GameLost"),CFSTR("png"),SPR_LOST);
	LoadTextureImage(CFSTR("OutofPower"),CFSTR("png"),SPR_OUTOFPOWER);
	LoadTextureImage(CFSTR("OutofSnacks"),CFSTR("png"),SPR_OUTOFSNACKS);

	LoadTextureImage(CFSTR("shstats"),CFSTR("png"),SPR_STATS);
	LoadTextureImage(CFSTR("shstats2"),CFSTR("png"),SPR_STATS2);
	LoadTextureImage(CFSTR("shButtons"),CFSTR("png"),SPR_BUTTONS);
	GrabSpriteSet(1,8,8,SPR_BUTTON0);
	LoadTextureImage(CFSTR("shicons"),CFSTR("png"),SPR_ICONS);
	GrabSpriteSet(2,2,4,SPR_ICON0);
	LoadTextureImage(CFSTR("shdigits"),	CFSTR("png"),SPR_DIGITS);
	GrabSpriteSet(10,1,10,SPR_DIGITS0);
	


	mTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0/FPS) target:self selector:@selector(renderScene) userInfo:nil repeats:YES];

	//Set up OpenGL projection matrix
	glMatrixMode(GL_PROJECTION);
	glOrthof(-160,160,-240,240, -500, 500);
	glMatrixMode(GL_MODELVIEW);
	    glViewport(0, 0, 320, 480);
	//Initialize OpenGL states
	glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
	
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	
	InitGame(); // initialises the game
	// if LoadPrefs loads an active game, its call to ResumeGame will override InitGame's settings
	
	// load the game
	gResetStats = 0; 
	[self LoadPrefs];
	if(gResetStats) // if LoadPrefs sets this, the prefs were damaged, so it will have saved a clean set for us to load again..
	{
		[self LoadPrefs];
	}
		
}


- (void)applicationWillTerminate:(UIApplication *)application 
{
	StashGame();
	[self SavePrefs];
}

- (void)dealloc {
	[window release];
	[glView release];
	[super dealloc];
}



- (void)renderScene
{
	float col;
	[glView startDrawing];
	
	gPulse = fmod(gPulse + 2.0f, 360.0f);
	
	col = sin(gPulse / 180.0 * 3.14159) * 0.25 + 0.75;
	
	
	glColor4f(1,1,1,1);
	if(gGameMode == MODE_MAP && gScanActive != 0)
	{
		DrawSpriteAt(SPR_LONGRANGESCREEN,0,0);
	}
	else
	{
		if(gGameMode == MODE_BATTLE)
		{
			DrawSpriteAt(SPR_COMBATSCREEN,0,0);
		}
		else
		{
			DrawSpriteAt(SPR_VIEWSCREEN,0,0);
		}
	}
	
	if(gGameOver > 0)
	{
		gCombatPage = 0;
		glColor4f(1,1,1,1);
		switch(gGameOver)
		{
			case GO_WON:
				DrawSpriteAt(SPR_WIN,0,0);
				break;
			case GO_OUTOFPOWER:
				DrawSpriteAt(SPR_OUTOFPOWER,0,0);
				break;
			case GO_OUTOFSNACKS:
				DrawSpriteAt(SPR_OUTOFSNACKS,0,0);
				break;
			case GO_DEFEATED:
				DrawSpriteAt(SPR_LOST,0,0);
				break;
		}
		
	//	DrawSpriteAt(SPR_BUTTON5,-80,-90);
	}
	else // gGameOver > 0
	{
		if(gCombatPage > 0)
		{
			// display combat page for last shot
			DrawSpriteAt(SPR_COMBATSCREEN + gCombatPage,0,0);
		}
		else // gCombatPage > 0
		{
			switch(gGameMode)
			{
				case MODE_ALERT:
					
					DrawSpriteAt(gAlert,0,80);
					DrawSpriteAt(SPR_BUTTON5,-80,-90);
					break;
				case MODE_MAP:
					if(gScanActive)
					{
						DrawScannedMap(gLocationX,gLocationY);
					}
					else
					{
						DrawMap(gLocationX,gLocationY); // draw the viewscreen map
					}
					
					// draw buttons
					glColor4f(1,1,1,1);
					// Whoop button, no longer used	
					//	DrawSpriteAt(SPR_BUTTON0,-80,-80);
					// Repair Button
					DrawSpriteAt(SPR_BUTTON1,80,-90);
					// Long range Scan button
					DrawSpriteAt(SPR_BUTTON2,-80,-90);
					// Battery/Armour stats
					DrawSpriteAt(SPR_STATS,-96,-196);
					// Snacks/Missiles stats
					DrawSpriteAt(SPR_STATS2,64,-196);
					
					// draw battery power value
					glColor4f(1,1,1,1);
					if(gBatteries < 25)
						glColor4f(1,0,0,1);
					DrawNumberAt(gBatteries,-42,-180);
					
					// draw armour value
					glColor4f(1,1,1,1);
					if(gArmour < 25)
						glColor4f(1,0,0,1);
					DrawNumberAt(gArmour,-42,-202);
					
					// draw snacks value
					glColor4f(1,1,1,1);
					if(gSnacks < 4)
						glColor4f(1,0,0,1);
					DrawNumberAt(gSnacks,106,-180);
					
					// draw missiles value
					glColor4f(1,1,1,1);
					DrawNumberAt(gMissiles,106,-202);
					
					// for debugging purposes, draw the number of Mingons remaining
				//	DrawNumberAt(gMingonCount,-42,-228);
					break;
				case MODE_BATTLE:
					// Lasers button
					DrawSpriteAt(SPR_BUTTON3,-80,-90);
					
					// Missiles button
					DrawSpriteAt(SPR_BUTTON4,80,-90);
					
					// emergency whoop button
					DrawSpriteAt(SPR_BUTTON0,-80,-130);
					
					// draw battery and armour stats label
					DrawSpriteAt(SPR_STATS,-96,-196);
					
					// draw Snacks and Missiles stats label
					DrawSpriteAt(SPR_STATS2,64,-196);
					
					// draw batteries value
					glColor4f(1,1,1,1);
					if(gBatteries < 25)
						glColor4f(1,0,0,1);
					DrawNumberAt(gBatteries,-42,-180);
					
					// draw armour value
					glColor4f(1,1,1,1);
					if(gArmour < 25)
						glColor4f(1,0,0,1);
					DrawNumberAt(gArmour,-42,-202);
					
					// draw snacks value
					glColor4f(1,1,1,1);
					if(gSnacks < 4)
						glColor4f(1,0,0,1);
					DrawNumberAt(gSnacks,106,-180);
					
					// draw missiles value
					glColor4f(1,1,1,1);
					DrawNumberAt(gMissiles,106,-202);
					break;
			}
		}
	}
	[glView endDrawing];
	
	// handle button presses
	
	if(gTouched)
	{
		// depending on which mode we're in (map, combat or an alert), respond differently to the buttons
		printf("Button %d touched\n",gTouched);
		if(gGameOver > 0)
		{
			if(gTouched == 1)
			{
				InitGame();
				
			}
		}
		else
		{
			if(gCombatPage > 0)
			{
				// display combat screens
				gCombatPage = 0;
			}
			else
			{
				switch(gGameMode)
				{
					case MODE_MAP:
						if(gBatteries <= 0)
						{
							gGameOver = GO_OUTOFPOWER;
						}
						
						switch(gTouched)
					{
						case 1: // set jump co-ordinates
							
							if(gScanActive) // if scan is active, switch it off and ignore input
							{
								gScanActive = 0;
							}
							else
							{
								gDestinationX = gLocationX + gMapX;
								gDestinationY = gLocationY + gMapY;
								gDestinationX = (gDestinationX + MAP_SIZE) % MAP_SIZE; // wrap around 25x25 map
								gDestinationY = (gDestinationY + MAP_SIZE) % MAP_SIZE; 
								printf("destination set to %d,%d\n",gDestinationX,gDestinationY);
								if(gDestinationX != gLocationX || gDestinationY != gLocationY)
								{
									// WHOOP!
									int fuel;
									fuel = fabs(gMapX) + fabs(gMapY);
									if(fuel <= gBatteries)
									{
										gLocationX = gDestinationX;
										gLocationY = gDestinationY;
										gBatteries -= fuel;
										printf("WHOOP! to %d,%d\n",gLocationX,gLocationY);
										CheckNewLocation(); // checks to see if we've landed on anything fun
										gScanActive = 0;
									}
								}		
							}
							break;
						case 2: // long range scan
							if(gBatteries >= 5 && gScanActive == 0)
							{
								gBatteries -= 5;
								gScanActive = 1;
								
								printf("long range scan\n");
							}
							break;
							
						case 3: // repair armour
							printf("repair armour\n");
							if(gBatteries >= 5)
							{
								gBatteries = gBatteries - min(5,(100 - gArmour) / 2);
								gArmour = min(100,gArmour + 20);
								gSnacks = min(20,gSnacks + 1);
								CheckNewLocation(); // so the Mingons move
							}
							break;
					}
						break;
					case MODE_BATTLE:
						
						
						switch(gTouched)
					{
							// nav button does nothing
						case 2: // fire lasers!
							gMingon[gAttacker].armour -= (20 + rnd(20));
							gCombatPage = COMBAT_LASERS;
							
							// PEW PEW PEW !
							gArmour = max(0,gArmour - 5 - rnd(5));
							gBatteries = max(0,gBatteries - 1);
							printf("PEW PEW PEW!\n");
							break;
						case 3: // fire missiles
							if(gMissiles > 0)
							{
								gMingon[gAttacker].armour -= (50 + rnd(20));
								gArmour = max(0,gArmour - 5 - rnd(5));
								gMissiles--;
								gCombatPage = COMBAT_MISSILES;
							}
							// whoosh!
							printf("WHOOOSH!\n");
							break;
						case 4: // RUN!
							gLocationX = rnd(MAP_SIZE);
							gLocationY = rnd(MAP_SIZE);
							gBatteries = min(gBatteries,rnd(5) + 10);
							gCombatPage = COMBAT_WHOOP;
							printf("RANDOM JUMP to %d,%d\n",gLocationX,gLocationY);
							break;
					}
						if(gMingon[gAttacker].armour <= 0)
						{
							gArmour = min(100,gArmour + rnd(10));
							gSnacks = min(20,gSnacks + rnd(3) + 1);
							gBatteries = min(100,gBatteries + rnd(10));
							gGameMode = MODE_MAP;
							gCombatPage = COMBAT_WON;
							
							CheckNewLocation(); // in case there are 2 or more mingons here
						}
						break;
					case MODE_ALERT:
						if(gTouched == 2)
							gGameMode = MODE_MAP;
						break;
				}
			}
		}
		gTouched = 0; // reset to 0 once handled
	}
	if(gArmour <= 0)
	{
		gGameOver = GO_DEFEATED;
	}
	if(gBatteries <= 0)
	{
		gGameOver = GO_OUTOFPOWER;
	}
	
}

-(void)SavePrefs
{
	int a;
	
	// Thanks to Dan for much better save/load code than the Apple hackers :)
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
						  [NSNumber numberWithFloat:63] ,
						  @"SaveGame",@"dummy",
						  [NSNumber numberWithFloat:1] ,
						  
						  nil ]; // terminate the list
	[[NSUserDefaults standardUserDefaults] registerDefaults:dict];
	
	// put our game data into our save game structure
	// modify this to suit your game
	gSaveGame.check = 14020901; // adding a version number allows you to disregard save data that's from earlier versions of the game
		// our active game save has been copied to gSaveGame by the StashGame() function already
	//------------------------------------------------
	
	//	Now actually save it
	
	NSData * savedata;
	unsigned char * ptr;
	unsigned char * save;
	save = malloc(sizeof(gSaveGame));
	
	ptr = (unsigned char *)&gSaveGame;
	for(a = 0; a < sizeof(gSaveGame);a++)
	{
		*(save + a) = *(ptr + a);
	}
	
	savedata = [[NSData alloc] initWithBytes:save length:sizeof(gSaveGame)];
	//------------------------------------------------
	[[NSUserDefaults standardUserDefaults] setObject:savedata forKey:@"SaveGame"];
	[[NSUserDefaults standardUserDefaults] synchronize]; 
}

-(void)LoadPrefs
{
	
	int check;
	NSData *savedata;
	savedata = [[NSUserDefaults standardUserDefaults] dataForKey:@"SaveGame"];
	//if user is starting game for the first time, set defaults and save them
	if(savedata == NULL || gResetStats)
	{
		//	printf("RESET SCORES\n");
		gResetStats = 0;
		gSaveGame.gameactive = 0;
		[self SavePrefs];
	}
	else
	{
		
		
		[savedata getBytes:&gSaveGame length:sizeof(gSaveGame)];
		
		// now grab your saved game data from the gSaveGame structure
		check = gSaveGame.check;
		if(check != 14020901) // check to see if our save game is the right version
		{
			// barf, bad data
			gResetStats = 1;
		}
		if(gSaveGame.gameactive)
		{
			// grab the save game data and resume the game from where we left off
			ResumeGame();
			gSaveGame.gameactive = 0;
		}
			
	}

	
}


@end
