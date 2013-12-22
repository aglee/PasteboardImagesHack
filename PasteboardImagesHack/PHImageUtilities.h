//
//  PHImageUtilities.h
//  PasteboardImagesHack
//
//  Created by Andy Lee on 12/20/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PHImageUtilities : NSObject

+ (NSImage *)imageWithPasteboardItem:(NSPasteboardItem *)pbItem
					   fileExtension:(NSString **)fileExtensionPtr
							   error:(NSError **)errorPtr;

+ (NSImage *)imageWithURL:(NSURL *)imageURL
			fileExtension:(NSString **)fileExtensionPtr
					error:(NSError **)errorPtr;

+ (NSImage *)imageWithData:(NSData *)imageData
			 fileExtension:(NSString **)fileExtensionPtr
					 error:(NSError **)errorPtr;

+ (NSImage *)imageWithCGImageSource:(CGImageSourceRef)imageSourceRef
					  fileExtension:(NSString **)fileExtensionPtr
							  error:(NSError **)errorPtr;

+ (NSImage *)imageByScalingImage:(NSImage *)originalImage
					   toFitSize:(NSSize)boundingSize;

@end
