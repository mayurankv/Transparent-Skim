//
//  SKMainWindowController.m
//  Skim
//
//  Created by Michael McCracken on 12/6/06.
/*
 This software is Copyright (c) 2006-2010
 Michael O. McCracken. All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:

 - Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.

 - Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in
    the documentation and/or other materials provided with the
    distribution.

 - Neither the name of Michael O. McCracken nor the names of any
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

#import "SKMainWindowController.h"
#import "SKMainToolbarController.h"
#import "SKMainWindowController_UI.h"
#import "SKMainWindowController_Actions.h"
#import "SKLeftSideViewController.h"
#import "SKRightSideViewController.h"
#import <Quartz/Quartz.h>
#import <Carbon/Carbon.h>
#import "SKStringConstants.h"
#import "SKNoteWindowController.h"
#import "SKInfoWindowController.h"
#import "SKBookmarkController.h"
#import "SKFullScreenWindow.h"
#import "SKNavigationWindow.h"
#import "SKSideWindow.h"
#import "PDFPage_SKExtensions.h"
#import "SKMainDocument.h"
#import "SKThumbnail.h"
#import "SKPDFView.h"
#import <SkimNotes/SkimNotes.h>
#import "PDFAnnotation_SKExtensions.h"
#import "SKNPDFAnnotationNote_SKExtensions.h"
#import "SKNoteText.h"
#import "SKPDFAnnotationTemporary.h"
#import "SKSplitView.h"
#import "NSScrollView_SKExtensions.h"
#import "NSBezierPath_SKExtensions.h"
#import "NSUserDefaultsController_SKExtensions.h"
#import "NSUserDefaults_SKExtensions.h"
#import "SKTocOutlineView.h"
#import "SKNoteOutlineView.h"
#import "SKThumbnailTableView.h"
#import "SKFindTableView.h"
#import "SKNoteTypeSheetController.h";
#import "SKAnnotationTypeImageCell.h"
#import "NSWindowController_SKExtensions.h"
#import "SKImageToolTipWindow.h"
#import "PDFSelection_SKExtensions.h"
#import "SKToolbarItem.h"
#import "NSValue_SKExtensions.h"
#import "NSString_SKExtensions.h"
#import "SKReadingBar.h"
#import "SKLineInspector.h"
#import "SKStatusBar.h"
#import "SKTransitionController.h"
#import "SKPresentationOptionsSheetController.h"
#import "SKTypeSelectHelper.h"
#import "NSGeometry_SKExtensions.h"
#import "SKProgressController.h"
#import "SKSecondaryPDFView.h"
#import "SKTextFieldSheetController.h"
#import "SKColorSwatch.h"
#import "SKApplicationController.h"
#import "NSSegmentedControl_SKExtensions.h"
#import "NSImage_SKExtensions.h"
#import "NSMenu_SKExtensions.h"
#import "SKGroupedSearchResult.h"
#import "RemoteControl.h"
#import "NSView_SKExtensions.h"
#import "NSResponder_SKExtensions.h"
#import "PDFOutline_SKExtensions.h"
#import "NSPointerArray_SKExtensions.h"
#import "SKFloatMapTable.h"
#import "SKColorCell.h"
#import "PDFDocument_SKExtensions.h"
#import "SKPDFPage.h"

#define MULTIPLICATION_SIGN_CHARACTER 0x00d7

#define PRESENTATION_SIDE_WINDOW_ALPHA 0.95

#define PAGELABELS_KEY              @"pageLabels"
#define SEARCHRESULTS_KEY           @"searchResults"
#define GROUPEDSEARCHRESULTS_KEY    @"groupedSearchResults"
#define NOTES_KEY                   @"notes"
#define THUMBNAILS_KEY              @"thumbnails"
#define SNAPSHOTS_KEY               @"snapshots"

#define PAGE_COLUMNID  @"page"
#define NOTE_COLUMNID  @"note"
#define COLOR_COLUMNID @"color"

#define RELEVANCE_COLUMNID  @"relevance"
#define RESULTS_COLUMNID    @"results"

#define PAGENUMBER_KEY  @"pageNumber"
#define PAGELABEL_KEY   @"pageLabel"

#define CONTENTVIEW_KEY @"contentView"
#define BUTTONVIEW_KEY @"buttonView"
#define FIRSTRESPONDER_KEY @"firstResponder"

#define SKMainWindowFrameKey        @"windowFrame"
#define LEFTSIDEPANEWIDTH_KEY       @"leftSidePaneWidth"
#define RIGHTSIDEPANEWIDTH_KEY      @"rightSidePaneWidth"
#define SCALEFACTOR_KEY             @"scaleFactor"
#define AUTOSCALES_KEY              @"autoScales"
#define DISPLAYPAGEBREAKS_KEY       @"displaysPageBreaks"
#define DISPLAYASBOOK_KEY           @"displaysAsBook" 
#define DISPLAYMODE_KEY             @"displayMode"
#define DISPLAYBOX_KEY              @"displayBox"
#define HASHORIZONTALSCROLLER_KEY   @"hasHorizontalScroller"
#define HASVERTICALSCROLLER_KEY     @"hasVerticalScroller"
#define AUTOHIDESSCROLLERS_KEY      @"autoHidesScrollers"
#define PAGEINDEX_KEY               @"pageIndex"

#define PAGETRANSITIONS_KEY @"pageTransitions"

#define SKMainWindowFrameAutosaveName @"SKMainWindow"

static char SKNPDFAnnotationPropertiesObservationContext;

static char SKMainWindowDefaultsObservationContext;

#define SKLeftSidePaneWidthKey @"SKLeftSidePaneWidth"
#define SKRightSidePaneWidthKey @"SKRightSidePaneWidth"

#define SKUsesDrawersKey @"SKUsesDrawers"
#define SKDisableAnimatedSearchHighlightKey @"SKDisableAnimatedSearchHighlight"

#define SKDisplayNoteBoundsKey @"SKDisplayNoteBounds" 

@interface SKMainWindowController (SKPrivate)

- (void)applyLeftSideWidth:(CGFloat)leftSideWidth rightSideWidth:(CGFloat)rightSideWidth;

- (void)setupToolbar;

- (void)updatePageLabel;

- (SKProgressController *)progressController;

- (void)goToSelectedFindResults:(id)sender;
- (void)updateFindResultHighlights:(BOOL)scroll;

- (void)selectSelectedNote:(id)sender;
- (void)goToSelectedOutlineItem:(id)sender;
- (void)toggleSelectedSnapshots:(id)sender;

- (void)updateNoteFilterPredicate;

- (void)registerForDocumentNotifications;
- (void)unregisterForDocumentNotifications;

- (void)registerAsObserver;
- (void)unregisterAsObserver;

- (void)startObservingNotes:(NSArray *)newNotes;
- (void)stopObservingNotes:(NSArray *)oldNotes;

- (void)observeUndoManagerCheckpoint:(NSNotification *)notification;

@end


@implementation SKMainWindowController

@synthesize mainWindow, splitView, centerContentView, pdfSplitView, pdfContentView, pdfView, leftSideController, rightSideController, toolbarController, leftSideContentView, rightSideContentView, progressController, presentationNotesDocument, tags, rating, pageNumber, pageLabel;
@dynamic pdfDocument, presentationOptions, selectedNotes, isPresentation, isFullScreen, autoScales, leftSidePaneState, rightSidePaneState, findPaneState, leftSidePaneIsOpen, rightSidePaneIsOpen;

+ (void)initialize {
    SKINITIALIZE;
    
    [PDFPage setUsesSequentialPageNumbering:[[NSUserDefaults standardUserDefaults] boolForKey:SKSequentialPageNumberingKey]];
}

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    if ([key isEqualToString:PAGENUMBER_KEY] || [key isEqualToString:PAGELABEL_KEY])
        return NO;
    else
        return [super automaticallyNotifiesObserversForKey:key];
}

- (id)init {
    if (self = [super initWithWindowNibName:@"MainWindow"]) {
        mwcFlags.isPresentation = 0;
        searchResults = [[NSMutableArray alloc] init];
        mwcFlags.findPanelFind = 0;
        mwcFlags.caseInsensitiveSearch = 1;
        mwcFlags.wholeWordSearch = 0;
        mwcFlags.caseInsensitiveNoteSearch = 1;
        groupedSearchResults = [[NSMutableArray alloc] init];
        thumbnails = [[NSMutableArray alloc] init];
        notes = [[NSMutableArray alloc] init];
        tags = [[NSArray alloc] init];
        rating = 0.0;
        snapshots = [[NSMutableArray alloc] init];
        dirtySnapshots = [[NSMutableArray alloc] init];
        pageLabels = [[NSMutableArray alloc] init];
        lastViewedPages = [[NSMutableArray alloc] init];
        rowHeights = [[SKFloatMapTable alloc] init];
        savedNormalSetup = [[NSMutableDictionary alloc] init];
        mwcFlags.leftSidePaneState = SKThumbnailSidePaneState;
        mwcFlags.rightSidePaneState = SKNoteSidePaneState;
        mwcFlags.findPaneState = SKSingularFindPaneState;
        temporaryAnnotations = [[NSMutableSet alloc] init];
        pageLabel = nil;
        pageNumber = NSNotFound;
        markedPageIndex = NSNotFound;
        beforeMarkedPageIndex = NSNotFound;
        mwcFlags.updatingColor = 0;
        mwcFlags.updatingFont = 0;
        mwcFlags.updatingLine = 0;
        mwcFlags.usesDrawers = [[NSUserDefaults standardUserDefaults] boolForKey:SKUsesDrawersKey];
        activityAssertionID = kIOPMNullAssertionID;
    }
    
    return self;
}

- (void)dealloc {
    [self stopObservingNotes:[self notes]];
    SKDESTROY(undoGroupOldPropertiesPerNote);
	[[NSNotificationCenter defaultCenter] removeObserver: self];
    [self unregisterAsObserver];
    [mainWindow setDelegate:nil];
    [fullScreenWindow setDelegate:nil];
    [splitView setDelegate:nil];
    [pdfSplitView setDelegate:nil];
    [pdfView setDelegate:nil];
    [[pdfView document] setDelegate:nil];
    [leftSideDrawer setDelegate:nil];
    [rightSideDrawer setDelegate:nil];
    [noteTypeSheetController setDelegate:nil];
    SKDESTROY(temporaryAnnotations);
    SKDESTROY(dirtySnapshots);
	SKDESTROY(searchResults);
	SKDESTROY(groupedSearchResults);
	SKDESTROY(thumbnails);
	SKDESTROY(notes);
	SKDESTROY(snapshots);
	SKDESTROY(tags);
    SKDESTROY(pageLabels);
    SKDESTROY(pageLabel);
	SKDESTROY(rowHeights);
    SKDESTROY(lastViewedPages);
	SKDESTROY(leftSideWindow);
	SKDESTROY(rightSideWindow);
	SKDESTROY(fullScreenWindow);
    SKDESTROY(mainWindow);
    SKDESTROY(statusBar);
    SKDESTROY(savedNormalSetup);
    SKDESTROY(progressController);
    SKDESTROY(colorAccessoryView);
    SKDESTROY(textColorAccessoryView);
    SKDESTROY(leftSideDrawer);
    SKDESTROY(rightSideDrawer);
    SKDESTROY(secondaryPdfContentView);
    SKDESTROY(presentationNotesDocument);
    SKDESTROY(noteTypeSheetController);
    SKDESTROY(splitView);
    SKDESTROY(centerContentView);
    SKDESTROY(pdfSplitView);
    SKDESTROY(pdfContentView);
    SKDESTROY(pdfView);
    SKDESTROY(leftSideController);
    SKDESTROY(rightSideController);
    SKDESTROY(toolbarController);
    SKDESTROY(leftSideContentView);
    SKDESTROY(rightSideContentView);
    [super dealloc];
}

- (void)windowDidLoad{
    NSUserDefaults *sud = [NSUserDefaults standardUserDefaults];
    BOOL hasWindowSetup = [savedNormalSetup count] > 0;
    
    mwcFlags.settingUpWindow = 1;
    
    // Set up the panes and subviews, needs to be done before we resize them
    [pdfSplitView setFrame:[centerContentView bounds]];
    [centerContentView addSubview:pdfSplitView];
    
    // This gets sometimes messed up in the nib, AppKit bug rdar://5346690
    [leftSideContentView setAutoresizesSubviews:YES];
    [rightSideContentView setAutoresizesSubviews:YES];
    [centerContentView setAutoresizesSubviews:YES];
    [pdfContentView setAutoresizesSubviews:YES];
    
    // make sure the first thing we call on the side view controllers is its view so their nib is loaded
    NSRect rect = [leftSideContentView bounds];
    if (mwcFlags.usesDrawers == 0) {
        rect = NSInsetRect(rect, -1, -1);
        rect.size.height -= 1;
    }
    [[leftSideController view] setFrame:rect];
    [leftSideContentView addSubview:leftSideController.view];
    rect = [rightSideContentView bounds];
    if (mwcFlags.usesDrawers == 0) {
        rect = NSInsetRect(rect, -1, -1);
        rect.size.height -= 1;
    }
    [[rightSideController view] setFrame:rect];
    [rightSideContentView addSubview:rightSideController.view];
    
    [leftSideController.searchField setAction:@selector(search:)];
    [leftSideController.searchField setTarget:self];
    [rightSideController.searchField setAction:@selector(searchNotes:)];
    [rightSideController.searchField setTarget:self];
    
    [rightSideController.noteOutlineView setDoubleAction:@selector(selectSelectedNote:)];
    [rightSideController.noteOutlineView setTarget:self];
    [leftSideController.tocOutlineView setDoubleAction:@selector(goToSelectedOutlineItem:)];
    [leftSideController.tocOutlineView setTarget:self];
    [rightSideController.snapshotTableView setDoubleAction:@selector(toggleSelectedSnapshots:)];
    [rightSideController.snapshotTableView setTarget:self];
    [leftSideController.findTableView setDoubleAction:@selector(goToSelectedFindResults:)];
    [leftSideController.findTableView setTarget:self];
    [leftSideController.groupedFindTableView setDoubleAction:@selector(goToSelectedFindResults:)];
    [leftSideController.groupedFindTableView setTarget:self];
    
    if (mwcFlags.usesDrawers) {
        leftSideDrawer = [[NSDrawer alloc] initWithContentSize:[leftSideContentView frame].size preferredEdge:NSMinXEdge];
        [leftSideDrawer setParentWindow:[self window]];
        [leftSideDrawer setContentView:leftSideContentView];
        [leftSideDrawer openOnEdge:NSMinXEdge];
        [leftSideDrawer setDelegate:self];
        rightSideDrawer = [[NSDrawer alloc] initWithContentSize:[rightSideContentView frame].size preferredEdge:NSMaxXEdge];
        [rightSideDrawer setParentWindow:[self window]];
        [rightSideDrawer setContentView:rightSideContentView];
        [rightSideDrawer openOnEdge:NSMaxXEdge];
        [rightSideDrawer setDelegate:self];
        [centerContentView setFrame:[splitView bounds]];
    }
    
    [self displayThumbnailViewAnimating:NO];
    [self displayNoteViewAnimating:NO];
    
    // we need to create the PDFView before setting the toolbar
    pdfView = [[SKPDFView alloc] initWithFrame:[pdfContentView bounds]];
    [pdfView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    
    // Set up the tool bar
    [toolbarController setupToolbar];
    
    // Set up the window
    [self setWindowFrameAutosaveNameOrCascade:SKMainWindowFrameAutosaveName];
    
    [[self window] setAutorecalculatesContentBorderThickness:NO forEdge:NSMinYEdge];
    
    if ([sud boolForKey:SKShowStatusBarKey])
        [self toggleStatusBar:nil];
    
    NSInteger windowSizeOption = [sud integerForKey:SKInitialWindowSizeOptionKey];
    if (hasWindowSetup) {
        NSString *rectString = [savedNormalSetup objectForKey:SKMainWindowFrameKey];
        if (rectString)
            [[self window] setFrame:NSRectFromString(rectString) display:NO];
    } else if (windowSizeOption == SKMaximizeWindowOption) {
        [[self window] setFrame:[[NSScreen mainScreen] visibleFrame] display:NO];
    }
    
    // Set up the PDF
    [pdfView setShouldAntiAlias:[sud boolForKey:SKShouldAntiAliasKey]];
    [pdfView setGreekingThreshold:[sud floatForKey:SKGreekingThresholdKey]];
    [pdfView setBackgroundColor:[sud colorForKey:SKBackgroundColorKey]];
    
    [self applyPDFSettings:hasWindowSetup ? savedNormalSetup : [sud dictionaryForKey:SKDefaultPDFDisplaySettingsKey]];
    
    [pdfView setDelegate:self];
    
    NSNumber *leftWidth = [savedNormalSetup objectForKey:LEFTSIDEPANEWIDTH_KEY] ?: [sud objectForKey:SKLeftSidePaneWidthKey];
    NSNumber *rightWidth = [savedNormalSetup objectForKey:RIGHTSIDEPANEWIDTH_KEY] ?: [sud objectForKey:SKRightSidePaneWidthKey];
    
    if (leftWidth && rightWidth)
        [self applyLeftSideWidth:[leftWidth doubleValue] rightSideWidth:[rightWidth doubleValue]];
    
    // this needs to be done before loading the PDFDocument
    [self resetThumbnailSizeIfNeeded];
    [self resetSnapshotSizeIfNeeded];
    
    // this needs to be done before loading the PDFDocument
    NSSortDescriptor *pageIndexSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:SKNPDFAnnotationPageIndexKey ascending:YES] autorelease];
    NSSortDescriptor *boundsSortDescriptor = [[[NSSortDescriptor alloc] initWithKey:SKNPDFAnnotationBoundsKey ascending:YES selector:@selector(boundsCompare:)] autorelease];
    [rightSideController.noteArrayController setSortDescriptors:[NSArray arrayWithObjects:pageIndexSortDescriptor, boundsSortDescriptor, nil]];
    [rightSideController.snapshotArrayController setSortDescriptors:[NSArray arrayWithObjects:pageIndexSortDescriptor, nil]];
    
    NSSortDescriptor *countDescriptor = [[[NSSortDescriptor alloc] initWithKey:SKGroupedSearchResultCountKey ascending:NO] autorelease];
    [leftSideController.groupedFindArrayController setSortDescriptors:[NSArray arrayWithObjects:countDescriptor, nil]];
    [[[leftSideController.groupedFindTableView tableColumnWithIdentifier:RELEVANCE_COLUMNID] dataCell] setEnabled:NO];
        
    // NB: the next line will load the PDF document and annotations, so necessary setup must be finished first!
    // windowControllerDidLoadNib: is not called automatically because the document overrides makeWindowControllers
    [[self document] windowControllerDidLoadNib:self];
    
    // Show/hide left side pane if necessary
    BOOL hasOutline = ([[pdfView document] outlineRoot] != nil);
    if ([sud boolForKey:SKOpenContentsPaneOnlyForTOCKey] && [self leftSidePaneIsOpen] != hasOutline)
        [self toggleLeftSidePane:nil];
    if (hasOutline)
        [self setLeftSidePaneState:SKOutlineSidePaneState];
    else
        [leftSideController.button setEnabled:NO forSegment:SKOutlineSidePaneState];
    
    // Due to a bug in Leopard we should only resize and swap in the PDFView after loading the PDFDocument
    [pdfView setFrame:[pdfContentView bounds]];
    [pdfContentView addSubview:pdfView];
    
    // Go to page?
    NSUInteger pageIndex = NSNotFound;
    if (hasWindowSetup)
        pageIndex = [[savedNormalSetup objectForKey:PAGEINDEX_KEY] unsignedIntegerValue];
    else if ([sud boolForKey:SKRememberLastPageViewedKey])
        pageIndex = [[SKBookmarkController sharedBookmarkController] pageIndexForRecentDocumentAtPath:[[[self document] fileURL] path]];
    if (pageIndex != NSNotFound && [[pdfView document] pageCount] > pageIndex)
        [pdfView goToPage:[[pdfView document] pageAtIndex:pageIndex]];
    
    // We can fit only after the PDF has been loaded
    if (windowSizeOption == SKFitWindowOption && hasWindowSetup == NO)
        [self performFit:self];
    
    // Open snapshots?
    NSArray *snapshotSetups = nil;
    if (hasWindowSetup)
        snapshotSetups = [savedNormalSetup objectForKey:SNAPSHOTS_KEY];
    else if ([sud boolForKey:SKRememberSnapshotsKey])
        snapshotSetups = [[SKBookmarkController sharedBookmarkController] snapshotsForRecentDocumentAtPath:[[[self document] fileURL] path]];
    if ([snapshotSetups count])
        [self showSnapshotsWithSetups:snapshotSetups];
    
    noteTypeSheetController = [[SKNoteTypeSheetController alloc] init];
    [noteTypeSheetController setDelegate:self];
    [[rightSideController.noteOutlineView headerView] setMenu:[noteTypeSheetController noteTypeMenu]];
    
    [pdfView setTypeSelectHelper:[leftSideController.thumbnailTableView typeSelectHelper]];
    
    [[self window] recalculateKeyViewLoop];
    [[self window] makeFirstResponder:pdfView];
    
    // Update page states
    [self handlePageChangedNotification:nil];
    [toolbarController handlePageChangedNotification:nil];
    
    // Observe notifications and KVO
    [self registerForNotifications];
    [self registerAsObserver];
    
    if (hasWindowSetup)
        [savedNormalSetup removeAllObjects];
    
    mwcFlags.settingUpWindow = 0;
}

- (void)applyLeftSideWidth:(CGFloat)leftSideWidth rightSideWidth:(CGFloat)rightSideWidth {
    if (mwcFlags.usesDrawers == 0) {
        [splitView setPosition:leftSideWidth ofDividerAtIndex:0];
        [splitView setPosition:[splitView maxPossiblePositionOfDividerAtIndex:1] - [splitView dividerThickness] - rightSideWidth ofDividerAtIndex:1];
    } else {
        if (leftSideWidth > 0.0) {
            [leftSideDrawer setContentSize:NSMakeSize(leftSideWidth, NSHeight([leftSideContentView frame]))];
            [leftSideDrawer openOnEdge:NSMinXEdge];
        } else {
            [leftSideDrawer close];
        }
        if (rightSideWidth > 0.0) {
            [rightSideDrawer setContentSize:NSMakeSize(leftSideWidth, NSHeight([rightSideContentView frame]))];
            [rightSideDrawer openOnEdge:NSMaxXEdge];
        } else {
            [rightSideDrawer close];
        }
    }
}

- (void)applySetup:(NSDictionary *)setup{
    if ([self isWindowLoaded] == NO) {
        [savedNormalSetup setDictionary:setup];
    } else {
        
        NSString *rectString = [setup objectForKey:SKMainWindowFrameKey];
        if (rectString)
            [mainWindow setFrame:NSRectFromString([setup objectForKey:SKMainWindowFrameKey]) display:YES];
        
        NSNumber *leftWidth = [setup objectForKey:LEFTSIDEPANEWIDTH_KEY];
        NSNumber *rightWidth = [setup objectForKey:RIGHTSIDEPANEWIDTH_KEY];
        if (leftWidth && rightWidth)
            [self applyLeftSideWidth:[leftWidth doubleValue] rightSideWidth:[rightWidth doubleValue]];
        
        NSUInteger pageIndex = [[setup objectForKey:PAGEINDEX_KEY] unsignedIntegerValue];
        if (pageIndex != NSNotFound)
            [pdfView goToPage:[[pdfView document] pageAtIndex:pageIndex]];
        
        NSArray *snapshotSetups = [setup objectForKey:SNAPSHOTS_KEY];
        if ([snapshotSetups count])
            [self showSnapshotsWithSetups:snapshotSetups];
        
        if ([self isFullScreen] || [self isPresentation])
            [savedNormalSetup addEntriesFromDictionary:setup];
        else
            [self applyPDFSettings:setup];
    }
}

- (NSDictionary *)currentSetup {
    NSMutableDictionary *setup = [NSMutableDictionary dictionary];
    
    [setup setObject:NSStringFromRect([mainWindow frame]) forKey:SKMainWindowFrameKey];
    [setup setObject:[NSNumber numberWithDouble:[self leftSidePaneIsOpen] ? NSWidth([leftSideContentView frame]) : 0.0] forKey:LEFTSIDEPANEWIDTH_KEY];
    [setup setObject:[NSNumber numberWithDouble:[self rightSidePaneIsOpen] ? NSWidth([rightSideContentView frame]) : 0.0] forKey:RIGHTSIDEPANEWIDTH_KEY];
    [setup setObject:[NSNumber numberWithUnsignedInteger:[[pdfView currentPage] pageIndex]] forKey:PAGEINDEX_KEY];
    if ([snapshots count])
        [setup setObject:[snapshots valueForKey:SKSnapshotCurrentSetupKey] forKey:SNAPSHOTS_KEY];
    if ([self isFullScreen] || [self isPresentation]) {
        [setup addEntriesFromDictionary:savedNormalSetup];
        [setup removeObjectsForKeys:[NSArray arrayWithObjects:HASHORIZONTALSCROLLER_KEY, HASVERTICALSCROLLER_KEY, AUTOHIDESSCROLLERS_KEY, nil]];
    } else {
        [setup addEntriesFromDictionary:[self currentPDFSettings]];
    }
    
    return setup;
}

- (void)applyPDFSettings:(NSDictionary *)setup {
    NSNumber *number;
    if (number = [setup objectForKey:SCALEFACTOR_KEY])
        [pdfView setScaleFactor:[number doubleValue]];
    if (number = [setup objectForKey:AUTOSCALES_KEY])
        [pdfView setAutoScales:[number boolValue]];
    if (number = [setup objectForKey:DISPLAYPAGEBREAKS_KEY])
        [pdfView setDisplaysPageBreaks:[number boolValue]];
    if (number = [setup objectForKey:DISPLAYASBOOK_KEY])
        [pdfView setDisplaysAsBook:[number boolValue]];
    if (number = [setup objectForKey:DISPLAYMODE_KEY])
        [pdfView setDisplayMode:[number integerValue]];
    if (number = [setup objectForKey:DISPLAYBOX_KEY])
        [pdfView setDisplayBox:[number integerValue]];
}

- (NSDictionary *)currentPDFSettings {
    NSMutableDictionary *setup = [NSMutableDictionary dictionary];
    
    if ([self isPresentation]) {
        [setup setDictionary:savedNormalSetup];
        [setup removeObjectsForKeys:[NSArray arrayWithObjects:HASHORIZONTALSCROLLER_KEY, HASVERTICALSCROLLER_KEY, AUTOHIDESSCROLLERS_KEY, nil]];
    } else {
        [setup setObject:[NSNumber numberWithBool:[pdfView displaysPageBreaks]] forKey:DISPLAYPAGEBREAKS_KEY];
        [setup setObject:[NSNumber numberWithBool:[pdfView displaysAsBook]] forKey:DISPLAYASBOOK_KEY];
        [setup setObject:[NSNumber numberWithInteger:[pdfView displayBox]] forKey:DISPLAYBOX_KEY];
        [setup setObject:[NSNumber numberWithDouble:[pdfView scaleFactor]] forKey:SCALEFACTOR_KEY];
        [setup setObject:[NSNumber numberWithBool:[pdfView autoScales]] forKey:AUTOSCALES_KEY];
        [setup setObject:[NSNumber numberWithInteger:[pdfView displayMode]] forKey:DISPLAYMODE_KEY];
    }
    
    return setup;
}

#pragma mark UI updating

- (void)updateLeftStatus {
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Page %ld of %ld", @"Status message"), (long)[self pageNumber], (long)[[pdfView document] pageCount]];
    [statusBar setLeftStringValue:message];
}

- (void)updateRightStatus {
    NSRect rect = [pdfView currentSelectionRect];
    CGFloat magnification = [pdfView currentMagnification];
    NSString *message;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:SKDisplayNoteBoundsKey] && NSEqualRects(rect, NSZeroRect) && [pdfView activeAnnotation])
        rect = [[pdfView activeAnnotation] bounds];
    
    if (NSEqualRects(rect, NSZeroRect) == NO) {
        if ([statusBar rightState] == NSOnState) {
            BOOL useMetric = [[[NSLocale currentLocale] objectForKey:NSLocaleUsesMetricSystem] boolValue];
            NSString *units = useMetric ? @"cm" : @"in";
            CGFloat factor = useMetric ? 0.035277778 : 0.013888889;
            message = [NSString stringWithFormat:@"%.2f %C %.2f @ (%.2f, %.2f) %@", NSWidth(rect) * factor, MULTIPLICATION_SIGN_CHARACTER, NSHeight(rect) * factor, NSMinX(rect) * factor, NSMinY(rect) * factor, units];
        } else {
            message = [NSString stringWithFormat:@"%ld %C %ld @ (%ld, %ld) pt", (long)NSWidth(rect), MULTIPLICATION_SIGN_CHARACTER, (long)NSHeight(rect), (long)NSMinX(rect), (long)NSMinY(rect)];
        }
    } else if (magnification > 0.0001) {
        message = [NSString stringWithFormat:@"%.2f %C", magnification, MULTIPLICATION_SIGN_CHARACTER];
    } else {
        message = @"";
    }
    [statusBar setRightStringValue:message];
}

- (void)updatePageColumnWidthForTableView:(NSTableView *)tv {
    NSTableColumn *tableColumn = [tv tableColumnWithIdentifier:PAGE_COLUMNID];
    id cell = [tableColumn dataCell];
    CGFloat labelWidth = [tv headerView] ? [[tableColumn headerCell] cellSize].width : 0.0;
    
    for (NSString *label in pageLabels) {
        [cell setStringValue:label];
        labelWidth = fmax(labelWidth, [cell cellSize].width);
    }
    
    [tableColumn setMinWidth:labelWidth];
    [tableColumn setMaxWidth:labelWidth];
    [tableColumn setWidth:labelWidth];
    [tv sizeToFit];
}

- (NSDictionary *)openStateForOutline:(PDFOutline *)anOutline {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:[anOutline label] forKey:@"label"];
    BOOL isOpen = ([anOutline parent] == nil || [leftSideController.tocOutlineView isItemExpanded:anOutline]);
    [dict setValue:[NSNumber numberWithBool:isOpen] forKey:@"isOpen"];
    if (isOpen) {
        NSUInteger i, iMax = [anOutline numberOfChildren];
        if (iMax > 0) {
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (i = 0; i < iMax; i++)
                [array addObject:[self openStateForOutline:[anOutline childAtIndex:i]]];
            [dict setValue:array forKey:@"children"];
            [array release];
        }
    }
    return dict;
}

- (void)openOutline:(PDFOutline *)anOutline forOpenState:(NSDictionary *)info {
    BOOL isOpen = info ? [[info valueForKey:@"isOpen"] boolValue] : [anOutline isOpen];
    if (isOpen) {
        NSUInteger i, iMax = [anOutline numberOfChildren];
        NSMutableArray *children = [[NSMutableArray alloc] init];
        for (i = 0; i < iMax; i++)
            [children addObject:[anOutline childAtIndex:i]];
        NSArray *childrenStates = [info valueForKey:@"children"];
        if ([anOutline parent])
            [leftSideController.tocOutlineView expandItem:anOutline];
        NSEnumerator *infoEnum = nil;
        if ([[children valueForKey:@"label"] isEqualToArray:[childrenStates valueForKey:@"label"]])
            infoEnum = [childrenStates objectEnumerator];
        for (PDFOutline *child in children)
            [self openOutline:child forOpenState:[infoEnum nextObject]];
        [children release];
    }
}

- (void)updatePageLabelsAndOutlineForOpenState:(NSDictionary *)info {
    // update page labels, also update the size of the table columns displaying the labels
    [self willChangeValueForKey:PAGELABELS_KEY];
    [pageLabels setArray:[[pdfView document] pageLabels]];
    [self didChangeValueForKey:PAGELABELS_KEY];
    
    [self updatePageLabel];
    
    [self updatePageColumnWidthForTableView:leftSideController.thumbnailTableView];
    [self updatePageColumnWidthForTableView:rightSideController.snapshotTableView];
    [self updatePageColumnWidthForTableView:leftSideController.tocOutlineView];
    [self updatePageColumnWidthForTableView:rightSideController.noteOutlineView];
    [self updatePageColumnWidthForTableView:leftSideController.findTableView];
    [self updatePageColumnWidthForTableView:leftSideController.groupedFindTableView];
    
    // this uses the pageLabels
    [[leftSideController.thumbnailTableView typeSelectHelper] rebuildTypeSelectSearchCache];
    
    // these carry a label, moreover when this is called the thumbnails will also be invalid
    [self resetThumbnails];
    [self allSnapshotsNeedUpdate];
    [rightSideController.noteOutlineView reloadData];
    
    mwcFlags.updatingOutlineSelection = 1;
    // If this is a reload following a TeX run and the user just killed the outline for some reason, we get a crash if the outlineView isn't reloaded, so no longer make it conditional on pdfOutline != nil
    [leftSideController.tocOutlineView reloadData];
    [self openOutline:[[pdfView document] outlineRoot] forOpenState:info];
    mwcFlags.updatingOutlineSelection = 0;
    [self updateOutlineSelection];
    
    // handle the case as above where the outline has disappeared in a reload situation
    if (nil == [[pdfView document] outlineRoot] && leftSideController.currentView == leftSideController.tocOutlineView.enclosingScrollView) {
        [self displayThumbnailViewAnimating:NO];
        [leftSideController.button setSelectedSegment:SKThumbnailSidePaneState];
    }

    [leftSideController.button setEnabled:[[pdfView document] outlineRoot] != nil forSegment:SKOutlineSidePaneState];
}

- (SKProgressController *)progressController {
    if (progressController == nil)
        progressController = [[SKProgressController alloc] init];
    return progressController;
}

#pragma mark Accessors

- (PDFDocument *)pdfDocument{
    return [pdfView document];
}

- (void)setPdfDocument:(PDFDocument *)document{

    if ([pdfView document] != document) {
        
        NSUInteger pageIndex = NSNotFound, secondaryPageIndex = NSNotFound;
        NSRect visibleRect = NSZeroRect, secondaryVisibleRect = NSZeroRect;
        NSArray *snapshotDicts = nil;
        NSDictionary *openState = nil;
        
        if ([pdfView document]) {
            pageIndex = [[pdfView currentPage] pageIndex];
            visibleRect = [pdfView convertRect:[pdfView convertRect:[[pdfView documentView] visibleRect] fromView:[pdfView documentView]] toPage:[pdfView currentPage]];
            if (secondaryPdfView) {
                secondaryPageIndex = [[secondaryPdfView currentPage] pageIndex];
                secondaryVisibleRect = [secondaryPdfView convertRect:[secondaryPdfView convertRect:[[secondaryPdfView documentView] visibleRect] fromView:[secondaryPdfView documentView]] toPage:[secondaryPdfView currentPage]];
            }
            openState = [self openStateForOutline:[[pdfView document] outlineRoot]];
            
            [[pdfView document] cancelFindString];
            [temporaryAnnotationTimer invalidate];
            [temporaryAnnotationTimer release];
            temporaryAnnotationTimer = nil;
            [temporaryAnnotations removeAllObjects];
            
            // make sure these will not be activated, or they can lead to a crash
            [pdfView removePDFToolTipRects];
            [pdfView setActiveAnnotation:nil];
            
            // these will be invalid. If needed, the document will restore them
            [self setSearchResults:nil];
            [self setGroupedSearchResults:nil];
            [self removeAllObjectsFromNotes];
            [self removeAllObjectsFromThumbnails];
            
            snapshotDicts = [snapshots valueForKey:SKSnapshotCurrentSetupKey];
            [snapshots makeObjectsPerformSelector:@selector(close)];
            [self removeAllObjectsFromSnapshots];
            
            [lastViewedPages removeAllObjects];
            
            [self unregisterForDocumentNotifications];
            
            [[pdfView document] setDelegate:nil];
        }
        
        [pdfView setDocument:document];
        [[pdfView document] setDelegate:self];
        
        [secondaryPdfView setDocument:document];
        
        [self registerForDocumentNotifications];
        
        [self updatePageLabelsAndOutlineForOpenState:openState];
        [self updateNoteSelection];
        
        [self showSnapshotsWithSetups:snapshotDicts];
        
        if ([document pageCount] && (pageIndex != NSNotFound || secondaryPageIndex != NSNotFound)) {
            PDFPage *page = nil;
            PDFPage *secondaryPage = nil;
            if (pageIndex != NSNotFound) {
                page = [document pageAtIndex:MIN(pageIndex, [document pageCount] - 1)];
                [pdfView goToPage:page];
            }
            if (secondaryPageIndex != NSNotFound) {
                secondaryPage = [document pageAtIndex:MIN(secondaryPageIndex, [document pageCount] - 1)];
                [secondaryPdfView goToPage:secondaryPage];
            }
            [[pdfView window] disableFlushWindow];
            if (page) {
                [pdfView display];
                [[pdfView documentView] scrollRectToVisible:[pdfView convertRect:[pdfView convertRect:visibleRect fromPage:page] toView:[pdfView documentView]]];
            }
            if (secondaryPage) {
                if ([secondaryPdfView window])
                    [secondaryPdfView display];
                [[secondaryPdfView documentView] scrollRectToVisible:[secondaryPdfView convertRect:[secondaryPdfView convertRect:secondaryVisibleRect fromPage:secondaryPage] toView:[secondaryPdfView documentView]]];
            }
            [[pdfView window] enableFlushWindow];
            [[pdfView window] flushWindowIfNeeded];
        }
        
        // the number of pages may have changed
        [toolbarController handleChangedHistoryNotification:nil];
        [toolbarController handlePageChangedNotification:nil];
        [self handlePageChangedNotification:nil];
        [self updateLeftStatus];
        [self updateRightStatus];
    }
}
    
- (void)addAnnotationsFromDictionaries:(NSArray *)noteDicts replace:(BOOL)replace {
    PDFAnnotation *annotation;
    PDFDocument *pdfDoc = [pdfView document];
    NSMutableArray *observableNotes = [self mutableArrayValueForKey:NOTES_KEY];
    
    if (replace) {
        [pdfView removePDFToolTipRects];
        // remove the current annotations
        [pdfView setActiveAnnotation:nil];
        for (annotation in [[notes copy] autorelease])
            [pdfView removeAnnotation:annotation];
    }
    
    // create new annotations from the dictionary and add them to their page and to the document
    for (NSDictionary *dict in noteDicts) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        NSUInteger pageIndex = [[dict objectForKey:SKNPDFAnnotationPageIndexKey] unsignedIntegerValue];
        if (annotation = [[PDFAnnotation alloc] initSkimNoteWithProperties:dict]) {
            if (pageIndex == NSNotFound)
                pageIndex = 0;
            else if (pageIndex >= [pdfDoc pageCount])
                pageIndex = [pdfDoc pageCount] - 1;
            PDFPage *page = [pdfDoc pageAtIndex:pageIndex];
            [pdfView addAnnotation:annotation toPage:page];
            // this is necessary for the initial load of the document, as the notification handler is not yet registered
            if ([observableNotes containsObject:annotation] == NO)
                [observableNotes addObject:annotation];
            [annotation release];
        }
        [pool release];
    }
    // make sure we clear the undo handling
    [self observeUndoManagerCheckpoint:nil];
    [rightSideController.noteOutlineView reloadData];
    [self allThumbnailsNeedUpdate];
    [pdfView resetPDFToolTipRects];
}

- (void)updatePageNumber {
    NSUInteger number = [[pdfView currentPage] pageIndex] + 1;
    if (pageNumber != number) {
        [self willChangeValueForKey:PAGENUMBER_KEY];
        pageNumber = number;
        [self didChangeValueForKey:PAGENUMBER_KEY];
    }
}

- (void)setPageNumber:(NSUInteger)number {
    // Check that the page number exists
    NSUInteger pageCount = [[pdfView document] pageCount];
    if (number > pageCount)
        number = pageCount;
    if (number > 0 && [[pdfView currentPage] pageIndex] != number - 1)
        [pdfView goToPage:[[pdfView document] pageAtIndex:number - 1]];
}

- (void)updatePageLabel {
    NSString *label = [[pdfView currentPage] displayLabel];
    if (label != pageLabel) {
        [self willChangeValueForKey:PAGELABEL_KEY];
        [pageLabel release];
        pageLabel = [label retain];
        [self didChangeValueForKey:PAGELABEL_KEY];
    }
}

- (void)setPageLabel:(NSString *)label {
    NSUInteger idx = [pageLabels indexOfObject:label];
    if (idx != NSNotFound && [[pdfView currentPage] pageIndex] != idx)
        [pdfView goToPage:[[pdfView document] pageAtIndex:idx]];
}

- (BOOL)validatePageLabel:(id *)value error:(NSError **)error {
    if ([pageLabels indexOfObject:*value] == NSNotFound)
        *value = [self pageLabel];
    return YES;
}

- (BOOL)isFullScreen {
    return [self window] == fullScreenWindow && mwcFlags.isPresentation == 0;
}

- (BOOL)isPresentation {
    return mwcFlags.isPresentation;
}

- (BOOL)autoScales {
    return [pdfView autoScales];
}

- (SKLeftSidePaneState)leftSidePaneState {
    return mwcFlags.leftSidePaneState;
}

- (void)setLeftSidePaneState:(SKLeftSidePaneState)newLeftSidePaneState {
    if (mwcFlags.leftSidePaneState != newLeftSidePaneState) {
        mwcFlags.leftSidePaneState = newLeftSidePaneState;
        
        if ([leftSideController.searchField stringValue] && [[leftSideController.searchField stringValue] isEqualToString:@""] == NO) {
            [leftSideController.searchField setStringValue:@""];
            [self removeTemporaryAnnotations];
        }
        
        if (mwcFlags.leftSidePaneState == SKThumbnailSidePaneState)
            [self displayThumbnailViewAnimating:NO];
        else if (mwcFlags.leftSidePaneState == SKOutlineSidePaneState)
            [self displayTocViewAnimating:NO];
    }
}

- (SKRightSidePaneState)rightSidePaneState {
    return mwcFlags.rightSidePaneState;
}

- (void)setRightSidePaneState:(SKRightSidePaneState)newRightSidePaneState {
    if (mwcFlags.rightSidePaneState != newRightSidePaneState) {
        mwcFlags.rightSidePaneState = newRightSidePaneState;
        
        if (mwcFlags.rightSidePaneState == SKNoteSidePaneState)
            [self displayNoteViewAnimating:NO];
        else if (mwcFlags.rightSidePaneState == SKSnapshotSidePaneState)
            [self displaySnapshotViewAnimating:NO];
    }
}

- (SKFindPaneState)findPaneState {
    return mwcFlags.findPaneState;
}

- (void)setFindPaneState:(SKFindPaneState)newFindPaneState {
    if (mwcFlags.findPaneState != newFindPaneState) {
        mwcFlags.findPaneState = newFindPaneState;
        
        if (mwcFlags.findPaneState == SKSingularFindPaneState) {
            if ([leftSideController.groupedFindTableView window])
                [self displayFindViewAnimating:NO];
        } else if (mwcFlags.findPaneState == SKGroupedFindPaneState) {
            if ([leftSideController.findTableView window])
                [self displayGroupedFindViewAnimating:NO];
        }
        [self updateFindResultHighlights:YES];
    }
}

- (BOOL)leftSidePaneIsOpen {
    NSInteger state;
    if ([self isFullScreen])
        state = [leftSideWindow state];
    else if ([self isPresentation])
        state = [leftSideWindow isVisible];
    else if (mwcFlags.usesDrawers)
        state = [leftSideDrawer state];
    else
        state = [splitView isSubviewCollapsed:leftSideContentView] == NO;
    return state == NSDrawerOpenState || state == NSDrawerOpeningState;
}

- (BOOL)rightSidePaneIsOpen {
    NSInteger state;
    if ([self isFullScreen])
        state = [rightSideWindow state];
    else if ([self isPresentation])
        state = [rightSideWindow isVisible];
    else if (mwcFlags.usesDrawers)
        state = [rightSideDrawer state];
    else
        state = [splitView isSubviewCollapsed:rightSideContentView] == NO;
    return state == NSDrawerOpenState || state == NSDrawerOpeningState;
}

- (void)closeSideWindow:(SKSideWindow *)sideWindow {    
    if ([sideWindow state] == NSDrawerOpenState || [sideWindow state] == NSDrawerOpeningState) {
        if (sideWindow == leftSideWindow) {
            [self toggleLeftSidePane:self];
        } else if (sideWindow == rightSideWindow) {
            [self toggleRightSidePane:self];
        }
    }
}

- (NSArray *)notes {
    return [[notes copy] autorelease];
}
	 
- (NSUInteger)countOfNotes {
    return [notes count];
}

- (PDFAnnotation *)objectInNotesAtIndex:(NSUInteger)theIndex {
    return [notes objectAtIndex:theIndex];
}

- (void)insertObject:(PDFAnnotation *)note inNotesAtIndex:(NSUInteger)theIndex {
    [notes insertObject:note atIndex:theIndex];

    // Start observing the just-inserted notes so that, when they're changed, we can record undo operations.
    [self startObservingNotes:[NSArray arrayWithObject:note]];
}

- (void)removeObjectFromNotesAtIndex:(NSUInteger)theIndex {
    PDFAnnotation *note = [notes objectAtIndex:theIndex];
    
    for (NSWindowController *wc in [[self document] windowControllers]) {
        if ([wc isNoteWindowController] && [[(SKNoteWindowController *)wc note] isEqual:note]) {
            [[wc window] orderOut:self];
            break;
        }
    }
    
    if ([[note texts] count])
        [rowHeights removeFloatForKey:[[note texts] lastObject]];
    [rowHeights removeFloatForKey:note];
    
    // Stop observing the removed notes
    [self stopObservingNotes:[NSArray arrayWithObject:note]];
    
    [notes removeObjectAtIndex:theIndex];
}

- (void)removeAllObjectsFromNotes {
    if ([notes count]) {
        NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [notes count])];
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:NOTES_KEY];
        
        for (NSWindowController *wc in [[self document] windowControllers]) {
            if ([wc isNoteWindowController])
                [[wc window] orderOut:self];
        }
        
        [rowHeights removeAllFloats];
        
        [self stopObservingNotes:notes];

        [notes removeAllObjects];
        
        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:NOTES_KEY];
        [rightSideController.noteOutlineView reloadData];
    }
}

- (NSArray *)thumbnails {
    return [[thumbnails copy] autorelease];
}

- (NSUInteger)countOfThumbnails {
    return [thumbnails count];
}

- (SKThumbnail *)objectInThumbnailsAtIndex:(NSUInteger)theIndex {
    return [thumbnails objectAtIndex:theIndex];
}

- (void)insertObject:(SKThumbnail *)thumbnail inThumbnailsAtIndex:(NSUInteger)theIndex {
    [thumbnails insertObject:thumbnail atIndex:theIndex];
}

- (void)removeObjectFromThumbnailsAtIndex:(NSUInteger)theIndex {
    [thumbnails removeObjectAtIndex:theIndex];
}

- (void)removeAllObjectsFromThumbnails {
    if ([thumbnails count]) {
        // cancel all delayed perform requests for makeImageForThumbnail:
        [[self class] cancelPreviousPerformRequestsWithTarget:self];
        NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [thumbnails count])];
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:THUMBNAILS_KEY];
        [thumbnails removeAllObjects];
        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:THUMBNAILS_KEY];
    }
}

- (NSArray *)snapshots {
    return [[snapshots copy] autorelease];
}

- (NSUInteger)countOfSnapshots {
    return [snapshots count];
}

- (SKSnapshotWindowController *)objectInSnapshotsAtIndex:(NSUInteger)theIndex {
    return [snapshots objectAtIndex:theIndex];
}

- (void)insertObject:(SKSnapshotWindowController *)snapshot inSnapshotsAtIndex:(NSUInteger)theIndex {
    [snapshots insertObject:snapshot atIndex:theIndex];
}

- (void)removeObjectFromSnapshotsAtIndex:(NSUInteger)theIndex {
    [dirtySnapshots removeObject:[snapshots objectAtIndex:theIndex]];
    [snapshots removeObjectAtIndex:theIndex];
}

- (void)removeAllObjectsFromSnapshots {
    if ([snapshots count]) {
        NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [snapshots count])];
        [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:SNAPSHOTS_KEY];
        
        [dirtySnapshots removeAllObjects];
        
        [snapshots removeAllObjects];
        
        [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:SNAPSHOTS_KEY];
    }
}

- (NSArray *)selectedNotes {
    NSMutableArray *selectedNotes = [NSMutableArray array];
    NSIndexSet *rowIndexes = [rightSideController.noteOutlineView selectedRowIndexes];
    NSUInteger row = [rowIndexes firstIndex];
    id item = nil;
    while (row != NSNotFound) {
        item = [rightSideController.noteOutlineView itemAtRow:row];
        if ([item type] == nil)
            item = [(SKNoteText *)item note];
        if ([selectedNotes containsObject:item] == NO)
            [selectedNotes addObject:item];
        row = [rowIndexes indexGreaterThanIndex:row];
    }
    return selectedNotes;
}

- (NSArray *)searchResults {
    return [[searchResults copy] autorelease];
}

- (void)setSearchResults:(NSArray *)newSearchResults {
    [searchResults setArray:newSearchResults];
}

- (NSUInteger)countOfSearchResults {
    return [searchResults count];
}

- (PDFSelection *)objectInSearchResultsAtIndex:(NSUInteger)theIndex {
    return [searchResults objectAtIndex:theIndex];
}

- (void)insertObject:(PDFSelection *)searchResult inSearchResultsAtIndex:(NSUInteger)theIndex {
    [searchResults insertObject:searchResult atIndex:theIndex];
}

- (void)removeObjectFromSearchResultsAtIndex:(NSUInteger)theIndex {
    [searchResults removeObjectAtIndex:theIndex];
}

- (NSArray *)groupedSearchResults {
    return [[groupedSearchResults copy] autorelease];
}

- (void)setGroupedSearchResults:(NSArray *)newGroupedSearchResults {
    [groupedSearchResults setArray:newGroupedSearchResults];
}

- (NSUInteger)countOfGroupedSearchResults {
    return [groupedSearchResults count];
}

- (SKGroupedSearchResult *)objectInGroupedSearchResultsAtIndex:(NSUInteger)theIndex {
    return [groupedSearchResults objectAtIndex:theIndex];
}

- (void)insertObject:(SKGroupedSearchResult *)groupedSearchResult inGroupedSearchResultsAtIndex:(NSUInteger)theIndex {
    [groupedSearchResults insertObject:groupedSearchResult atIndex:theIndex];
}

- (void)removeObjectFromGroupedSearchResultsAtIndex:(NSUInteger)theIndex {
    [groupedSearchResults removeObjectAtIndex:theIndex];
}

- (NSDictionary *)presentationOptions {
    SKTransitionController *transitions = [pdfView transitionController];
    SKAnimationTransitionStyle style = [transitions transitionStyle];
    NSString *styleName = [SKTransitionController nameForStyle:style];
    NSArray *pageTransitions = [transitions pageTransitions];
    NSMutableDictionary *options = nil;
    if ([styleName length] || [pageTransitions count]) {
        options = [NSMutableDictionary dictionary];
        [options setValue:(styleName ?: @"") forKey:SKStyleNameKey];
        [options setValue:[NSNumber numberWithDouble:[transitions duration]] forKey:SKDurationKey];
        [options setValue:[NSNumber numberWithBool:[transitions shouldRestrict]] forKey:SKShouldRestrictKey];
        [options setValue:pageTransitions forKey:PAGETRANSITIONS_KEY];
    }
    return options;
}

- (void)setPresentationOptions:(NSDictionary *)dictionary {
    SKTransitionController *transitions = [pdfView transitionController];
    NSString *styleName = [dictionary objectForKey:SKStyleNameKey];
    NSNumber *duration = [dictionary objectForKey:SKDurationKey];
    NSNumber *shouldRestrict = [dictionary objectForKey:SKShouldRestrictKey];
    NSArray *pageTransitions = [dictionary objectForKey:PAGETRANSITIONS_KEY];
    if (styleName)
        [transitions setTransitionStyle:[SKTransitionController styleForName:styleName]];
    if (duration)
        [transitions setDuration:[duration doubleValue]];
    if (shouldRestrict)
        [transitions setShouldRestrict:[shouldRestrict boolValue]];
    [transitions setPageTransitions:pageTransitions];
}

#pragma mark Full Screen support

- (void)showLeftSideWindowOnScreen:(NSScreen *)screen {
    if (leftSideWindow == nil)
        leftSideWindow = [[SKSideWindow alloc] initWithMainController:self edge:NSMinXEdge];
    
    if ([[[leftSideController.view window] firstResponder] isDescendantOf:leftSideController.view])
        [[leftSideController.view window] makeFirstResponder:nil];
    [leftSideWindow setMainView:leftSideController.view];
    
    if ([self isPresentation]) {
        mwcFlags.savedLeftSidePaneState = [self leftSidePaneState];
        [self setLeftSidePaneState:SKThumbnailSidePaneState];
        [leftSideWindow setAlphaValue:PRESENTATION_SIDE_WINDOW_ALPHA];
        [leftSideWindow setEnabled:NO];
        [leftSideWindow makeFirstResponder:leftSideController.thumbnailTableView];
        [leftSideWindow attachToWindow:[self window] onScreen:screen];
        [leftSideWindow expand];
    } else {
        [leftSideWindow makeFirstResponder:leftSideController.searchField];
        [leftSideWindow attachToWindow:[self window] onScreen:screen];
    }
}

- (void)showRightSideWindowOnScreen:(NSScreen *)screen {
    if (rightSideWindow == nil) 
        rightSideWindow = [[SKSideWindow alloc] initWithMainController:self edge:NSMaxXEdge];
    
    if ([[[rightSideController.view window] firstResponder] isDescendantOf:rightSideController.view])
        [[rightSideController.view window] makeFirstResponder:nil];
    [rightSideWindow setMainView:rightSideController.view];
    
    if ([self isPresentation]) {
        [rightSideWindow setAlphaValue:PRESENTATION_SIDE_WINDOW_ALPHA];
        [rightSideWindow setEnabled:NO];
        [rightSideWindow attachToWindow:[self window] onScreen:screen];
        [rightSideWindow expand];
    } else {
        [rightSideWindow attachToWindow:[self window] onScreen:screen];
    }
}

- (void)hideLeftSideWindow {
    if ([[leftSideController.view window] isEqual:leftSideWindow]) {
        [leftSideWindow remove];
        
        if ([[leftSideWindow firstResponder] isDescendantOf:leftSideController.view])
            [leftSideWindow makeFirstResponder:nil];
        NSRect rect = [leftSideContentView bounds];
        if (mwcFlags.usesDrawers == 0) {
            rect = NSInsetRect(rect, -1, -1);
            rect.size.height -= 1;
        }
        [leftSideController.view setFrame:rect];
        [leftSideContentView addSubview:leftSideController.view];
        
        if ([self isPresentation]) {
            [self setLeftSidePaneState:mwcFlags.savedLeftSidePaneState];
            [leftSideWindow setAlphaValue:1.0];
            [leftSideWindow setEnabled:YES];
        }
    }
}

- (void)hideRightSideWindow {
    if ([[rightSideController.view window] isEqual:rightSideWindow]) {
        [rightSideWindow remove];
        
        if ([[rightSideWindow firstResponder] isDescendantOf:rightSideController.view])
            [rightSideWindow makeFirstResponder:nil];
        NSRect rect = [rightSideContentView bounds];
        if (mwcFlags.usesDrawers == 0) {
            rect = NSInsetRect(rect, -1, -1);
            rect.size.height -= 1;
        }
        [rightSideController.view setFrame:rect];
        [rightSideContentView addSubview:rightSideController.view];
        
        if ([self isPresentation]) {
            [rightSideWindow setAlphaValue:1.0];
            [rightSideWindow setEnabled:YES];
        }
    }
}

- (void)showSideWindowsOnScreen:(NSScreen *)screen {
    [self showLeftSideWindowOnScreen:screen];
    [self showRightSideWindowOnScreen:screen];
    
    if ([SKSideWindow isAutoHideEnabled])
        [pdfSplitView setFrame:NSInsetRect([[pdfSplitView superview] bounds], 9.0, 0.0)];
    [[pdfSplitView superview] setNeedsDisplay:YES];
}

- (void)hideSideWindows {
    [self hideLeftSideWindow];
    [self hideRightSideWindow];
    
    [pdfView setFrame:[[pdfView superview] bounds]];
}

- (void)goFullScreen {
    NSScreen *screen = [[self window] screen] ?: [NSScreen mainScreen]; // @@ screen: or should we use the main screen?
    NSColor *backgroundColor = [self isPresentation] ? [NSColor blackColor] : [[NSUserDefaults standardUserDefaults] colorForKey:SKFullScreenBackgroundColorKey];
    NSInteger level = [self isPresentation] && [[NSUserDefaults standardUserDefaults] boolForKey:SKUseNormalLevelForPresentationKey] == NO ? NSPopUpMenuWindowLevel : NSNormalWindowLevel;
    
    // Create the full-screen window if it does not already  exist.
    if (fullScreenWindow == nil)
        fullScreenWindow = [[SKFullScreenWindow alloc] initWithScreen:screen];
        
    // explicitly set window frame; screen may have moved, or may be nil (in which case [fullScreenWindow frame] is wrong, which is weird); the first time through this method, [fullScreenWindow screen] is nil
    [fullScreenWindow setFrame:[screen frame] display:NO];
    
    if ([[mainWindow firstResponder] isDescendantOf:pdfView])
        [mainWindow makeFirstResponder:nil];
    [fullScreenWindow setMainView:([self isPresentation] ? (id)pdfView : (id)pdfSplitView)];
    [fullScreenWindow setBackgroundColor:backgroundColor];
    [fullScreenWindow setLevel:level];
    [pdfView setBackgroundColor:[self isPresentation] ? [NSColor clearColor] : backgroundColor];
    [secondaryPdfView setBackgroundColor:backgroundColor];
    [pdfView layoutDocumentView];
    [pdfView setNeedsDisplay:YES];
    
    for (NSWindowController *wc in [[self document] windowControllers]) {
        if ([wc isNoteWindowController] || [wc isSnapshotWindowController])
            [(id)wc setForceOnTop:YES];
    }
        
    if (NO == [self isPresentation] && [[NSUserDefaults standardUserDefaults] boolForKey:SKBlankAllScreensInFullScreenKey] && [[NSScreen screens] count] > 1) {
        if (nil == blankingWindows)
            blankingWindows = [[NSMutableArray alloc] init];
        [blankingWindows removeAllObjects];
        for (NSScreen *screenToBlank in [NSScreen screens]) {
            if ([screenToBlank isEqual:screen] == NO) {
                SKFullScreenWindow *window = [[SKFullScreenWindow alloc] initWithScreen:screenToBlank canBecomeMain:NO];
                [window setBackgroundColor:backgroundColor];
                [window setLevel:NSFloatingWindowLevel];
                [window setFrame:[screenToBlank frame] display:YES];
                [window orderFront:nil];
                [window setReleasedWhenClosed:YES];
                [window setHidesOnDeactivate:YES];
                [blankingWindows addObject:window];
                [window release];
            }
        }
    }
    
    [mainWindow setDelegate:nil];
    [self setWindow:fullScreenWindow];
    [fullScreenWindow makeKeyAndOrderFront:self];
    [fullScreenWindow makeFirstResponder:pdfView];
    [fullScreenWindow recalculateKeyViewLoop];
    [mainWindow orderOut:self];    
    [fullScreenWindow setDelegate:self];
    [NSApp addWindowsItem:fullScreenWindow title:[self windowTitleForDocumentDisplayName:[[self document] displayName]] filename:NO];
}

- (void)saveNormalSetup {
    NSScrollView *scrollView = [[pdfView documentView] enclosingScrollView];
    [savedNormalSetup setDictionary:[self currentPDFSettings]];
    [savedNormalSetup setObject:[NSNumber numberWithBool:[scrollView hasHorizontalScroller]] forKey:HASHORIZONTALSCROLLER_KEY];
    [savedNormalSetup setObject:[NSNumber numberWithBool:[scrollView hasVerticalScroller]] forKey:HASVERTICALSCROLLER_KEY];
    [savedNormalSetup setObject:[NSNumber numberWithBool:[scrollView autohidesScrollers]] forKey:AUTOHIDESSCROLLERS_KEY];
}

- (void)enterPresentationMode {
    NSScrollView *scrollView = [[pdfView documentView] enclosingScrollView];
    if ([self isFullScreen] == NO)
        [self saveNormalSetup];
    // Set up presentation mode
    [pdfView setAutoScales:YES];
    [pdfView setDisplayMode:kPDFDisplaySinglePage];
    [pdfView setDisplayBox:kPDFDisplayBoxCropBox];
    [pdfView setDisplaysPageBreaks:NO];
    [scrollView setAutohidesScrollers:YES];
    [scrollView setHasHorizontalScroller:NO];
    [scrollView setHasVerticalScroller:NO];
    
    [pdfView setCurrentSelection:nil];
    if ([pdfView hasReadingBar])
        [pdfView toggleReadingBar];
    
    [pdfView setBackgroundColor:[NSColor clearColor]];
    [fullScreenWindow setBackgroundColor:[NSColor blackColor]];
    [fullScreenWindow setLevel:[[NSUserDefaults standardUserDefaults] boolForKey:SKUseNormalLevelForPresentationKey] == NO ? NSPopUpMenuWindowLevel : NSNormalWindowLevel];
    
    SKPDFView *notesPdfView = [[self presentationNotesDocument] pdfView];
    if (notesPdfView)
        [notesPdfView goToPage:[[notesPdfView document] pageAtIndex:[[pdfView currentPage] pageIndex]]];
    
    // prevent sleep
    if (activityAssertionID == kIOPMNullAssertionID && kIOReturnSuccess != IOPMAssertionCreate(kIOPMAssertionTypeNoDisplaySleep, kIOPMAssertionLevelOn, &activityAssertionID))
        activityAssertionID = kIOPMNullAssertionID;
    
    mwcFlags.isPresentation = 1;
}

- (void)exitPresentationMode {
    if (activityAssertionID != kIOPMNullAssertionID && kIOReturnSuccess == IOPMAssertionRelease(activityAssertionID))
        activityAssertionID = kIOPMNullAssertionID;
    
    NSScrollView *scrollView = [[pdfView documentView] enclosingScrollView];
    [self applyPDFSettings:savedNormalSetup];
    [scrollView setHasHorizontalScroller:[[savedNormalSetup objectForKey:HASHORIZONTALSCROLLER_KEY] boolValue]];
    [scrollView setHasVerticalScroller:[[savedNormalSetup objectForKey:HASVERTICALSCROLLER_KEY] boolValue]];
    [scrollView setAutohidesScrollers:[[savedNormalSetup objectForKey:AUTOHIDESSCROLLERS_KEY] boolValue]];
    
    [self hideLeftSideWindow];
    
    mwcFlags.isPresentation = 0;
}

- (IBAction)enterFullScreen:(id)sender {
    if ([self isFullScreen])
        return;
    
    NSScreen *screen = [[self window] screen] ?: [NSScreen mainScreen]; // @@ screen: or should we use the main screen?
    if ([screen isEqual:[[NSScreen screens] objectAtIndex:0]])
        SetSystemUIMode(kUIModeAllHidden, kUIOptionAutoShowMenuBar);
    else if ([self isPresentation])
        SetSystemUIMode(kUIModeNormal, 0);
    
    if ([self isPresentation]) {
        [self exitPresentationMode];
        [pdfView setFrame:[pdfContentView bounds]];
        [pdfContentView addSubview:pdfView];
        [fullScreenWindow setMainView:pdfSplitView];
    } else {
        [self saveNormalSetup];
        [self goFullScreen];
    }
    
    NSColor *backgroundColor = [[NSUserDefaults standardUserDefaults] colorForKey:SKFullScreenBackgroundColorKey];
    [pdfView setBackgroundColor:backgroundColor];
    [secondaryPdfView setBackgroundColor:backgroundColor];
    [fullScreenWindow setBackgroundColor:backgroundColor];
    [fullScreenWindow setLevel:NSNormalWindowLevel];
    
    NSDictionary *fullScreenSetup = [[NSUserDefaults standardUserDefaults] dictionaryForKey:SKDefaultFullScreenPDFDisplaySettingsKey];
    if ([fullScreenSetup count])
        [self applyPDFSettings:fullScreenSetup];
    
    [pdfView setInteractionMode:SKFullScreenMode screen:screen];
    [self showSideWindowsOnScreen:screen];
}

- (IBAction)enterPresentation:(id)sender {
    if ([self isPresentation])
        return;
    
    BOOL wasFullScreen = [self isFullScreen];
    
    [self enterPresentationMode];
    
    NSScreen *screen = [[self window] screen] ?: [NSScreen mainScreen]; // @@ screen: or should we use the main screen?
    if ([screen isEqual:[[NSScreen screens] objectAtIndex:0]])
        SetSystemUIMode(kUIModeAllHidden, kUIOptionDisableProcessSwitch);
    else
        SetSystemUIMode(kUIModeNormal, 0);
    
    if (wasFullScreen) {
        [pdfSplitView setFrame:[centerContentView bounds]];
        [centerContentView addSubview:pdfSplitView];
        [fullScreenWindow setMainView:pdfView];
        [self hideSideWindows];
    } else {
        [self goFullScreen];
    }
    
    [pdfView setInteractionMode:SKPresentationMode screen:screen];
}

- (IBAction)exitFullScreen:(id)sender {
    if ([self isFullScreen] == NO && [self isPresentation] == NO)
        return;
    
    if ([self isFullScreen])
        [self hideSideWindows];
    
    if ([[fullScreenWindow firstResponder] isDescendantOf:pdfView])
        [fullScreenWindow makeFirstResponder:nil];
    
    // do this first, otherwise the navigation window may be covered by fadeWindow and then reveiled again, which looks odd
    [pdfView setInteractionMode:SKNormalMode screen:[[self window] screen]];
    
    // first fade out the pdfView so we can move the pdfView to the main window before it's revealed
    // animating the view itself does no work as PDFView does not work nicely with CoreAnimation, so we use a temporary window
    SKFullScreenWindow *fadeWindow = [[SKFullScreenWindow alloc] initWithScreen:[fullScreenWindow screen] canBecomeMain:NO];
    [fadeWindow setBackgroundColor:[fullScreenWindow backgroundColor]];
    [fadeWindow setLevel:[fullScreenWindow level]];
    [fadeWindow setMainView:[fullScreenWindow mainView]];
    [fadeWindow orderWindow:NSWindowAbove relativeTo:[fullScreenWindow windowNumber]];
    [fadeWindow display];
    [fullScreenWindow display];
    [fullScreenWindow setDelegate:nil];
    [fadeWindow fadeOutBlocking];
    [fadeWindow release];
    
    // this should be done before exitPresentationMode to get a smooth transition
    if ([self isFullScreen]) {
        [pdfSplitView setFrame:[centerContentView bounds]];
        [centerContentView addSubview:pdfSplitView];
    } else {
        [pdfView setFrame:[pdfContentView bounds]];
        [pdfContentView addSubview:pdfView]; 
    }
    [pdfView setBackgroundColor:[[NSUserDefaults standardUserDefaults] colorForKey:SKBackgroundColorKey]];
    [secondaryPdfView setBackgroundColor:[[NSUserDefaults standardUserDefaults] colorForKey:SKBackgroundColorKey]];
    [pdfView layoutDocumentView];
    
    if ([self isPresentation])
        [self exitPresentationMode];
    else
        [self applyPDFSettings:savedNormalSetup];
    
    for (NSWindowController *wc in [[self document] windowControllers]) {
        if ([wc isNoteWindowController] || [wc isSnapshotWindowController])
            [(id)wc setForceOnTop:NO];
    }
    
    [fullScreenWindow setLevel:NSPopUpMenuWindowLevel];
    
    SetSystemUIMode(kUIModeNormal, 0);
    
    [self setWindow:mainWindow];
    [mainWindow orderWindow:NSWindowBelow relativeTo:[fullScreenWindow windowNumber]];
    [mainWindow display];
    [fullScreenWindow fadeOut];
    [mainWindow makeFirstResponder:pdfView];
    [mainWindow recalculateKeyViewLoop];
    [mainWindow setDelegate:self];
    [mainWindow makeKeyWindow];
    // the page number may have changed
    [self synchronizeWindowTitleWithDocumentName];
    
    [blankingWindows makeObjectsPerformSelector:@selector(fadeOut)];
    [[blankingWindows copy] autorelease];
    [blankingWindows removeAllObjects];
}

#pragma mark Swapping tables

- (void)displayTocViewAnimating:(BOOL)animate {
    [leftSideController replaceSideView:leftSideController.tocOutlineView.enclosingScrollView animate:animate];
    [self updateOutlineSelection];
}

- (void)displayThumbnailViewAnimating:(BOOL)animate {
    [leftSideController replaceSideView:leftSideController.thumbnailTableView.enclosingScrollView animate:animate];
    [self updateThumbnailSelection];
}

- (void)displayFindViewAnimating:(BOOL)animate {
    [leftSideController replaceSideView:leftSideController.findTableView.enclosingScrollView animate:animate];
}

- (void)displayGroupedFindViewAnimating:(BOOL)animate {
    [leftSideController replaceSideView:leftSideController.groupedFindTableView.enclosingScrollView animate:animate];
}

- (void)displayNoteViewAnimating:(BOOL)animate {
    [rightSideController replaceSideView:rightSideController.noteOutlineView.enclosingScrollView animate:animate];
}

- (void)displaySnapshotViewAnimating:(BOOL)animate {
    [rightSideController replaceSideView:rightSideController.snapshotTableView.enclosingScrollView animate:animate];
    [self updateSnapshotsIfNeeded];
}

#pragma mark Searching

- (void)temporaryAnnotationTimerFired:(NSTimer *)timer {
    [self removeTemporaryAnnotations];
}

- (void)addAnnotationsForSelection:(PDFSelection *)sel {
    NSArray *pages = [sel pages];
    NSColor *color = [[NSUserDefaults standardUserDefaults] colorForKey:SKSearchHighlightColorKey] ?: [NSColor redColor];
    
    for (PDFPage *page in pages) {
        NSRect bounds = [sel boundsForPage:page];
        if (NSIsEmptyRect(bounds) == NO) {
            bounds = NSInsetRect(bounds, -4.0, -4.0);
            SKPDFAnnotationTemporary *circle = [[SKPDFAnnotationTemporary alloc] initWithBounds:bounds];
            
            // use a heavier line width at low magnification levels; would be nice if PDFAnnotation did this for us
            PDFBorder *border = [[PDFBorder alloc] init];
            [border setLineWidth:1.5 / ([pdfView scaleFactor])];
            [border setStyle:kPDFBorderStyleSolid];
            [circle setBorder:border];
            [border release];
            [circle setColor:color];
            [page addAnnotation:circle];
            [pdfView setNeedsDisplayForAnnotation:circle];
            [circle release];
            [temporaryAnnotations addObject:circle];
        }
    }
}

- (void)addTemporaryAnnotationForPoint:(NSPoint)point onPage:(PDFPage *)page {
    NSRect bounds = NSMakeRect(point.x - 2.0, point.y - 2.0, 4.0, 4.0);
    SKPDFAnnotationTemporary *circle = [[SKPDFAnnotationTemporary alloc] initWithBounds:bounds];
    NSColor *color = [[NSUserDefaults standardUserDefaults] colorForKey:SKSearchHighlightColorKey];
    
    [self removeTemporaryAnnotations];
    [circle setColor:color];
    [circle setInteriorColor:color];
    [page addAnnotation:circle];
    [pdfView setNeedsDisplayForAnnotation:circle];
    [circle release];
    [temporaryAnnotations addObject:circle];
    temporaryAnnotationTimer = [[NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(temporaryAnnotationTimerFired:) userInfo:NULL repeats:NO] retain];
}

static void removeTemporaryAnnotations(const void *annotation, void *context)
{
    SKMainWindowController *wc = (SKMainWindowController *)context;
    PDFAnnotation *annote = (PDFAnnotation *)annotation;
    [[wc pdfView] setNeedsDisplayForAnnotation:annote];
    [[annote page] removeAnnotation:annote];
    // no need to update thumbnail, since temp annotations are only displayed when the search table is displayed
}

- (void)removeTemporaryAnnotations {
    [temporaryAnnotationTimer invalidate];
    SKDESTROY(temporaryAnnotationTimer);
    // for long documents, this is much faster than iterating all pages and sending -isTemporaryAnnotation to each one
    CFSetApplyFunction((CFSetRef)temporaryAnnotations, removeTemporaryAnnotations, self);
    [temporaryAnnotations removeAllObjects];
}

- (void)displaySearchResultsForString:(NSString *)string {
    if ([self leftSidePaneIsOpen] == NO)
        [self toggleLeftSidePane:nil];
    // strip extra search criteria, such as kind:pdf
    NSRange range = [string rangeOfString:@":"];
    if (range.location != NSNotFound) {
        range = [string rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet] options:NSBackwardsSearch range:NSMakeRange(0, range.location)];
        if (range.location != NSNotFound && range.location > 0)
            string = [string substringWithRange:NSMakeRange(0, range.location)];
    }
    [leftSideController.searchField setStringValue:string];
    [self performSelector:@selector(search:) withObject:leftSideController.searchField afterDelay:0.0];
}

- (IBAction)search:(id)sender {

    // cancel any previous find to remove those results, or else they stay around
    if ([[pdfView document] isFinding])
        [[pdfView document] cancelFindString];

    if ([[sender stringValue] isEqualToString:@""]) {
        
        // get rid of temporary annotations
        [self removeTemporaryAnnotations];
        if (mwcFlags.leftSidePaneState == SKThumbnailSidePaneState)
            [self displayThumbnailViewAnimating:YES];
        else 
            [self displayTocViewAnimating:YES];
    } else {
        NSInteger options = mwcFlags.caseInsensitiveSearch ? NSCaseInsensitiveSearch : 0;
        if (mwcFlags.wholeWordSearch) {
            NSMutableArray *words = [NSMutableArray array];
            for (NSString *word in [[sender stringValue] componentsSeparatedByString:@" "]) {
                if ([word isEqualToString:@""] == NO)
                    [words addObject:word];
            }
            [[pdfView document] beginFindStrings:words withOptions:options];
        } else {
            [[pdfView document] beginFindString:[sender stringValue] withOptions:options];
        }
        if (mwcFlags.findPaneState == SKSingularFindPaneState)
            [self displayFindViewAnimating:YES];
        else
            [self displayGroupedFindViewAnimating:YES];
        
        NSPasteboard *findPboard = [NSPasteboard pasteboardWithName:NSFindPboard];
        [findPboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
        [findPboard setString:[sender stringValue] forType:NSStringPboardType];
    }
}

- (PDFSelection *)findString:(NSString *)string fromSelection:(PDFSelection *)selection withOptions:(NSInteger)options {
	mwcFlags.findPanelFind = 1;
    selection = [[pdfView document] findString:string fromSelection:selection withOptions:options];
	mwcFlags.findPanelFind = 0;
    return selection;
}

- (void)findString:(NSString *)string options:(NSInteger)options{
    PDFSelection *sel = [pdfView currentSelection];
    NSUInteger pageIndex = [[pdfView currentPage] pageIndex];
    while ([sel hasCharacters] == NO && pageIndex-- > 0) {
        PDFPage *page = [[pdfView document] pageAtIndex:pageIndex];
        sel = [page selectionForRect:[page boundsForBox:kPDFDisplayBoxCropBox]];
    }
    PDFSelection *selection = [self findString:string fromSelection:sel withOptions:options];
    if ([selection hasCharacters] == NO && [sel hasCharacters])
        selection = [self findString:string fromSelection:nil withOptions:options];
    if (selection) {
        [pdfView setCurrentSelection:selection];
		[pdfView scrollSelectionToVisible:self];
        [leftSideController.findTableView deselectAll:self];
        [leftSideController.groupedFindTableView deselectAll:self];
        if ([[NSUserDefaults standardUserDefaults] boolForKey:SKShouldHighlightSearchResultsKey]) {
            [self removeTemporaryAnnotations];
            [self addAnnotationsForSelection:selection];
            temporaryAnnotationTimer = [[NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(temporaryAnnotationTimerFired:) userInfo:NULL repeats:NO] retain];
        }
        if ([[NSUserDefaults standardUserDefaults] boolForKey:SKDisableAnimatedSearchHighlightKey] == NO)
            [pdfView setCurrentSelection:selection animate:YES];
	} else {
		NSBeep();
	}
}

- (NSString *)findString {
    return [[[self pdfView] currentSelection] string];
}

- (void)removeHighlightedSelections:(NSTimer *)timer {
    [highlightTimer invalidate];
    [highlightTimer release];
    highlightTimer = nil;
    [pdfView setHighlightedSelections:nil];
}

- (void)goToFindResults:(NSArray *)findResults scrollToVisible:(BOOL)scroll {
    NSEnumerator *selE = [findResults objectEnumerator];
    PDFSelection *sel;
    
    // arm:  PDFSelection is mutable, and using -addSelection on an object from selectedObjects will actually mutate the object in searchResults, which does bad things.
    PDFSelection *firstSel = [selE nextObject];
    PDFSelection *currentSel = [[firstSel copy] autorelease];
    
    while (sel = [selE nextObject]) {
        if ([sel hasCharacters])
            [currentSel addSelection:sel];
    }
    
    if (scroll && [firstSel hasCharacters]) {
        PDFPage *page = [currentSel safeFirstPage];
        NSRect rect = NSIntersectionRect(NSInsetRect([currentSel boundsForPage:page], -50.0, -50.0), [page boundsForBox:kPDFDisplayBoxCropBox]);
        [pdfView goToPage:page];
        [pdfView goToRect:rect onPage:page];
    }
    
    [self removeTemporaryAnnotations];
    
    // add an annotation so it's easier to see the search result
    if ([[NSUserDefaults standardUserDefaults] boolForKey:SKShouldHighlightSearchResultsKey]) {
        for (sel in findResults) {
            if ([sel hasCharacters])
                [self addAnnotationsForSelection:sel];
        }
    }
    
    if (highlightTimer)
        [self removeHighlightedSelections:highlightTimer];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:SKDisableAnimatedSearchHighlightKey] == NO && [findResults count] > 1) {
        PDFSelection *tmpSel = [[currentSel copy] autorelease];
        [tmpSel setColor:[NSColor yellowColor]];
        [pdfView setHighlightedSelections:[NSArray arrayWithObject:tmpSel]];
        highlightTimer = [[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(removeHighlightedSelections:) userInfo:nil repeats:NO] retain];
    }
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:SKDisableAnimatedSearchHighlightKey] == NO && [firstSel hasCharacters])
        [pdfView setCurrentSelection:firstSel animate:YES];
    
    if (currentSel)
        [pdfView setCurrentSelection:currentSel];
}

- (void)goToSelectedFindResults:(id)sender {
    [self updateFindResultHighlights:YES];
}

- (void)updateFindResultHighlights:(BOOL)scroll {
    NSArray *findResults = nil;
    
    if (mwcFlags.findPaneState == SKSingularFindPaneState && [leftSideController.findTableView window])
        findResults = [leftSideController.findArrayController selectedObjects];
    else if (mwcFlags.findPaneState == SKGroupedFindPaneState && [leftSideController.groupedFindTableView window])
        findResults = [[leftSideController.groupedFindArrayController selectedObjects] valueForKeyPath:@"@unionOfArrays.matches"];
    [self goToFindResults:findResults scrollToVisible:scroll];
}

- (IBAction)searchNotes:(id)sender {
    if ([[sender stringValue] length] && mwcFlags.rightSidePaneState != SKNoteSidePaneState)
        [self setRightSidePaneState:SKNoteSidePaneState];
    [self updateNoteFilterPredicate];
    if ([[sender stringValue] length]) {
        NSPasteboard *findPboard = [NSPasteboard pasteboardWithName:NSFindPboard];
        [findPboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
        [findPboard setString:[sender stringValue] forType:NSStringPboardType];
    }
}

#pragma mark PDFDocument delegate

- (void)didMatchString:(PDFSelection *)instance {
    if (mwcFlags.findPanelFind == 0) {
        if (mwcFlags.wholeWordSearch) {
            PDFSelection *copy = [[instance copy] autorelease];
            NSString *string = [instance string];
            NSUInteger l = [string length];
            [copy extendSelectionAtEnd:1];
            string = [copy string];
            if ([string length] > l && [[NSCharacterSet letterCharacterSet] characterIsMember:[string characterAtIndex:l]])
                return;
            l = [string length];
            [copy extendSelectionAtStart:1];
            string = [copy string];
            if ([string length] > l && [[NSCharacterSet letterCharacterSet] characterIsMember:[string characterAtIndex:0]])
                return;
        }
        [searchResults addObject:instance];
        
        PDFPage *page = [instance safeFirstPage];
        SKGroupedSearchResult *result = [groupedSearchResults lastObject];
        NSUInteger maxCount = [result maxCount];
        if ([[result page] isEqual:page] == NO) {
            result = [SKGroupedSearchResult groupedSearchResultWithPage:page maxCount:maxCount];
            [groupedSearchResults addObject:result];
        }
        [result addMatch:instance];
        
        if ([result count] > maxCount) {
            maxCount = [result count];
            for (result in groupedSearchResults)
                [result setMaxCount:maxCount];
        }
    }
}

- (void)documentDidBeginDocumentFind:(NSNotification *)note {
    if (mwcFlags.findPanelFind == 0) {
        NSString *message = [NSLocalizedString(@"Searching", @"Message in search table header") stringByAppendingEllipsis];
        [self setSearchResults:nil];
        [[[leftSideController.findTableView tableColumnWithIdentifier:RESULTS_COLUMNID] headerCell] setStringValue:message];
        [[leftSideController.findTableView headerView] setNeedsDisplay:YES];
        [[[leftSideController.groupedFindTableView tableColumnWithIdentifier:RELEVANCE_COLUMNID] headerCell] setStringValue:message];
        [[leftSideController.groupedFindTableView headerView] setNeedsDisplay:YES];
        [self setGroupedSearchResults:nil];
        [statusBar setProgressIndicatorStyle:SKProgressIndicatorBarStyle];
        [[statusBar progressIndicator] setMaxValue:[[note object] pageCount]];
        [[statusBar progressIndicator] setDoubleValue:0.0];
        [statusBar startAnimation:self];
        [self willChangeValueForKey:SEARCHRESULTS_KEY];
        [self willChangeValueForKey:GROUPEDSEARCHRESULTS_KEY];
    }
}

- (void)documentDidEndDocumentFind:(NSNotification *)note {
    if (mwcFlags.findPanelFind == 0) {
        NSString *message = [NSString stringWithFormat:NSLocalizedString(@"%ld Results", @"Message in search table header"), (long)[searchResults count]];
        [self didChangeValueForKey:GROUPEDSEARCHRESULTS_KEY];
        [self didChangeValueForKey:SEARCHRESULTS_KEY];
        [[[leftSideController.findTableView tableColumnWithIdentifier:RESULTS_COLUMNID] headerCell] setStringValue:message];
        [[leftSideController.findTableView headerView] setNeedsDisplay:YES];
        [[[leftSideController.groupedFindTableView tableColumnWithIdentifier:RELEVANCE_COLUMNID] headerCell] setStringValue:message];
        [[leftSideController.groupedFindTableView headerView] setNeedsDisplay:YES];
        [statusBar stopAnimation:self];
        [statusBar setProgressIndicatorStyle:SKProgressIndicatorNone];
    }
}

- (void)documentDidEndPageFind:(NSNotification *)note {
    NSNumber *pageIndex = [[note userInfo] objectForKey:@"PDFDocumentPageIndex"];
    [[statusBar progressIndicator] setDoubleValue:[pageIndex doubleValue]];
    if ([pageIndex unsignedIntegerValue] % 50 == 0) {
        [self didChangeValueForKey:GROUPEDSEARCHRESULTS_KEY];
        [self didChangeValueForKey:SEARCHRESULTS_KEY];
        [self willChangeValueForKey:SEARCHRESULTS_KEY];
        [self willChangeValueForKey:GROUPEDSEARCHRESULTS_KEY];
    }
}

- (void)documentDidUnlock:(NSNotification *)notification {
    [self updatePageLabelsAndOutlineForOpenState:[self openStateForOutline:[[pdfView document] outlineRoot]]];
}

- (void)document:(PDFDocument *)aDocument didUnlockWithPassword:(NSString *)password {log_method();
    [[self document] savePasswordInKeychain:password];
}

#pragma mark PDFDocument notifications

- (void)handlePageBoundsDidChangeNotification:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    PDFPage *page = [info objectForKey:SKPDFPagePageKey];
    BOOL displayChanged = [[info objectForKey:SKPDFPageActionKey] isEqualToString:SKPDFPageActionRotate] || [pdfView displayBox] == kPDFDisplayBoxCropBox;
    
    if (displayChanged)
        [pdfView layoutDocumentView];
    if (page) {
        NSUInteger idx = [page pageIndex];
        for (SKSnapshotWindowController *wc in snapshots) {
            if ([wc isPageVisible:page]) {
                [self snapshotNeedsUpdate:wc];
                [wc redisplay];
            }
        }
        if (displayChanged)
            [self updateThumbnailAtPageIndex:idx];
    } else {
        [snapshots makeObjectsPerformSelector:@selector(redisplay)];
        [self allSnapshotsNeedUpdate];
        if (displayChanged)
            [self allThumbnailsNeedUpdate];
    }
    
    [secondaryPdfView setNeedsDisplay:YES];
}

- (void)handleDocumentBeginWrite:(NSNotification *)notification {
	// Establish maximum and current value for progress bar.
	[[self progressController] setMaxValue:(double)[[pdfView document] pageCount]];
	[[self progressController] setDoubleValue:0.0];
	[[self progressController] setMessage:[NSLocalizedString(@"Exporting PDF", @"Message for progress sheet") stringByAppendingEllipsis]];
	
	// Bring up the save panel as a sheet.
	[[self progressController] beginSheetModalForWindow:[self window]];
}

- (void)handleDocumentEndWrite:(NSNotification *)notification {
	[[self progressController] dismissSheet:nil];
}

- (void)handleDocumentEndPageWrite:(NSNotification *)notification {
	[[self progressController] setDoubleValue: [[[notification userInfo] objectForKey:@"PDFDocumentPageIndex"] doubleValue]];
}

- (void)registerForDocumentNotifications {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(handleDocumentBeginWrite:) 
                             name:PDFDocumentDidBeginWriteNotification object:[pdfView document]];
    [nc addObserver:self selector:@selector(handleDocumentEndWrite:) 
                             name:PDFDocumentDidEndWriteNotification object:[pdfView document]];
    [nc addObserver:self selector:@selector(handleDocumentEndPageWrite:) 
                             name:PDFDocumentDidEndPageWriteNotification object:[pdfView document]];
    [nc addObserver:self selector:@selector(handlePageBoundsDidChangeNotification:) 
                             name:SKPDFPageBoundsDidChangeNotification object:[pdfView document]];
}

- (void)unregisterForDocumentNotifications {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:PDFDocumentDidBeginWriteNotification object:[pdfView document]];
    [nc removeObserver:self name:PDFDocumentDidEndWriteNotification object:[pdfView document]];
    [nc removeObserver:self name:PDFDocumentDidEndPageWriteNotification object:[pdfView document]];
    [nc removeObserver:self name:SKPDFPageBoundsDidChangeNotification object:[pdfView document]];
}

#pragma mark Subwindows

- (void)showSnapshotAtPageNumber:(NSInteger)pageNum forRect:(NSRect)rect scaleFactor:(CGFloat)scaleFactor autoFits:(BOOL)autoFits {
    SKSnapshotWindowController *swc = [[SKSnapshotWindowController alloc] init];
    BOOL snapshotsOnTop = [[NSUserDefaults standardUserDefaults] boolForKey:SKSnapshotsOnTopKey];
    
    [swc setDelegate:self];
    
    [swc setPdfDocument:[pdfView document]
            scaleFactor:scaleFactor
         goToPageNumber:pageNum
                   rect:rect
               autoFits:autoFits];
    
    [swc setForceOnTop:[self isFullScreen] || [self isPresentation]];
    [[swc window] setHidesOnDeactivate:snapshotsOnTop];
    
    [[self document] addWindowController:swc];
    [swc release];
    
    [swc showWindow:self];
}

- (void)showSnapshotsWithSetups:(NSArray *)setups {
    BOOL snapshotsOnTop = [[NSUserDefaults standardUserDefaults] boolForKey:SKSnapshotsOnTopKey];
    
    for (NSDictionary *setup in setups) {
        SKSnapshotWindowController *swc = [[SKSnapshotWindowController alloc] init];
        
        [swc setDelegate:self];
        
        [swc setPdfDocument:[pdfView document] setup:setup];
        
        [swc setForceOnTop:[self isFullScreen] || [self isPresentation]];
        [[swc window] setHidesOnDeactivate:snapshotsOnTop];
        
        [[self document] addWindowController:swc];
        [swc release];
    }
}

- (void)toggleSelectedSnapshots:(id)sender {
    // there should only be a single snapshot
    SKSnapshotWindowController *controller = [[rightSideController.snapshotArrayController selectedObjects] lastObject];
    
    if ([[controller window] isVisible])
        [controller miniaturize];
    else
        [controller deminiaturize];
}

- (void)snapshotControllerDidFinishSetup:(SKSnapshotWindowController *)controller {
    NSImage *image = [controller thumbnailWithSize:snapshotCacheSize];
    
    [controller setThumbnail:image];
    [[self mutableArrayValueForKey:SNAPSHOTS_KEY] addObject:controller];
}

- (void)snapshotControllerWindowWillClose:(SKSnapshotWindowController *)controller {
    [[self mutableArrayValueForKey:SNAPSHOTS_KEY] removeObject:controller];
}

- (void)snapshotControllerViewDidChange:(SKSnapshotWindowController *)controller {
    [self snapshotNeedsUpdate:controller];
}

- (void)hideRightSideWindow:(NSTimer *)timer {
    [rightSideWindow collapse];
}

- (NSRect)rowRectForSnapshotController:(SKSnapshotWindowController *)controller scrollToVisible:(BOOL)shouldScroll {
    NSInteger row = [[rightSideController.snapshotArrayController arrangedObjects] indexOfObject:controller];
    if (shouldScroll)
        [rightSideController.snapshotTableView scrollRowToVisible:row];
    NSRect rect = [rightSideController.snapshotTableView frameOfCellAtColumn:0 row:row];
    rect = [rightSideController.snapshotTableView convertRect:rect toView:nil];
    rect.origin = [[rightSideController.snapshotTableView window] convertBaseToScreen:rect.origin];
    return rect;
}

- (NSRect)snapshotControllerTargetRectForMiniaturize:(SKSnapshotWindowController *)controller {
    if ([self isPresentation] == NO) {
        if ([self isFullScreen] == NO && [self rightSidePaneIsOpen] == NO) {
            [self toggleRightSidePane:self];
        } else if ([self isFullScreen] && ([rightSideWindow state] == NSDrawerClosedState || [rightSideWindow state] == NSDrawerClosingState)) {
            [rightSideWindow expand];
            [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(hideRightSideWindow:) userInfo:NULL repeats:NO];
        }
        [self setRightSidePaneState:SKSnapshotSidePaneState];
    }
    return [self rowRectForSnapshotController:controller scrollToVisible:YES];
}

- (NSRect)snapshotControllerSourceRectForDeminiaturize:(SKSnapshotWindowController *)controller {
    if ([[[self document] windowControllers] containsObject:controller] == NO)
        [[self document] addWindowController:controller];
    return [self rowRectForSnapshotController:controller scrollToVisible:NO];
}

- (void)showNote:(PDFAnnotation *)annotation {
    NSWindowController *wc = nil;
    for (wc in [[self document] windowControllers]) {
        if ([wc isNoteWindowController] && [(SKNoteWindowController *)wc note] == annotation)
            break;
    }
    if (wc == nil) {
        wc = [[SKNoteWindowController alloc] initWithNote:annotation];
        [(SKNoteWindowController *)wc setForceOnTop:[self isFullScreen] || [self isPresentation]];
        [[self document] addWindowController:wc];
        [wc release];
    }
    [wc showWindow:self];
}

#pragma mark Observer registration

- (void)registerAsObserver {
    [[NSUserDefaultsController sharedUserDefaultsController] addObserver:self forKeys:
        [NSArray arrayWithObjects:SKBackgroundColorKey, SKFullScreenBackgroundColorKey, SKPageBackgroundColorKey, 
                                  SKSearchHighlightColorKey, SKShouldHighlightSearchResultsKey, 
                                  SKThumbnailSizeKey, SKSnapshotThumbnailSizeKey, 
                                  SKShouldAntiAliasKey, SKGreekingThresholdKey, 
                                  SKTableFontSizeKey, nil]
        context:&SKMainWindowDefaultsObservationContext];
}

- (void)unregisterAsObserver {
    @try {
        [[NSUserDefaultsController sharedUserDefaultsController] removeObserver:self forKeys:
            [NSArray arrayWithObjects:SKBackgroundColorKey, SKFullScreenBackgroundColorKey, SKPageBackgroundColorKey, 
                                      SKSearchHighlightColorKey, SKShouldHighlightSearchResultsKey, 
                                      SKThumbnailSizeKey, SKSnapshotThumbnailSizeKey, 
                                      SKShouldAntiAliasKey, SKGreekingThresholdKey, 
                                      SKTableFontSizeKey, nil]];
    }
    @catch (id e) {}
}

#pragma mark Undo

- (void)startObservingNotes:(NSArray *)newNotes {
    // Each note can have a different set of properties that need to be observed.
    for (PDFAnnotation *note in newNotes) {
        for (NSString *key in [note keysForValuesToObserveForUndo]) {
            // We use NSKeyValueObservingOptionOld because when something changes we want to record the old value, which is what has to be set in the undo operation. We use NSKeyValueObservingOptionNew because we compare the new value against the old value in an attempt to ignore changes that aren't really changes.
            [note addObserver:self forKeyPath:key options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:&SKNPDFAnnotationPropertiesObservationContext];
        }
    }
}

- (void)stopObservingNotes:(NSArray *)oldNotes {
    // Do the opposite of what's done in -startObservingNotes:.
    for (PDFAnnotation *note in oldNotes) {
        for (NSString *key in [note keysForValuesToObserveForUndo])
            [note removeObserver:self forKeyPath:key];
    }
}

- (void)setNoteProperties:(NSMapTable *)propertiesPerNote {
    // The passed-in dictionary is keyed by note...
    for (PDFAnnotation *note in propertiesPerNote) {
        // ...with values that are dictionaries of properties, keyed by key-value coding key.
        NSDictionary *noteProperties = [propertiesPerNote objectForKey:note];
        // Use a relatively unpopular method. Here we're effectively "casting" a key path to a key (see how these dictionaries get built in -observeValueForKeyPath:ofObject:change:context:). It had better really be a key or things will get confused. For example, this is one of the things that would need updating if -[SKTNote keysForValuesToObserveForUndo] someday becomes -[SKTNote keyPathsForValuesToObserveForUndo].
        [note setValuesForKeysWithDictionary:noteProperties];
    }
}

- (void)observeUndoManagerCheckpoint:(NSNotification *)notification {
    // Start the coalescing of note property changes over.
    [undoGroupOldPropertiesPerNote release];
    undoGroupOldPropertiesPerNote = nil;
}

#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == &SKMainWindowDefaultsObservationContext) {
        
        // A default value that we are observing has changed
        NSString *key = [keyPath substringFromIndex:7];
        if ([key isEqualToString:SKBackgroundColorKey]) {
            if ([self isFullScreen] == NO && [self isPresentation] == NO) {
                [pdfView setBackgroundColor:[[NSUserDefaults standardUserDefaults] colorForKey:SKBackgroundColorKey]];
                [secondaryPdfView setBackgroundColor:[[NSUserDefaults standardUserDefaults] colorForKey:SKBackgroundColorKey]];
            }
        } else if ([key isEqualToString:SKFullScreenBackgroundColorKey]) {
            if ([self isFullScreen]) {
                NSColor *color = [[NSUserDefaults standardUserDefaults] colorForKey:SKFullScreenBackgroundColorKey];
                if (color) {
                    [pdfView setBackgroundColor:color];
                    [secondaryPdfView setBackgroundColor:color];
                    [fullScreenWindow setBackgroundColor:color];
                    [[fullScreenWindow contentView] setNeedsDisplay:YES];
                    
                    for (NSWindow *window in blankingWindows) {
                        [window setBackgroundColor:color];
                        [[window contentView] setNeedsDisplay:YES];
                    }
                }
            }
        } else if ([key isEqualToString:SKPageBackgroundColorKey]) {
            [pdfView setNeedsDisplay:YES];
            [secondaryPdfView setNeedsDisplay:YES];
            [self allThumbnailsNeedUpdate];
            [self allSnapshotsNeedUpdate];
        } else if ([key isEqualToString:SKSearchHighlightColorKey]) {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:SKShouldHighlightSearchResultsKey] && 
                [[leftSideController.searchField stringValue] length] && 
                (([leftSideController.findTableView window] && [leftSideController.findTableView numberOfSelectedRows]) || ([leftSideController.groupedFindTableView window] && [leftSideController.groupedFindTableView numberOfSelectedRows]))) {
                // clear the selection
                [self updateFindResultHighlights:NO];
            }
        } else if ([key isEqualToString:SKShouldHighlightSearchResultsKey]) {
            if ([[leftSideController.searchField stringValue] length] &&  ([leftSideController.findTableView numberOfSelectedRows] || [leftSideController.groupedFindTableView numberOfSelectedRows])) {
                // clear the selection
                [self updateFindResultHighlights:NO];
            }
        } else if ([key isEqualToString:SKThumbnailSizeKey]) {
            [self resetThumbnailSizeIfNeeded];
            [leftSideController.thumbnailTableView noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self countOfThumbnails])]];
        } else if ([key isEqualToString:SKSnapshotThumbnailSizeKey]) {
            [self resetSnapshotSizeIfNeeded];
            [rightSideController.snapshotTableView noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [self countOfSnapshots])]];
        } else if ([key isEqualToString:SKShouldAntiAliasKey]) {
            [pdfView setShouldAntiAlias:[[NSUserDefaults standardUserDefaults] boolForKey:SKShouldAntiAliasKey]];
            [secondaryPdfView setShouldAntiAlias:[[NSUserDefaults standardUserDefaults] boolForKey:SKShouldAntiAliasKey]];
        } else if ([key isEqualToString:SKGreekingThresholdKey]) {
            [pdfView setGreekingThreshold:[[NSUserDefaults standardUserDefaults] floatForKey:SKGreekingThresholdKey]];
            [secondaryPdfView setGreekingThreshold:[[NSUserDefaults standardUserDefaults] floatForKey:SKGreekingThresholdKey]];
        } else if ([key isEqualToString:SKTableFontSizeKey]) {
            NSFont *font = [NSFont systemFontOfSize:[[NSUserDefaults standardUserDefaults] floatForKey:SKTableFontSizeKey]];
            [leftSideController.tocOutlineView setFont:font];
            [self updatePageColumnWidthForTableView:leftSideController.tocOutlineView];
        }
        
    } else if (context == &SKNPDFAnnotationPropertiesObservationContext) {
        
        // The value of some note's property has changed
        PDFAnnotation *note = (PDFAnnotation *)object;
        // Ignore changes that aren't really changes.
        // How much processor time does this memory optimization cost? We don't know, because we haven't measured it. The use of NSKeyValueObservingOptionNew in -startObservingNotes:, which makes NSKeyValueChangeNewKey entries appear in change dictionaries, definitely costs something when KVO notifications are sent (it costs virtually nothing at observer registration time). Regardless, it's probably a good idea to do simple memory optimizations like this as they're discovered and debug just enough to confirm that they're saving the expected memory (and not introducing bugs). Later on it will be easier to test for good responsiveness and sample to hunt down processor time problems than it will be to figure out where all the darn memory went when your app turns out to be notably RAM-hungry (and therefore slowing down _other_ apps on your user's computers too, if the problem is bad enough to cause paging).
        // Is this a premature optimization? No. Leaving out this very simple check, because we're worried about the processor time cost of using NSKeyValueChangeNewKey, would be a premature optimization.
        // We should be adding undo for nil values also. I'm not sure if KVO does this automatically. Note that -setValuesForKeysWithDictionary: converts NSNull back to nil.
        id newValue = [change objectForKey:NSKeyValueChangeNewKey] ?: [NSNull null];
        id oldValue = [change objectForKey:NSKeyValueChangeOldKey] ?: [NSNull null];
        // All values are suppsed to be true value objects that should be compared with isEqual:
        if ([newValue isEqual:oldValue] == NO) {
            
            // Is this the first observed note change in the current undo group?
            NSUndoManager *undoManager = [[self document] undoManager];
            BOOL isUndoOrRedo = ([undoManager isUndoing] || [undoManager isRedoing]);
            if (undoGroupOldPropertiesPerNote == nil) {
                // We haven't recorded changes for any notes at all since the last undo manager checkpoint. Get ready to start collecting them. We don't want to copy the PDFAnnotations though.
                undoGroupOldPropertiesPerNote = [[NSMapTable alloc] initWithKeyOptions:NSMapTableZeroingWeakMemory | NSMapTableObjectPointerPersonality valueOptions:NSMapTableStrongMemory | NSMapTableObjectPointerPersonality capacity:0];
                // Register an undo operation for any note property changes that are going to be coalesced between now and the next invocation of -observeUndoManagerCheckpoint:.
                [undoManager registerUndoWithTarget:self selector:@selector(setNoteProperties:) object:undoGroupOldPropertiesPerNote];
                // Don't set the undo action name during undoing and redoing
                if (isUndoOrRedo == NO)
                    [undoManager setActionName:NSLocalizedString(@"Edit Note", @"Undo action name")];
            }

            // Find the dictionary in which we're recording the old values of properties for the changed note
            NSMutableDictionary *oldNoteProperties = [undoGroupOldPropertiesPerNote objectForKey:note];
            if (oldNoteProperties == nil) {
                // We have to create a dictionary to hold old values for the changed note
                oldNoteProperties = [[NSMutableDictionary alloc] init];
                // -setValue:forKey: copies, even if the callback doesn't, so we need to use CF functions
                [undoGroupOldPropertiesPerNote setObject:oldNoteProperties forKey:note];
                [oldNoteProperties release];
                // set the mod date here, need to do that only once for each note for a real user action
                if ([[NSUserDefaults standardUserDefaults] boolForKey:SKDisableModificationDateKey] == NO && isUndoOrRedo == NO)
                    [note setModificationDate:[NSDate date]];
            }
            
            // Record the old value for the changed property, unless an older value has already been recorded for the current undo group. Here we're "casting" a KVC key path to a dictionary key, but that should be OK. -[NSMutableDictionary setObject:forKey:] doesn't know the difference.
            if ([oldNoteProperties objectForKey:keyPath] == nil)
                [oldNoteProperties setObject:oldValue forKey:keyPath];
            
            // Update the UI, we should always do that unless the value did not really change or we're just changing the mod date
            if ([keyPath isEqualToString:SKNPDFAnnotationModificationDateKey] == NO) {
                PDFPage *page = [note page];
                NSRect oldRect = NSZeroRect;
                if ([keyPath isEqualToString:SKNPDFAnnotationBoundsKey] && [oldValue isEqual:[NSNull null]] == NO)
                    oldRect = [note displayRectForBounds:[oldValue rectValue]];
                
                [self updateThumbnailAtPageIndex:[note pageIndex]];
                
                for (SKSnapshotWindowController *wc in snapshots) {
                    if ([wc isPageVisible:[note page]]) {
                        [self snapshotNeedsUpdate:wc];
                        [wc setNeedsDisplayForAnnotation:note onPage:page];
                        if (NSIsEmptyRect(oldRect) == NO)
                            [wc setNeedsDisplayInRect:oldRect ofPage:page];
                    }
                }
                
                [pdfView setNeedsDisplayForAnnotation:note];
                [secondaryPdfView setNeedsDisplayForAnnotation:note onPage:page];
                if (NSIsEmptyRect(oldRect) == NO) {
                    [pdfView setNeedsDisplayInRect:oldRect ofPage:page];
                    [secondaryPdfView setNeedsDisplayInRect:oldRect ofPage:page];
                }
            }
            if ([[note type] isEqualToString:SKNNoteString] && [keyPath isEqualToString:SKNPDFAnnotationBoundsKey])
                [pdfView resetPDFToolTipRects];
            
            if ([keyPath isEqualToString:SKNPDFAnnotationBoundsKey] || [keyPath isEqualToString:SKNPDFAnnotationStringKey] || [keyPath isEqualToString:SKNPDFAnnotationTextKey] || [keyPath isEqual:SKNPDFAnnotationColorKey]) {
                [rightSideController.noteArrayController rearrangeObjects];
                [rightSideController.noteOutlineView reloadData];
            }
            
            if ([keyPath isEqualToString:SKNPDFAnnotationBoundsKey] && [[NSUserDefaults standardUserDefaults] boolForKey:SKDisplayNoteBoundsKey]) {
                [self updateRightStatus];
            }
            
            // update the various panels if necessary
            if ([[self window] isMainWindow] && [note isEqual:[pdfView activeAnnotation]]) {
                if (mwcFlags.updatingColor == 0 && ([keyPath isEqualToString:SKNPDFAnnotationColorKey] || [keyPath isEqualToString:SKNPDFAnnotationInteriorColorKey])) {
                    mwcFlags.updatingColor = 1;
                    [[NSColorPanel sharedColorPanel] setColor:[note color]];
                    mwcFlags.updatingColor = 0;
                }
                if (mwcFlags.updatingFont == 0 && ([keyPath isEqualToString:SKNPDFAnnotationFontKey])) {
                    mwcFlags.updatingFont = 1;
                    [[NSFontManager sharedFontManager] setSelectedFont:[(PDFAnnotationFreeText *)note font] isMultiple:NO];
                    mwcFlags.updatingFont = 0;
                }
                if (mwcFlags.updatingFontAttributes == 0 && ([keyPath isEqualToString:SKNPDFAnnotationFontColorKey])) {
                    mwcFlags.updatingFontAttributes = 1;
                    [[NSFontManager sharedFontManager] setSelectedAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[(PDFAnnotationFreeText *)note fontColor], NSForegroundColorAttributeName, nil] isMultiple:NO];
                    mwcFlags.updatingFontAttributes = 0;
                }
                if (mwcFlags.updatingLine == 0 && ([keyPath isEqualToString:SKNPDFAnnotationBorderKey] || [keyPath isEqualToString:SKNPDFAnnotationStartLineStyleKey] || [keyPath isEqualToString:SKNPDFAnnotationEndLineStyleKey])) {
                    mwcFlags.updatingLine = 1;
                    [[SKLineInspector sharedLineInspector] setAnnotationStyle:note];
                    mwcFlags.updatingLine = 0;
                }
            }
        }

    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark Outline

- (NSInteger)outlineRowForPageIndex:(NSUInteger)pageIndex {
    if ([[pdfView document] outlineRoot] == nil)
        return -1;
    
	NSInteger i, numRows = [leftSideController.tocOutlineView numberOfRows];
	for (i = 0; i < numRows; i++) {
		// Get the destination of the given row....
		PDFOutline *outlineItem = [leftSideController.tocOutlineView itemAtRow:i];
        PDFPage *page = [outlineItem page];
		
        if (page == nil) {
            continue;
		} else if ([page pageIndex] == pageIndex) {
            break;
        } else if ([page pageIndex] > pageIndex) {
			if (i > 0) --i;
            break;	
		}
	}
    if (i == numRows)
        i--;
    return i;
}

- (void)updateOutlineSelection{

	// Skip out if this PDF has no outline.
	if ([[pdfView document] outlineRoot] == nil || mwcFlags.updatingOutlineSelection)
		return;
	
	// Get index of current page.
	NSUInteger pageIndex = [[pdfView currentPage] pageIndex];
    
	// Test that the current selection is still valid.
	NSInteger row = [leftSideController.tocOutlineView selectedRow];
    if (row == -1 || [[[[leftSideController.tocOutlineView itemAtRow:row] destination] page] pageIndex] != pageIndex) {
        row = [self outlineRowForPageIndex:pageIndex];
        if (row != -1) {
            mwcFlags.updatingOutlineSelection = 1;
            [leftSideController.tocOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
            mwcFlags.updatingOutlineSelection = 0;
        }
    }
}

#pragma mark Thumbnails

- (void)makeImageForThumbnail:(SKThumbnail *)thumbnail {
    NSSize newSize, oldSize = [thumbnail size];
    PDFDocument *pdfDoc = [pdfView document];
    PDFPage *page = [pdfDoc pageAtIndex:[thumbnail pageIndex]];
    NSRect readingBarRect = [[[pdfView readingBar] page] isEqual:page] ? [[pdfView readingBar] currentBoundsForBox:[pdfView displayBox]] : NSZeroRect;
    NSImage *image = [page thumbnailWithSize:thumbnailCacheSize forBox:[pdfView displayBox] readingBarRect:readingBarRect];
    
    [thumbnail setImage:image];
    
    newSize = [image size];
    if (fabs(newSize.width - oldSize.width) > 1.0 || fabs(newSize.height - oldSize.height) > 1.0)
        [leftSideController.thumbnailTableView noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndex:[thumbnail pageIndex]]];
}

- (BOOL)generateImageForThumbnail:(SKThumbnail *)thumbnail {
    if ([leftSideController.thumbnailTableView isScrolling] || [[pdfView document] isLocked] || [presentationSheetController isScrolling])
        return NO;
    [self performSelector:@selector(makeImageForThumbnail:) withObject:thumbnail afterDelay:0.0];
    return YES;
}

- (void)updateThumbnailSelection {
	// Get index of current page.
	NSUInteger pageIndex = [[pdfView currentPage] pageIndex];
    mwcFlags.updatingThumbnailSelection = 1;
    [leftSideController.thumbnailTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:pageIndex] byExtendingSelection:NO];
    [leftSideController.thumbnailTableView scrollRowToVisible:pageIndex];
    mwcFlags.updatingThumbnailSelection = 0;
}

- (void)resetThumbnails {
    NSUInteger i, count = [pageLabels count];
    // cancel all delayed perform requests for makeImageForThumbnail:
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    [self willChangeValueForKey:THUMBNAILS_KEY];
    [thumbnails removeAllObjects];
    if (count) {
        PDFPage *firstPage = [[pdfView document] pageAtIndex:0];
        PDFPage *emptyPage = [[[SKPDFPage alloc] init] autorelease];
        [emptyPage setBounds:[firstPage boundsForBox:kPDFDisplayBoxCropBox] forBox:kPDFDisplayBoxCropBox];
        [emptyPage setBounds:[firstPage boundsForBox:kPDFDisplayBoxMediaBox] forBox:kPDFDisplayBoxMediaBox];
        [emptyPage setRotation:[firstPage rotation]];
        NSImage *image = [emptyPage thumbnailWithSize:thumbnailCacheSize forBox:[pdfView displayBox]];
        [image lockFocus];
        NSRect imgRect = NSZeroRect;
        imgRect.size = [image size];
        CGFloat width = 0.8 * fmin(NSWidth(imgRect), NSHeight(imgRect));
        imgRect = NSInsetRect(imgRect, 0.5 * (NSWidth(imgRect) - width), 0.5 * (NSHeight(imgRect) - width));
        [[NSImage imageNamed:@"NSApplicationIcon"] drawInRect:imgRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:0.5];
        [image unlockFocus];
        
        for (i = 0; i < count; i++) {
            SKThumbnail *thumbnail = [[SKThumbnail alloc] initWithImage:image label:[pageLabels objectAtIndex:i] pageIndex:i];
            [thumbnail setDelegate:self];
            [thumbnail setDirty:YES];
            [thumbnails addObject:thumbnail];
            [thumbnail release];
        }
    }
    [self didChangeValueForKey:THUMBNAILS_KEY];
    [self allThumbnailsNeedUpdate];
}

- (void)resetThumbnailSizeIfNeeded {
    roundedThumbnailSize = round([[NSUserDefaults standardUserDefaults] floatForKey:SKThumbnailSizeKey]);

    CGFloat defaultSize = roundedThumbnailSize;
    CGFloat thumbnailSize = (defaultSize < 32.1) ? 32.0 : (defaultSize < 64.1) ? 64.0 : (defaultSize < 128.1) ? 128.0 : 256.0;
    
    if (fabs(thumbnailSize - thumbnailCacheSize) > 0.1) {
        thumbnailCacheSize = thumbnailSize;
        
        if ([self countOfThumbnails])
            [self allThumbnailsNeedUpdate];
    }
}

- (void)updateThumbnailAtPageIndex:(NSUInteger)anIndex {
    SKThumbnail *tn = [self objectInThumbnailsAtIndex:anIndex];
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(makeImageForThumbnail:) object:tn];
    [tn setDirty:YES];
    [leftSideController.thumbnailTableView reloadData];
}

- (void)allThumbnailsNeedUpdate {
    for (SKThumbnail *tn in thumbnails) {
        [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(makeImageForThumbnail:) object:tn];
        [tn setDirty:YES];
    }
    [leftSideController.thumbnailTableView reloadData];
}

#pragma mark Notes

- (void)updateNoteSelection {

    NSArray *orderedNotes = [rightSideController.noteArrayController arrangedObjects];
    PDFAnnotation *annotation, *selAnnotation = nil;
    NSUInteger pageIndex = [[pdfView currentPage] pageIndex];
	NSInteger i, count = [orderedNotes count];
    NSMutableIndexSet *selPageIndexes = [NSMutableIndexSet indexSet];
    
    for (selAnnotation in [self selectedNotes])
        [selPageIndexes addIndex:[selAnnotation pageIndex]];
    
    if (count == 0 || [selPageIndexes containsIndex:pageIndex])
		return;
	
	// Walk outline view looking for best firstpage number match.
	for (i = 0; i < count; i++) {
		// Get the destination of the given row....
        annotation = [orderedNotes objectAtIndex:i];
		
		if ([annotation pageIndex] == pageIndex) {
            selAnnotation = annotation;
			break;
		} else if ([annotation pageIndex] > pageIndex) {
			if (i == 0)
				selAnnotation = [orderedNotes objectAtIndex:0];
			else if ([selPageIndexes containsIndex:[[orderedNotes objectAtIndex:i - 1] pageIndex]])
                selAnnotation = [orderedNotes objectAtIndex:i - 1];
			break;
		}
	}
    if (selAnnotation) {
        mwcFlags.updatingNoteSelection = 1;
        [rightSideController.noteOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:[rightSideController.noteOutlineView rowForItem:selAnnotation]] byExtendingSelection:NO];
        mwcFlags.updatingNoteSelection = 0;
    }
}

- (void)updateNoteFilterPredicate {
    [rightSideController.noteArrayController setFilterPredicate:[noteTypeSheetController filterPredicateForSearchString:[rightSideController.searchField stringValue] caseInsensitive:mwcFlags.caseInsensitiveNoteSearch]];
    [rightSideController.noteOutlineView reloadData];
}

#pragma mark Snapshots

- (void)resetSnapshotSizeIfNeeded {
    roundedSnapshotThumbnailSize = round([[NSUserDefaults standardUserDefaults] floatForKey:SKSnapshotThumbnailSizeKey]);
    CGFloat defaultSize = roundedSnapshotThumbnailSize;
    CGFloat snapshotSize = (defaultSize < 32.1) ? 32.0 : (defaultSize < 64.1) ? 64.0 : (defaultSize < 128.1) ? 128.0 : 256.0;
    
    if (fabs(snapshotSize - snapshotCacheSize) > 0.1) {
        snapshotCacheSize = snapshotSize;
        
        if (snapshotTimer) {
            [snapshotTimer invalidate];
            SKDESTROY(snapshotTimer);
        }
        
        if ([self countOfSnapshots])
            [self allSnapshotsNeedUpdate];
    }
}

- (void)snapshotNeedsUpdate:(SKSnapshotWindowController *)dirtySnapshot {
    if ([dirtySnapshots containsObject:dirtySnapshot] == NO) {
        [dirtySnapshots addObject:dirtySnapshot];
        [self updateSnapshotsIfNeeded];
    }
}

- (void)allSnapshotsNeedUpdate {
    [dirtySnapshots setArray:[self snapshots]];
    [self updateSnapshotsIfNeeded];
}

- (void)updateSnapshotsIfNeeded {
    if ([rightSideController.snapshotTableView window] != nil && [dirtySnapshots count] > 0 && snapshotTimer == nil)
        snapshotTimer = [[NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(updateSnapshot:) userInfo:NULL repeats:YES] retain];
}

- (void)updateSnapshot:(NSTimer *)timer {
    if ([dirtySnapshots count]) {
        SKSnapshotWindowController *controller = [dirtySnapshots objectAtIndex:0];
        NSSize newSize, oldSize = [[controller thumbnail] size];
        NSImage *image = [controller thumbnailWithSize:snapshotCacheSize];
        
        [controller setThumbnail:image];
        [dirtySnapshots removeObject:controller];
        
        newSize = [image size];
        if (fabs(newSize.width - oldSize.width) > 1.0 || fabs(newSize.height - oldSize.height) > 1.0) {
            NSUInteger idx = [[rightSideController.snapshotArrayController arrangedObjects] indexOfObject:controller];
            [rightSideController.snapshotTableView noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndex:idx]];
        }
    }
    if ([dirtySnapshots count] == 0) {
        [snapshotTimer invalidate];
        SKDESTROY(snapshotTimer);
    }
}

#pragma mark Remote Control

- (void)remoteButtonPressed:(NSEvent *)theEvent {
    RemoteControlEventIdentifier remoteButton = (RemoteControlEventIdentifier)[theEvent data1];
    BOOL remoteScrolling = (BOOL)[theEvent data2];
    
    switch (remoteButton) {
        case kRemoteButtonPlus:
            if (remoteScrolling)
                [[[self pdfView] documentView] scrollLineUp];
            else if ([self isPresentation])
                [self doAutoScale:nil];
            else
                [self doZoomIn:nil];
            break;
        case kRemoteButtonMinus:
            if (remoteScrolling)
                [[[self pdfView] documentView] scrollLineDown];
            else if ([self isPresentation])
                [self doZoomToActualSize:nil];
            else
                [self doZoomOut:nil];
            break;
        case kRemoteButtonRight_Hold:
        case kRemoteButtonRight:
            if (remoteScrolling)
                [[[self pdfView] documentView] scrollLineRight];
            else 
                [self doGoToNextPage:nil];
            break;
        case kRemoteButtonLeft_Hold:
        case kRemoteButtonLeft:
            if (remoteScrolling)
                [[[self pdfView] documentView] scrollLineLeft];
            else 
                [self doGoToPreviousPage:nil];
            break;
        case kRemoteButtonPlay:        
            [self togglePresentation:nil];
            break;
        default:
            break;
    }
}

@end
