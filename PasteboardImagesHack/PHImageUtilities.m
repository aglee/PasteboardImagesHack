//
//  PHImageUtilities.m
//  PasteboardImagesHack
//
//  Created by Andy Lee on 12/20/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import "PHImageUtilities.h"
#import "PHError.h"

@implementation PHImageUtilities

// The order in which we examine the contents of the pasteboard item matters.
// We check first for a file URL and then for image data.  We don't check for
// image data first, because if the user selects an image file in the Finder and
// does Copy, the pasteboard will contain image data, but it will be data for
// the file icon, not the file contents.
+ (NSImage *)imageWithPasteboardItem:(NSPasteboardItem *)pbItem
					   fileExtension:(NSString **)fileExtensionPtr
							   error:(NSError **)errorPtr
{
	// See if the pasteboard contains a file URL.
	NSString *fileURLType = [pbItem availableTypeFromArray:@[ (NSString *)kUTTypeFileURL ]];
	NSString *urlString = (fileURLType ? [pbItem stringForType:fileURLType] : nil);
	NSURL *imageFileURL;

	if (urlString)
	{
		imageFileURL = [NSURL URLWithString:urlString];
		if (imageFileURL == nil)
		{
			*errorPtr = PHError(0, (@"A pasteboard item contains [%@], which is is not a valid URL string."),
								urlString);
			return nil;
		}
	}

	// If so, load image data from the file.
	if (imageFileURL)
	{
		return [self imageWithURL:imageFileURL
					fileExtension:fileExtensionPtr
							error:errorPtr];
	}

	// Otherwise, if the pasteboard item contains image data, use that.
	NSArray *preferredUTIs = @[ (NSString *)kUTTypeJPEG,
								(NSString *)kUTTypeJPEG2000,
								(NSString *)kUTTypePNG,
								(NSString *)kUTTypeTIFF,
								(NSString *)kUTTypeImage ];
	NSString *imageType = [pbItem availableTypeFromArray:preferredUTIs];
	if (imageType)
	{
		return [self imageWithData:[pbItem dataForType:imageType]
					 fileExtension:fileExtensionPtr
							 error:errorPtr];
	}

	// If we got this far, we failed.
	*errorPtr = PHError(0, @"Could not detect image data in an item on the pasteboard.");
	return nil;
}

+ (NSImage *)imageWithURL:(NSURL *)imageURL
			fileExtension:(NSString **)fileExtensionPtr
					error:(NSError **)errorPtr
{
	// Contruct a CGImageSource.
	CGImageSourceRef imageSourceRef = CGImageSourceCreateWithURL((__bridge CFURLRef)imageURL, NULL);
	if (imageSourceRef == NULL)
	{
		*errorPtr = PHError(0, @"The function CGImageSourceCreateWithURL failed with URL [%@].", imageURL);
		return nil;
	}

	// Get an NSImage from the CGImageSource.
	NSImage *image = [self imageWithCGImageSource:imageSourceRef
									fileExtension:fileExtensionPtr
											error:errorPtr];
	if (image == nil)
	{
		if ([imageURL isFileURL])
		{
			*errorPtr = PHError(0, @"Could not get image data from the file at [%@]. %@",
								[[imageURL filePathURL] path],
								[*errorPtr localizedDescription]);
		}
		else
		{
			*errorPtr = PHError(0, @"Could not get image data from the URL [%@]. %@",
								imageURL,
								[*errorPtr localizedDescription]);
		}
		return nil;
	}

	// Clean up CF objects before returning.
	CFRelease(imageSourceRef);

	return image;
}

+ (NSImage *)imageWithData:(NSData *)imageData
			 fileExtension:(NSString **)fileExtensionPtr
					 error:(NSError **)errorPtr
{
	// Contruct a CGImageSource.
	CGImageSourceRef imageSourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
	if (imageSourceRef == NULL)
	{
		*errorPtr = PHError(0, @"Failed to create a CGImageSource.");
		return nil;
	}

	// Get an NSImage from the CGImageSource.
	NSImage *image = [self imageWithCGImageSource:imageSourceRef
									fileExtension:fileExtensionPtr
											error:errorPtr];

	// Clean up CF objects before returning.
	CFRelease(imageSourceRef);

	return image;
}

+ (NSImage *)imageWithCGImageSource:(CGImageSourceRef)imageSourceRef
					  fileExtension:(NSString **)fileExtensionPtr
							  error:(NSError **)errorPtr
{
	NSImage *image;

	// Create a CGImage.
	CGImageRef imageRef = CGImageSourceCreateImageAtIndex(imageSourceRef, 0, NULL);

	if (imageRef == NULL)
	{
		*errorPtr = PHError(0, @"Failed to extract image data.");
	}
	else
	{
		// Create an NSImage from the CGImage.
		NSString *imageUTI = (__bridge NSString *)CGImageSourceGetType(imageSourceRef);

		image = [[NSImage alloc] initWithCGImage:imageRef size:NSZeroSize];
		*fileExtensionPtr = [[NSWorkspace sharedWorkspace] preferredFilenameExtensionForType:imageUTI];

		// Clean up CF objects.
		CFRelease(imageRef);
	}

	return image;
}

+ (NSImage *)imageByScalingImage:(NSImage *)originalImage
					   toFitSize:(NSSize)boundingSize
{
	if (originalImage == nil)
	{
		return nil;
	}

	NSSize scaledImageSize = [self _scaleSize:originalImage.size toFitSize:boundingSize];
	NSImage *scaledImage = [[NSImage alloc] initWithSize:scaledImageSize];

	[scaledImage lockFocus];
	{{
		[NSGraphicsContext currentContext].imageInterpolation = NSImageInterpolationHigh;

		[originalImage drawInRect:(NSRect){ .origin = NSZeroPoint, .size = scaledImageSize }
						 fromRect:(NSRect){ .origin = NSZeroPoint, .size = [originalImage size] }
						operation:NSCompositeCopy
						 fraction:1.0];
	}}
	[scaledImage unlockFocus];

	return scaledImage;
}

#pragma mark - Private methods

+ (NSSize)_scaleSize:(NSSize)originalSize
		   toFitSize:(NSSize)boundingSize
{
	if (originalSize.width == 0 || originalSize.height == 0
		|| boundingSize.width == 0 || boundingSize.height == 0)
	{
		return originalSize;
	}

	CGFloat originalAspectRatio = originalSize.width / originalSize.height;
	CGFloat boundingAspectRatio = boundingSize.width / boundingSize.height;

	if (originalAspectRatio <= boundingAspectRatio)
	{
		// The bounding size is relatively wider, so the scaled size will fill the height.
		return NSMakeSize(originalSize.width * boundingSize.height / originalSize.height,
						  boundingSize.height);
	}
	else
	{
		// The original size is relatively wider, so the scaled size will fill the width.
		return NSMakeSize(boundingSize.width,
						  originalSize.height * boundingSize.width / originalSize.width);
	}
}

@end
