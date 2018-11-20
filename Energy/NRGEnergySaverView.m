/*
 Copyright (c) 2016-2018, Stephane Sudre
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 - Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 - Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 - Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "NRGEnergySaverView.h"

#import <IOKit/ps/IOPowerSources.h>

#import "NRGConfigurationWindowController.h"

#import "ScreenSaverModules.h"
#import "ScreenSaverModule.h"

#import "ILifeMediaBrowser.h"
#import "SlideShows.h"

#import "NSImage+Private.h"

#import "NRGSettings.h"

#include <dlfcn.h>
#include <notify.h>

static id _runningScreenSaverView=nil;

@interface NRGEnergySaverView ()
{
    ScreenSaverModule * _limitedPowerModule;
	NSString * _limitedPowerModuleStyleID;
    ScreenSaverModule * _unlimitedPowerModule;
	NSString * _unlimitedPowerModuleStyleID;
	
	int _notificationToken;
	
    // Preferences
	
	NRGConfigurationWindowController *_configurationWindowController;
}

+ (NSString *)displayNameForModule:(ScreenSaverModule *)inModule styleID:(NSString *)inStyleID;

+ (NSImage *)thumbnailForModule:(ScreenSaverModule *)inModule styleID:(NSString *)inStyleID;

@end

@implementation NRGEnergySaverView

+ (void)initialize
{
	dlopen("/System/Library/PrivateFrameworks/Slideshows.framework/Slideshows", RTLD_LAZY);
}

+ (NSString *)displayNameForModule:(ScreenSaverModule *)inModule styleID:(NSString *)inStyleID
{
	if ([[inModule name] isEqualToString:@"iLifeSlideshows"]==YES && inStyleID!=nil)
	{
		MPStyleManager * tSharedStyleManager=[NSClassFromString(@"MPStyleManager") sharedManager];
		
		return [tSharedStyleManager localizedNameForStyleID:inStyleID];
	}
	
	NSString * tLocalizedName=[inModule displayName];
	
	return tLocalizedName ?: [inModule name];
}

+ (NSImage *)thumbnailForModule:(ScreenSaverModule *)inModule styleID:(NSString *)inStyleID
{
	if ([inModule isScreenSaver]==YES && [[inModule name] isEqualToString:@"iLifeSlideshows"]==NO)
	{
		NSImage * tThumbnail=[inModule thumbnail];
		
		if (tThumbnail!=nil)
			return tThumbnail;
	}
	
	NSBundle * tBundle=[NSBundle bundleWithPath:@"/System/Library/PreferencePanes/DesktopScreenEffectsPref.prefPane/Contents/Resources/ScreenEffects.prefPane"];
	
	if (tBundle==nil)
		return nil;
	
	if ([[inModule name] isEqualToString:@"iLifeSlideshows"]==YES)
		return [tBundle imageForResource:inStyleID];
	
	if ([inModule isQC]==YES)
		return [tBundle imageForResource:[inModule name]];
	
	return [tBundle imageForResource:@"Default"];
}

#pragma mark -

+ (NSBackingStoreType)backingStoreType
{
	if (_runningScreenSaverView!=nil)
	{
		return [[_runningScreenSaverView class] backingStoreType];
	}
	
	return NSBackingStoreBuffered;
}

+ (BOOL)performGammaFade
{
	if (_runningScreenSaverView!=nil)
	{
		return [[_runningScreenSaverView class] performGammaFade];
	}
	
	return YES;
}

- (id)initWithFrame:(NSRect)inFrame isPreview:(BOOL)inPreview
{
    if (inPreview==NO)
    {
        NSString *tIdentifier = [[NSBundle bundleForClass:[self class]] bundleIdentifier];
        ScreenSaverDefaults *tDefaults = [ScreenSaverDefaults defaultsForModuleWithName:tIdentifier];
        
        NRGSettings * tSettings=[[NRGSettings alloc] initWithDictionaryRepresentation:[tDefaults dictionaryRepresentation]];
        
        NSString * tModuleName=nil;
		NSString * tModuleStyleID=nil;
		
        CFTimeInterval tTimeRemainingEstimate=IOPSGetTimeRemainingEstimate();
        
        if (tTimeRemainingEstimate==kIOPSTimeRemainingUnlimited)
        {
            tModuleName=tSettings.unlimitedPowerModuleName;
			tModuleStyleID=tSettings.unlimitedPowerModuleStyleID;
        }
        else
        {
            tModuleName=tSettings.limitedPowerModuleName;
			tModuleStyleID=tSettings.limitedPowerModuleStyleID;
        }
		
		ScreenSaverModules * tModules=[ScreenSaverModules sharedInstance];
		
		[tModules findAllModules];
		
		ScreenSaverModule * tModule=nil;
		
		if (([tModuleName isEqualToString:@"iTunes Artwork"] == YES) &&
			([[[ILPluginManager sharedPluginManager] pluginForIdentifier:@"com.apple.iTunes" forceLoad:YES] canLoadData] ==NO))
		{
			NSString * tMessage=NSLocalizedStringFromTableInBundle(@"The iTunes Artwork module could not be used.",@"Localizable",[NSBundle bundleForClass:[self class]],@"");
			
			tModule=[ScreenSaverModule floatingMessageModuleWithMessage:tMessage];
		}
		else
		{
			if (tModuleName==nil)
			{
				NSString * tMessage=NSLocalizedStringFromTableInBundle(@"No Screen Saver module has been defined for this power source mode.",@"Localizable",[NSBundle bundleForClass:[self class]],@"");
				
				tModule=[ScreenSaverModule floatingMessageModuleWithMessage:tMessage];
			}
			else
			{
				if ([tModuleName isEqualToString:@"iLifeSlideshows"]==YES && tModuleStyleID!=nil)
				{
					ScreenSaverDefaults * tDefaults=[ScreenSaverDefaults defaultsForModuleWithName:@"com.apple.ScreenSaver.iLifeSlideShows"];	// Not really obvious that it's @"com.apple.ScreenSaver.iLifeSlideShows"
					
					[tDefaults setObject:tModuleStyleID forKey:@"styleKey"];
					
					[tDefaults synchronize];
				}
				
				tModule=[tModules moduleWithName:tModuleName];
				
				NSString * tMessage=[NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"The Screen Saver module named \"%@\" has not be found on this computer.",@"Localizable",[NSBundle bundleForClass:[self class]],@""),tModuleName];
				
				if (tModuleName==nil)
					tModule=[ScreenSaverModule floatingMessageModuleWithMessage:tMessage];
			}
		}
		
		if (tModule!=nil)
		{
			_runningScreenSaverView=[tModules loadModule:tModule frame:inFrame isPreview:inPreview];
			
			return _runningScreenSaverView;
		}
    }
	
	self=[super initWithFrame:inFrame isPreview:inPreview];
	
	return self;
}

- (void)dealloc
{
	_runningScreenSaverView=nil;
}

#pragma mark -

- (void)startAnimation
{
    NSString *tIdentifier = [[NSBundle bundleForClass:[self class]] bundleIdentifier];
    ScreenSaverDefaults *tDefaults = [ScreenSaverDefaults defaultsForModuleWithName:tIdentifier];
    
    NRGSettings * tSettings=[[NRGSettings alloc] initWithDictionaryRepresentation:[tDefaults dictionaryRepresentation]];
    
    ScreenSaverModules * tModules=[ScreenSaverModules sharedInstance];
	[tModules findAllModules];
	
    _limitedPowerModule=[tModules moduleWithName:tSettings.limitedPowerModuleName];
	_limitedPowerModuleStyleID=tSettings.limitedPowerModuleStyleID;
	
    _unlimitedPowerModule=[tModules moduleWithName:tSettings.unlimitedPowerModuleName];
	_unlimitedPowerModuleStyleID=tSettings.unlimitedPowerModuleStyleID;
	
	[self setNeedsDisplay:YES];
	
    [super startAnimation];
	
	NRGEnergySaverView * __weak tWeakSelf=self;
	
	uint32_t tRegistrationStatus=notify_register_dispatch(kIOPSNotifyPowerSource, &_notificationToken, dispatch_get_main_queue(), ^(int bToken) {
		
		NRGEnergySaverView * tStrongSelf=tWeakSelf;
		
		[tStrongSelf setNeedsDisplay:YES];
		
	});
	
	if (tRegistrationStatus!=NOTIFY_STATUS_OK)
		NSLog(@"Could not register for power source notifications (status=%d)",tRegistrationStatus);
}

- (void)stopAnimation
{
	notify_cancel(_notificationToken);
	
    _limitedPowerModule=nil;
	_limitedPowerModuleStyleID=nil;
	
    _unlimitedPowerModule=nil;
	_unlimitedPowerModuleStyleID=nil;
    
    [super stopAnimation];
}

#define THUMBNAIL_WIDTH		90.
#define THUMBNAIL_HEIGHT	58.
#define THUMBNAIL_CORNER_RADIUS	4.

#define CENTER_VERTICAL_OFFSET	20.

- (void)drawRect:(NSRect)rect
{
    if ([self isPreview]==YES)
    {
		BOOL tIsDarkAppearance=[self NRG_isEffectiveAppareanceDarkAqua];
		
		BOOL tIsLimitedPowerSource;
		
		tIsLimitedPowerSource=(IOPSGetTimeRemainingEstimate()!=kIOPSTimeRemainingUnlimited);
		
        NSColor * tLimitedPowerSourceColor=(tIsLimitedPowerSource==YES)? [NSColor labelColor] : [NSColor tertiaryLabelColor];
        NSColor * tUnlimitedPowerSourceColor=(tIsLimitedPowerSource==NO)? [NSColor labelColor] : [NSColor tertiaryLabelColor];
        CGFloat tLimitedPowerSourceAlpha=(tIsLimitedPowerSource==YES)? 1.0 : 0.5;
		CGFloat tUnimitedPowerSourceAlpha=(tIsLimitedPowerSource==NO)? 1.0 : 0.5;
		
        if (tIsDarkAppearance==NO)
            [[NSColor whiteColor] set];
        else
            [[NSColor colorWithDeviceWhite:0.0 alpha:0.85] set];
        
        NSRectFill(rect);
        
		if (tIsDarkAppearance==NO)
            [[NSColor colorWithDeviceWhite:0.75 alpha:1.0] set];
		else
            [[NSColor colorWithDeviceWhite:0.25 alpha:1.0] set];
        
        NSRect tBounds=[self bounds];
        
        NSRectFillUsingOperation(NSMakeRect(round(NSMidX(tBounds)),NSMinY(tBounds),1,NSHeight(tBounds)),NSCompositeSourceOver);
        
        NSRect tLimitedPowerFrame=tBounds;
        tLimitedPowerFrame.size.width=round(NSWidth(tBounds)*0.5);
        
		NSImage * tPowerSourceIcon=[[NSBundle bundleForClass:[self class]] imageForResource:@"limitedPower"];
		tPowerSourceIcon.template=YES;
        
		NSSize tPowerSourceIconSize=tPowerSourceIcon.size;
		
        [tPowerSourceIcon _drawMappingAlignmentRectToRect:NSMakeRect(round(NSMidX(tLimitedPowerFrame)-tPowerSourceIconSize.width*0.5)+2.0,round(NSMaxY(tLimitedPowerFrame)-tPowerSourceIconSize.height-10.),tPowerSourceIconSize.width,tPowerSourceIconSize.height)
                                      withState:10
                                backgroundStyle:NSBackgroundStyleRaised
                                      operation:NSCompositeSourceOver
                                       fraction:tLimitedPowerSourceAlpha
                                           flip:NO
                                          hints:nil];
		
		NSImage * tThumbnail=[NRGEnergySaverView thumbnailForModule:_limitedPowerModule styleID:_limitedPowerModuleStyleID];
        
        if (tThumbnail!=nil)
        {
            NSSize tSize=[tThumbnail size];
            
            [tThumbnail drawAtPoint:NSMakePoint(round(NSMidX(tLimitedPowerFrame)-tSize.width*0.5),round(NSMidY(tLimitedPowerFrame)-tSize.height*0.5)-CENTER_VERTICAL_OFFSET) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:tLimitedPowerSourceAlpha];
        }
		
		NSBezierPath * tBezierPath=[NSBezierPath bezierPathWithRoundedRect:NSMakeRect(round(NSMidX(tLimitedPowerFrame)-THUMBNAIL_WIDTH*0.5)+0.5,round(NSMidY(tLimitedPowerFrame)-THUMBNAIL_HEIGHT*0.5)+0.5-CENTER_VERTICAL_OFFSET, THUMBNAIL_WIDTH-1, THUMBNAIL_HEIGHT-1)
																   xRadius:THUMBNAIL_CORNER_RADIUS
																   yRadius:THUMBNAIL_CORNER_RADIUS];
		
		[tLimitedPowerSourceColor setStroke];
		[tBezierPath stroke];
		
        NSString * tDisplayName=[NRGEnergySaverView displayNameForModule:_limitedPowerModule styleID:_limitedPowerModuleStyleID];
        
        NSMutableDictionary * tTitleAttributes=[@{NSForegroundColorAttributeName: tLimitedPowerSourceColor,
												  NSFontAttributeName : [NSFont labelFontOfSize:11.0]} mutableCopy];
            
		NSMutableParagraphStyle * tMutableParagraphStyle=[[NSParagraphStyle defaultParagraphStyle] mutableCopy];
		
		[tMutableParagraphStyle setAlignment:NSCenterTextAlignment];
		
		[tTitleAttributes setObject:tMutableParagraphStyle forKey:NSParagraphStyleAttributeName];
        
        [tDisplayName drawInRect:NSMakeRect(NSMinX(tLimitedPowerFrame),NSMidY(tLimitedPowerFrame)-55.0-CENTER_VERTICAL_OFFSET,NSWidth(tLimitedPowerFrame),20) withAttributes:tTitleAttributes];
        
        /****/
        
        NSRect tUnlimitedPowerFrame=tBounds;
        tUnlimitedPowerFrame.size.width=round(NSWidth(tBounds)*0.5);
        tUnlimitedPowerFrame.origin.x=NSMaxX(tBounds)-NSWidth(tUnlimitedPowerFrame);
		
		tPowerSourceIcon=[[NSBundle bundleForClass:[self class]] imageForResource:@"unlimitedPower"];
        tPowerSourceIcon.template=YES;
        
		tPowerSourceIconSize=tPowerSourceIcon.size;
		
        [tPowerSourceIcon _drawMappingAlignmentRectToRect:NSMakeRect(round(NSMidX(tUnlimitedPowerFrame)-tPowerSourceIconSize.width*0.5)+2.0,round(NSMaxY(tUnlimitedPowerFrame)-tPowerSourceIconSize.height-10.),tPowerSourceIconSize.width,tPowerSourceIconSize.height)
                                                withState:10
                                          backgroundStyle:NSBackgroundStyleRaised
                                                operation:NSCompositeSourceOver
                                                 fraction:tUnimitedPowerSourceAlpha
                                                     flip:NO
                                                    hints:nil];
		
		tThumbnail=[NRGEnergySaverView thumbnailForModule:_unlimitedPowerModule styleID:_unlimitedPowerModuleStyleID];
        
        if (tThumbnail!=nil)
        {
            NSSize tSize=[tThumbnail size];
            
            [tThumbnail drawAtPoint:NSMakePoint(round(NSMidX(tUnlimitedPowerFrame)-tSize.width*0.5),round(NSMidY(tUnlimitedPowerFrame)-tSize.height*0.5)-CENTER_VERTICAL_OFFSET) fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:tUnimitedPowerSourceAlpha];
        }
		
		tBezierPath=[NSBezierPath bezierPathWithRoundedRect:NSMakeRect(round(NSMidX(tUnlimitedPowerFrame)-THUMBNAIL_WIDTH*0.5)+0.5,round(NSMidY(tUnlimitedPowerFrame)-THUMBNAIL_HEIGHT*0.5)+0.5-CENTER_VERTICAL_OFFSET, THUMBNAIL_WIDTH-1, THUMBNAIL_HEIGHT-1)
													xRadius:THUMBNAIL_CORNER_RADIUS
													yRadius:THUMBNAIL_CORNER_RADIUS];
		
		[tUnlimitedPowerSourceColor setStroke];
		[tBezierPath stroke];
		
		tDisplayName=[NRGEnergySaverView displayNameForModule:_unlimitedPowerModule styleID:_unlimitedPowerModuleStyleID];
		
		[tTitleAttributes setObject:tUnlimitedPowerSourceColor forKey:NSForegroundColorAttributeName];
		
        [tDisplayName drawInRect:NSMakeRect(NSMinX(tUnlimitedPowerFrame),NSMidY(tUnlimitedPowerFrame)-55.0-CENTER_VERTICAL_OFFSET,NSWidth(tUnlimitedPowerFrame),20) withAttributes:tTitleAttributes];
    }
}

- (void)animateOneFrame
{
	return;
}

#pragma mark - Configuration

- (BOOL)hasConfigureSheet
{
	return YES;
}

- (NSWindow*)configureSheet
{
	if (_configurationWindowController==nil)
		_configurationWindowController=[[NRGConfigurationWindowController alloc] init];
	
	NSWindow * tWindow=_configurationWindowController.window;
	
	[_configurationWindowController restoreUI];
	
	return tWindow;
}

@end
