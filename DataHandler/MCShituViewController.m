//
//  MCShituViewController.m
//  mycity
//
//  Created by openapp on 15/5/28.
//  Copyright (c) 2015年 openapp. All rights reserved.
//

#import "MCShituViewController.h"
#import "MCShitu.h"
#import "MCResultView.h"
#import "AFNetworking.h"
#import "TGCameraNavigationController.h"
#import "NSString+URLEncoding.h"

#define NavigationHeight self.navigationController.navigationBar.frame.size.height+20

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@interface MCShituViewController ()<MCShituDelegate, UIWebViewDelegate, MCResultViewDelegate>
@end

@implementation MCShituViewController{
    UIWebView *webview;
    UIView *loading1;
    UIView *loading2;
    UIView *rot;
    MCShitu *shitu;
    BOOL stop;
}

+ (instancetype)createWebViewPageWithGPS:(CLLocationCoordinate2D)gps andImageUrl:(NSString *)imageUrl
{
    MCShituViewController *webView = [[MCShituViewController alloc] init];
    webView.gps = gps;
    webView.imageUrl = imageUrl;
    return webView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    loading1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height/2)];
    [loading1 setBackgroundColor:[UIColor colorWithRed:235/255.0 green:134/255.0 blue:76/255.0 alpha:1]];
    [self.view addSubview:loading1];
    
    loading2 = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height/2, self.view.bounds.size.width, self.view.bounds.size.height/2)];
    [loading2 setBackgroundColor:[UIColor colorWithRed:235/255.0 green:134/255.0 blue:76/255.0 alpha:1]];
    [self.view addSubview:loading2];
    
    UIImageView *li = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loading1"]];
    UIImageView *li1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loading2"]];
    rot = [[UIView alloc] initWithFrame:CGRectMake((loading1.bounds.size.width-li.bounds.size.width)/2, (loading1.bounds.size.height-li.bounds.size.height), li.bounds.size.width, li.bounds.size.height+li1.bounds.size.height)];
    li1.frame = CGRectMake(0, li.bounds.size.height, li1.bounds.size.width, li1.bounds.size.height);
    [rot addSubview:li];
    [rot addSubview:li1];
    [self.view addSubview:rot];
    
    //[rot layer].anchorPoint = CGPointMake(rot.bounds.size.width/2, rot.bounds.size.height/2);
    
    
    stop = NO;
    
    
    
    shitu = [[MCShitu alloc] init];
    shitu.delegate = self;
    [shitu fetchWithGPS:self.gps andImage:self.imageUrl];
    
    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, 0, 100, 50)];
    [button addTarget:self action:@selector(doneFunc)forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 50)];
    label.tag = 111;
    [label setFont:[UIFont fontWithName:@"Arial-BoldMT" size:20]];
    [label setText:@"< 返回"];
    [label setTextColor:[UIColor whiteColor]];
    [label setBackgroundColor:[UIColor clearColor]];
    [button addSubview:label];
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = leftBarButton;
 
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    //CAAnimation *anim2 = [[rot layer] animationForKey:@"spinAnimation"];
    // && [[anim valueForKey:@"animType"] isEqualToString:@"spinAnimation"]
    if (flag){
        NSLog(@"a");
        if (stop){
            [rot removeFromSuperview];
            UIImageView *li = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loading1"]];
            li.frame = CGRectMake((loading1.bounds.size.width-li.bounds.size.width)/2, (loading1.bounds.size.height-li.bounds.size.height), li.bounds.size.width, li.bounds.size.height);
            [loading1 addSubview:li];
            
            
            li = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loading2"]];
            li.frame = CGRectMake((loading1.bounds.size.width-li.bounds.size.width)/2, 0, li.bounds.size.width, li.bounds.size.height);
            [loading2 addSubview:li];
            
            [UIView animateWithDuration:0.5f animations:^(void){
                
                loading1.frame = CGRectMake(0, 0-loading1.frame.size.height, loading1.frame.size.width, loading1.frame.size.height);
                loading2.frame = CGRectMake(0, self.view.bounds.size.height, loading2.frame.size.width, loading2.frame.size.height);
            } completion:^(BOOL finished){
                self.navigationController.navigationBar.hidden = NO;
                [loading1 removeFromSuperview];
                [loading2 removeFromSuperview];
            }];
        }else{
            CABasicAnimation* spinAnimation = [CABasicAnimation
                                               animationWithKeyPath:@"transform.rotation"];
            spinAnimation.toValue = [NSNumber numberWithFloat:2*M_PI];
            spinAnimation.duration = 1;
            spinAnimation.delegate = self;
            [rot.layer addAnimation:spinAnimation forKey:@"spinAnimation"];
        }
        

    }
}

