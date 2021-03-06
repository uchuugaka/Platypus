/*
 Copyright (c) 2003-2015, Sveinbjorn Thordarson <sveinbjornt@gmail.com
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2. Redistributions in binary form must reproduce the above copyright notice, this
 list of conditions and the following disclaimer in the documentation and/or other
 materials provided with the distribution.
 
 3. Neither the name of the copyright holder nor the names of its contributors may
 be used to endorse or promote products derived from this software without specific
 prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 */

#import "IconController.h"
#import "IconFamily.h"
#import "PlatypusUtility.h"
#import "UKKQueue.h"
#import "Common.h"

@implementation IconController

- (id)init {
    if ((self = [super init])) {
        icnsFilePath = nil;
    }
    return self;
}

- (void)dealloc {
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
    
    if (icnsFilePath != nil)
        [icnsFilePath release];
    
    [super dealloc];
}

- (void)awakeFromNib {
    // we list ourself as an observer of changes to file system, in case of icns file moving
    [[[NSWorkspace sharedWorkspace] notificationCenter]
     addObserver:self selector:@selector(updateIcnsStatus) name:UKFileWatcherRenameNotification object:NULL];
    [[[NSWorkspace sharedWorkspace] notificationCenter]
     addObserver:self selector:@selector(updateIcnsStatus) name:UKFileWatcherDeleteNotification object:NULL];
}

#pragma mark -

- (IBAction)copyIcon:(id)sender {
    [[NSPasteboard generalPasteboard] declareTypes:[NSArray arrayWithObject:NSTIFFPboardType] owner:self];
    [[NSPasteboard generalPasteboard] setData:[[iconImageView image] TIFFRepresentation] forType:NSTIFFPboardType];
}

- (IBAction)pasteIcon:(id)sender {
    [self loadImageFromPasteboard];
}

- (IBAction)revealIconInFinder:(id)sender {
    [[NSWorkspace sharedWorkspace] selectFile:[self icnsFilePath] inFileViewerRootedAtPath:nil];
}

#pragma mark -

- (void)updateIcnsStatus {
    if ([self hasIcns] && ![FILEMGR fileExistsAtPath:icnsFilePath] && ![icnsFilePath isEqualToString:@""])
        [iconNameTextField setTextColor:[NSColor redColor]];
    else
        [iconNameTextField setTextColor:[NSColor blackColor]];
}

// called when user pastes or cuts in field
- (IBAction)contentsWereAltered:(id)sender {
    [self updateForCustomIcon];
}

#pragma mark -

- (IBAction)nextIcon:(id)sender {
    if ([iconToggleButton intValue] + 1 > [iconToggleButton maxValue])
        [iconToggleButton setIntValue:[iconToggleButton minValue]];
    else
        [iconToggleButton setIntValue:[iconToggleButton intValue] + 1];
    
    [self setAppIconForType:[iconToggleButton intValue]];
}

- (IBAction)previousIcon:(id)sender {
    if ([iconToggleButton intValue] - 1 < [iconToggleButton minValue])
        [iconToggleButton setIntValue:[iconToggleButton maxValue]];
    else
        [iconToggleButton setIntValue:[iconToggleButton intValue] - 1];
    
    [self setAppIconForType:[iconToggleButton intValue]];
}

/*****************************************
 - Set the icon according to the default icon number index
 *****************************************/

- (void)setAppIconForType:(int)type {
    [self loadPresetIcon:[self getIconInfoForType:type]];
}

// get information about the default icons
- (NSDictionary *)getIconInfoForType:(int)type {
    NSImage *iconImage = nil;
    NSString *iconName = @"";
    NSString *iconPath = @"";
    
    switch (type) {
        case 0:
            iconImage = [NSImage imageNamed:@"PlatypusDefault"];
            iconName = @"Platypus Default";
            iconPath = [[NSBundle mainBundle] pathForResource:@"PlatypusDefault" ofType:@"icns"];
            break;
            
        case 1:
            iconImage = [NSImage imageNamed:@"PlatypusInstaller"];
            iconName = @"Platypus Installer";
            iconPath = [[NSBundle mainBundle] pathForResource:@"PlatypusInstaller" ofType:@"icns"];
            break;
            
        case 2:
            iconImage = [NSImage imageNamed:@"PlatypusPlate"];
            iconName = @"Platypus Plate";
            iconPath = [[NSBundle mainBundle] pathForResource:@"PlatypusPlate" ofType:@"icns"];
            break;
            
        case 3:
            iconImage = [NSImage imageNamed:@"PlatypusMenu"];
            iconName = @"Platypus Menu";
            iconPath = [[NSBundle mainBundle] pathForResource:@"PlatypusMenu" ofType:@"icns"];
            break;
            
        case 4:
            iconImage = [NSImage imageNamed:@"PlatypusCube"];
            iconName = @"Platypus Cube";
            iconPath = [[NSBundle mainBundle] pathForResource:@"PlatypusCube" ofType:@"icns"];
            break;
            
        case 5:
            iconImage = [NSImage imageNamed:@"NSDefaultApplicationIcon"];
            [iconImage setSize:NSMakeSize(128, 128)]; // fix the bug where it would appear small
            iconName = @"Generic Application Icon";
            iconPath = @"";
            break;
    }
    
    return [NSDictionary dictionaryWithObjectsAndKeys:iconImage, @"Image", iconName, @"Name", iconPath, @"Path", NULL];
}

