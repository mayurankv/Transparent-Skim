//
//  SKPDFDocument.h
//  Skim
//
//  Created by Christiaan Hofman on 9/4/09.
/*
 This software is Copyright (c) 2009-2023
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
#import "PDFDocument_SKExtensions.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SKPDFDocumentDelegate;

@interface SKPDFDocument : PDFDocument {
    SKLanguageDirectionAngles *languageDirectionAngles;
    __weak NSDocument *containingDocument;
    NSMutableArray *detectedWidgets;
}
@property (nonatomic, nullable, weak) NSDocument *containingDocument;
@property (nonatomic, nullable, readonly) NSArray *detectedWidgets;
- (nullable id <SKPDFDocumentDelegate>)delegate;
- (void)setDelegate:(nullable id <SKPDFDocumentDelegate>)newDelegate;
- (void)detectedWidgets:(NSArray *)newWidgets onPage:(PDFPage *)page;
@end

#pragma mark -

@protocol SKPDFDocumentDelegate <PDFDocumentDelegate>
@optional
- (void)document:(PDFDocument *)document didUnlockWithPassword:(NSString *)password;
- (void)document:(PDFDocument *)document didDetectWidgets:(NSArray *)widgets onPage:(PDFPage *)page;
@end

NS_ASSUME_NONNULL_END
