//
//  MVVisualEffectView.m
//  Skim
//
//  Created by Mayuran Visakan on 31/01/2024.
//

#import "MVVisualEffectView.h"

@implementation MVVisualEffectView

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    if (self) {
        [self setupView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.state = NSVisualEffectStateActive;
    self.material =NSVisualEffectMaterialFullScreenUI;
    self.blendingMode = NSVisualEffectBlendingModeBehindWindow;
    self.alphaValue = 1.0;
    self.layer.cornerRadius = 16.0;
    self.layer.masksToBounds = YES;
}

@end
