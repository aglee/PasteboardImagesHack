//
//  PHPrefs.m
//  PasteboardImagesHack
//
//  Created by Andy Lee on 12/21/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import "PHPrefs.h"

@implementation PHPrefs

+ (BOOL)shouldScaleImages
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:PHUserDefaultsShouldScaleImages];
}

+ (CGFloat)imageBoundingWidth
{
	return [[NSUserDefaults standardUserDefaults] floatForKey:PHUserDefaultsImageBoundingWidth];
}

+ (CGFloat)imageBoundingHeight
{
	return [[NSUserDefaults standardUserDefaults] floatForKey:PHUserDefaultsImageBoundingHeight];
}

+ (PHSpreadsheetFillDirection)spreadsheetFillDirection
{
	return (PHSpreadsheetFillDirection)[[NSUserDefaults standardUserDefaults] integerForKey:PHUserDefaultsSpreadsheetFillDirection];
}

@end
