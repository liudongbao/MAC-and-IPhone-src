//
//  VillainTrackerAppDelegate.h
//  VillainTracker
//
//  Created by Peter Clark on 6/19/12.
//  Copyright (c) 2012 Learn Cocoa. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface VillainTrackerAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *nameView;
@property (weak) IBOutlet NSTextField *lastKnownLocationView;
@property (weak) IBOutlet NSDatePicker *lastSeenDateView;
@property (weak) IBOutlet NSComboBox *swornEnemyView;
@property (weak) IBOutlet NSLevelIndicator *evilnessView;
@property (weak) IBOutlet NSMatrix *powersView;
@property (weak) IBOutlet NSPopUpButton *powerSourceView;
@property (weak) IBOutlet NSMatrix *primaryMotivationView;
@property (weak) IBOutlet NSImageView *mugshotView;
@property (unsafe_unretained) IBOutlet NSTextView *notesView;
@property (weak) IBOutlet NSTableView *villainsTableView;

@property (strong) NSMutableDictionary *villain;
@property (strong) NSMutableArray *villains;

- (IBAction)takeName:(id)sender;
- (IBAction)takeLastKnownLocation:(id)sender;
- (IBAction)takeLastSeenDate:(id)sender;
- (IBAction)takeSwornEnemy:(id)sender;
- (IBAction)takeEvilness:(id)sender;
- (IBAction)takePowers:(id)sender;
- (IBAction)takePowerSource:(id)sender;
- (IBAction)takePrimaryMotivation:(id)sender;
- (IBAction)takeMugshot:(id)sender;

- (IBAction)newVillain:(id)sender;
- (IBAction)deleteVillain:(id)sender;

@end
