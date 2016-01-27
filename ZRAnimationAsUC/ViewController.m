//
//  ViewController.m
//  ZRAnimationAsUC
//
//  Created by 58赶集 on 16/1/26.
//  Copyright © 2016年 ZhangHongyun. All rights reserved.
//

#import "ViewController.h"
#import "ZRAnimationAsUCView.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    ZRAnimationAsUCView * view = [[ZRAnimationAsUCView alloc]initWithFrame:CGRectMake(0, 0, 375, 667)];
    [self.view addSubview:view];
}
@end
