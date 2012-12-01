//
//  ResultsViewController.m
//  TwentyFour
//

#import "ResultsViewController.h"
#import "TwentyFourAppDelegate.h"


@implementation ResultsViewController

@synthesize results, labelStatus, tableResults;


#pragma mark -
#pragma mark UITableViewDataSource Method Implementations

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [results count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *resultCellIdentifier = @"resultCell";

  UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:resultCellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:resultCellIdentifier] autorelease];
	}

  cell.textLabel.text = [results objectAtIndex:indexPath.row];  
  return cell;
}

- (void)dealloc {
  self.labelStatus = nil;
  self.tableResults = nil;
  self.results = nil;
  [super dealloc];
}

@end
