//
//  JMBackgroundCameraView.m
//  JMBackgroundCameraView
//
//  Created by Joan Molinas on 23/10/14.
//  Copyright (c) 2014 joan molinas ramon. All rights reserved.
//

#import "JMBackgroundCameraView.h"


@implementation JMBackgroundCameraView {
    UIERealTimeBlurView *blurView;
}
-(instancetype)initWithFrame:(CGRect)frame positionDevice:(DevicePositon)position blur:(BOOL)blur {
    if (self = [super initWithFrame:frame]) {
        [self initCameraInPosition:position];
        [self addBlurEffect];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame positionDevice:(DevicePositon)position {
    if (self = [super initWithFrame:frame]) {
        [self initCameraInPosition:position];
    }
    return self;
}
-(void)initCameraInPosition:(DevicePositon)position {
    self.session = [AVCaptureSession new];
    [self.session setSessionPreset:AVCaptureSessionPresetHigh];
    
    NSArray *devices = [NSArray new];
    devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if (position == DevicePositonBack) {
            if ([device position] == AVCaptureDevicePositionBack) {
                _device = device;
                break;
            }
        }else {
            if ([device position] == AVCaptureDevicePositionFront) {
                _device = device;
                break;
            }
        }
    }
    
    NSError *error;
    
    self.input = [[AVCaptureDeviceInput alloc] initWithDevice:self.device error:&error];
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    
    self.imageOutput = [AVCaptureStillImageOutput new];
    NSDictionary *outputSettings = @{AVVideoCodecKey:AVVideoCodecJPEG};
    [self.imageOutput setOutputSettings:outputSettings];
    [self.session addOutput:self.imageOutput];
    self.preview = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    [self.preview setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [self.preview setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self.layer addSublayer:self.preview];
    [self.session startRunning];

}
-(void)removeBlurEffect {
    [blurView removeFromSuperview];
}
-(void)addBlurEffect {
    blurView = [[UIERealTimeBlurView alloc] initWithFrame:self.frame];
    [self insertSubview:blurView atIndex:1];
}

@end

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com 
