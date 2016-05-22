/*
 Copyright (c) 2016, Stephane Sudre
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 - Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 - Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 - Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "NRGConfigurationWindowController.h"

#import <ScreenSaver/ScreenSaver.h>

#import "NRGAboutBoxWindowController.h"

#import "NRGSettings.h"

#import "NRGWindow.h"

#import "NRGCollectionView.h"

#import "NRGCollectionViewItem.h"

#import "ScreenSaverModules.h"
#import "SlideShows.h"

NSString * const NRGModuleNameILifeSlideshows=@"iLifeSlideshows";

@interface NRGConfigurationWindowController () <NRGCollectionViewDelegate,NRGWindowDelegate>
{
    IBOutlet NRGCollectionView *_limitedPowerModulesCollectionView;
	
	IBOutlet NRGCollectionView *_unlimitedPowerModulesCollectionView;
    
    IBOutlet NSButton * _cancelButton;
    
    NSRect _savedCancelButtonFrame;
    
    NSArray * _cachedModulesList;
    
    NRGSettings * _nrgSettings;
}

- (void)_selectCollectionView:(NRGCollectionView *) inCollectionView itemWithModuleName:(NSString *)inModuleName styleID:(NSString *)inStyleID;

- (IBAction)showAboutBox:(id)sender;

- (IBAction)resetDialogSettings:(id)sender;

- (IBAction)closeDialog:(id)sender;

@end

@implementation NRGConfigurationWindowController

+ (NSArray *)modulesList
{
	NSBundle * tScreenEffectsPrefPaneBundle=[NSBundle bundleWithPath:@"/System/Library/PreferencePanes/DesktopScreenEffectsPref.prefPane/Contents/Resources/ScreenEffects.prefPane"];
	
	NSMutableArray * tDiaporamaModulesList=[NSMutableArray array];
	
	// Diaporamas "Modules" (they are not sorted alphabetically)
	
	MPStyleManager * tSharedStyleManager=[MPStyleManager sharedManager];
	
	NSArray * tWellKnownStyleIDs=@[@"Floating",
								   @"Flipup",
								   @"Reflections",
								   @"Origami",
								   @"ShiftingTiles",
								   @"SlidingPanels",
								   @"PhotoMobile",
								   @"HolidayMobile",
								   @"PhotoWall",
								   @"VintagePrints",
								   @"KenBurns",
								   @"Classic"];
	
	NSMutableArray * tSlideShowStyleIDs=[[tSharedStyleManager allStyleIDs] mutableCopy];
	
	[tSlideShowStyleIDs removeObjectsInArray:tWellKnownStyleIDs];
	
	[tSlideShowStyleIDs insertObjects:tWellKnownStyleIDs atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [tWellKnownStyleIDs count])]];
	
	for(NSString * tStyleID in tSlideShowStyleIDs)
	{
		if ([tStyleID isEqualToString:@"WatercolorPanels"]==NO &&
			[tStyleID isEqualToString:@"PhotoEdges"]==NO &&
			[tStyleID isEqualToString:@"Places"]==NO &&
			[tStyleID isEqualToString:@"Shatter"]==NO)
		{
			NSString * tLocalizedName=[tSharedStyleManager localizedNameForStyleID:tStyleID];
			
			NSMutableDictionary * tRepresentation=[NSMutableDictionary dictionaryWithObjectsAndKeys:NRGModuleNameILifeSlideshows,NRGCollectionViewRepresentedObjectName,
												   tStyleID,NRGCollectionViewRepresentedObjectStyleID,
												   tLocalizedName,NRGCollectionViewRepresentedObjectDisplayName,
												   nil];
			
			NSImage * tThumbnail=[tScreenEffectsPrefPaneBundle imageForResource:tStyleID];
			
			
			if (tThumbnail==nil)
				tThumbnail=[tScreenEffectsPrefPaneBundle imageForResource:@"Default"];
			
			if (tThumbnail!=nil)
				tRepresentation[NRGCollectionViewRepresentedObjectThumbnail]=tThumbnail;
			
			[tDiaporamaModulesList addObject:tRepresentation];
		}
	}
	
	ScreenSaverModules * tSharedInstance=[ScreenSaverModules sharedInstance];
	
	// Apple "Modules" (they are not sorted alphabetically)
	
	NSArray * tWellKnownAppleModules=@[@"Flurry",@"Arabesque",@"Shell",@"Computer Name",@"iTunes Artwork",@"Word of the Day"];
	
	NSMutableArray * tAppleModulesList=[NSMutableArray array];
	
	for(NSString * tModuleName in tWellKnownAppleModules)
	{
		NSString * tPath=[tSharedInstance pathForModuleName:tModuleName];
		
		if ([tPath length]!=0)
		{
			NSString * tLocalizedName=[ScreenSaverModule localizedSaverNameForPath:tPath];
			
			NSMutableDictionary * tRepresentation=[NSMutableDictionary dictionaryWithObjectsAndKeys:tModuleName,NRGCollectionViewRepresentedObjectName,
												   tLocalizedName ?: tModuleName,NRGCollectionViewRepresentedObjectDisplayName,
												   nil];
			
			NSImage * tThumbnail=nil;
			
			if ([[tPath pathExtension] isEqualToString:@"qtz"]==YES)	// Quartz Module are not bundles.
			{
				tThumbnail=[tScreenEffectsPrefPaneBundle imageForResource:tModuleName];
			}
			else
			{
				NSBundle * tModuleBundle=[NSBundle bundleWithPath:tPath];
			
				tThumbnail=[tModuleBundle imageForResource:@"thumbnail"];
			}
			
			if (tThumbnail==nil)
				tThumbnail=[tScreenEffectsPrefPaneBundle imageForResource:@"Default"];
			
			if (tThumbnail!=nil)
				tRepresentation[NRGCollectionViewRepresentedObjectThumbnail]=tThumbnail;
			
			[tAppleModulesList addObject:tRepresentation];
			
		}
	}
	
	// Other Modules
	
	NSMutableArray * tAllModules=[[tSharedInstance moduleNames] mutableCopy];
	
	[tAllModules removeObjectsInArray:tWellKnownAppleModules];
	
	NSMutableArray * tOtherModulesList=[NSMutableArray array];
	
	for(NSString * tModuleName in tAllModules)
	{
		if ([tModuleName isEqualToString:NRGModuleNameILifeSlideshows]==NO &&			// It was taken care of of these above
			[tModuleName isEqualToString:@"Pictures Folder"]==NO &&
			[tModuleName isEqualToString:@"FloatingMessage"]==NO &&
			[tModuleName isEqualToString:@"Energy"]==NO &&								// To avoid re-entrancy
			[tModuleName isEqualToString:@"Random"]==NO &&								// To avoid re-entrancy
			[tModuleName isEqualToString:@"screensaver.shuffle"]==NO)
		{
			NSString * tPath=[tSharedInstance pathForModuleName:tModuleName];
			
			if ([tPath length]!=0)
			{
				NSString * tLocalizedName=[ScreenSaverModule localizedSaverNameForPath:tPath];
				
				NSMutableDictionary * tRepresentation=[NSMutableDictionary dictionaryWithObjectsAndKeys:tModuleName,NRGCollectionViewRepresentedObjectName,
													   tLocalizedName ?: tModuleName,NRGCollectionViewRepresentedObjectDisplayName,
													   nil];
				
				NSBundle * tModuleBundle=[NSBundle bundleWithPath:tPath];
				
				NSImage * tThumbnail=[tModuleBundle imageForResource:@"thumbnail"];
				
				if (tThumbnail==nil)
					tThumbnail=[tScreenEffectsPrefPaneBundle imageForResource:@"Default"];
				
				if (tThumbnail!=nil)
					tRepresentation[NRGCollectionViewRepresentedObjectThumbnail]=tThumbnail;
				
				[tOtherModulesList addObject:tRepresentation];
			}
		}
	}
	
	[tOtherModulesList sortUsingComparator:^NSComparisonResult(NSDictionary * bDictionary1,NSDictionary *bDictionary2){
	
		return [bDictionary1[NRGCollectionViewRepresentedObjectDisplayName] caseInsensitiveCompare:bDictionary2[NRGCollectionViewRepresentedObjectDisplayName]];
	}];
	
	NSMutableArray * tModulesList=[NSMutableArray array];
	
	[tModulesList addObjectsFromArray:tDiaporamaModulesList];
	[tModulesList addObjectsFromArray:tAppleModulesList];
	[tModulesList addObjectsFromArray:tOtherModulesList];
	
	return [tModulesList copy];
}

- (id)init
{
	self=[super init];
	
	if (self!=nil)
	{
		NSString *tIdentifier = [[NSBundle bundleForClass:[self class]] bundleIdentifier];
		ScreenSaverDefaults *tDefaults = [ScreenSaverDefaults defaultsForModuleWithName:tIdentifier];
		
		_cachedModulesList=[NRGConfigurationWindowController modulesList];
		
		_nrgSettings=[[NRGSettings alloc] initWithDictionaryRepresentation:[tDefaults dictionaryRepresentation]];
	}
	
	return self;
}

- (NSString *)windowNibName
{
	return NSStringFromClass([self class]);
}

- (void)windowDidLoad
{
	[super windowDidLoad];
	
	_savedCancelButtonFrame=[_cancelButton frame];
	
	[_limitedPowerModulesCollectionView setMinItemSize:NSMakeSize(114.0,100.0)];
	
	[_limitedPowerModulesCollectionView setContent:_cachedModulesList];
	
	[_unlimitedPowerModulesCollectionView setMinItemSize:NSMakeSize(114.0,100.0)];
	
	[_unlimitedPowerModulesCollectionView setContent:_cachedModulesList];
}

#pragma mark -

- (void)_selectCollectionView:(NRGCollectionView *) inCollectionView itemWithModuleName:(NSString *)inModuleName styleID:(NSString *)inStyleID
{
	[inCollectionView.content enumerateObjectsUsingBlock:^(NSDictionary * bDictionary,NSUInteger bIndex,BOOL * bOutStop){
		NSString * tModuleName=bDictionary[NRGCollectionViewRepresentedObjectName];
		
		if ([tModuleName isEqualToString:inModuleName]==YES)
		{
			if ([inModuleName isEqualToString:NRGModuleNameILifeSlideshows]==NO)
			{
				[inCollectionView NRG_selectItemAtIndex:bIndex];
				
				*bOutStop=YES;
				return;
			}
		
			NSString * tModuleStyleID=bDictionary[NRGCollectionViewRepresentedObjectStyleID];
			
			if (inStyleID!=nil && [tModuleStyleID isEqualToString:inStyleID]==YES)
			{
				[inCollectionView NRG_selectItemAtIndex:bIndex];
					
				*bOutStop=YES;
			}
		}
	}];
}

#pragma mark -

- (void)restoreUI
{
	NSString * tSearchedModuleName=_nrgSettings.limitedPowerModuleName;
	NSString * tSearchedStyleID=_nrgSettings.limitedPowerModuleStyleID;
	
	[self _selectCollectionView:_limitedPowerModulesCollectionView itemWithModuleName:tSearchedModuleName styleID:tSearchedStyleID];
	
	tSearchedModuleName=_nrgSettings.unlimitedPowerModuleName;
	tSearchedStyleID=_nrgSettings.unlimitedPowerModuleStyleID;
	
	[self _selectCollectionView:_unlimitedPowerModulesCollectionView itemWithModuleName:tSearchedModuleName styleID:tSearchedStyleID];
}

#pragma mark -

- (IBAction)showAboutBox:(id)sender
{
	static NRGAboutBoxWindowController * sAboutBoxWindowController=nil;
	
	if (sAboutBoxWindowController==nil)
		sAboutBoxWindowController=[NRGAboutBoxWindowController new];
	
	if ([sAboutBoxWindowController.window isVisible]==NO)
		[sAboutBoxWindowController.window center];
	
	[sAboutBoxWindowController.window makeKeyAndOrderFront:nil];
}

- (IBAction)resetDialogSettings:(id)sender
{
	[_nrgSettings resetSettings];
	
	[self restoreUI];
}

- (IBAction)closeDialog:(id)sender
{
	NSString *tIdentifier = [[NSBundle bundleForClass:[self class]] bundleIdentifier];
	ScreenSaverDefaults *tDefaults = [ScreenSaverDefaults defaultsForModuleWithName:tIdentifier];
	
	if ([sender tag]==NSModalResponseOK)
	{
		NSIndexSet * tSelectionIndexSet=[_limitedPowerModulesCollectionView selectionIndexes];
		
		if ([tSelectionIndexSet count]==1)
		{
			NSUInteger tIndex=[tSelectionIndexSet firstIndex];
			
			NRGCollectionViewItem * tCollectionViewItem=(NRGCollectionViewItem *)[_limitedPowerModulesCollectionView itemAtIndex:tIndex];
			
			if (tCollectionViewItem!=nil)
			{
				_nrgSettings.limitedPowerModuleName=tCollectionViewItem.name;
				_nrgSettings.limitedPowerModuleStyleID=tCollectionViewItem.styleID;
			}
		}
		else
		{
			NSLog(@"Strange case: there should only be one selected item");
		}
		
		tSelectionIndexSet=[_unlimitedPowerModulesCollectionView selectionIndexes];
		
		if ([tSelectionIndexSet count]==1)
		{
			NSUInteger tIndex=[tSelectionIndexSet firstIndex];
			
			NRGCollectionViewItem * tCollectionViewItem=(NRGCollectionViewItem *)[_unlimitedPowerModulesCollectionView itemAtIndex:tIndex];
			
			if (tCollectionViewItem!=nil)
			{
				_nrgSettings.unlimitedPowerModuleName=tCollectionViewItem.name;
				_nrgSettings.unlimitedPowerModuleStyleID=tCollectionViewItem.styleID;
			}
		}
		else
		{
			NSLog(@"Strange case: there should only be one selected item");
		}

		// Set Defaults
		
		NSDictionary * tDictionary=[_nrgSettings dictionaryRepresentation];
		
		NSArray * tCurrentKeys=[[tDefaults dictionaryRepresentation] allKeys];	// Remove all objects so that key with nil values are no more set.
		
		for(NSString * tKey in tCurrentKeys)
			[tDefaults removeObjectForKey:tKey];
		
		[tDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *bKey,id bObject, BOOL * bOutStop){
			[tDefaults setObject:bObject forKey:bKey];
		}];
		
		[tDefaults synchronize];
	}
	
	[NSApp endSheet:self.window];
}

#pragma mark -

- (void)window:(NSWindow *)inWindow modifierFlagsDidChange:(NSUInteger) inModifierFlags
{
	if ((inModifierFlags & NSAlternateKeyMask) == NSAlternateKeyMask)
	{
		NSRect tOriginalFrame=[_cancelButton frame];
		
		[_cancelButton setTitle:NSLocalizedStringFromTableInBundle(@"Reset",@"Localizable",[NSBundle bundleForClass:[self class]],@"")];
		[_cancelButton setAction:@selector(resetDialogSettings:)];
		
		[_cancelButton sizeToFit];
		
		NSRect tFrame=[_cancelButton frame];
		
		tFrame.size.width+=10.0;	// To compensate for sizeToFit stupidity
		
		if (NSWidth(tFrame)<84.0)
			tFrame.size.width=84.0;
		
		tFrame.origin.x=NSMaxX(tOriginalFrame)-NSWidth(tFrame);
		
		[_cancelButton setFrame:tFrame];
	}
	else
	{
		[_cancelButton setTitle:NSLocalizedStringFromTableInBundle(@"Cancel",@"Localizable",[NSBundle bundleForClass:[self class]],@"")];
		[_cancelButton setAction:@selector(closeDialog:)];
		
		[_cancelButton setFrame:_savedCancelButtonFrame];
	}
}

@end
