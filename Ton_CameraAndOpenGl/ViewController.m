//
//  ViewController.m
//  Ton_CameraAndOpenGl
//
//  Created by wang on 15/12/18.
//  Copyright © 2015年 wang. All rights reserved.
//

#import "ViewController.h"
#import "JMBackgroundCameraView.h"
#import "ModelViewController.h"


@interface ViewController ()
{
    JMBackgroundCameraView *v;
    ModelViewController *modelViewController;
}



@end

@implementation ViewController

//电池条
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    v = [[JMBackgroundCameraView alloc] initWithFrame:self.view.frame positionDevice:DevicePositonBack];
    [self.view addSubview:v];
    
    [self addModelView];
}

-(void)addModelView{
    modelViewController = [[ModelViewController alloc] init];
    
    modelViewController.view.layer.frame = self.view.frame;
    
    modelViewController.view.layer.backgroundColor = [UIColor clearColor].CGColor;
    
    
//    [self addChildViewController:modelViewController];
   
    [v addSubview:modelViewController.view];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