- (NSData *)httpBodyForParamsDictionary:(NSDictionary *)paramDictionary
{
    NSMutableArray *parameterArray = [NSMutableArray array];
    
    [paramDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *obj, BOOL *stop) {
        NSString *param = [NSString stringWithFormat:@"%@=%@", key, [self percentEscapeString:obj]];
        [parameterArray addObject:param];
    }];
    
    NSString *string = [parameterArray componentsJoinedByString:@"&"];
    
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)percentEscapeString:(NSString *)string
{
    NSString *result = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                 (CFStringRef)string,
                                                                                 (CFStringRef)@" ",
                                                                                 (CFStringRef)@":/?@!$&'()*+,;=",
                                                                                 kCFStringEncodingUTF8));
    return [result stringByReplacingOccurrencesOfString:@" " withString:@"+"];
}

- (void)doneWithShops:(NSString *)shops baidu:(NSString *)baidu sogou:(NSString *)sogou {
    NSString *postStr = [shops stringByAppendingFormat:@"\t%@\t%@", baidu, sogou];
    NSLog(@"%@", postStr);
    NSDictionary *params = @{@"body": postStr};
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://123.126.68.90/shitu"]];
    
    
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[self httpBodyForParamsDictionary:params]];
    

    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFHTTPResponseSerializer serializer];
    op.responseSerializer.acceptableContentTypes = [op.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *response = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSLog(@"%@", response);
        CGRect frame =  CGRectMake(0, NavigationHeight, self.view.bounds.size.width, self.view.bounds.size.height - NavigationHeight);
        MCResultView *resultView =[[MCResultView alloc]initWithFrame:frame WithURL:self.imageUrl WithResult:[response componentsSeparatedByString:@","]];
        resultView.delegate = self;
        [self.view insertSubview:resultView atIndex:0 ];
        stop = YES;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", [error localizedDescription]);
        [self.navigationController popViewControllerAnimated:NO];
    }];
    [op start];
    
    return;
}

- (void)viewWillAppear:(BOOL)animated {
    
    CABasicAnimation* spinAnimation = [CABasicAnimation
                                       animationWithKeyPath:@"transform.rotation"];
    spinAnimation.toValue = [NSNumber numberWithFloat:2*M_PI];
    spinAnimation.duration = 1;
    spinAnimation.delegate = self;
    [rot.layer addAnimation:spinAnimation forKey:@"spinAnimation"];
//    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    //[self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillDisappear:animated];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view insertSubview:webview atIndex:0];
    
    
}

- (void)doneFunc {
//    NSLog(@"done...");
//    [self dismissViewControllerAnimated:NO completion:nil];
     [self.navigationController popViewControllerAnimated:YES];

}

- (void)didSelectFoodNameResult:(NSString *)foodName {
    NSLog(@"%@", foodName);
    NSUInteger height = NavigationHeight;

    webview = [[UIWebView alloc] initWithFrame:CGRectMake(0, height, self.view.bounds.size.width, self.view.bounds.size.height-height)];
    webview.delegate = self;
    
    NSString *url = [NSString stringWithFormat:@"http://123.126.68.90/dish?name=%@&imgurl=%@", [foodName urlEncodeUsingEncoding:NSUTF8StringEncoding], [self.imageUrl urlEncodeUsingEncoding:NSUTF8StringEncoding]];
    //url = @"http://www.sogou.com/";
    NSLog(@"%@", url);
    NSURL *nu = [[NSURL alloc] initWithString:url];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:nu];
    
    
    [webview loadRequest:request];
    [self.view addSubview:webview];

}

- (void)didReshotButtonClick {
    [self.navigationController popViewControllerAnimated:NO];
}

@end;
