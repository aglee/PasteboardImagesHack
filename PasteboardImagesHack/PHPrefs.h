//
//  PHPrefs.h
//  PasteboardImagesHack
//
//  Created by Andy Lee on 12/21/13.
//  Copyright (c) 2013 Andy Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PHUserDefaultsShouldScaleImages @"PHUserDefaultsShouldScaleImages"
#define PHUserDefaultsImageBoundingWidth @"PHUserDefaultsImageBoundingWidth"
#define PHUserDefaultsImageBoundingHeight @"PHUserDefaultsImageBoundingHeight"
#define PHUserDefaultsSpreadsheetFillDirection @"PHUserDefaultsSpreadsheetFillDirection"

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

@interface PHPrefs : NSObject

/*!
 * If true, we proportionally scale images up or down to fit the size given by
 * imageBoundingWidth and imageBoundingHeight.
 */
+ (BOOL)shouldScaleImages;

/*! If non-zero, and shouldScaleImages is true, we try to scale the image to fill this width. */
+ (CGFloat)imageBoundingWidth;

/*! If non-zero, and shouldScaleImages is true, we try to scale the image to fill this height. */
+ (CGFloat)imageBoundingHeight;

+ (PHSpreadsheetFillDirection)spreadsheetFillDirection;

@end
