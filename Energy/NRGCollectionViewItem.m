/*
 Copyright (c) 2016, Stephane Sudre
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
 
 - Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
 - Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
 - Neither the name of the WhiteBox nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "NRGCollectionViewItem.h"
#import "NRGCollectionViewItemLabel.h"

NSString * const NRGCollectionViewRepresentedObjectThumbnail=@"thumbnail";
NSString * const NRGCollectionViewRepresentedObjectDisplayName=@"displayName";

NSString * const NRGCollectionViewRepresentedObjectName=@"name";
NSString * const NRGCollectionViewRepresentedObjectStyleID=@"styleID";

@interface NRGCollectionViewItem ()
{
	IBOutlet NSImageView * _thumbnailImageView;
	IBOutlet NRGCollectionViewItemLabel * _nameLabelView;
}

@property (nonatomic,readwrite) NSImage * thumbnail;
@property (nonatomic,readwrite,copy) NSString * displayName;

@property (nonatomic,readwrite,copy) NSString * name;
@property (nonatomic,readwrite,copy) NSString * styleID;

@property (readwrite) NSInteger tag;

@end

@implementation NRGCollectionViewItem

- (void)awakeFromNib
{
	[self setThumbnail:_thumbnail];
	
	[self setDisplayName:_displayName];
	
	[self setName:_name];
	
	[self setSelected:[self isSelected]];
}

#pragma mark -

- (void)setThumbnail:(NSImage *)inThumbnail
{
	_thumbnail=inThumbnail;
	
	[_thumbnailImageView setImage:_thumbnail];
}

- (void)setDisplayName:(NSString *)inDisplayName
{
	_displayName=inDisplayName;
	
	if (_name!=nil)
		[_nameLabelView setStringValue:_displayName];
	else
		[_nameLabelView setStringValue:@""];
}

- (void)setSelected:(BOOL)inSelected
{
	[super setSelected:inSelected];
	
	[_nameLabelView setSelected:inSelected];
}

#pragma mark -

- (void)setRepresentedObject:(id)inRepresentedObject
{
	[super setRepresentedObject:inRepresentedObject];
	
	if ([inRepresentedObject isKindOfClass:[NSDictionary class]]==YES)
	{
		NSDictionary * tDictionary=(NSDictionary *)inRepresentedObject;
		
		self.thumbnail=tDictionary[NRGCollectionViewRepresentedObjectThumbnail];
		self.displayName=tDictionary[NRGCollectionViewRepresentedObjectDisplayName];
		
		self.name=tDictionary[NRGCollectionViewRepresentedObjectName];
		self.styleID=tDictionary[NRGCollectionViewRepresentedObjectStyleID];
	}
}

@end
