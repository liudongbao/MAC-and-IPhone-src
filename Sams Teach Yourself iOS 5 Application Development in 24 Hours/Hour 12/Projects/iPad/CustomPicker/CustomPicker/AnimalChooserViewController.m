//
//  AnimalChooserViewController.m
//  CustomPicker
//
//  Created by John Ray on 10/3/11.
//  Copyright (c) 2011 John E. Ray. All rights reserved.
//

#import "AnimalChooserViewController.h"

#define kComponentCount 2
#define kAnimalComponent 0
#define kSoundComponent 1

@implementation AnimalChooserViewController

@synthesize animalNames;
@synthesize animalSounds;
@synthesize animalImages;
@synthesize delegate;

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return kComponentCount;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView 
numberOfRowsInComponent:(NSInteger)component {
	if (component==kAnimalComponent) {
		return [self.animalNames count];
	} else {
		return [self.animalSounds count];
	}
}


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row 
		  forComponent:(NSInteger)component reusingView:(UIView *)view {
	if (component==kAnimalComponent) {
		return [self.animalImages objectAtIndex:row];
	} else {
		UILabel *soundLabel;
		soundLabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0,100,32)];
	//	[soundLabel autorelease];
		soundLabel.backgroundColor=[UIColor clearColor];
		soundLabel.text=[self.animalSounds objectAtIndex:row];
		return soundLabel;
	}
}

- (CGFloat)pickerView:(UIPickerView *)pickerView 
rowHeightForComponent:(NSInteger)component {
	return 55.0;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
	if (component==kAnimalComponent) {
		return 75.0;
	} else {
		return 150.0;
	}
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row 
	   inComponent:(NSInteger)component {
    
    ViewController *initialView;
    initialView=(ViewController *)self.delegate;
    
    if (component==kAnimalComponent) {
        int chosenSound=[pickerView selectedRowInComponent:kSoundComponent];
        [initialView displayAnimal:[self.animalNames objectAtIndex:row]
                         withSound:[self.animalSounds objectAtIndex:chosenSound]
                     fromComponent:@"the Animal"];
    } else {
        int chosenAnimal=[pickerView selectedRowInComponent:kAnimalComponent];
        [initialView displayAnimal:[self.animalNames objectAtIndex:chosenAnimal]
                         withSound:[self.animalSounds objectAtIndex:row]
                     fromComponent:@"the Sound"];
    }

}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

-(void)viewWillDisappear:(BOOL)animated {
    ((ViewController *)self.delegate).animalChooserVisible=NO;
}

-(void)viewDidAppear:(BOOL)animated {
    ViewController *initialView;
    initialView=(ViewController *)self.delegate;
    [initialView displayAnimal:[self.animalNames objectAtIndex:0]
                     withSound:[self.animalSounds objectAtIndex:0]
                 fromComponent:@"nothing yet..."];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{    
    self.animalNames=[[NSArray alloc]initWithObjects:
                      @"Mouse",@"Goose",@"Cat",@"Dog",@"Snake",@"Bear",@"Pig",nil];
	self.animalSounds=[[NSArray alloc]initWithObjects:
                       @"Oink",@"Rawr",@"Ssss",@"Roof",@"Meow",@"Honk",@"Squeak",nil];
	self.animalImages=[[NSArray alloc]initWithObjects:
                       [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mouse.png"]],
                       [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"goose.png"]],
                       [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cat.png"]],
                       [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dog.png"]],
                       [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"snake.png"]],
                       [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bear.png"]],
                       [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pig.png"]],
                       nil
                       ];
    
    [super viewDidLoad];
}


- (void)viewDidUnload
{
    [self setDelegate:nil];
    [self setAnimalNames:nil];
    [self setAnimalImages:nil];
    [self setAnimalSounds:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)dismissAnimalChooser:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
