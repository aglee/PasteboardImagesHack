//
//  PHWindowController.h
//  PasteboardImagesHack
//
//  Created by Andy Lee on 12/14/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum {
	/*!
	 * Images in the generated string are separated with tabs, so when the
	 * string is pasted into Numbers they will fill a row of cells.
	 */
	PHSpreadsheetFillRow = 0,

	/*!
	 * Images in the generated string are separated with newlines, so when the
	 * string is pasted into Numbers they will fill a column of cells.
	 */
	PHSpreadsheetFillColumn = 1,
} PHSpreadsheetFillDirection;

@interface PHWindowController : NSWindowController

/*!
 * If true, we proportionally scale images up or down to fit the size given by
 * imageBoundingWidth and imageBoundingHeight.
 */
@property (nonatomic, assign) BOOL shouldScaleImages;

/*! If non-zero, and shouldScaleImages is true, we try to scale the image to fill this width. */
@property (nonatomic, assign) NSInteger imageBoundingWidth;

/*! If non-zero, and shouldScaleImages is true, we try to scale the image to fill this height. */
@property (nonatomic, assign) NSInteger imageBoundingHeight;

@property (nonatomic, assign) PHSpreadsheetFillDirection spreadsheetFillDirection;

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
