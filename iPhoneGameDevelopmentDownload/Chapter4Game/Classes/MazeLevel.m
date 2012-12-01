//
//  LionLevel.m
//  Chapter3 Framework
//
//  Created by Joe Hogue on 6/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MazeLevel.h"
#import "TileWorld.h"
#import "ResourceManager.h"
#import "Animation.h"
#import "Tom.h"
#import "Sprite.h"
#import "Emu.h"
#import "Lion.h"
#import "MazeDoor.h"
#import "Entity.h"
#import "MazeButton.h"
#import "pointmath.h"

@implementation MazeLevel

- (void) setupWorld {
	tileWorld = [[TileWorld alloc] initWithFrame:self.frame];
	[tileWorld loadLevel:@"lvl3_idx.txt" withTiles:@"lvl3_tiles.png"];
	[tileWorld setCamera:CGPointMake(0, 0)];
	
	Animation* tomanim = [[Animation alloc] initWithAnim:@"tom_walk.png"];
	m_tom = [[Tom alloc] initWithPos:CGPointMake(5.0f*TILE_SIZE, 12*TILE_SIZE) sprite:[Sprite spriteWithAnimation:tomanim]];
	[tileWorld addEntity:m_tom];
	[tomanim autorelease];
	
	Animation* catanim = [[Animation alloc] initWithAnim:@"cat.png"];
	cat = [[Tom alloc] initWithPos:CGPointMake(2*TILE_SIZE, 8*TILE_SIZE) sprite:[Sprite spriteWithAnimation:catanim]];
	[tileWorld addEntity:cat];
	[catanim release];

	Animation* mouseanim = [[Animation alloc] initWithAnim:@"mouse.png"];
	mouse = [[Tom alloc] initWithPos:CGPointMake(8*TILE_SIZE, 8*TILE_SIZE) sprite:[Sprite spriteWithAnimation:mouseanim]];
	[tileWorld addEntity:mouse];
	[mouseanim autorelease];
	
	Animation* goalanim = [[Animation alloc] initWithAnim:@"mcguffin.png"];
	cheese = [[Entity alloc] initWithPos:CGPointMake(2*TILE_SIZE, 2*TILE_SIZE+0.1f) sprite:[Sprite spriteWithAnimation:goalanim]];
	[tileWorld addEntity:cheese];
	[goalanim autorelease];

	Animation* vertdoor = [[Animation alloc] initWithAnim:@"mazedoor.png"];
	for(int x=0;x<2;x++){
		for(int y=0;y<3;y++) {
			door[0][x][y] =
				[[MazeDoor alloc] initWithPos:CGPointMake((3*x+3.5f)*TILE_SIZE, (3*y+1.0f)*TILE_SIZE) sprite:[Sprite spriteWithAnimation:vertdoor]];
			[tileWorld addEntity:door[0][x][y]];
		}
	}
	[vertdoor autorelease];
	
	Animation* horizdoor = [[Animation alloc] initWithAnim:@"mazedoor-horizontal.png"];
	for(int x=0;x<3;x++){
		for(int y=0;y<2;y++) {
			door[1][y][x] =
				[[MazeDoor alloc] initWithPos:CGPointMake((3*x+2.0f)*TILE_SIZE, (3*y+3.5f)*TILE_SIZE) sprite:[Sprite spriteWithAnimation:horizdoor]];
			[tileWorld addEntity:door[1][y][x]];
		}
	}
	[horizdoor autorelease];
	
	Animation* buttonanim = [[Animation alloc] initWithAnim:@"buttons.png"];
	for(int i=0;i<buttons_length;i++){
		buttons[i] = [[MazeButton alloc] initWithPos:CGPointMake((2.5f+2.5f*i)*TILE_SIZE,12*TILE_SIZE) sprite:[Sprite spriteWithAnimation:buttonanim] color:i];
		[tileWorld addEntity:buttons[i]];
	}
	[buttonanim release];
	
	[self decorateDoors];
	state = WAITING_FOR_PLAYER;
}

-(id) initWithFrame:(CGRect)frame andManager:(GameStateManager*)pManager;
{
    [super initWithFrame:frame andManager:pManager];
	[self setupWorld];
    return self;
}

