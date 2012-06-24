//
//  PersistenceViewController.m
//  Core Data Persistence
//
//  Created by Dave Mark on 12/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PersistenceViewController.h"
#import "Core_Data_PersistenceAppDelegate.h"

@implementation PersistenceViewController
@synthesize line1;
@synthesize line2;
@synthesize line3;
@synthesize line4;

- (void)viewDidLoad {
    Core_Data_PersistenceAppDelegate *appDelegate =
	[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
											  entityForName:@"Line"
											  inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
	
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    if (objects == nil) {
        NSLog(@"There was an error!");
        // Do whatever error handling is appropriate
    }
	
    for (NSManagedObject *oneObject in objects) {
        NSNumber *lineNum = [oneObject valueForKey:@"lineNum"];
        NSString *lineText = [oneObject valueForKey:@"lineText"];
		
        NSString *fieldName = [NSString
							   stringWithFormat:@"line%d", [lineNum integerValue]];
        UITextField *theField = [self valueForKey:fieldName];
        theField.text = lineText;
    }
    [request release];
	
    UIApplication *app = [UIApplication sharedApplication];
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(applicationWillResignActive:)
												 name:UIApplicationWillResignActiveNotification
											   object:app];
    [super viewDidLoad];
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    Core_Data_PersistenceAppDelegate *appDelegate =
	[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSError *error;
    for (int i = 1; i <= 4; i++) {
        NSString *fieldName = [NSString stringWithFormat:@"line%d", i];
        UITextField *theField = [self valueForKey:fieldName];
		
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
		
        NSEntityDescription *entityDescription = [NSEntityDescription
												  entityForName:@"Line"
												  inManagedObjectContext:context];
        [request setEntity:entityDescription];
        NSPredicate *pred = [NSPredicate
							 predicateWithFormat:@"(lineNum = %d)", i];
        [request setPredicate:pred];
		
        NSManagedObject *theLine = nil;
		
        NSArray *objects = [context executeFetchRequest:request
												  error:&error];
		
        if (objects == nil) {
            NSLog(@"There was an error!");
            // Do whatever error handling is appropriate
        }
        if ([objects count] > 0)
            theLine = [objects objectAtIndex:0];
        else
            theLine = [NSEntityDescription
					   insertNewObjectForEntityForName:@"Line"
					   inManagedObjectContext:context];
		
        [theLine setValue:[NSNumber numberWithInt:i] forKey:@"lineNum"];
        [theLine setValue:theField.text forKey:@"lineText"];
		
        [request release];
    }
    [context save:&error];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    self.line1 = nil;
    self.line2 = nil;
    self.line3 = nil;
    self.line4 = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [line1 release];
    [line2 release];
    [line3 release];
    [line4 release];
    [super dealloc];
}

@end
