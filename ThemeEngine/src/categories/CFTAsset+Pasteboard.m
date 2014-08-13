//
//  CFTAsset+Pasteboard.m
//  carFileTool
//
//  Created by Alexander Zielenski on 8/12/14.
//  Copyright (c) 2014 Alexander Zielenski. All rights reserved.
//

#import "CFTAsset+Pasteboard.h"

@implementation CFTAsset (Pasteboard)

#pragma mark - NSPasteboardWriting

- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard {
    if (self.type > kCoreThemeTypePDF && self.type != kCoreThemeTypeColor)
        return @[];

    NSMutableArray *types = [NSMutableArray array];

    if (self.color) {
        [types addObject:NSPasteboardTypeColor];
        [types addObject:kCFTColorPboardType];
    }
    if (self.effectPreset)
        [types addObject:kCFTEffectWrapperPboardType];
    if (self.gradient)
        [types addObject:kCFTGradientPboardType];
    if (self.pdfData)
        [types addObject:NSPasteboardTypePDF];
    if (self.image)
        [types addObject:NSPasteboardTypePNG];
    [types addObject:(__bridge NSString *)kPasteboardTypeFilePromiseContent];
    [types addObject:(__bridge NSString *)kUTTypeFileURL];
    
    return types;
}

- (NSPasteboardWritingOptions)writingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pasteboard {
    return NSPasteboardWritingPromised;
}

- (id)pasteboardPropertyListForType:(NSString *)type {
    if ([type isEqualToString:NSPasteboardTypePDF])
        return self.pdfData;
    else if ([type isEqualToString:NSPasteboardTypePNG])
        return [self.previewImage.representations[0] representationUsingType:NSPNGFileType properties:nil];
    else if ([type isEqualToString:(__bridge NSString *)kPasteboardTypeFilePromiseContent]) {
        return self.type == kCoreThemeTypePDF ? (__bridge NSString *)kUTTypePDF : (__bridge NSString *)kUTTypePNG;
    } else if ([type isEqualToString:kCFTEffectWrapperPboardType]) {
        return [self.effectPreset pasteboardPropertyListForType:type];
    } else if ([type isEqualToString:NSPasteboardTypeColor]) {
        return [self.color pasteboardPropertyListForType:type];
    } else if ([type isEqualToString:kCFTGradientPboardType]) {
        return [self.gradient pasteboardPropertyListForType:type];
    } else if ([type isEqualToString:kCFTColorPboardType] ) {
        return [self.color pasteboardPropertyListForType:kCFTColorPboardType];
    }
    
    NSURL *finalURL = [NSURL URLWithString:[[[[NSUUID UUID] UUIDString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByAppendingPathExtension:self.type == kCoreThemeTypePDF ? @"pdf" : @"png"] relativeToURL:[NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:NSBundle.mainBundle.bundleIdentifier]]];
    
    if (self.type == kCoreThemeTypePDF)
        [self.pdfData writeToURL:finalURL atomically:NO];
    else
        [[self.previewImage.representations[0] representationUsingType:NSPNGFileType properties:nil] writeToURL:finalURL atomically:NO];
    
    
    return [finalURL absoluteString];
}

@end
