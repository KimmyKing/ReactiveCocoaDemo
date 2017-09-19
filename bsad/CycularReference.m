//
//  CycularReference.m
//  bsad
//
//  Created by Cain on 16/9/2.
//  Copyright © 2016年 JimmyKing. All rights reserved.
//

#import "CycularReference.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ReactiveCocoa/RACEXTScope.h>


@interface CycularReference ()

@property (nonatomic , strong)RACSignal *signal;

@end

@implementation CycularReference

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor cyanColor];
    UIButton *button = [[UIButton alloc]init];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button setTitle:@"dismiss" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(actionDismiss) forControlEvents:UIControlEventTouchUpInside];
    button.center = self.view.center;
    [button sizeToFit];
    [self.view addSubview:button];
    
    //将self改为弱引用，和@strongify(self)成对使用
    @weakify(self);
    
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        //只有在这个block中改为强引用，防止self无法使用
        @strongify(self);
        
        NSLog(@"%@",self);
        return nil;
    }];
    //造成循环引用：当前控制器强引用了signal，signal是一个block，在block中强引用了控制器
    _signal = signal;
}

- (void)actionDismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc
{
    NSLog(@"%s",__func__);
}

@end
