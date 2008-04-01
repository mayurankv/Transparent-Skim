//
//  SKPDFAnnotationNote.h
//  Skim
//
//  Created by Christiaan Hofman on 2/6/07.
/*
 This software is Copyright (c) 2007-2008
 Christiaan Hofman. All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:

 - Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.

 - Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in
    the documentation and/or other materials provided with the
    distribution.

 - Neither the name of Christiaan Hofman nor the names of any
    contributors may be used to endorse or promote products derived
    from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

extern NSString *SKPDFAnnotationTypeKey;
extern NSString *SKPDFAnnotationBoundsKey;
extern NSString *SKPDFAnnotationPageIndexKey;
extern NSString *SKPDFAnnotationContentsKey;
extern NSString *SKPDFAnnotationStringKey;
extern NSString *SKPDFAnnotationColorKey;
extern NSString *SKPDFAnnotationBorderKey;
extern NSString *SKPDFAnnotationLineWidthKey;
extern NSString *SKPDFAnnotationBorderStyleKey;
extern NSString *SKPDFAnnotationDashPatternKey;

extern NSString *SKPDFAnnotationInteriorColorKey;

extern NSString *SKPDFAnnotationQuadrilateralPointsKey;

extern NSString *SKPDFAnnotationFontKey;
extern NSString *SKPDFAnnotationFontNameKey;
extern NSString *SKPDFAnnotationFontSizeKey;
extern NSString *SKPDFAnnotationRotationKey;

extern NSString *SKPDFAnnotationIconTypeKey;
extern NSString *SKPDFAnnotationTextKey;
extern NSString *SKPDFAnnotationImageKey;

extern NSString *SKPDFAnnotationStartLineStyleKey;
extern NSString *SKPDFAnnotationEndLineStyleKey;
extern NSString *SKPDFAnnotationStartPointKey;
extern NSString *SKPDFAnnotationEndPointKey;

extern void SKCGContextSetDefaultRGBColorSpace(CGContextRef context);

@interface PDFAnnotation (SKExtensions)

- (id)initWithDictionary:(NSDictionary *)dict;

- (NSDictionary *)dictionaryValue;

- (NSString *)fdfString;

- (PDFDestination *)destination;
- (unsigned int)pageIndex;

- (PDFBorderStyle)borderStyle;
- (void)setBorderStyle:(PDFBorderStyle)style;
- (float)lineWidth;
- (void)setLineWidth:(float)width;
- (NSArray *)dashPattern;
- (void)setDashPattern:(NSArray *)pattern;

- (NSString *)string;
- (void)setString:(NSString *)newString;

- (NSImage *)image;
- (NSAttributedString *)text;

- (NSArray *)texts;

- (BOOL)isNoteAnnotation;
- (BOOL)isMarkupAnnotation;
- (BOOL)isTemporaryAnnotation;
- (BOOL)isResizable;
- (BOOL)isMovable;
- (BOOL)isEditable;

- (BOOL)isConvertibleAnnotation;
- (id)copyNoteAnnotation;

- (BOOL)hitTest:(NSPoint)point;

- (NSRect)displayRectForBounds:(NSRect)bounds;

- (NSSet *)keysForValuesToObserveForUndo;

- (NSScriptObjectSpecifier *)objectSpecifier;
- (int)scriptingNoteType;
- (int)scriptingIconType;
- (id)textContents;
- (void)setTextContents:(id)text;
- (id)richText;
- (void)setBoundsAsQDRect:(NSData *)inQDBoundsAsData;
- (NSData *)boundsAsQDRect;
- (NSString *)fontName;
- (float)fontSize;
- (int)scriptingBorderStyle;
- (void)setScriptingBorderStyle:(int)style;
- (NSData *)startPointAsQDPoint;
- (NSData *)endPointAsQDPoint;
- (int)scriptingStartLineStyle;
- (int)scriptingEndLineStyle;
- (id)selectionSpecifier;

@end

#pragma mark -

@interface SKPDFAnnotationCircle : PDFAnnotationCircle
@end

#pragma mark -

@interface SKPDFAnnotationSquare : PDFAnnotationSquare
@end

#pragma mark -

@interface SKPDFAnnotationMarkup : PDFAnnotationMarkup {
    NSRect *lineRects;
    unsigned numberOfLines;
}

- (id)initWithSelection:(PDFSelection *)selection markupType:(int)type;
- (PDFSelection *)selection;

@end

#pragma mark -

@interface SKPDFAnnotationFreeText : PDFAnnotationFreeText

- (void)setFontName:(NSString *)fontName;
- (void)setFontSize:(float)pointSize;

@end

#pragma mark -

@interface PDFAnnotationText (SKLeopardDeprecated)
// these are deprecated on 10.5, but we don't want to use the popup for 10.4 compatibility; we check for existence before using this anyway
- (BOOL)windowIsOpen;
- (void)setWindowIsOpen:(BOOL)isOpen;
@end

#pragma mark -

@interface SKPDFAnnotationNote : PDFAnnotationText {
    NSString *string;
    NSImage *image;
    NSTextStorage *textStorage;
    NSAttributedString *text;
    NSArray *texts;
}

- (void)setImage:(NSImage *)newImage;
- (void)setText:(NSAttributedString *)newText;

- (void)setRichText:(id)newText;

@end

#pragma mark -

@interface SKPDFAnnotationLine : PDFAnnotationLine

- (void)setStartPointAsQDPoint:(NSData *)inQDPointAsData;
- (void)setEndPointAsQDPoint:(NSData *)inQDPointAsData;
- (void)setScriptingStartLineStyle:(int)style;
- (void)setScriptingEndLineStyle:(int)style;

@end

#pragma mark -

@interface SKPDFAnnotationTemporary : PDFAnnotationCircle
@end

#pragma mark -

@interface SKNoteText : NSObject {
    PDFAnnotation *annotation;
}

- (id)initWithAnnotation:(PDFAnnotation *)anAnnotation;

- (PDFAnnotation *)annotation;

- (NSArray *)texts;

- (NSString *)type;
- (PDFPage *)page;
- (unsigned int)pageIndex;
- (NSAttributedString *)string;

@end

#pragma mark -

extern int SKScriptingBorderStyleFromBorderStyle(int borderStyle);
extern int SKBorderStyleFromScriptingBorderStyle(int borderStyle);
extern int SKScriptingLineStyleFromLineStyle(int lineStyle);
extern int SKLineStyleFromScriptingLineStyle(int lineStyle);
extern int SKScriptingIconTypeFromIconType(int iconType);
extern int SKIconTypeFromScriptingIconType(int iconType);

#pragma mark -

static inline
Rect RectFromNSRect(NSRect rect) {
    Rect qdRect;
    qdRect.left = round(NSMinX(rect));
    qdRect.bottom = round(NSMinY(rect));
    qdRect.right = round(NSMaxX(rect));
    qdRect.top = round(NSMaxY(rect));
    return qdRect;
}

static inline
NSRect NSRectFromRect(Rect qdRect) {
    NSRect rect;
    rect.origin.x = (float)qdRect.left;
    rect.origin.y = (float)qdRect.bottom;
    rect.size.width = (float)(qdRect.right - qdRect.left);
    rect.size.height = (float)(qdRect.top - qdRect.bottom);
    return rect;
}


static inline
Point PointFromNSPoint(NSPoint point) {
    Point qdPoint;
    qdPoint.h = round(point.x);
    qdPoint.v = round(point.y);
    return qdPoint;
}

static inline
NSPoint NSPointFromPoint(Point qdPoint) {
    NSPoint point;
    point.x = (float)qdPoint.h;
    point.y = (float)qdPoint.v;
    return point;
}
