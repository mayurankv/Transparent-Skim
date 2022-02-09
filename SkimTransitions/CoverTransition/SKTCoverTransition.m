//
//  SKTCoverTransition.m
//  SkimTransitions
//
//  Created by Christiaan Hofman on 22/5/2019.
//  Copyright Christiaan Hofman 2019-2022. All rights reserved.
//

#import "SKTCoverTransition.h"
#import <Foundation/Foundation.h>
#import <ApplicationServices/ApplicationServices.h>
#import "SKTPluginLoader.h"

#define kCIInputRectangleKey @"inputRectangle"

@implementation SKTCoverTransition

@synthesize inputImage, inputTargetImage, inputExtent, inputAngle, inputTime;

static CIKernel *_SKTCoverTransitionKernel = nil;

- (id)init
{
    if (_SKTCoverTransitionKernel == nil)
        _SKTCoverTransitionKernel = [SKTPlugInLoader kernelWithName:@"coverComposition"];
    return [super init];
}

+ (NSDictionary *)customAttributes
{
    return [NSDictionary dictionaryWithObjectsAndKeys:

        [NSDictionary dictionaryWithObjectsAndKeys:
            [CIVector vectorWithX:0.0 Y:0.0 Z:300.0 W:300.0], kCIAttributeDefault,
            kCIAttributeTypeRectangle,          kCIAttributeType,
            nil],                               kCIInputExtentKey,
 
        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithDouble:  0.0], kCIAttributeMin,
            [NSNumber numberWithDouble:  0.0], kCIAttributeMax,
            [NSNumber numberWithDouble:  -M_PI], kCIAttributeSliderMin,
            [NSNumber numberWithDouble:  M_PI], kCIAttributeSliderMax,
            [NSNumber numberWithDouble:  0.0], kCIAttributeDefault,
            [NSNumber numberWithDouble:  0.0], kCIAttributeIdentity,
            kCIAttributeTypeAngle,             kCIAttributeType,
            nil],                              kCIInputAngleKey,
 
        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithDouble:  0.0], kCIAttributeMin,
            [NSNumber numberWithDouble:  1.0], kCIAttributeMax,
            [NSNumber numberWithDouble:  0.0], kCIAttributeSliderMin,
            [NSNumber numberWithDouble:  1.0], kCIAttributeSliderMax,
            [NSNumber numberWithDouble:  0.0], kCIAttributeDefault,
            [NSNumber numberWithDouble:  0.0], kCIAttributeIdentity,
            kCIAttributeTypeTime,              kCIAttributeType,
            nil],                              kCIInputTimeKey,

        nil];
}

- (NSDictionary *)customAttributes
{
    return [[self class] customAttributes];
}

- (CGRect)regionOf:(int)sampler destRect:(CGRect)R userInfo:(CIVector *)offset {
    if (sampler == 1) {
        R = CGRectOffset(R, -[offset X], -[offset Y]);
    }
    return R;
}

// called when setting up for fragment program and also calls fragment program
- (CIImage *)outputImage
{
    CISampler *src = [CISampler samplerWithImage:inputImage];
    CISampler *trgt = [CISampler samplerWithImage:inputTargetImage];
    CGFloat t = [inputTime doubleValue];
    CGFloat angle = [inputAngle doubleValue];
    CGFloat c = cos(angle);
    CGFloat s = sin(angle);
    CGFloat d = [inputExtent Z] * (1.0 - t) / fmax(fabs(c), fabs(s));
    NSNumber *shade = [NSNumber numberWithDouble:1.0 - 0.2 * t];
    CIVector *offset = [CIVector vectorWithX:d * c Y:d * s];
    NSArray *extent = [NSArray arrayWithObjects:[NSNumber numberWithDouble:[inputExtent X]], [NSNumber numberWithDouble:[inputExtent Y]], [NSNumber numberWithDouble:[inputExtent Z]], [NSNumber numberWithDouble:[inputExtent W]], nil];
    NSArray *arguments = [NSArray arrayWithObjects:src, trgt, inputExtent, offset, shade, nil];
    NSDictionary *options  = [NSDictionary dictionaryWithObjectsAndKeys:extent, kCIApplyOptionDefinition, extent, kCIApplyOptionExtent, offset, kCIApplyOptionUserInfo, nil];
    
    [_SKTCoverTransitionKernel setROISelector:@selector(regionOf:destRect:userInfo:)];
    
    return [self apply:_SKTCoverTransitionKernel arguments:arguments options:options];
}

@end
