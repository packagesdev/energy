//
//  NSImage+Private.h
//  Energy
//
//  Created by stephane on 19/11/2018.
//  Copyright © 2018 Whitebox. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSImage (Private)

- (void)_drawMappingAlignmentRectToRect:(NSRect)rect withState:(NSUInteger)arg2 backgroundStyle:(int)arg3 operation:(NSCompositingOperation)op fraction:(CGFloat)delta flip:(BOOL)inFlipped hints:(id)hints;

@end
