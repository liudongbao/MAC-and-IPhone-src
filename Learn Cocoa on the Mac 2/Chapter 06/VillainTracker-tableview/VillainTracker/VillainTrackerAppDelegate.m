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
@synthesize villainsTableView;

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
    
    self.villains = [NSMutableArray arrayWithObject:self.villain];
    [villainsTableView reloadData];
    [villainsTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
    
    [self updateDetailViews];
}

- (IBAction)takeName:(id)sender {
    [villain setObject:[sender stringValue] forKey:kName];
    NSLog(@"current villain properties: %@", villain);
    [villainsTableView reloadData];
    [self updateDetailViews];
}

- (IBAction)takeLastKnownLocation:(id)sender {
    [villain setObject:[sender stringValue] forKey:kLastKnownLocation];
    NSLog(@"current villain properties: %@", villain);
}

- (IBAction)takeLastSeenDate:(id)sender {
    [villain setObject:[sender dateValue] forKey:kLastSeenDate];
    NSLog(@"current villain properties: %@", villain);
    [villainsTableView reloadData];
    [self updateDetailViews];
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
    [villainsTableView reloadData];
    [self updateDetailViews];
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
    [_window endEditingFor:nil];
    [villains addObject:[NSMutableDictionary
                         dictionaryWithObjectsAndKeys:
                         @"", kName,
                         @"", kLastKnownLocation,
                         [NSDate date], kLastSeenDate,
                         @"", kSwornEnemy,
                         @"Greed", kPrimaryMotivation,
                         [NSArray array], kPowers,
                         @"", kPowerSource,
                         [NSNumber numberWithInt:0], kEvilness,
                         [NSImage imageNamed:@"NSUser"], kMugshot,
                         @"" , kNotes,
                         nil]];
    
    [villainsTableView reloadData];
    
    [villainsTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:[villains count]-1]
                   byExtendingSelection:NO];

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

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    return [villains count];
}

- (NSView *)tableView:(NSTableView *)aTableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row {
    
    NSMutableDictionary *thisVillain = [villains objectAtIndex:row];
    NSString *thisColName = [tableColumn identifier];
    
    NSView *result = nil;
    
    // Depending on which column we're using, we need to do different things.
    // Passing [tableColumn identifier] to makeViewWithIdentifier ensures that we get the view that's already been configured for the column in IB, and AppKit manages this for us.
    if ([thisColName isEqualToString:kName]) {
        NSTableCellView *thisCell = [aTableView makeViewWithIdentifier:thisColName owner:self];
        thisCell.textField.stringValue = [thisVillain objectForKey:kName];
        result = thisCell;
    } else if ([thisColName isEqualToString:kLastSeenDate]) {
        NSTableCellView *thisCell = [aTableView makeViewWithIdentifier:thisColName owner:self];
        thisCell.textField.stringValue = [thisVillain objectForKey:kLastSeenDate];
        result = thisCell;
    } else if ([thisColName isEqualToString:kMugshot]) {
        NSImageView *thisCell = [aTableView makeViewWithIdentifier:thisColName owner:self];
        [thisCell setImage:[thisVillain objectForKey:kMugshot]];
        result = thisCell;
    }

    
    // return the result.
    return result;
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
    if ([villainsTableView selectedRow] > -1) {
        self.villain = [self.villains
                        objectAtIndex:[villainsTableView selectedRow]];
        [self updateDetailViews];
        NSLog(@"current villain properties: %@", villain);
    }
}


@end