- (void) Update {
	float time = 0.033f;
	
	//move mouse, wait to stop.
	//move cat, wait to stop.
	//decorate doors, wait for button push.
	switch (state) {
		case MOVING_MOUSE:
			if([mouse doneMoving]){
				if (distsquared(mouse.position, cheese.position) < 16) {
					//todo: win.
					state = GOT_CHEESE;
					m_tom.celebrating = true;
					[self onWin:2];
					NSLog(@"win condition triggered.");
				} else {
					//time to move the cat.
					NSArray* moves = [self possibleMoves:cat];
					int angle = [[moves objectAtIndex:random()%[moves count]] intValue];
					
					MazeDoor* door_tmp = [self doorFrom:cat.position inDirection:angle];
					door_tmp.sprite.sequence = @"opening";
					
					//move the char through the open door.
					CGPoint catpos = cat.position;
					//int angle = random() % 4;
					catpos.y += TILE_SIZE*3*cheapsin[angle];
					catpos.x += TILE_SIZE*3*cheapcos[angle];
					[cat moveToPosition:catpos];
					state = MOVING_CAT;
				}
			}
			break;
		case MOVING_CAT:
			if([cat doneMoving]){
				if(distsquared(mouse.position, cat.position) < 16){
					//lose.
					state = MOUSE_KILLED;
					[mouse dieWithAnimation:@"dying"];
					[tileWorld removeEntity:cat];
					[self onFail];
					NSLog(@"lose condition triggered.");
				} else {
					[self decorateDoors];
					state = WAITING_FOR_PLAYER;
				}
			}
			break;
		case WAITING_FOR_PLAYER:
			//nothing interesting here... transition to MOVING_MOUSE is done in touch handler.
			break;
	}
	
	[m_tom update:time];
	[cat update:time];
	[mouse update:time];
	[cheese update:time];
	for(int i=0;i<2;i++){
		for(int x=0;x<2;x++){
			for(int y=0;y<3;y++){
				[door[i][x][y] update:time];
			}
		}
	}
	for(int i=0;i<buttons_length;i++){
		[buttons[i] update:time];
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


int gamepos(float worldPos){
	return (worldPos / TILE_SIZE - 2)/3;
}

- (NSArray*) possibleMoves:(Entity*) guy {
	NSMutableArray* moves = [NSMutableArray array];
	for(int i=0;i<4;i++)
		[moves addObject:[NSNumber numberWithInt:i]]; //start off with all directions.
	int x = gamepos(guy.position.x);
	int y = gamepos(guy.position.y);
	if(x == 0)
		[moves removeObjectIdenticalTo:[NSNumber numberWithInt:1]]; //cant go left
	if(x == 2)
		[moves removeObjectIdenticalTo:[NSNumber numberWithInt:3]]; //cant go right
	if(y == 0)
		[moves removeObjectIdenticalTo:[NSNumber numberWithInt:2]]; //cant go down
	if(y == 2)
		[moves removeObjectIdenticalTo:[NSNumber numberWithInt:0]]; //cant go up
	
	//NSLog(@"pos %dx%d, moves %@", x, y, moves);
	return moves;
}

- (MazeDoor*) doorFrom:(CGPoint) pos inDirection:(int) angle {
	//figure out which door to open.
	//pre: you can actually move in the specified direction from the specified position.
	int x = gamepos(pos.x);
	int y = gamepos(pos.y);
	if(angle == 1 || angle == 3){
		//moving left/right
		if(angle == 1) x--; //haaaaacks
		return door[0][x][y];
	} else {
		//moving up/down
		if(angle == 2) y--;
		return door[1][y][x]; //x and y are reversed for horizontal doors, so that we can squeeze 2x3 of them in.
	}
}

- (void) decorateDoors {
	NSString* doorcolors[] = {
		@"closed-blue",
		@"closed-green",
		@"closed-red",
	};
	NSArray* moves = [self possibleMoves:mouse];
	for(int i=0; i < [moves count] && i < 3; i++){
		int angle = [[moves objectAtIndex:i] intValue];
		[self doorFrom:mouse.position inDirection:angle].sprite.sequence = doorcolors[i];
	}
}

-(void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
	[super touchEndgame];
	UITouch* touch = [touches anyObject];
	CGPoint touchpos = [tileWorld worldPosition:[self touchPosition:touch]];
	float dist = distsquared(touchpos, m_tom.position);
	if(dist < 30*30){
		if(state != WAITING_FOR_PLAYER) return;
		//figure out if the player has stomped a button.
		int buttonpressed = -1;
		for(int i=0;i<buttons_length;i++){
			if([buttons[i] under:m_tom]){
				[buttons[i] press];
				buttonpressed = i;
				break; //probably not necessary to break.
			}
		}
		if(buttonpressed == -1) { //this is where joe would use a goto, to jump to the default movement code.
			[m_tom moveToPosition:touchpos];
			return;
		}

		//perform action.
		NSArray* moves;
		int angle;
		
		moves = [self possibleMoves:mouse];
		if(buttonpressed < [moves count]){
			angle = [[moves objectAtIndex:buttonpressed] intValue];
			//open the chosen door
			[self doorFrom:mouse.position inDirection:angle].sprite.sequence = @"opening";

			//un-decorate the other possible doors.
			for(NSNumber* n in moves){
				int i = [n intValue];
				if (i==angle) continue;
				[self doorFrom:mouse.position inDirection:i].sprite.sequence = @"closed";
			}

			//move the char through the open door.
			CGPoint mousepos = mouse.position;
			//int angle = random() % 4;
			mousepos.y += TILE_SIZE*3*cheapsin[angle];
			mousepos.x += TILE_SIZE*3*cheapcos[angle];
			[mouse moveToPosition:mousepos];
			//wait for the mouse to stop moving.
			state = MOVING_MOUSE;
		}
	} else {
		[m_tom moveToPosition:touchpos];
	}
}

- (void) dealloc {
	[tileWorld release];
	[m_tom release];
	[cat release];
	[mouse release];
	[cheese release];
	for(int i=0;i<2;i++)
		for(int x=0;x<2;x++)
			for(int y=0;y<3;y++)
				[door[i][x][y] release];
	for(int i=0;i<buttons_length;i++)
		[buttons[i] release];
	[super dealloc];
}

@end
