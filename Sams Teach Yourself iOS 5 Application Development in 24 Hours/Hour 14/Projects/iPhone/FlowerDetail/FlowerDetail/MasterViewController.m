//
//  MasterViewController.m
//  FlowerDetail
//
//  Created by John E. Ray on 10/17/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"

@implementation MasterViewController

@synthesize detailViewController = _detailViewController;
@synthesize flowerData;
@synthesize flowerSections;

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [self createFlowerData];
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    }
}

- (void)viewDidUnload
{
    [self setFlowerData:nil];
    [self setFlowerSections:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    // Return the number of sections.
    return [self.flowerSections count];
}


- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	return [[self.flowerData objectAtIndex:section] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView 
                             dequeueReusableCellWithIdentifier:@"flowerCell"];
    
    cell.textLabel.text=[[[self.flowerData objectAtIndex:indexPath.section] 
                          objectAtIndex: indexPath.row] objectForKey:@"name"];
    cell.detailTextLabel.text=[[[self.flowerData objectAtIndex:indexPath.section] 
                                objectAtIndex: indexPath.row] objectForKey:@"url"];
    
    UIImage *flowerImage;
    flowerImage=[UIImage imageNamed:
                 [[[self.flowerData objectAtIndex:indexPath.section] 
                   objectAtIndex: indexPath.row] objectForKey:@"picture"]];
    
    cell.imageView.image=flowerImage;
    
    return cell;
}




- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [self.flowerSections objectAtIndex:section];
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.detailViewController.detailItem=[[flowerData 
                                           objectAtIndex:indexPath.section]
                                          objectAtIndex: indexPath.row];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    self.detailViewController=segue.destinationViewController;
}


- (void)createFlowerData {
    
	NSMutableArray *redFlowers;
	NSMutableArray *blueFlowers;
	
	self.flowerSections=[[NSArray alloc] initWithObjects:
					@"Red Flowers",@"Blue Flowers",nil];
	
	redFlowers=[[NSMutableArray alloc] init];
	blueFlowers=[[NSMutableArray alloc] init];
	
	[redFlowers addObject:[[NSDictionary alloc]
						   initWithObjectsAndKeys:@"Poppy",@"name",
						   @"poppy.png",@"picture",
						   @"http://en.wikipedia.org/wiki/Poppy",@"url",nil]];
	[redFlowers addObject:[[NSDictionary alloc]
						   initWithObjectsAndKeys:@"Tulip",@"name",
						   @"tulip.png",@"picture",
						   @"http://en.wikipedia.org/wiki/Tulip",@"url",nil]];
	[redFlowers addObject:[[NSDictionary alloc]
						   initWithObjectsAndKeys:@"Gerbera",@"name",
						   @"gerbera.png",@"picture",
						   @"http://en.wikipedia.org/wiki/Gerbera",@"url",nil]];
	[redFlowers addObject:[[NSDictionary alloc]
						   initWithObjectsAndKeys:@"Peony",@"name",
						   @"peony.png",@"picture",
						   @"http://en.wikipedia.org/wiki/Peony",@"url",nil]];
	[redFlowers addObject:[[NSDictionary alloc]
						   initWithObjectsAndKeys:@"Rose",@"name",
						   @"rose.png",@"picture",
						   @"http://en.wikipedia.org/wiki/Rose",@"url",nil]];
	[redFlowers addObject:[[NSDictionary alloc]
						   initWithObjectsAndKeys:@"Hollyhock",@"name",
						   @"hollyhock.png",@"picture",
						   @"http://en.wikipedia.org/wiki/Hollyhock",
						   @"url",nil]];
	[redFlowers addObject:[[NSDictionary alloc]
						   initWithObjectsAndKeys:@"Straw Flower",@"name",
						   @"strawflower.png",@"picture",
						   @"http://en.wikipedia.org/wiki/Strawflower",
						   @"url",nil]];
	
	[blueFlowers addObject:[[NSDictionary alloc]
							initWithObjectsAndKeys:@"Hyacinth",@"name",
							@"hyacinth.png",@"picture",
							@"http://en.m.wikipedia.org/wiki/Hyacinth_(flower)",
							@"url",nil]];
	[blueFlowers addObject:[[NSDictionary alloc]
							initWithObjectsAndKeys:@"Hydrangea",@"name",
							@"hydrangea.png",@"picture",
							@"http://en.m.wikipedia.org/wiki/Hydrangea",
							@"url",nil]];
	[blueFlowers addObject:[[NSDictionary alloc]
							initWithObjectsAndKeys:@"Sea Holly",@"name",
							@"sea holly.png",@"picture",
							@"http://en.wikipedia.org/wiki/Sea_holly",
							@"url",nil]];
	[blueFlowers addObject:[[NSDictionary alloc]
							initWithObjectsAndKeys:@"Grape Hyacinth",@"name",
							@"grapehyacinth.png",@"picture",
							@"http://en.wikipedia.org/wiki/Grape_hyacinth",
							@"url",nil]];
	[blueFlowers addObject:[[NSDictionary alloc]
							initWithObjectsAndKeys:@"Phlox",@"name",
							@"phlox.png",@"picture",
							@"http://en.wikipedia.org/wiki/Phlox",@"url",nil]];
	[blueFlowers addObject:[[NSDictionary alloc]
							initWithObjectsAndKeys:@"Pin Cushion Flower",@"name",
							@"pincushionflower.png",@"picture",
							@"http://en.wikipedia.org/wiki/Scabious",
							@"url",nil]];
	[blueFlowers addObject:[[NSDictionary alloc]
							initWithObjectsAndKeys:@"Iris",@"name",
							@"iris.png",@"picture",
							@"http://en.wikipedia.org/wiki/Iris_(plant)",
							@"url",nil]];
    
	self.flowerData=[[NSArray alloc] initWithObjects:
				redFlowers,blueFlowers,nil];
    
}


@end
