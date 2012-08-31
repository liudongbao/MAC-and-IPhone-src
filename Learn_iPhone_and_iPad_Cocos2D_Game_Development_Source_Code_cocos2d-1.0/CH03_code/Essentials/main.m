//
//  main.m
//  Essentials
//
//  Created by Steffen Itterheim on 14.07.10.
//  Copyright Steffen Itterheim 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

int main(int argc, char *argv[]) {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	int retVal = UIApplicationMain(argc, argv, nil, @"EssentialsAppDelegate");
	[pool release];
	return retVal;
}
