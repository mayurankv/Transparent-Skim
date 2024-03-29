//
//  SKTSinkTransition.m
//  SkimTransitions
//
//  Created by Christiaan Hofman on 22/5/2019.
//  Copyright Christiaan Hofman 2019. All rights reserved.
//

#import "SKTSinkTransition.h"
#import "SKTPluginLoader.h"

@implementation SKTSinkTransition

@synthesize inputImage, inputTargetImage, inputCenter, inputTime;

static CIKernel *_SKTSinkTransitionKernel = nil;

- (id)init
{
    if (_SKTSinkTransitionKernel == nil)
        _SKTSinkTransitionKernel = [SKTPlugInLoader kernelWithName:@"sinkTransition"];
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
            [CIVector vectorWithX:150.0 Y:150.0], kCIAttributeDefault,
            kCIAttributeTypePosition,          kCIAttributeType,
            nil],                              kCIInputCenterKey,
 
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

- (CGRect)regionOf:(int)sampler destRect:(CGRect)R userInfo:(CISampler *)img {
    if (sampler == 0) {
        return [img extent];
    }
    return R;
}

// called when setting up for fragment program and also calls fragment program
- (CIImage *)outputImage
{
    CISampler *src = [CISampler samplerWithImage:inputImage];
    CISampler *trgt = [CISampler samplerWithImage:inputTargetImage];

    NSArray *arguments = [NSArray arrayWithObjects:src, trgt, inputCenter, inputTime, nil];
    NSDictionary *options  = [NSDictionary dictionaryWithObjectsAndKeys:[src definition], kCIApplyOptionDefinition, src, kCIApplyOptionUserInfo, nil];
    
    [_SKTSinkTransitionKernel setROISelector:@selector(regionOf:destRect:userInfo:)];
    
    return [self apply:_SKTSinkTransitionKernel arguments:arguments options:options];
}

@end