- (void)setDefaultIcon {
    [self setAppIconForType:0];
}

- (IBAction)switchIcons:(id)sender {
    [self setAppIconForType:[sender intValue]];
}

#pragma mark -

/*****************************************
 - Write an NSImage as icon to a path
 *****************************************/

- (void)writeIconToPath:(NSString *)path {
    if ([iconImageView image] == NULL)
        [PlatypusUtility alert:@"Icon Error" subText:@"No icon could be found for your application.  Please set an icon to fix this."];
    
    IconFamily *iconFam = [[IconFamily alloc] initWithThumbnailsOfImage:[iconImageView image]];
    [iconFam writeToFile:path];
    [iconFam release];
}

- (NSData *)imageData {
    return [[iconImageView image] TIFFRepresentation];
}

- (BOOL)hasIcns {
    return (icnsFilePath != nil);
}

- (NSString *)icnsFilePath {
    return icnsFilePath;
}

- (void)setIcnsFilePath:(NSString *)path {
    if (icnsFilePath != nil)
        [icnsFilePath release];
    
    if (path == nil)
        icnsFilePath = nil;
    else {
        icnsFilePath = [[NSString alloc] initWithString:path];
        if (![icnsFilePath isEqualToString:@""])
            [[UKKQueue sharedFileWatcher] addPathToQueue:path];
    }
    [self updateIcnsStatus];
    [platypusController updateEstimatedAppSize];
}

- (UInt64)iconSize {
    // if there is no icns associated with the icon, we calculate size of TIFF data
    if (![self hasIcns])
        return 400000; // just guess the icon will be 400k in size
    
    // else, just size of icns file
    return [PlatypusUtility fileOrFolderSize:[self icnsFilePath]];
}

#pragma mark -

- (BOOL)validateMenuItem:(NSMenuItem *)anItem {
    if ([[anItem title] isEqualToString:@"Paste Icon"]) {
        NSArray *pbTypes = [NSArray arrayWithObjects:NSTIFFPboardType, NSPDFPboardType, NSPostScriptPboardType, NULL];
        NSString *type = [[NSPasteboard generalPasteboard] availableTypeFromArray:pbTypes];
        
        if (type == NULL)
            return NO;
    }
    return YES;
}

#pragma mark -

- (IBAction)selectIcon:(id)sender {
    [window setTitle:[NSString stringWithFormat:@"%@ - Select an image file", PROGRAM_NAME]];
    
    // create open panel
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];
    [oPanel setPrompt:@"Select"];
    [oPanel setAllowsMultipleSelection:NO];
    [oPanel setCanChooseDirectories:NO];
    [oPanel setAllowedFileTypes:[PlatypusUtility imageFileSuffixes]];
    
    // run open panel sheet
    [oPanel beginSheetModalForWindow:window completionHandler:^(NSInteger result) {
        if (result == NSOKButton) {
            NSString *filename = [[[oPanel URLs] objectAtIndex:0] path];
            if ([filename hasSuffix:@"icns"])
                [self loadIcnsFile:filename];
            else
                [self loadImageFile:filename];
        }
        [window setTitle:PROGRAM_NAME];
    }];
}

- (IBAction)selectIcnsFile:(id)sender {
    [window setTitle:[NSString stringWithFormat:@"%@ - Select an icns file", PROGRAM_NAME]];

    // create open panel
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];
    [oPanel setPrompt:@"Select"];
    [oPanel setAllowsMultipleSelection:NO];
    [oPanel setCanChooseDirectories:NO];
    [oPanel setAllowedFileTypes:[NSArray arrayWithObject:@"icns"]];
    
    //run open panel
    [oPanel beginSheetModalForWindow:window completionHandler:^(NSInteger result) {
        if (result == NSOKButton) {
            NSString *filename = [[[oPanel URLs] objectAtIndex:0] path];
            [self loadIcnsFile:filename];
        }
        [window setTitle:PROGRAM_NAME];
    }];
}

