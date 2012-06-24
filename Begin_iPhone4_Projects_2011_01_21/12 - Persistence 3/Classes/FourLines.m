//
//  FourLines.m
//  Persistence
//
//  Created by Dave Mark on 12/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FourLines.h"

#define    kField1Key    @"Field1"
#define    kField2Key    @"Field2"
#define    kField3Key    @"Field3"
#define    kField4Key    @"Field4"

@implementation FourLines
@synthesize field1;
@synthesize field2;
@synthesize field3;
@synthesize field4;

#pragma mark NSCoding
- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:field1 forKey:kField1Key];
    [encoder encodeObject:field2 forKey:kField2Key];
    [encoder encodeObject:field3 forKey:kField3Key];
    [encoder encodeObject:field4 forKey:kField4Key];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        field1 = [[decoder decodeObjectForKey:kField1Key] retain];
        field2 = [[decoder decodeObjectForKey:kField2Key] retain];
        field3 = [[decoder decodeObjectForKey:kField3Key] retain];
        field4 = [[decoder decodeObjectForKey:kField4Key] retain];
    }
    return self;
}

#pragma mark -
#pragma mark NSCopying
- (id)copyWithZone:(NSZone *)zone {
    FourLines *copy = [[[self class] allocWithZone: zone] init];
    copy.field1 = [[self.field1 copyWithZone:zone] autorelease];
    copy.field2 = [[self.field2 copyWithZone:zone] autorelease];
    copy.field3 = [[self.field3 copyWithZone:zone] autorelease];
    copy.field4 = [[self.field4 copyWithZone:zone] autorelease];
    return copy;
}
@end
