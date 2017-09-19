//
//  ViewController.m
//  bsad
//
//  Created by Cain on 16/9/2.
//  Copyright © 2016年 JimmyKing. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "CycularReference.h"
#import <ReactiveCocoa/RACReturnSignal.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    [self observeTextEditing];
    //    [self observeGestureRecognizer];
    //    [self observeScrollViewScrolling];
//        [self observeSignal];
    //    [self observeSignalWithSubject];
        [self observeWithLiftRAC];
    //    [self bindingEntryMacros];
    //    [self cycularReference];
    //    [self onceSignalRequest];
    //    [self signalWithRACCammond];
    //    [self signalSwitchToLatest];
    //    [self bindingSignal];
    //    [self flattenMapPrinciple];
    //    [self flattenMapActualUse];
    //    [self map];
    //    [self composeSignal];
    //    [self mergeSignal];
    //    [self zipSignal];
//    [self combineSignal];
//    [self filter];
//    [self ignore];
//    [self take];
//    [self distinctUntilChanged];
//    [self skip];
}

#pragma mark
#pragma mark 跳跃信号
- (void)skip
{
    //1.创建信号
    RACSubject *subject = [RACSubject subject];
    //2.跳跃3个信号,订阅信号
    [[subject skip:3] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    //3.发送信号
    [subject sendNext:@1];
    [subject sendNext:@2];
    [subject sendNext:@3];
    [subject sendNext:@4];
    [subject sendNext:@5];
    [subject sendNext:@6];
}

#pragma mark
#pragma mark 如果当前信号和上一个信号相同,就屏蔽
- (void)distinctUntilChanged
{
    //1.创建信号
    RACSubject *subject = [RACSubject subject];
    //2.订阅信号,如果当前信号和上一个信号相同,就屏蔽
    [[subject distinctUntilChanged] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    //3.发送信号
    [subject sendNext:@1];
    [subject sendNext:@2];
    [subject sendNext:@1];
    [subject sendNext:@1];
}

#pragma mark
#pragma mark 屏蔽多余的信号
- (void)take
{
    //1.创建信号
    RACSubject *subject = [RACSubject subject];
    
    //定义一条结束信号
    RACSubject *untilSignal = [RACSubject subject];
    
    //2.订阅信号,只接受1条信号
//    [[subject take:1] subscribeNext:^(id x) {
//        NSLog(@"%@",x);
//    }];
    //取后面2个信号,必须要发送完成信号之后才会执行nextBlock
//    [[subject takeLast:2] subscribeNext:^(id x) {
//        NSLog(@"%@",x);
//    }];
    //当untilSignal发送任意信号后,subject就不再订阅信号了
    [[subject takeUntil:untilSignal] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    //3.发送信号
    [subject sendNext:@1];
    [subject sendNext:@2];
    
    //untilSignal发送信号
    [untilSignal sendNext:@8];
//    [untilSignal sendCompleted];
    
    [subject sendNext:@3];
    //发送完成信号
    [subject sendCompleted];
}

#pragma mark
#pragma mark 忽略值
- (void)ignore
{
    //1.创建信号
    RACSubject *subject = [RACSubject subject];
    //2.给信号添加过滤,如果传送过来的值是"1",就会过滤掉
//    RACSignal *ignore = [subject ignore:@"1"];
    //过滤所有信号
    RACSignal *ignore = [subject ignoreValues];
    //3.订阅信号
    [ignore subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    //4.发送信号
    [subject sendNext:@"1dsa"];
    [subject sendNext:@"sad"];
}

#pragma mark
#pragma mark 增加过滤条件
- (void)filter
{
    UITextField *field = [[UITextField alloc]initWithFrame:CGRectMake(0, 100, 375, 30)];
    field.placeholder = @"请输入";
    field.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:field];
    
    //监听Field的信号,并添加过滤条件
    [[[field rac_textSignal] filter:^BOOL(id value) {
      //当输入的长度超过5才会返回
        return [value length] > 5;
        //订阅信号
    }] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
}

#pragma mark
#pragma mark 聚合信号,同时监听两个输入框的信号,当两个输入框都有内容时,才可以点击按钮
- (void)combineSignal
{
    //1.搭界面
    UITextField *accountField = [[UITextField alloc]initWithFrame:CGRectMake(0, 100, 375, 30)];
    accountField.placeholder = @"account";
    accountField.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:accountField];
    UITextField *passwordField = [[UITextField alloc]initWithFrame:CGRectMake(0,200, 375, 30)];
    passwordField.textAlignment = NSTextAlignmentCenter;
    passwordField.placeholder = @"password";
    [self.view addSubview:passwordField];
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(0, 300, 375, 30)];
    button.enabled = NO;
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [button setTitle:@"login" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(actionClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    //3.聚合信号,同时监听两个输入框的信号,当两个输入框都有内容时,才可以点击按钮
    [[RACSignal combineLatest:@[accountField.rac_textSignal,passwordField.rac_textSignal] reduce:^id(NSString *account,NSString *password){
        
        //方法一:可以自定义参数,对应监听的内容然后再返回一个BOOL值
        return @(account.length&&password.length);
        //方法二:可以直接返回需要监听的内容
        //        return @(accountField.text.length&&passwordField.text.length);
        
        //2.订阅信号,执行nextBlock
    }] subscribeNext:^(id x) {
        button.enabled = [x boolValue];
    }];
}

- (void)actionClick
{
    NSLog(@"click");
}

#pragma mark
#pragma mark 压缩信号
- (void)zipSignal
{
    //1.创建信号
    RACSubject *signalA = [RACSubject subject];
    RACSubject *signalB = [RACSubject subject];
    //2.压缩信号,只有当两个信号同时发送时,才会执行压缩信号的nextBlock,执行顺序和压缩的顺序有关
    [[signalA zipWith:signalB] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];;
    //3.发送信号
    [signalB sendNext:@2];
    [signalA sendNext:@1];
}

#pragma mark
#pragma mark 任意组合信号
- (void)mergeSignal
{
    //1.创建信号
    RACSubject *signalA = [RACSubject subject];
    RACSubject *signalB = [RACSubject subject];
    RACSubject *signalC = [RACSubject subject];
    
    //3.组合信号,并订阅,执行顺序和发送信号的顺序有关
    [[RACSignal merge:@[signalA,signalC,signalB]] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    //2.发送信号
    [signalA sendNext:@"A数据"];
    [signalB sendNext:@"B数据"];
    [signalC sendNext:@"C数据"];
}

#pragma mark
#pragma mark 组合信号
- (void)concatSignal
{
    //1.创建A信号
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"发送A部分数据");
        //4.发送A信号的数据
        [subscriber sendNext:@"A数据"];
        //5.A数据发送完成后需要发送 完成 的信号,才会执行B信号
        [subscriber sendCompleted];
        return nil;
    }];
    
    //2.创建B信号
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"发送B部分数据");
        //6.发送B信号数据
        [subscriber sendNext:@"B数据"];
        return nil;
    }];
    
    //3.组合A信号和B信号,并订阅这个组合信号
    [[signalA concat:signalB] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];;
    //也是组合A信号和B信号,并订阅这个组合信号,和concat不同的是会忽略掉前一个信号的所有值
    //    [[signalA then:^RACSignal *{
    //        return signalB;
    //    }] subscribeNext:^(id x) {
    //        NSLog(@"%@",x);
    //    }];
}

