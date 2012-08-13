//
//  ViewController.m
//  FlowerColorTable
//
//  Created by John E. Ray on 10/17/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

#define kSectionCount 2
#define kRedSection 0
#define kBlueSection 1

@implementation ViewController

@synthesize redFlowers;
@synthesize blueFlowers;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    self.redFlowers = [[NSArray alloc] 
                       initWithObjects:@"Gerbera",@"Peony",@"Rose",
                       @"Poppy",nil];
	self.blueFlowers = [[NSArray alloc] 
                        initWithObjects:@"Hyacinth",@"Hydrangea",
                        @"Sea Holly",@"Phlox",@"Iris",nil];

    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setRedFlowers:nil];
    [self setBlueFlowers:nil];
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
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return kSectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView 
    numberOfRowsInSection:(NSInteger)section
{
	switch (section) {
		case kRedSection:
			return [self.redFlowers count];
		case kBlueSection:
			return [self.blueFlowers count];
		default:
			return 0;
	}
}

- (NSString *)tableView:(UITableView *)tableView 
titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case kRedSection:
            return @"Red";
        case kBlueSection:
            return @"Blue";
        default:
            return @"Unknown";
    }
}

/*
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
 {
 static NSString *CellIdentifier = @"Cell";
 
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
 if (cell == nil) {
 cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
 }
 
 switch (indexPath.section) {
 case kRedSection:
 [[cell textLabel] 
 setText:[redFlowers objectAtIndex:indexPath.row]];
 break;
 case kBlueSection:
 [[cell textLabel] 
 setText:[blueFlowers objectAtIndex:indexPath.row]];
 break;
 default:
 [[cell textLabel] 
 setText:@"Unknown"];
 }
 
 return cell;
 }
 */

- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView 
                             dequeueReusableCellWithIdentifier:@"flowerCell"];
    
    
    switch (indexPath.section) {
		case kRedSection:
			cell.textLabel.text=[self.redFlowers 
                                 objectAtIndex:indexPath.row];
			break;
		case kBlueSection:
			cell.textLabel.text=[self.blueFlowers 
                                 objectAtIndex:indexPath.row];
			break;
		default:
			cell.textLabel.text=@"Unknown";
	}
    
    UIImage *flowerImage;
    flowerImage=[UIImage imageNamed:
                 [NSString stringWithFormat:@"%@%@",
                  cell.textLabel.text,@".png"]];
    cell.imageView.image=flowerImage;
    
    return cell;
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
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
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

#pragma mark - Table view delegate


- (void)tableView:(UITableView *)tableView 
            didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	UIAlertView *showSelection;
	NSString	*flowerMessage;
    
	switch (indexPath.section) {
		case kRedSection:
			flowerMessage=[[NSString alloc] 
						   initWithFormat:
						   @"You chose the red flower - %@",
						   [self.redFlowers objectAtIndex: indexPath.row]];
			break;
		case kBlueSection:
			flowerMessage=[[NSString alloc] 
						   initWithFormat:
						   @"You chose the blue flower - %@",
						   [self.blueFlowers objectAtIndex: indexPath.row]];
			break;
		default:
			flowerMessage=[[NSString alloc] 
						   initWithFormat:
						   @"I have no idea what you chose!?"];
			break;
	}
	
	showSelection = [[UIAlertView alloc] 
					 initWithTitle: @"Flower Selected" 
					 message:flowerMessage 
					 delegate: nil 
					 cancelButtonTitle: @"Ok" 
					 otherButtonTitles: nil];
	[showSelection show];
}


@end
