/*
 Copyright (c) 2016, Stephane Sudre
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 - Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 - Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 - Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "NRGCollectionViewItemLabel.h"

#define NRGCOLLECTIONVIEWITEMLABEL_TEXT_INSET	4.0

@implementation NRGCollectionViewItemLabel

- (void)setSelected:(BOOL)inSelected
{
	_selected=inSelected;
	
	[self setNeedsDisplay:YES];
}

#pragma mark -

- (void)drawRect:(NSRect)dirtyRect
{
	NSRect tBounds=[self bounds];
	NSRect tRoundRect=NSInsetRect(tBounds,1,1);
	CGFloat tRadius=round(NSHeight(tRoundRect)*0.5);
	tRoundRect.size.height=2*tRadius;
	
	NSString * tString=[self stringValue];
	NSRect tBoundingRect;
	
	// Draw Background
	
	NSDictionary * tAttributes=nil;
	
	if ([self isSelected]==YES)
	{
		static NSDictionary * sSelectedAttributesDictionary=nil;
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			
			NSMutableParagraphStyle * tMutableParagraphStyle=[[NSParagraphStyle defaultParagraphStyle] mutableCopy];
			
			[tMutableParagraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
			[tMutableParagraphStyle setAlignment:NSCenterTextAlignment];
			
			NSShadow * tShadow=[NSShadow new];
			
			tShadow.shadowBlurRadius=0;
			tShadow.shadowOffset=CGSizeMake(0,-1);
			tShadow.shadowColor=[NSColor colorWithDeviceWhite:0.40 alpha:1.0];
			
			sSelectedAttributesDictionary=@{
											NSForegroundColorAttributeName : [NSColor whiteColor],
											NSParagraphStyleAttributeName : tMutableParagraphStyle,
											NSShadowAttributeName : tShadow,
											NSFontAttributeName : [NSFont systemFontOfSize:11.0]
											};
		});
		
		tAttributes=sSelectedAttributesDictionary;
	}
	else
	{
		static NSDictionary * sUnselectedAttributesDictionary=nil;
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			
			NSMutableParagraphStyle * tMutableParagraphStyle=[[NSParagraphStyle defaultParagraphStyle] mutableCopy];
			
			[tMutableParagraphStyle setLineBreakMode:NSLineBreakByTruncatingMiddle];
			[tMutableParagraphStyle setAlignment:NSCenterTextAlignment];

			
			sUnselectedAttributesDictionary=@{
											  NSForegroundColorAttributeName : [NSColor blackColor],
											  NSParagraphStyleAttributeName : tMutableParagraphStyle,
											  NSFontAttributeName : [NSFont systemFontOfSize:11.0]
											  };
		});
		
		tAttributes=sUnselectedAttributesDictionary;
	}
	
	tBoundingRect=[tString boundingRectWithSize:tRoundRect.size options:0 attributes:tAttributes];
	
	if (tBoundingRect.size.width<=(tRoundRect.size.width-2*(tRadius+NRGCOLLECTIONVIEWITEMLABEL_TEXT_INSET)))
	{
		tRoundRect.size.width=tBoundingRect.size.width+2*(tRadius+NRGCOLLECTIONVIEWITEMLABEL_TEXT_INSET);
		
		[self setToolTip:nil];
	}
	else
	{
		[self setToolTip:tString];
	}
	
	tRoundRect.origin.x=round(NSMidX(tBounds)-NSWidth(tRoundRect)*0.5);
	
	if ([self isSelected]==YES)
	{
		tRoundRect.origin.y-=0.5;
		
		NSBezierPath * tBezierPath=[NSBezierPath bezierPathWithRoundedRect:tRoundRect xRadius:tRadius yRadius:tRadius];
		
		[[NSColor colorWithDeviceRed:78.0/255.0 green:168.0/255.0 blue:229.0/255.0 alpha:1.0] setFill];
		
		[tBezierPath fill];
		
		[[NSColor colorWithDeviceRed:40.0/255.0 green:130.0/255.0 blue:191.0/255.0 alpha:1.0] setStroke];
		
		[tBezierPath stroke];
	}
	
	[tString drawInRect:NSMakeRect(NSMinX(tRoundRect)+tRadius+NRGCOLLECTIONVIEWITEMLABEL_TEXT_INSET,NSMinY(tRoundRect)-0.5,NSWidth(tRoundRect)-2*(tRadius+NRGCOLLECTIONVIEWITEMLABEL_TEXT_INSET),NSHeight(tBoundingRect)) withAttributes:tAttributes];
}

@end