#pragma mark -

- (BOOL)loadIcnsFile:(NSString *)filePath {
    [iconNameTextField setStringValue:[filePath lastPathComponent]];
    
    NSImage *img = [[[NSImage alloc] initByReferencingFile:filePath] autorelease];
    
    if (img == nil) {
        IconFamily *iconFam = [[[IconFamily alloc] initWithSystemIcon:kQuestionMarkIcon] autorelease];
        [iconImageView setImage:[iconFam imageWithAllReps]];
        return NO;
    }
    
    [iconImageView setImage:img];
    [self setIcnsFilePath:filePath];
    
    return YES;
}

- (BOOL)loadImageFile:(NSString *)filePath {
    NSImage *img = [[[NSImage alloc] initByReferencingFile:filePath] autorelease];
    
    if (img == nil)
        return NO;
    
    [iconImageView setImage:img];
    [self updateForCustomIcon];
    return YES;
}

- (BOOL)loadImageWithData:(NSData *)imgData {
    NSImage *img = [[[NSImage alloc] initWithData:imgData] autorelease];
    
    if (img == nil)
        return NO;
    
    [iconImageView setImage:img];
    [self updateForCustomIcon];
    return YES;
}

- (BOOL)loadImageFromPasteboard {
    NSImage *img = [[[NSImage alloc] initWithPasteboard:[NSPasteboard generalPasteboard]] autorelease];
    
    if (img == nil)
        return NO;
    
    [iconImageView setImage:img];
    [self updateForCustomIcon];
    return YES;
}

- (BOOL)loadPresetIcon:(NSDictionary *)iconInfo {
    [iconNameTextField setStringValue:[iconInfo objectForKey:@"Name"]];
    
    NSImage *img = [iconInfo objectForKey:@"Image"];
    
    if (img == nil)
        return NO;
    
    [iconImageView setImage:img];
    [self setIcnsFilePath:[iconInfo objectForKey:@"Path"]];
    
    return YES;
}

#pragma mark -

// sets text to custom icon
- (void)updateForCustomIcon {
    [iconNameTextField setStringValue:@"Custom Icon"];
    [self writeIconToPath:TMP_ICON_PATH];
    [self setIcnsFilePath:TMP_ICON_PATH];
}

#pragma mark -

/*****************************************
 - Dragging and dropping for the PlatypusIconView
 *****************************************/

- (BOOL)performDragOperation:(id <NSDraggingInfo> )sender {
    NSPasteboard *pboard = [sender draggingPasteboard];
    
    if ([[pboard types] containsObject:NSFilenamesPboardType]) {
        int i;
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
        
        // first, we look for an icns file, and load it if there is one
        for (i = 0; i < [files count]; i++)
            if ([[files objectAtIndex:i] hasSuffix:@"icns"])
                return [self loadIcnsFile:[files objectAtIndex:i]];
        
        // since no icns file, search for an image, load the first one we find
        for (i = 0; i < [files count]; i++) {
            NSArray *supportedImageTypes = [PlatypusUtility imageFileSuffixes];
            int j;
            for (j = 0; j < [supportedImageTypes count]; j++)
                if ([[files objectAtIndex:i] hasSuffix:[supportedImageTypes objectAtIndex:j]])
                    return [self loadImageFile:[files objectAtIndex:i]];
        }
    }
    
    return NO;
}

- (BOOL)isPresetIcon:(NSString *)str {
    return ([str hasPrefix:[[NSBundle mainBundle] resourcePath]]);
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo> )sender {
    // we accept dragged files
    if ([[[sender draggingPasteboard] types] containsObject:NSFilenamesPboardType]) {
        NSArray *files = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
        int i;
        
        
        // link for icns file, but not if it's a preset icon
        for (i = 0; i < [files count]; i++) {
            if ([self isPresetIcon:[files objectAtIndex:i]])
                return NSDragOperationNone;
            
            if ([[files objectAtIndex:i] hasSuffix:@"icns"])
                return NSDragOperationLink;
        }
        
        // copy plus for image file
        for (i = 0; i < [files count]; i++) {
            NSArray *supportedImageTypes = [PlatypusUtility imageFileSuffixes];
            int j;
            for (j = 0; j < [supportedImageTypes count]; j++)
                if ([[files objectAtIndex:i] hasSuffix:[supportedImageTypes objectAtIndex:j]])
                    return NSDragOperationCopy;
        }
    }
    
    return NSDragOperationNone;
}

// if we just created a file with a dragged string, we open it in default editor
- (void)concludeDragOperation:(id <NSDraggingInfo> )sender {
}

@end