#pragma mark
#pragma mark map映射
- (void)map
{
    //1.创建信号
    RACSubject *subject = [RACSubject subject];
    //2.绑定信号
    [[subject map:^id(id value) {
        //4.返回的类型,需要映射的值
        return [NSString stringWithFormat:@"JK%@",value];
        //5.订阅绑定信号
    }] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    //3.发送信号
    [subject sendNext:@"cain"];
    [subject sendNext:@"king"];
}

#pragma mark
#pragma mark flattenMap映射信号,开发中的使用场景:嵌套信号
- (void)flattenMapActualUse
{
    //1.创建源信号和信号
    RACSubject *sourceSignal = [RACSubject subject];
    RACSubject *signal = [RACSubject subject];
    
    [[sourceSignal flattenMap:^RACStream *(id value) {
        //4.执行源信号的nextBlock
        return value;
        //5.订阅信号:执行信号的nextBlock
    }] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    //2.源信号发送信号
    [sourceSignal sendNext:signal];
    //3.信号发送value
    [signal sendNext:@"cain"];
}

#pragma mark
#pragma mark 映射信号,原理
- (void)flattenMapPrinciple
{
    //1.创建信号
    RACSubject *subject = [RACSubject subject];
    //2.创建绑定信号来接受映射信号的返回信号
    RACSignal *bindSignal = [subject flattenMap:^RACStream *(id value) {
        //5.处理源信号发送的value,只要源信号发送,就会执行这个block
        value = [NSString stringWithFormat:@"修改value:%@",value];
        //6.返回给绑定信号(执行绑定信号的nextBlock)
        return [RACSignal return:value];
    }];
    
    //3.订阅绑定信号,保存nextblock
    [bindSignal subscribeNext:^(id x) {
        NSLog(@"接受返回的信号数据：%@",x);
    }];
    //4.源信号发送数据(执行绑定信号的nextblock)
    [subject sendNext:@"jim"];
}

#pragma mark
#pragma mark 绑定信号
- (void)bindingSignal
{
    //1.创建源信号
    RACSubject *subject = [RACSubject subject];
    //2.创建绑定信号
    RACSignal *bingingSignal = [subject bind:^RACStreamBindBlock{
        //这个block一般不做事情
        
        
        return ^RACSignal *(id value , BOOL *stop){
            //4.只要源信号发送数据，就会调用这个block，处理传过来的value
            NSLog(@"接受源信号%@",value);
            //返回空信号，不能为nil，底层其实是[[RACSignal alloc]init];
            //            return [RACSignal empty];
            
            //返回处理后的信号，传递处理后的value给绑定信号（执行绑定信号的value）
            value = [NSString stringWithFormat:@"JK%@",value];
            return [RACReturnSignal return:value];
        };
    }];
    
    //5.订阅绑定信号(保存nextBlock)，接受处理后的value
    [bingingSignal subscribeNext:^(id x) {
        NSLog(@"接受处理后的信号%@",x);
    }];
    //3.源信号发送数据
    [subject sendNext:@"signal"];
}

#pragma mark
#pragma mark 获取信号中 信号发送的 最新信号
- (void)signalSwitchToLatest
{
    //1.创建信号
    RACSubject *sourceSignal = [RACSubject subject];
    RACSubject *signalA = [RACSubject subject];
    RACSubject *signalB = [RACSubject subject];
    
    //3.获取最新的信号（执行nextBlock）
    [sourceSignal.switchToLatest subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    //2.发送信号
    //发送sourceSignal信号，将信号signalA信号发送过去（嵌套信号），只能收到signalA的信号，signalB是无法收到的
    [sourceSignal sendNext:signalA];
    //发送signalA信号信息
    [signalA sendNext:@"sad"];
    [signalB sendNext:@"订阅信号B"];
    [signalA sendNext:@"das"];
}

#pragma mark
#pragma mark 直接订阅执行命令返回的信号
- (void)signalWithRACCammond
{
    //1.创建命令，必须有信号类返回值（保存signalBlock）
    RACCommand *command = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        
        NSLog(@"%@",input);
        
        //返回一个信号
        return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
            //4.发送信号（执行nextBlock）
            [subscriber sendNext:@"执行命令产生的数据"];
            
            [subscriber sendCompleted];
            
            return nil;
        }];
    }];
    
    //2.执行命令（执行signalBlock）,用信号类接受命令类的返回值
    RACSignal *signal = [command execute:@"执行命令"];
    //3.订阅信号（保存nextBlock）
    [signal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
}


