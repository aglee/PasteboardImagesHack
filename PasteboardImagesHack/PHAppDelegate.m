//
//  PHAppDelegate.m
//  PasteboardImagesHack
//
//  Created by Andy Lee on 12/14/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import "PHAppDelegate.h"
#import "PHWindowController.h"

@implementation PHAppDelegate
{
	PHWindowController *_windowController;
}

#pragma mark - NSApplicationDelegate methods

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	_windowController = [[PHWindowController alloc] initWithWindowNibName:@"PHWindowController"];
	[_windowController showWindow:nil];
	[NSApp activateIgnoringOtherApps:YES];
}

- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames
{
	[_windowController processImagesWithFilePaths:filenames];
}

@end
