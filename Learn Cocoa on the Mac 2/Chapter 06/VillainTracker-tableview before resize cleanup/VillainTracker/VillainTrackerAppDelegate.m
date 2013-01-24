//
//  VillainTrackerAppDelegate.m
//  VillainTracker
//
//  Created by Peter Clark on 6/19/12.
//  Copyright (c) 2012 Learn Cocoa. All rights reserved.
//

#define kName @"name"
#define kLastKnownLocation @"lastKnownLocation"
#define kLastSeenDate @"lastSeenDate"
#define kSwornEnemy @"swornEnemy"
#define kPrimaryMotivation @"primaryMotivation"
#define kPowers @"powers"
#define kPowerSource @"powerSource"
#define kEvilness @"evilness"
#define kMugshot @"mugshot"
#define kNotes @"notes"


#import "VillainTrackerAppDelegate.h"

@implementation VillainTrackerAppDelegate
@synthesize nameView;
@synthesize lastKnownLocationView;
@synthesize lastSeenDateView;
@synthesize swornEnemyView;
@synthesize evilnessView;
@synthesize powersView;
@synthesize powerSourceView;
@synthesize primaryMotivationView;
@synthesize mugshotView;
@synthesize notesView;

@synthesize villain;
@synthesize villains;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.villain = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                    @"Lex Luthor", kName,
                    @"Smallville", kLastKnownLocation,
                    [NSDate date], kLastSeenDate,
                    @"Superman", kSwornEnemy,
                    @"Revenge", kPrimaryMotivation,
                    [NSArray arrayWithObjects:@"Evil Genius", nil], kPowers,
                    @"Superhero action", kPowerSource,
                    @9, kEvilness,
                    [NSImage imageNamed:@"NSUser"], kMugshot,
                    @"", kNotes,
                    nil];
    
    [self updateDetailViews];
}

- (IBAction)takeName:(id)sender {
    [villain setObject:[sender stringValue] forKey:kName];
    NSLog(@"current villain properties: %@", villain);
}

- (IBAction)takeLastKnownLocation:(id)sender {
    [villain setObject:[sender stringValue] forKey:kLastKnownLocation];
    NSLog(@"current villain properties: %@", villain);
}

- (IBAction)takeLastSeenDate:(id)sender {
    [villain setObject:[sender dateValue] forKey:kLastSeenDate];
    NSLog(@"current villain properties: %@", villain);
}

- (IBAction)takeSwornEnemy:(id)sender {
    [villain setObject:[sender stringValue] forKey:kSwornEnemy];
    NSLog(@"current villain properties: %@", villain);
}

- (IBAction)takePrimaryMotivation:(id)sender {
    [villain setObject:[[sender selectedCell] title] forKey:kPrimaryMotivation];
    NSLog(@"current villain properties: %@", villain);
}

- (IBAction)takePowerSource:(id)sender {
    [villain setObject:[sender title] forKey:kPowerSource];
    NSLog(@"current villain properties: %@", villain);
}

- (IBAction)takeEvilness:(id)sender {
    [villain setObject:[NSNumber numberWithInteger:[sender integerValue]] forKey:kEvilness];
    NSLog(@"current villain properties: %@", villain);
}

- (IBAction)takeMugshot:(id)sender {
    [villain setObject:[sender image] forKey:kMugshot];
    NSLog(@"current villain properties: %@", villain);
}

- (IBAction)takePowers:(id)sender {
    NSMutableArray *powers = [NSMutableArray array];
    for (NSCell *cell in [sender cells]) {
        if ([cell state]==NSOnState) {
            [powers addObject:[cell title]];
        }
    }
    [villain setObject:powers forKey:kPowers];
    NSLog(@"current villain properties: %@", villain);
}


- (IBAction)newVillain:(id)sender {
    
}

- (IBAction)deleteVillain:(id)sender {
    
}


- (void)textDidChange:(NSNotification *)aNotification {
    [villain setObject:[[notesView string] copy] forKey:kNotes];
    NSLog(@"current villain properties: %@", villain);
}


- (void)updateDetailViews {
    [nameView setStringValue:[villain objectForKey:kName]];
    [lastKnownLocationView setStringValue:
     [villain objectForKey:kLastKnownLocation]];
    [lastSeenDateView setDateValue:[villain objectForKey:kLastSeenDate]];
    [evilnessView setIntegerValue:[[villain objectForKey:kEvilness] integerValue]];
    [powerSourceView setTitle:[villain objectForKey:kPowerSource]];
    [mugshotView setImage:[villain objectForKey:kMugshot]];
    [notesView setString:[villain objectForKey:kNotes]];
    if ([swornEnemyView indexOfItemWithObjectValue:
         [villain objectForKey:kSwornEnemy]]==NSNotFound) {
        [swornEnemyView addItemWithObjectValue:
         [villain objectForKey:kSwornEnemy]];
    }
    [swornEnemyView selectItemWithObjectValue:[villain objectForKey:kSwornEnemy]];
    [primaryMotivationView selectCellWithTag:[[[self class] motivations] indexOfObject:[villain objectForKey:kPrimaryMotivation]]];
    
    [powersView deselectAllCells];
    for (NSString *power in [[self class] powers]) {
        if ([[villain objectForKey:kPowers] containsObject:power]) {
            [[powersView cellWithTag:[[[self class] powers] indexOfObject:power]] setState:NSOnState];
        }
    }
}
+ (NSArray *)motivations {
    static NSArray *motivations = nil;
    if (!motivations) {
        motivations = [[NSArray alloc] initWithObjects:@"Greed", @"Revenge", @"Bloodlust", @"Nihilism", @"Insanity", nil];
    }
    return motivations;
}
+ (NSArray *)powers {
    static NSArray *powers = nil;
    if (!powers) {
        powers = [[NSArray alloc] initWithObjects:@"Evil Genius", @"Mind Reader", @"Nigh-invulnerable", @"Weather Control", nil];
    }
    return powers;
}

@end