#pragma mark
#pragma mark RAC订阅信号，通知所有订阅者，但是只执行一次请求
- (void)onceSignalRequest
{
    //1.创建信号（保存didSubscribe这个block）
    RACSignal *signal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"start requestNetWork");
        //4.发送信号
        [subscriber sendNext:@"321"];
        return nil;
    }];
    
    //2.把信号转换为连接类（底层是转换为了RACSubject这个类，保存订阅者，订阅者其实就是nextBlock）
    RACMulticastConnection *connection = [signal publish];
    [connection.signal subscribeNext:^(id x) {
        NSLog(@"订阅者1:%@",x);
    }];
    [connection.signal subscribeNext:^(id x) {
        NSLog(@"订阅者2:%@",x);
    }];
    [connection.signal subscribeNext:^(id x) {
        NSLog(@"订阅者3:%@",x);
    }];
    
    //3.连接（订阅源信号，底层是把源信号改为了RACSubject这个类（_signal就是RACSubject），执行didSubscribe这个block，会遍历订阅者数组，执行数组中的nextBlock）
    [connection connect];
}

#pragma mark
#pragma mark RAC解决循环引用
- (void)cycularReference
{
    UIButton *button = [[UIButton alloc]init];
    button.center = self.view.center;
    [button setTitle:@"present" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(actionPresentController) forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    [self.view addSubview:button];
}

- (void)actionPresentController
{
    [self presentViewController:[CycularReference new] animated:YES completion:nil];
}

#pragma mark
#pragma mark 绑定宏
- (void)bindingEntryMacros
{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 50, 375, 30)];
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    
    UITextField *field = [[UITextField alloc]initWithFrame:CGRectMake(0, 100, 375, 30)];
    field.textAlignment = NSTextAlignmentCenter;
    field.placeholder = @"在field输入文字显示到label上";
    [self.view addSubview:field];
    //将lbael的属性text绑定信号，只要产生信号内容，就会把信号内容给绑定的属性
    RAC(label,text) = [field rac_textSignal];
}

