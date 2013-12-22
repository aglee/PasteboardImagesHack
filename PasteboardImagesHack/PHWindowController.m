//
//  PHWindowController.m
//  PasteboardImagesHack
//
//  Created by Andy Lee on 12/14/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import "PHWindowController.h"
#import "PHError.h"
#import "PHPrefs.h"
#import "PHImageUtilities.h"

@interface PHWindowController ()
@property (nonatomic, copy) NSAttributedString *resultString;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@end

@implementation PHWindowController

- (void)processImagesInPasteboard:(NSPasteboard *)sourcePasteboard
{
	[self _processImagesGivenByArray:[sourcePasteboard pasteboardItems]];
}

- (void)processImagesWithFilePaths:(NSArray *)imageFilePaths
{
	[self _processImagesGivenByArray:imageFilePaths];
}

#pragma mark - Action methods

- (IBAction)processImagesInGeneralPasteboard:(id)sender
{
	[self processImagesInPasteboard:[NSPasteboard generalPasteboard]];
}

- (IBAction)showHelp:(id)sender
{
    [self.helpPopover showRelativeToRect:[sender bounds]
                                  ofView:sender
                           preferredEdge:NSMaxYEdge];
	[self.helpTextView setNeedsDisplay:YES];
}

- (IBAction)showResultsWindow:(id)sender
{
	[self.resultsWindow orderFront:nil];
}

- (IBAction)discardResults:(id)sender
{
	self.resultString = nil;
	self.resultsTextView.textStorage.attributedString = [NSAttributedString new];
	[self _setStatus_NoResultsToShow];
}

- (IBAction)putResultsInClipboard:(id)sender
{
	if (self.resultString)
	{
		[[NSPasteboard generalPasteboard] clearContents];
		[[NSPasteboard generalPasteboard] writeObjects:@[ self.resultString ]];
	}
}

#pragma mark - NSWindowController methods

- (void)windowDidLoad
{
	// Set ivars.
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	dateFormatter.formatterBehavior = NSDateFormatterBehavior10_4;
	dateFormatter.dateFormat = @"yyyy-MM-dd hh:mm:ss aa";

	self.dateFormatter = dateFormatter;

	// Populate the help popover.
	NSString *helpFilePath = [[NSBundle mainBundle] pathForResource:@"Help" ofType:@"rtf"];
	NSAttributedString *helpText = [[NSAttributedString alloc] initWithPath:helpFilePath
														 documentAttributes:NULL];
	[self.helpTextView.textStorage setAttributedString:helpText];
	[self _setStatus_NoResultsToShow];

	// Tell the window to expect things to be dragged into it.
	[self.window registerForDraggedTypes:@[ (NSString *)kUTTypeImage,
											(NSString *)kUTTypeFileURL ]];
}

#pragma mark - NSDraggingDestination methods

- (NSDragOperation)draggingEntered:(id < NSDraggingInfo >)sender
{
	return NSDragOperationCopy;
}

- (BOOL)performDragOperation:(id < NSDraggingInfo >)sender
{
	[self processImagesInPasteboard:[sender draggingPasteboard]];
	return YES;
}

#pragma mark - Private methods

- (void)_processImagesGivenByArray:(NSArray *)sourceArray
{
	NSMutableAttributedString *stringWithAllImages = [NSMutableAttributedString new];
	NSString *separator = ([PHPrefs spreadsheetFillDirection] == PHSpreadsheetFillRow ? @"\t" : @"\r");
	NSAttributedString *attributedSeparator = [[NSAttributedString alloc] initWithString:separator];
	NSError *error;

	// Construct an attributed string containing all the images, separated by
	// either tabs or newlines.
	NSUInteger itemIndex = 0;
	for (id sourceObject in sourceArray)
	{
		[self _setStatus_ProcessingImageAtIndex:itemIndex count:[sourceArray count]];

		// Get an image from the source object and make it into a string.
		NSAttributedString *stringWithImage = [self _imageStringFromSourceObject:sourceObject
																		   error:&error];
		if (stringWithImage == nil)
		{
			[[NSAlert alertWithError:error] runModal];
			[self _setStatus_ConversionFailedOnDate:[NSDate date]];
			return;
		}

		// Add the glyph to the result string.
		if (stringWithAllImages.length)
		{
			[stringWithAllImages appendAttributedString:attributedSeparator];
		}
		[stringWithAllImages appendAttributedString:stringWithImage];

		// Prepare for next loop iteration.
		itemIndex++;
	}

	self.resultString = stringWithAllImages;
	self.resultsTextView.textStorage.attributedString = self.resultString;

	// Put the attributed string on the pasteboard, replacing whatever was there.
	(void)[[NSPasteboard generalPasteboard] clearContents];
	if ([[NSPasteboard generalPasteboard] writeObjects:@[ stringWithAllImages ]])
	{
		[self _setStatus_NumImages:[sourceArray count] wereProcessedOnDate:[NSDate date]];
	}
	else
	{
		error = PHError(0, @"Failed to write objects to the pasteboard.");
		[[NSAlert alertWithError:error] runModal];
		[self _setStatus_ConversionFailedOnDate:[NSDate date]];
	}
}

