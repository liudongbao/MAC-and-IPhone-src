//
//  Box2DView.mm
//  Box2D OpenGL View
//
//  Box2D iPhone port by Simon Oliver - http://www.simonoliver.com - http://www.handcircus.com
//

//
// File heavily modified for cocos2d integration
// http://www.cocos2d-iphone.org
//

#import "Box2DView.h"
#import "iPhoneTest.h"

#define kAccelerometerFrequency 30
#define FRAMES_BETWEEN_PRESSES_FOR_DOUBLE_CLICK 10

extern int g_totalEntries;

Settings settings;

enum {
	kTagBox2DNode,
};


@implementation MenuLayer

@synthesize Bomb = m_bomb;

+(id) menuWithEntryID:(int)entryId
{
	return [[[self alloc] initWithEntryID:entryId] autorelease];
}

- (id) initWithEntryID:(int)entryId
{
	if ((self = [super init])) {
		
		CGSize s = [[CCDirector sharedDirector] winSize];
		
		entryID = entryId;
		
		self.isTouchEnabled = YES;
		
		Box2DView *view = [Box2DView viewWithEntryID:entryId];
		[self addChild:view z:0 tag:kTagBox2DNode];
		[view setScale:15];
		[view setAnchorPoint:ccp(0,0)];
		[view setPosition:ccp(s.width/2, s.height/3)];
		
		CCLabelTTF* label = [CCLabelTTF labelWithString:[view title] fontName:@"Arial" fontSize:32];
		[self addChild: label z:1];
		[label setPosition: ccp(s.width/2, s.height-50)];
		
		CCMenuItemImage *item1 = [CCMenuItemImage itemFromNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		CCMenuItemImage *item2 = [CCMenuItemImage itemFromNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		CCMenuItemImage *item3 = [CCMenuItemImage itemFromNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
		
		CCMenu *menu = [CCMenu menuWithItems:item1, item2, item3, nil];
		
		menu.position = CGPointZero;
		item1.position = ccp( s.width/2 - 100,30);
		item2.position = ccp( s.width/2, 30);
		item3.position = ccp( s.width/2 + 100,30);
		[self addChild: menu z:1];		

		// ZY++ We add the following code for simulate the Keybord input

		
		TestEntry *entry = g_testEntries + entryId;
		NSString *str = [NSString stringWithUTF8String:entry->act];

        //ZY++ Add a menu and a toggle menu for launch a bomb
		[CCMenuItemFont setFontName:@"Verdana"];
		[CCMenuItemFont setFontSize:16];
        
        CCMenuItemFont *mtb = [CCMenuItemFont itemFromString:@"LaunchBomb: " target:self selector:@selector(ToggleBomb:)];
        
        [menu addChild:mtb];
        
        [mtb setPosition:ccp(70 , 70)];
        
        CCMenuItemImage * unchecked2 = [CCMenuItemImage  
                                        itemFromNormalImage:@"options_check_d.png"
                                        selectedImage:@"options_check.png"];
        
        CCMenuItemImage * checked2 = [CCMenuItemImage  
                                      itemFromNormalImage:@"options_check.png"
                                      selectedImage:@"options_check_d.png" ];
        
        m_bomb = [CCMenuItemToggle itemWithTarget:self  
                                    selector:nil 
                                    items:checked2,unchecked2,nil];       // @selector(ToggleBomb:) 
        
        [menu addChild:m_bomb];
        
        [m_bomb setPosition:ccp(70  + 75, 75)];
        
		[CCMenuItemFont setFontName:@"Verdana"];
		[CCMenuItemFont setFontSize:24];

        CCMenuItemFont *ViewScalL = [CCMenuItemFont itemFromString:@"+" target:self selector:@selector(charAct:)];
        [menu addChild:ViewScalL];
        [ViewScalL setPosition:ccp(240 - 60 , 70)];
        
        CCMenuItemFont *ViewScalS = [CCMenuItemFont itemFromString:@"-" target:self selector:@selector(charAct:)];
        [menu addChild:ViewScalS];
        [ViewScalS setPosition:ccp(240 - 30 , 70)];

   
		[CCMenuItemFont setFontSize:16];
        
		int i, nA;
		nA = [str length];
		
		for (i = 0; i < nA; i++) 
		{
			NSRange nr;
			
			nr.location = i;
			nr.length = 1;
			
			NSString *ss = [str substringWithRange:nr];
			CCMenuItemFont *muf = [CCMenuItemFont itemFromString:ss target:self selector:@selector(charAct:)];
			
			[menu addChild:muf];
			
			[muf setPosition:ccp(32 * i + 240 , 70)];
		}
		
		lbInfo = [CCLabelTTF labelWithString:@"This is Debug Info." fontName:@"Verdana" fontSize:12];
		
		[self addChild:lbInfo];
		
		[lbInfo setPosition:ccp(240, 300)];
		
		Test *pt = [view GetTestObj];
		pt->m_debugDraw.m_pDebugInfoLabel = lbInfo;
		
	}
	return self;
}

-(void) charAct: (id) sender
{
    
	CCMenuItemFont *muf = (CCMenuItemFont *)sender;
	Box2DView *bv = (Box2DView *)[self getChildByTag:kTagBox2DNode];
	
	NSString *ss = [muf.label string];
    
    if (ss == @"+") {
        int ns;
        CCNode *vw;
        
        vw = [self getChildByTag:kTagBox2DNode];
        ns = vw.scale;
        ns++;
        
        if (ns >= 30) {
            ns = 30;
        }

        [vw setScale:ns];       
        
        return ;
    }
    else if (ss == @"-")
    {
        int ns;
        CCNode *vw;
        
        vw = [self getChildByTag:kTagBox2DNode];
        ns = vw.scale;
        ns--;
        
        if (ns <= 0) {
            ns = 1;
        }
        
        [vw setScale:ns];        
        
        return ;
    }
        
	
	[bv DoKey:[ss characterAtIndex:0]];
	
}

-(void) ToggleBomb: (id) sender
{
    [m_bomb setSelectedIndex:1];
}

-(void) restartCallback: (id) sender
{
	CCScene *s = [CCScene node];
	id box = [MenuLayer menuWithEntryID:entryID];
	[s addChild:box];
	[[CCDirector sharedDirector] replaceScene: s];
}

-(void) nextCallback: (id) sender
{
	CCScene *s = [CCScene node];
	int next = entryID + 1;
	if( next >= g_totalEntries)
		next = 0;
	id box = [MenuLayer menuWithEntryID:next];
	[s addChild:box];
	[[CCDirector sharedDirector] replaceScene: s];
}

-(void) backCallback: (id) sender
{
	CCScene *s = [CCScene node];
	int next = entryID - 1;
	if( next < 0 ) {
		next = g_totalEntries - 1;
	}
	
	id box = [MenuLayer menuWithEntryID:next];
	[s addChild:box];
	[[CCDirector sharedDirector] replaceScene: s];
}

-(void) registerWithTouchDispatcher
{
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	return YES;
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
}

-(void) ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
}

-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint touchLocation = [touch locationInView: [touch view]];	
	CGPoint prevLocation = [touch previousLocationInView: [touch view]];	
	
	touchLocation = [[CCDirector sharedDirector] convertToGL: touchLocation];
	prevLocation = [[CCDirector sharedDirector] convertToGL: prevLocation];
	
	CGPoint diff = ccpSub(touchLocation,prevLocation);
	
	CCNode *node = [self getChildByTag:kTagBox2DNode];
	CGPoint currentPos = [node position];
	[node setPosition: ccpAdd(currentPos, diff)];
}
@end

#pragma mark -
#pragma mark Box2DView
@implementation Box2DView

+(id) viewWithEntryID:(int)entryId
{
	return [[[self alloc] initWithEntryID:entryId] autorelease];
}

-(void)DoKey:(unichar)chr
{
	test->Keyboard(chr);
}

-(void)DoBomb
{
	test->LaunchBomb();
}


-(Test *)GetTestObj
{
	return test;
}

- (id) initWithEntryID:(int)entryId
{    
    if ((self = [super init])) {
		
		self.isAccelerometerEnabled = YES;
		self.isTouchEnabled = YES;

		[self schedule:@selector(tick:)];

		entry = g_testEntries + entryId;
		test = entry->createFcn();
		
		// init settings
//		settings.drawAABBs = 1;
//		settings.drawPairs = 1;
//		settings.drawContactPoints = 1;
//		settings.drawCOMs = 1;
		
    }
		
    return self;
}

-(NSString*) title
{
	return [NSString stringWithCString:entry->name];
}

- (void)tick:(ccTime) dt
{
	test->Step(&settings);
}

-(void) draw
{
	[super draw];

	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states:  GL_VERTEX_ARRAY, 
	// Unneeded states: GL_TEXTURE_2D, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	glPushMatrix();
	float scale = CC_CONTENT_SCALE_FACTOR();
	glScalef( scale, scale, 1 );
	
	test->m_world->DrawDebugData();
	
	test->Step(&settings);		// ZY++ It's not logical but can show additional drawings for your understanding of Box2D
	
	glPopMatrix();
	
	// restore default GL states
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
}

- (void)dealloc
{
	delete test;
    [super dealloc];
}

-(void) registerWithTouchDispatcher
{
	// higher priority than dragging
	[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:-10 swallowsTouches:YES];
}

- (BOOL) ccTouchBegan:(UITouch*)touch withEvent:(UIEvent*)event
{
	
	CGPoint touchLocation=[touch locationInView:[touch view]];
	touchLocation=[[CCDirector sharedDirector] convertToGL:touchLocation];
	CGPoint nodePosition = [self convertToNodeSpace: touchLocation];
//	NSLog(@"pos: %f,%f -> %f,%f", touchLocation.x, touchLocation.y, nodePosition.x, nodePosition.y);

    MenuLayer *ly = (MenuLayer *)[self parent];

    if (ly.Bomb.selectedIndex == 1) {
        test->ShiftMouseDown(b2Vec2(nodePosition.x,nodePosition.y));
        return true;
    }
    else
    {
        return test->MouseDown(b2Vec2(nodePosition.x,nodePosition.y));
    }
}

- (void) ccTouchMoved:(UITouch*)touch withEvent:(UIEvent*)event
{
	CGPoint touchLocation=[touch locationInView:[touch view]];
	touchLocation=[[CCDirector sharedDirector] convertToGL:touchLocation];
	CGPoint nodePosition = [self convertToNodeSpace: touchLocation];

    test->MouseMove(b2Vec2(nodePosition.x,nodePosition.y));		
}

- (void) ccTouchEnded:(UITouch*)touch withEvent:(UIEvent*)event
{
	CGPoint touchLocation=[touch locationInView:[touch view]];
	touchLocation=[[CCDirector sharedDirector] convertToGL:touchLocation];
	CGPoint nodePosition = [self convertToNodeSpace: touchLocation];
	
    MenuLayer *ly = (MenuLayer *)[self parent];
    if (ly.Bomb.selectedIndex == 1) 
    {
        if (test->m_bombSpawning) 
        {
            test->CompleteBombSpawn(b2Vec2(nodePosition.x,nodePosition.y));

            MenuLayer *ly = (MenuLayer *)[self parent];
            [ly.Bomb setSelectedIndex:0];
            return ;
        }
    }
    else
        test->MouseUp(b2Vec2(nodePosition.x,nodePosition.y));
}


- (void) accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{
	// Only run for valid values
	if (acceleration.y!=0 && acceleration.x!=0)
	{
		if (test) test->SetGravity((float)-acceleration.y,(float)acceleration.x);
	}
}

@end
