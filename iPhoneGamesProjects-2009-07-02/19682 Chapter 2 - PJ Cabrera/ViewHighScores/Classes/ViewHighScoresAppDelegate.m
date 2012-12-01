//
//  ViewHighScoresAppDelegate.m
//  ViewHighScores
//
//  Created by PJ Cabrera on 1/13/09.
//  Copyright PJ Cabrera 2009. All rights reserved.
//

#import "ViewHighScoresAppDelegate.h"
#import "RootViewController.h"

@implementation ViewHighScoresAppDelegate

@synthesize window;
@synthesize navigationController;

@synthesize highScores;
@synthesize rootViewController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	// Configure and show the window
	[window addSubview:[navigationController view]];
	[window makeKeyAndVisible];

	[self getHighScores];
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
}


- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}

#pragma mark web service connection methods

#define HIGH_SCORES_URL @"http://localhost:3000/top_100_scores.xml"

- (void)getHighScores {
	[self getHighScoresFromWebService: HIGH_SCORES_URL];
}

- (void)getHighScoresFromWebService:(NSString *)URLstr {
	[rootViewController setTitle: @"Getting High Scores ..."];
	[[UIApplication sharedApplication] 
		setNetworkActivityIndicatorVisible:TRUE];
	
	NSURL *theURL = [NSURL URLWithString:URLstr];
	NSURLRequest *theRequest = [NSURLRequest requestWithURL:theURL
		cachePolicy:NSURLRequestUseProtocolCachePolicy
		timeoutInterval:10.0];
	
    NSURLConnection *theConnection = [[NSURLConnection alloc] 
		initWithRequest:theRequest delegate:self];
	
	if (theConnection) {
		responseData = [[NSMutableData data] retain];
	} else {
		// the connection request is invalid; malformed URL, perhaps?
		[rootViewController setTitle: @"Error Getting High Scores"];
		[[UIApplication sharedApplication] 
			setNetworkActivityIndicatorVisible:FALSE];
	}
}

-(void)connection:(NSURLConnection *)connection 
		didFailWithError:(NSError *)error 
{
	[navigationController setTitle: @"Error Getting High Scores"];
	[[UIApplication sharedApplication] 
		setNetworkActivityIndicatorVisible:FALSE];

	NSLog(@"Error connecting - %@", [error localizedFailureReason]);
	[connection release];
	[responseData release];
}

-(void)connection:(NSURLConnection *)connection 
		didReceiveResponse:(NSURLResponse *)response 
{
	NSHTTPURLResponse *HTTPresponse = (NSHTTPURLResponse *)response;
	NSInteger statusCode = [HTTPresponse statusCode];
	if ( 404 == statusCode || 500 == statusCode ) {
		[rootViewController setTitle: @"Error Getting High Scores"];
		[[UIApplication sharedApplication] 
			setNetworkActivityIndicatorVisible:FALSE];
		
		[connection cancel];
		
		NSLog(@"Server Error - %@", [ NSHTTPURLResponse 
			localizedStringForStatusCode:statusCode ]);
	} else {
		[ responseData setLength:0];
	}
}

- (void)connection:(NSURLConnection *)connection 
		didReceiveData:(NSData *)data 
{
	[ responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[self parseHighScores: responseData];
	[connection release];
	[responseData release];
}

#pragma mark XML parsing methods

- (void)parseHighScores:(NSData *) highScoresXMLData {
	if (highScoresParser)
        [highScoresParser release];
    highScoresParser = [[NSXMLParser alloc] initWithData: highScoresXMLData];
    [highScoresParser setDelegate:self];
    [highScoresParser setShouldResolveExternalEntities:NO];
    [highScoresParser parse];
}

- (void)parser:(NSXMLParser *)parser 
        didStartElement:(NSString *)elementName
        namespaceURI:(NSString *)namespaceURI 
        qualifiedName:(NSString *)qName
        attributes:(NSDictionary *)attributeDict 
{
	currentKey = nil;
	[currentStringValue release];
	currentStringValue = nil;

	if ( [elementName isEqualToString:@"high-scores"]) {
		if (highScores)
			[highScores removeAllObjects];
		else
			highScores = [[NSMutableArray alloc] init];
        return;
    }
	
	if ( [elementName isEqualToString:@"high-score"] ) {
		// create a new NSMutableDictionary object
		newScore = [[NSMutableDictionary alloc] 
			initWithCapacity: 2];
        return;
    }
	
	if ( [elementName isEqualToString:@"score"] ) {
        currentKey = @"score";
        return;
    }
	
	if ( [elementName isEqualToString:@"full-name"] ) {
		currentKey = @"full-name";
		return;
    }
}

- (void)parser:(NSXMLParser *)parser
        foundCharacters:(NSString *)string 
{
	if (currentKey) {
		if (!currentStringValue) {
			currentStringValue = [[NSMutableString alloc] 
				initWithCapacity:50];
		}
		[currentStringValue appendString:string];
	}
}

- (void)parser:(NSXMLParser *)parser
        didEndElement:(NSString *)elementName
        namespaceURI:(NSString *)namespaceURI
        qualifiedName:(NSString *)qName 
{
    // ignore root and empty elements
    if (( [elementName isEqualToString:@"high-scores"])) 
	{
        // reaching this end tag means we've finished parsing everything
		[rootViewController setTitle: @"View High Scores"];
		[[UIApplication sharedApplication] 
			setNetworkActivityIndicatorVisible:FALSE];
		return;
	}
	
    if ( [elementName isEqualToString:@"high-score"] ) 
	{
		// add the new score to the table model and 
		// force the table to update
		[ highScores addObject: newScore ];
		[rootViewController reloadData];
        return;
    }
	
    if ( [elementName isEqualToString:@"score"] || 
	    [elementName isEqualToString:@"full-name"]) 
	{
		[ newScore setValue: currentStringValue forKey: currentKey ];
	}

	currentKey = nil;
    [currentStringValue release];
    currentStringValue = nil;
}

@end
