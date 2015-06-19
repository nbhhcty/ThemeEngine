//
//  TKBitmapRendition.m
//  ThemeKit
//
//  Created by Alexander Zielenski on 6/13/15.
//  Copyright © 2015 Alex Zielenski. All rights reserved.
//

#import "TKBitmapRendition.h"
#import "TKRendition+Private.h"
#import "TKElement.h"
#import "TKLayoutInformation+Private.h"

#import <CoreUI/Renditions/CUIRenditions.h>

@implementation TKBitmapRendition
@dynamic image;

- (instancetype)_initWithCUIRendition:(CUIThemeRendition *)rendition csiData:(NSData *)csiData  key:(CUIRenditionKey *)key {
    if ((self = [super _initWithCUIRendition:rendition csiData:(NSData *)csiData key:key])) {
        self.assetPack = rendition.type == CoreThemeTypeAssetPack;
        self.exifOrientation = rendition.exifOrientation;
        self.utiType         = rendition.utiType;
        self.blendMode       = rendition.blendMode;
        self.opacity         = rendition.opacity;
        
        if (self.type == CoreThemeTypeSixPart) {
            self.layoutInformation = [TKLayoutInformation layoutInformationWithCSIData:csiData];
//            NSLog(@"%@", rendition.sliceInformation);
        }
        
    }
    
    return self;
}

- (void)computePreviewImageIfNecessary {
    if (self._previewImage)
        return;
    
    if (self.image) {
        // Just get the image of the rendition
        self._previewImage = [[NSImage alloc] initWithSize:self.image.size];
        [self._previewImage addRepresentation:self.image];
    }
}

- (void)setElement:(TKElement * __nullable)element {
    [super setElement:element];
    
    if ([self.rendition isKindOfClass:TKClass(_CUIInternalLinkRendition)]) {
        [self.rendition _setStructuredThemeStore:self.element.storage];
    }
}

- (NSBitmapImageRep *)image {
    // Lazy load
    // We must set our image here so internal references can be resolved
    // -initWithCGImage: only bumps the retain count, it does not copy, so we're good
    if (!_image) {
        CGImageRef unsliced = self.rendition.unslicedImage;
        if (unsliced != NULL)
            self.image = [[NSBitmapImageRep alloc] initWithCGImage:unsliced];
    }
    return _image;
}

- (void)setImage:(NSBitmapImageRep *)image {
    if (!image) {
        [NSException raise:@"Invalid Argument" format:@"TKBitmapRendition: Image must be non-null!"];
        return;
    }
    
    _image = image;
    self._previewImage = nil;
}

@end
