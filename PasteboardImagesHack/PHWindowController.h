//
//  PHWindowController.h
//  PasteboardImagesHack
//
//  Created by Andy Lee on 12/14/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PHWindowController : NSWindowController

@property (strong) IBOutlet NSPopover *helpPopover;
@property (strong) IBOutlet NSTextView *helpTextView;
@property (strong) IBOutlet NSTextField *statusField;

@property (nonatomic, copy, readonly) NSAttributedString *resultString;
@property (strong) IBOutlet NSWindow *resultsWindow;
@property (strong) IBOutlet NSTextView *resultsTextView;

- (void)processImagesInPasteboard:(NSPasteboard *)sourcePasteboard;

- (void)processImagesWithFilePaths:(NSArray *)imageFilePaths;

#pragma mark - Action methods

- (IBAction)processImagesInGeneralPasteboard:(id)sender;

/*! Displays helpPopover. */
- (IBAction)showHelp:(id)sender;
- (IBAction)showResultsWindow:(id)sender;
- (IBAction)discardResults:(id)sender;
- (IBAction)putResultsInClipboard:(id)sender;

@end