#pragma mark
#pragma mark 当一个界面有多个请求时，需求是所有请求完毕后才执行UI操作
- (void)observeWithLiftRAC
{
    //1.创建信号
    RACSignal *hotSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"正在请求热销模块数据");
        //3.发送数据
        [subscriber sendNext:@"热销模块数据请求成功"];
        return nil;
    }];
    //1.创建信号
    RACSignal *fashionSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSLog(@"正在请求时尚模块数据");
        //3.发送数据
        [subscriber sendNext:@"时尚模块数据请求成功"];
        return nil;
    }];
    
    //2.订阅数组中的信号：当数组中的信号任务都执行完毕之后，才会执行selector方法，方法的参数数量必须和数组的数量相等
    [self rac_liftSelector:@selector(updateUIWithHotString:fashionString:) withSignalsFromArray:@[hotSignal,fashionSignal]];
}

- (void)updateUIWithHotString:(NSString *)hotString fashionString:(NSString *)fashionString
{
    NSLog(@"%@,%@，开始更新UI",hotString,fashionString);
}

#pragma mark
#pragma mark 监听信号，多个订阅者
- (void)observeSignalWithSubject
{
    //1.创建信号
    RACSubject *subject = [RACSubject subject];
    //2.多个订阅者订阅信号，存入一个数组
    [subject subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    [subject subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    //3.遍历数组，发送信号
    [subject sendNext:@"sad"];
}

#pragma mark
#pragma mark 监听信号，单个订阅者
- (void)observeSignal
{
    //1.创建冷信号
    RACSignal *singnal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        //3.发送数据，执行nextBlock
        [subscriber sendNext:@111];
        
        //5.只要取消订阅就会进入这个block（或者RACSubscriber对象销毁）
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"取消订阅");
        }];
    }];
    
    //2.订阅信号（热信号）
    RACDisposable *disposable = [singnal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    
    //4.主动取消订阅信号
    [disposable dispose];
}

#pragma mark
#pragma mark   监听scrollView的滚动
- (void)observeScrollViewScrolling
{
    UIScrollView *sc = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    sc.contentSize = CGSizeMake(0, 3000);
    sc.backgroundColor = [UIColor cyanColor];
    self.view = sc;

    //只要sc的contentOffSet属性一改变就会产生信号
    [RACObserve(sc, contentOffset) subscribeNext:^(UIScrollView *x) {
        NSLog(@"scrolling");
    }];
}

#pragma mark
#pragma mark 监听手势
- (void)observeGestureRecognizer
{
    UIView *redView = [[UIView alloc]initWithFrame:CGRectMake(100, 100, 200, 200)];
    redView.backgroundColor = [UIColor redColor];
    [self.view addSubview:redView];
    
    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc]init];
    swipe.direction = UISwipeGestureRecognizerDirectionUp;
    [redView addGestureRecognizer:swipe];
    //添加向上手势监视者和监视方法
    [[swipe rac_gestureSignal] subscribeNext:^(id x) {
        NSLog(@"swipe");
    }];
}

#pragma mark
#pragma mark 监听textField的输入
- (void)observeTextEditing
{
    UITextField *field = [[UITextField alloc]initWithFrame:CGRectMake(100, 100, 200, 30)];
    field.placeholder = @"请输入";
    [self.view addSubview:field];
    //监听textField的输入
    [[field rac_signalForControlEvents:UIControlEventEditingChanged] subscribeNext:^(UITextField  *x){
        NSLog(@"%@",x.text);
    }];
}

@end
