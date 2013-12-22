# PasteboardImagesHack

This utility converts multiple images into a form that you can paste into a Numbers spreadsheet, whereupon they will fill a row or column of cells.

PasteboardImagesHack was inspired by a [tweet]( from Michael B. Johnson, aka @drwave.  I did it purely as a learning exercise and for fun, to see if it would work.  For all I know there's a simpler way to accomplish the same thing.


## Input

There are two ways to provide the input images:

* Drag and drop.  Drag image files onto the application window or the application icon.
* The clipboard.  Copy images (or image files) into the clipboard and either press the "Use Images on Clipboard" button or use the corresponding menu item.


## Output

Upon receiving input, the application constructs an attributed string that contains the input images.  There is an option to scale the images first.  Each image becomes a glyph in the string, and the glyphs are separated by either tabs or newlines, depending on whether you want to fill a row or a column in your spreadsheet.  The resulting string is put into the pasteboard, so you can immediately paste it into Numbers.

When you paste any string into Numbers, it normally puts the whole string into one cell, but if the string contains newlines or tabs, Numbers uses these separators to divide the string into substrings which go into separate cells.  It turns out that when one of those substrings consists of a single image glyph, Numbers makes the image the background image of the cell.

Pasting into Excel doesn't have the same effect.  I don't know why.


## Enhancements

I don't have any immediate plans for enhancements.  Here are some that come to mind if I were to do so:

* Save settings in user defaults so they persist between launches.
* Do the image operations on a background thread and be able to cancel.
* Figure out if there's a way to make this work for Excel too.