// Returns a string containing one glyph, namely the (possibly scaled) image
// derived from sourceObject.
- (NSAttributedString *)_imageStringFromSourceObject:(id)sourceObject
											   error:(NSError **)errorPtr
{
	if ([sourceObject isKindOfClass:[NSString class]])
	{
		return [self _imageStringFromFilePath:sourceObject error:errorPtr];
	}
	else if ([sourceObject isKindOfClass:[NSPasteboardItem class]])
	{
		return [self _imageStringFromPasteboardItem:sourceObject error:errorPtr];
	}
	else
	{
		*errorPtr = PHError(0, @"Unexpected object of type [%@]. Could not get image.",
							[sourceObject className]);
		return nil;
	}
}

- (NSAttributedString *)_imageStringFromFilePath:(NSString *)imageFilePath
										   error:(NSError **)errorPtr
{
	NSURL *imageURL = [NSURL fileURLWithPath:imageFilePath];
	if (imageURL == nil)
	{
		*errorPtr = PHError(0, (@"A valid URL could not be generated from the file path [%@]."),
							imageFilePath);
		return nil;
	}

	NSString *fileExtension;
	NSImage *image = [PHImageUtilities imageWithURL:imageURL
									  fileExtension:&fileExtension
											  error:errorPtr];
	return [self _imageStringFromOriginalImage:image
								 fileExtension:fileExtension
										 error:errorPtr];
}

- (NSAttributedString *)_imageStringFromPasteboardItem:(NSPasteboardItem *)pbItem
												 error:(NSError **)errorPtr
{
	NSString *fileExtension;
	NSImage *image = [PHImageUtilities imageWithPasteboardItem:pbItem
												 fileExtension:&fileExtension
														 error:errorPtr];
	return [self _imageStringFromOriginalImage:image
								 fileExtension:fileExtension
										 error:errorPtr];
}

- (NSAttributedString *)_imageStringFromOriginalImage:(NSImage *)image
										fileExtension:(NSString *)fileExtension
												error:(NSError **)errorPtr
{
	if (image == nil)
	{
		return nil;
	}

	// Maybe scale the image.
	if ([PHPrefs shouldScaleImages])
	{
		NSSize boundingSize = NSMakeSize([PHPrefs imageBoundingWidth], [PHPrefs imageBoundingHeight]);

		image = [PHImageUtilities imageByScalingImage:image toFitSize:boundingSize];
	}

	// Construct a file wrapper containing the image.
	NSFileWrapper *fileWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:[image TIFFRepresentation]];
	fileWrapper.preferredFilename = [@"Image" stringByAppendingPathExtension:fileExtension];

	// Construct and return a string containing the file wrapper.
	NSTextAttachment* textAttachment = [[NSTextAttachment alloc] initWithFileWrapper:fileWrapper];
	NSAttributedString *imageString = [NSAttributedString attributedStringWithAttachment:textAttachment];

	return imageString;
}

- (void)_setStatus_NoResultsToShow
{
	self.statusField.stringValue = @"No images processed.";
}

- (void)_setStatus_ProcessingImageAtIndex:(NSUInteger)imageIndex
									count:(NSUInteger)imageCount
{
	self.statusField.stringValue = [NSString stringWithFormat:@"Processing image %td of %td...",
									(imageIndex + 1), imageCount];
	[self.statusField display];
}

- (void)_setStatus_ConversionFailedOnDate:(NSDate *)date
{
	self.statusField.stringValue = [NSString stringWithFormat:@"Image processing failed at %@",
									[self.dateFormatter stringFromDate:date]];
}

- (void)_setStatus_NumImages:(NSUInteger)numImages
		 wereProcessedOnDate:(NSDate *)date
{
	self.statusField.stringValue = [NSString stringWithFormat:@"%td image%@ processed at %@",
									numImages,
									(numImages == 1 ? @" was" : @"s were"),
									[self.dateFormatter stringFromDate:date]];
}

@end
