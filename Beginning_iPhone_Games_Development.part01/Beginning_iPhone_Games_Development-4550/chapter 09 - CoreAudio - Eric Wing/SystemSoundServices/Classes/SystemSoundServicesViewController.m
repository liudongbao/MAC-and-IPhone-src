//
//  SystemSoundServicesViewController.m
//  SystemSoundServices
//
//  Created by Eric Wing on 7/2/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "SystemSoundServicesViewController.h"


// Define a callback to be called when the sound is finished
// playing. Useful when you need to free memory after playing.
static void MySoundFinishedPlayingCallback(SystemSoundID sound_id, void* user_data)
{
	AudioServicesDisposeSystemSoundID(sound_id);
}


@implementation SystemSoundServicesViewController

@synthesize alertSoundID;


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void) viewDidLoad
{
	[super viewDidLoad];
	
	// Get the URL to the sound file contained within the app bundle. (This is autoreleased.)
	NSURL* alert_sound_url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"AlertChordStroke" ofType:@"wav"]];
	
	// Create a system sound object representing the sound file
	AudioServicesCreateSystemSoundID(
		(CFURLRef)alert_sound_url,
		&alertSoundID
	);
}

- (void) didReceiveMemoryWarning
{
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
	// Here would actually be a good place to release and SystemSoundIDs not in use.
	// But we would need support code to reload the sound files on demand if unloaded.
}


- (void) dealloc
{
	// Release the alert sound memory
	AudioServicesDisposeSystemSoundID(alertSoundID);	
	[super dealloc];
}

// Vibrate on action
- (IBAction) vibrate
{
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

// Play alert on action
- (IBAction) playAlertSound
{
	AudioServicesPlayAlertSound(self.alertSoundID);
}

// Play system sound on action
- (IBAction) playSystemSound
{
	// Get the URL to the sound file contained within the app bundle. (This is autoreleased.)
	NSURL* system_sound_url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"BeepGMC500" ofType:@"wav"]];
	SystemSoundID system_sound_id;
	
	// Create a system sound object representing the sound file
	AudioServicesCreateSystemSoundID(
		(CFURLRef)system_sound_url,
		&system_sound_id
	);

	// Since we allocated memory for the sound using local variables, we risk leaking memory.
	// To properly cleanup, we can register for a callback to happen when the sound finishes playing.
	// The callback will have the system_sound_id value of the sound that finished playing so we can cleanup 
	// the SystemSoundID.
	// We can also pass user data and release that memory in the callback too, but we don't need to do anything here.
	
    // Register the sound completion callback.
    AudioServicesAddSystemSoundCompletion(
		system_sound_id,
		NULL, // uses the main run loop
		NULL, // uses kCFRunLoopDefaultMode
		MySoundFinishedPlayingCallback, // the name of our custom callback function
		NULL // for user data, but we don't need to do that in this case, so we just pass NULL
	);

		// Play the System Sound
	AudioServicesPlaySystemSound(system_sound_id);
}

@end
