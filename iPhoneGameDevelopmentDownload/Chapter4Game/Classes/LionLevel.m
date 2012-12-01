//
//  LionLevel.m
//  Chapter3 Framework
//
//  Created by Joe Hogue on 6/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LionLevel.h"
#import "TileWorld.h"
#import "ResourceManager.h"
#import "Animation.h"
#import "Tom.h"
#import "Sprite.h"
#import "Emu.h"
#import "Lion.h"

@implementation LionLevel

- (void) setupWorld {
	tileWorld = [[TileWorld alloc] initWithFrame:self.frame];
	[tileWorld loadLevel:@"lvl2_idx.txt" withTiles:@"lvl2_tiles.png"];
	[tileWorld setCamera:CGPointMake(0, 0)];

	Animation* tomanim = [[Animation alloc] initWithAnim:@"tom_walk.png"];
	m_tom = [[Tom alloc] initWithPos:CGPointMake(5.0f*TILE_SIZE, 1*TILE_SIZE) sprite:[Sprite spriteWithAnimation:tomanim]];
	[tileWorld addEntity:m_tom];
	[tomanim autorelease];
	
	//intial positions of each lion.  Coordinates in tile units, relative to bottom-left.
	int bottom = 3;
	int left = 1;
	int lion_positions[] = {
		1,8,
		3,10,
		3,11,
		4,8,
		4,6,
		5,9,
		7,11,
		7,5,
		8,10,
		8,6,
		9,8,
	};
	bool lion_faceleft[] = {
		false,
		true,
		true,
		false,
		true,
		false,
		true,
		true,
		false,
		true,
		true,
	};
	int lioncount = 11;
	
	Animation* lionanim = [[Animation alloc] initWithAnim:@"lion.png"];
	Animation* lioness = [[Animation alloc] initWithAnim:@"lioness.png"];
	Lion** lions;
	lions = malloc(lioncount*sizeof(Lion*));
	for(int i=0;i<lioncount;i++) {
		Lion* otherlion = [[Lion alloc] 
		 initWithPos:CGPointMake((left+lion_positions[i*2+0])*TILE_SIZE, (bottom+lion_positions[i*2+1])*TILE_SIZE) 
		 sprite:[Sprite spriteWithAnimation:random()%100<25?lionanim:lioness] 
		 facingLeft:lion_faceleft[i]];
		[tileWorld addEntity:otherlion];
		[otherlion obstruct];
		lions[i] = otherlion;
	}
	[lioness autorelease];
	[lionanim autorelease];
	m_lions = lions;
	lions_length = lioncount;
	
	Animation* goalanim = [[Animation alloc] initWithAnim:@"mcguffin.png"];
	Entity* goal = [[Entity alloc] initWithPos:CGPointMake((left+5)*TILE_SIZE, (bottom+13)*TILE_SIZE) sprite:[Sprite spriteWithAnimation:goalanim]];
	[tileWorld addEntity:goal];
	[goalanim autorelease];
	
	m_goal = goal;
}

-(id) initWithFrame:(CGRect)frame andManager:(GameStateManager*)pManager;
{
    [super initWithFrame:frame andManager:pManager];
	[self setupWorld];
    return self;
}

- (void) Update {
	float time = 0.033f;
	[m_tom update:time];
	for(int i=0;i<lions_length;i++){
		if([m_lions[i] wakeAgainst:m_tom]){
			[self onFail];
			[m_tom dieWithAnimation:@"mauled"];
		}
		[m_lions[i] update:time];
	}
	if(m_goal){
		[m_goal update:time];
	}
	if(m_goal && distsquared(m_tom.position, m_goal.position) < 32*32){
		//grab the macguffin and rush for the door.
		[tileWorld removeEntity:m_goal];
		[m_goal release];
		m_goal = nil;
	}
	if(m_goal == nil && m_tom.position.y < 8*TILE_SIZE){
		//clear to the door, so win.
		m_tom.celebrating = true;
		[self onWin:1];
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

-(void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
	UITouch* touch = [touches anyObject];
	[m_tom moveToPosition:[tileWorld worldPosition:[self touchPosition:touch]]];
	[super touchEndgame];
}

-(void) dealloc {
	[m_tom release];
	[tileWorld release];
	for(int i=0;i<lions_length;i++){
		[m_lions[i] release];
	}
	free(m_lions);
	[m_goal release];
	[super dealloc];
}

@end
