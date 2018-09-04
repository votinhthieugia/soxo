//
//  AppController.mm
//  Copyright 2009 Friends Group. All rights reserved.
//

#import "AppController.h"

@implementation AppController

@synthesize window;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[window setOpaque:YES];
	[window setUserInteractionEnabled:YES];
	[window setMultipleTouchEnabled:YES];
	[window setExclusiveTouch:YES];
	
	Director::sharedNew(window);
    [window makeKeyAndVisible];
	
	Director::shared->start();
}

- (void)dealloc {
	Director::sharedDelete();
    [window release];
    [super dealloc];
}

- (void)applicationWillResignActive:(UIApplication *)application {
	// Getting a phone call. Pause the game.
 	Director::shared->pause();
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Resume the game.
	Director::shared->pause();
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

@end