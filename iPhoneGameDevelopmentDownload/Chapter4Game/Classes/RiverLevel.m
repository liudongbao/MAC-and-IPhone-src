//
//  TextureTest.m
//  Test_Framework
//
//  Created by Joe Hogue on 4/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RiverLevel.h"
#import "ResourceManager.h"
#import "gsMainMenu.h"
#import "Entity.h"
#import "TileWorld.h"
#import "Sprite.h"
#import "Animation.h"
#import "Emu.h"
#import "Tile.h"
#import "Tom.h"

@implementation RiverLevel

- (void) setupWorld {
	tileWorld = [[TileWorld alloc] initWithFrame:self.frame];
	[tileWorld loadLevel:@"lvl4_idx.txt" withTiles:@"lvl4_tiles.png"];
	
	Animation* tomanim = [[Animation alloc] initWithAnim:@"tom_walk.png"];
	m_tom = [[Tom alloc] initWithPos:CGPointMake(100, 100) sprite:[Sprite spriteWithAnimation:tomanim]];
	[tileWorld addEntity:m_tom];
	[tomanim autorelease];
	
	int log_position[log_length*2] = {
		4,5,
		3,7,
		5,13,
		2,15,
		8,15,
		7,16,
		4,21,
		9,22,
		2,23,
		7,26,
	};
	
	Animation* loganim = [[Animation alloc] initWithAnim:@"log.png"];
	for(int i=0;i<log_length;i++){
		log[i] = [[Rideable alloc] initWithPos:CGPointMake(log_position[i*2+0]*TILE_SIZE, log_position[i*2+1]*TILE_SIZE) sprite:[Sprite spriteWithAnimation:loganim]];
		[tileWorld addEntity:log[i]];
		log[i].sprite.sequence = @"idle";
	}
	[loganim autorelease];
	

	int croc_position[croc_length*2] = {
		8,5,
		5,13,
		9,16,
		4,21,
		10,26,
	};
	
	Animation* crocanim = [[Animation alloc] initWithAnim:@"croc.png"];
	for(int i=0;i<croc_length;i++){
		croc[i] = [[Croc alloc] initWithPos:CGPointMake(croc_position[i*2+0]*TILE_SIZE, croc_position[i*2+1]*TILE_SIZE+11) sprite:[Sprite spriteWithAnimation:crocanim]];
		[tileWorld addEntity:croc[i]];
	}
	[crocanim autorelease];
	
	int bush_position[] = {
		16,16,
		16,112,
		16,272,
		16,304,
		16,336,
		16,784,
		48,592,
		304,592,
		304,912,
		320,752,
		368,48,
		368,272,
		368,304,
		368,336,
	};
	int bush_count=14;
	
	Animation* bushanim = [[Animation alloc] initWithAnim:@"plant.png"];
	for(int i=0;i<bush_count;i++){
		Entity* bush = [[Entity alloc] initWithPos:CGPointMake(bush_position[i*2+0],bush_position[i*2+1]) sprite:[Sprite spriteWithAnimation:bushanim]];
		[tileWorld addEntity:[bush autorelease]];
	}
	[bushanim release];
	
	Animation* goalanim = [[Animation alloc] initWithAnim:@"mcguffin.png"];
	m_goal = [[Entity alloc] initWithPos:CGPointMake(192,896) sprite:[Sprite spriteWithAnimation:goalanim]];
	[tileWorld addEntity:m_goal];
	[goalanim autorelease];
	
	[tileWorld setCamera:m_tom.position];
	
}

- (void) Update {
	float time = 0.033f;
	[m_tom update:time];
	for(int i=0;i<log_length;i++){
		[log[i] update:time];
	}
	
	for(int i=0;i<croc_length;i++){
		[croc[i] update:time];
		if(m_tom.inJump && [croc[i] under:m_tom.position]){
			[croc[i] attack:m_tom];
			//NSLog(@"lose, crikey!");
			[m_tom dieWithAnimation:@"drowning"];
			[super onFail];
		}
	}
	
	if(m_tom.riding && [m_tom.riding.sprite.sequence isEqualToString:@"sunk"]) {
		[m_tom dieWithAnimation:@"drowning"];
		[super onFail];
		//NSLog(@"lose");
	}
	
	if(m_goal && distsquared(m_tom.position, m_goal.position) < 32*32){
		m_tom.celebrating = true;
		[super onWin:3];
		//NSLog(@"win");
	}

	[m_goal update:time];

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
	CGPoint touchpos = [tileWorld worldPosition:[self touchPosition:touch]];
	float dist = distsquared(touchpos, m_tom.position);
	if(dist < 30*30){
		[m_tom jump];
	}
	if(![m_tom inJump])
	{
		[m_tom moveToPosition:[tileWorld worldPosition:[self touchPosition:touch]]];
	}
	[super touchEndgame];
}

- (void) dealloc {
	[tileWorld release];
	[m_tom release];
	for(int i=0;i<log_length;i++){
		[log[i] release];
	}
	for(int i=0;i<croc_length;i++){
		[croc[i] release];
	}
	[m_goal release];
	[super dealloc];
}

@end
