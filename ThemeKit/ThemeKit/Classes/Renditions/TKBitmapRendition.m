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
        self.blendMode       = rendition.blendMode;
        self.opacity         = rendition.opacity;
        
        self.layoutInformation = [TKLayoutInformation layoutInformationWithCSIData:csiData];
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
        if (unsliced != NULL) {
            _image = [[NSBitmapImageRep alloc] initWithCGImage:unsliced];
            self._previewImage = nil;
            
            // remove backing image after we're done with it
            CGImageRef *ptr = TKIvarPointer(self.rendition, "_unslicedImage");
            if (ptr != NULL && *ptr != NULL) {
                CGImageRelease(*ptr);
                *ptr = NULL;
            }

            // This is on CUIThemePixelRendition
            //!TODO: Circumvent the default unslicedImage implementation
            //! so that we can reliably throw out unused Apple data.
            //! and save ram
//            CGImageRef *image = TKIvarPointer(self.rendition, "unslicedImage");
//            if (image != NULL) {
//                if (*image != NULL)
//                    CGImageRelease(*image);
//                *image = NULL;
//            }
        }
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

+ (NSDictionary *)undoProperties {
    static NSDictionary *TKBitmapProperties = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        TKBitmapProperties = @{
                               TKKey(utiType): @"Change UTI",
                               TKKey(image): @"Change Image",
                               TKKey(opacity): @"Change Opacity",
                               TKKey(blendMode): @"Change Blend Mode",
                               TKKey(exifOrientation): @"Change EXIF Orientation",
                               TKKey(layoutInformation): @"Change Layout",
                               @"layoutInformation.sliceRects": @"Change Slices",
                               @"layoutInformation.edgeInsets": @"Change Metrics",
                               @"layoutInformation.imageSize": @"Change Image Size"
                               };
    });
    
    return TKBitmapProperties;
}

@end
