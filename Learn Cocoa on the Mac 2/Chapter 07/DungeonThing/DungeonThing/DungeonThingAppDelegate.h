//
//  DungeonThingAppDelegate.h
//  DungeonThing
//
//  Created by Peter Clark on 7/24/12.
//  Copyright (c) 2012 Learn Cocoa. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DungeonThingAppDelegate : NSObject <NSApplicationDelegate>

// add these:
@property (strong) NSMutableDictionary *characters;
@property (strong) NSMutableDictionary *monsters;
@property (strong) NSMutableDictionary *dungeons;

@property (weak) IBOutlet NSArrayController *characterArrayController;
@property (weak) IBOutlet NSArrayController *monsterArrayController;
@property (weak) IBOutlet NSArrayController *dungeonArrayController;

@property (assign) IBOutlet NSWindow *window;

- (IBAction)createCharacter:(id)sender;
- (IBAction)createMonster:(id)sender;
- (IBAction)createDungeon:(id)sender;

@end
