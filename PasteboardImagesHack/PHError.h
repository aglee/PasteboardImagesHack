//
//  PHError.h
//  PasteboardImagesHack
//
//  Created by Andy Lee on 12/19/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define PHErrorDomain [[[NSBundle mainBundle] bundleIdentifier] stringByAppendingString:@".PHGeneralErrorDomain"]
#define PHError(errorCode, descFormat, ...) [NSError errorWithDomain:PHErrorDomain code:(errorCode) userInfo:@{ NSLocalizedDescriptionKey : [NSString stringWithFormat:(descFormat), ## __VA_ARGS__] }]

