//
//  TextureTest.m
//  Test_Framework
//
//  Created by Joe Hogue on 4/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "EmuLevel.h"
#import "ResourceManager.h"
#import "gsMainMenu.h"
#import "Entity.h"
#import "TileWorld.h"
#import "Sprite.h"
#import "Animation.h"
#import "Emu.h"
#import "EmuMother.h"
#import "Tile.h"
#import "Tom.h"
#import "pointmath.h"

@implementation EmuLevel

- (void) setupWorld {
	tileWorld = [[TileWorld alloc] initWithFrame:self.frame];
	[tileWorld loadLevel:@"lvl1_idx.txt" withTiles:@"lvl1_tiles.png"];
	
	Animation* emuanim = [[Animation alloc] initWithAnim:@"emuchick.png"];
	
	Animation* tomanim = [[Animation alloc] initWithAnim:@"tom_walk.png"];

	m_tom = [[Tom alloc] initWithPos:CGPointMake(100, 100) sprite:[Sprite spriteWithAnimation:tomanim]];
	[tileWorld addEntity:m_tom];
	
	int emucount = 10;
	Emu** emus;// = new Emu*[emucount];
	emus = malloc(emucount*sizeof(Emu*));
	for(int i=0;i<emucount;i++) {
		Emu* otheremu = [[Emu alloc] initWithPos:CGPointMake(200, 5*TILE_SIZE) sprite:[Sprite spriteWithAnimation:emuanim]];
		[tileWorld addEntity:otheremu];
		emus[i] = otheremu;
	}
	
	flock = emus;
	flock_len = emucount;
	
	Animation* bigemu = [[Animation alloc] initWithAnim:@"emumom.png"];
	mama = [[EmuMother alloc] initWithPos:CGPointMake(7.5f*TILE_SIZE, 22.5f*TILE_SIZE) sprite:[Sprite spriteWithAnimation:bigemu]];
	[tileWorld addEntity:mama];
	[bigemu autorelease];
	
	//Entity* otheremu = [[Entity alloc] initWithPos:CGPointMake(200, 200) sprite:[Sprite spriteWithAnimation:emuanim]];
	//[tileWorld addEntity:otheremu];
	
	[tileWorld setCamera:CGPointMake(100, 100)];
	
	[emuanim autorelease];
	[tomanim autorelease];

	[g_ResManager stopMusic];
	[g_ResManager playMusic:@"trimsqueak.mp3"];
}

- (void) Update {
	float time = 0.033f;
	[m_tom update:time];
	[mama update:time];
	for(int i=0;i<flock_len;i++){
		[flock[i] flockAgainst:flock count:flock_len];
	}
	bool winning = true;
	for(int i=0;i<flock_len;i++){
		[flock[i] avoid:m_tom];
		[flock[i] goal:mama];
		[flock[i] update:time]; //finalize movement and update sprite appearance
		if(distsquared(mama.position, flock[i].position) > 128*128){
			winning = false;
		}
	}
	if(winning && endgame_state == 0) {
		m_tom.celebrating = true;
		[self onWin:0];
		for(int i=0;i<flock_len;i++){
			flock[i].runawaymode = true;
		}
	}
	[tileWorld setCamera:[m_tom position]];
	[super updateEndgame:time];
}

- (void) Render {
	
	//clear anything left over from the last frame, and set background color.
	//glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
	glClearColor(0xff/256.0f, 0x66/256.0f, 0x00/256.0f, 1.0f);
	glClear(GL_COLOR_BUFFER_BIT);
	
	[tileWorld draw];
	
	[super renderEndgame];
	
	//you get a nice boring white screen if you forget to swap buffers.
	[self swapBuffers];
}

-(id) initWithFrame:(CGRect)frame andManager:(GameStateManager*)pManager;
{
    if (self = [super initWithFrame:frame andManager:pManager]) {
		[self setupWorld];
    }
    return self;
}

-(void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
	UITouch* touch = [touches anyObject];
	[m_tom moveToPosition:[tileWorld worldPosition:[self touchPosition:touch]]];
	[super touchEndgame];
}

- (void) dealloc {
	[tileWorld release];
	[m_tom release];
	[mama release];
	for(int i=0;i<flock_len;i++){
		[flock[i] release];
	}
	free(flock);
	[super dealloc];
}

@end
