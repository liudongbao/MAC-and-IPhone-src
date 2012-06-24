//
//  President.m
//  Nav
//
//  Created by Dave Mark on 12/8/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "President.h"

@implementation President
@synthesize number;
@synthesize name;
@synthesize fromYear;
@synthesize toYear;
@synthesize party;

- (void)dealloc{
    [name release];
    [fromYear release];
    [toYear release];
    [party release];
    [super dealloc];
}

#pragma mark -
#pragma mark NSCoding
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInt:self.number forKey:kPresidentNumberKey];
    [coder encodeObject:self.name forKey:kPresidentNameKey];
    [coder encodeObject:self.fromYear forKey:kPresidentFromKey];
    [coder encodeObject:self.toYear forKey:kPresidentToKey];
    [coder encodeObject:self.party forKey:kPresidentPartyKey];
}

- (id)initWithCoder:(NSCoder *)coder {
    if (self = [super init]) {
        number = [coder decodeIntForKey:kPresidentNumberKey];
        name = [[coder decodeObjectForKey:kPresidentNameKey] retain];
        fromYear = [[coder decodeObjectForKey:kPresidentFromKey] retain];
        toYear = [[coder decodeObjectForKey:kPresidentToKey] retain];
        party = [[coder decodeObjectForKey:kPresidentPartyKey] retain];
    }
    return self;
}

@end
