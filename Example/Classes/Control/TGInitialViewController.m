//
//  TGInitialViewController.m
//  TGCameraViewController
//
//  Created by Bruno Furtado on 15/09/14.
//  Copyright (c) 2014 Tudo Gostoso Internet. All rights reserved.
//

#import "TGInitialViewController.h"
#import "TGCamera.h"
#import "TGCameraViewController.h"
#import "MCShituViewController.h"
#import "STPicInfo.h"
#import "MCMapViewController.h"

#define ShotButtonRadius 207.f
#define FoodButtonRadiu 85.f

#define GBKEncoding CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)


#if __IPHONE_OS_VERSION_MAX_ALLOWED < 70000
#define BUILD_BASE_IOS7 NO
#else
#define BUILD_BASE_IOS7 YES
#endif

#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
int bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast;
#else
int bitmapInfo = kCGImageAlphaPremultipliedLast;
#endif

#define GBKEncoding CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)

#define ShouleAdaptForiOS7  (BUILD_BASE_IOS7 && [UIDevice currentDevice].systemVersion.floatValue > 6.99f)
#define isiOS8 (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1)
#define isiOS7 (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1 && NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1)
#define isiOS6 (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_5_1 && NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_6_1)


#define isRetina4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#define NavigationBarHeight (44.0f)
#define StatusBarHeight (isiOS7?20.0f:0.0f)
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define ScreenWidth ([UIScreen mainScreen].bounds.size.width)
#define ScreenHeight ([UIScreen mainScreen].bounds.size.height)

#define ScreenFactor ([UIScreen mainScreen].bounds.size.width/320.0)

#define SGFontWithSize(f)  ([UIFont fontWithName:@"FZLTHK--GBK1-0" size:(CGFloat)(f)])

#define SGScaleWidth  (ScreenWidth/320)
#define SGScaleHeight (ScreenHeight/568)


@interface TGInitialViewController () <TGCameraDelegate>

@property (strong, nonatomic) UIImageView *backgroundView;
@property (strong, nonatomic) UIButton *shotButton;
@property (strong, nonatomic) UIView *foodsImageView;
@property (strong, nonatomic) UIView *statusBarView;

@end



@implementation TGInitialViewController {
    CLLocationManager *_locationManager;
    BOOL _updatingLocation;
    NSError *_lastLocationError;
    NSMutableArray *foodsData;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super initWithCoder:decoder];
    if (!self) {
        return nil;
    }
    
    foodsData = [[NSMutableArray alloc]initWithCapacity:6];
    STPicInfo *info = [[STPicInfo alloc]init];
    
    info.gps = CLLocationCoordinate2DMake(39.9926133333333, 116.3263550000000);
    info.url = @"http://img02.sogoucdn.com/app/a/100520146/F9F2ADD5EF305AF5F38637C04FF15A09";
    [foodsData addObject:@{@"name":@"", @"info":info, @"pic":@"img0"}];
    
    
    info = [[STPicInfo alloc]init];
    info.gps = CLLocationCoordinate2DMake(31.31728666667, 120.6242833333333f);
    info.url = @"http://img03.sogoucdn.com/app/a/100520146/057EB97CC78E079432BF67679CBD9D81";
    [foodsData addObject:@{@"name":@"", @"info":info, @"pic":@"img1"}];
    
    info = [[STPicInfo alloc]init];
    info.gps = CLLocationCoordinate2DMake(39.9926133333333, 116.3263550000000);
    info.url = @"http://img02.sogoucdn.com/app/a/100520146/64228BAF6994B7BB4F352D725C7A8AFC";
    [foodsData addObject:@{@"name":@"", @"info":info, @"pic":@"img2"}];
    /*
    info = [[STPicInfo alloc]init];
    info.gps = CLLocationCoordinate2DMake(39.99261799f, 116.32617276f);
    info.url = @"http://img03.sogoucdn.com/app/a/100520146/996B189157DFB6BF9EB28A311E31D46A";
    [foodsData addObject:@{@"name":@"小龙虾", @"info":info, @"pic":@"CameraEffectCurve"}];
    
    info = [[STPicInfo alloc]init];
    info.gps = CLLocationCoordinate2DMake(39.99261799f, 116.32617276f);
    info.url = @"http://img03.sogoucdn.com/app/a/100520146/996B189157DFB6BF9EB28A311E31D46A";
    [foodsData addObject:@{@"name":@"小龙虾", @"info":info, @"pic":@"CameraEffectCurve"}];
    
    info = [[STPicInfo alloc]init];
    info.gps = CLLocationCoordinate2DMake(39.99261799f, 116.32617276f);
    info.url = @"http://img03.sogoucdn.com/app/a/100520146/996B189157DFB6BF9EB28A311E31D46A";
    [foodsData addObject:@{@"name":@"小龙虾", @"info":info, @"pic":@"CameraEffectCurve"}];*/
    
    return self;
}

- (void)dealloc{
    self.location = nil;
    self.backgroundView = nil;
    self.shotButton = nil;
    self.foodsImageView = nil;
    self.statusBarView = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBar.hidden = YES;
    [self startLocationManager];
}

- (void)viewDidDisappear:(BOOL)animated {
    [self stopLocationManager];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
     _locationManager = [[CLLocationManager alloc] init];
    
    self.view.backgroundColor = [UIColor colorWithRed:240/255.0 green:239/255.0 blue:244/255.0 alpha:1];
    self.statusBarView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 20)];
    self.statusBarView.backgroundColor = [UIColor colorWithRed:236/255.0 green:130/255.0 blue:72/255.0 alpha:1];
    [self.view addSubview:self.statusBarView];
    
    
    self.backgroundView = [[UIImageView alloc]initWithFrame: CGRectMake(0, 0, ScreenWidth, 562/2)];
    self.backgroundView.image = [UIImage imageNamed:@"backgroundHeader"];
//    self.backgroundView.contentMode = UIViewContentModeCenter;
    [self.view addSubview:self.backgroundView];
    
    self.foodsImageView = [[UIView alloc]initWithFrame:CGRectMake(0, (562+ShotButtonRadius)/2, ScreenWidth, ScreenHeight - (562+ShotButtonRadius)/2)];
    [self.view addSubview:self.foodsImageView];
    
    UIImageView *foodTitle = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 138/2+10)];
    foodTitle.image = [UIImage imageNamed:@"foodTitle"];
    [self.foodsImageView addSubview:foodTitle];
    
    CGRect frame = CGRectMake((ScreenWidth - ShotButtonRadius)/2 , (562-ShotButtonRadius)/2, ShotButtonRadius, ShotButtonRadius);
    self.shotButton = [self makeRoundButton:ShotButtonRadius WithImage:[UIImage imageNamed:@"shotButton"] WithFrame:frame];
    [self.shotButton addTarget:self action:@selector(onShotButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.shotButton];
    

    
    UIButton *foodButton;
    UIImage *foodImage;
    float margin = 40.f;
    float offset = ((ScreenWidth - margin*2) - (FoodButtonRadiu*3))/2;
    
    for (int i = 0; i < [foodsData count]; i++) {
        frame = CGRectMake((margin+(i%3)*(FoodButtonRadiu+offset)), 138/2 + ((i<=2)?0:(10+FoodButtonRadiu)), FoodButtonRadiu, FoodButtonRadiu);
        foodImage = [self addImage:foodsData[i][@"pic"] WithName:foodsData[i][@"name"] WithFrame:frame];
        foodButton = [self makeRoundButton:FoodButtonRadiu WithImage:foodImage WithFrame:frame];
        foodButton.tag = i;
        [self.foodsImageView addSubview:foodButton];
        [foodButton addTarget:self action:@selector(onFoodButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLocationInfoGot:) name:@"TGLocationInfoGot" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onShotButtonClicked) name:@"MCReshotClicked" object:nil];
}

- (UIButton *) makeRoundButton:(float)radius WithImage:(UIImage *)image WithFrame:(CGRect)frame{
    UIButton *roundButton;
    
    roundButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [roundButton setImage:image forState:UIControlStateNormal];
    roundButton.frame = frame;
    roundButton.clipsToBounds = YES;
    roundButton.layer.cornerRadius = radius/2.0f;
    //    self.shotButton.layer.borderColor=[UIColor redColor].CGColor;
    //    self.shotButton.layer.borderWidth=2.0f;
    return roundButton;
}

#pragma mark actions and buttons
- (void) onLocationInfoGot:(NSNotification*)notification {
    if ([notification.name isEqualToString:@"TGLocationInfoGot"]){
        NSLog(@"%@" , notification.object);
        
        STPicInfo *info = (STPicInfo *)notification.object;
        if (![info isGpsSetted]){
            if (self.location!= nil) {
                info.gps = self.location.coordinate;
            } else {
                //no position
                MCMapViewController *map = [MCMapViewController createMapViewPageWithImageUrl:info.url];
                [self.navigationController pushViewController:map animated:YES];
                return;
            }
        }
    
        MCShituViewController *controller = [MCShituViewController createWebViewPageWithGPS:info.gps andImageUrl:info.url];
        [self.navigationController pushViewController:controller animated:NO];
    }
}

- (void) onShotButtonClicked {
    TGCameraNavigationController *navigationController = [TGCameraNavigationController newWithCameraDelegate:self];
    [self presentViewController:navigationController animated:YES completion:nil];
}

- (void) onFoodButtonClicked:(id) sender{
    NSLog(@"%ld", (long)[sender tag]);
    NSInteger tag = [sender tag];
    STPicInfo *info = [foodsData objectAtIndex:tag][@"info"];
    MCShituViewController *controller = [MCShituViewController createWebViewPageWithGPS:info.gps andImageUrl:info.url];
    [self.navigationController pushViewController:controller animated:NO];

}

#pragma mark location manager

- (void) stopLocationManager {
    if (_updatingLocation) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(didTimeOut:) object:nil];
        
        [_locationManager stopUpdatingHeading];
        _locationManager.delegate = nil;
        _updatingLocation = NO;
    }
}

- (void) didTimeOut:(id) Obj {
    NSLog(@"..超时了");
    
    if (self.location == nil) {
        [self stopLocationManager];
        _lastLocationError = [NSError errorWithDomain:@"MYError" code:1 userInfo:nil];
    }
}


- (void) startLocationManager {
    if([CLLocationManager locationServicesEnabled]) {
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        //        if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        //            [_locationManager requestWhenInUseAuthorization];
        //        }
        [self requestAlwaysAuthorization];
        [_locationManager startUpdatingLocation];
        _updatingLocation = YES;
        
        [self performSelector:@selector(didTimeOut:) withObject:nil afterDelay:60];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // Send the user to the Settings for this app
        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:settingsURL];
    }
}

- (void)requestAlwaysAuthorization
{
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    NSLog(@"%d", status);
    // If the status is denied or only granted for when in use, display an alert
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse || status == kCLAuthorizationStatusDenied) {
        NSString *title;
        title = (status == kCLAuthorizationStatusDenied) ? @"定位功能未开启" : @"程序在后台运行的时候需要使用您的位置信息";
        NSString *message = @"请在系统设置中打开定位开关";
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                                  otherButtonTitles:@"设置", nil];
        [alertView show];
    }
    // The user has not enabled any location services. Request background authorization.
    else if (status == kCLAuthorizationStatusNotDetermined) {
        if([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [_locationManager requestAlwaysAuthorization];
        }
        //[_locationManager requestAlwaysAuthorization];
    }
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *newLocation = [locations lastObject];
    NSLog(@"已更新坐标，当前位置：%@", newLocation);
    
    if ([newLocation.timestamp timeIntervalSinceNow] < -5.0) {
        return;
    }
    
    if (newLocation.horizontalAccuracy < 0) {
        return;
    }
    
    CLLocationDistance distance = MAXFLOAT;
    if (self.location != nil) {
        distance = [newLocation distanceFromLocation:self.location];
    }
    
    if (self.location ==nil || self.location.horizontalAccuracy > newLocation.horizontalAccuracy) {
        _lastLocationError = nil;
        self.location = newLocation;

        
        if (newLocation.horizontalAccuracy <= _locationManager.desiredAccuracy) {
            NSLog(@"定位成功");
            [self stopLocationManager];
        }
    
        
        if (distance < 1.0) {
        NSTimeInterval timeInterval = [newLocation.timestamp timeIntervalSinceDate:self.location.timestamp];
        if (timeInterval > 10) {
            NSLog(@"强制完成");
            [self stopLocationManager];

        }
        }
    }

}


#pragma mark -
#pragma mark - TGCameraDelegate required

- (void)cameraDidCancel
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)cameraDidTakePhoto:(UIImage *)image
{
//    _photoView.image = image;
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)cameraDidSelectAlbumPhoto:(UIImage *)image
{
//    _photoView.image = image;
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark -
#pragma mark - TGCameraDelegate optional

- (void)cameraWillTakePhoto
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
}

- (void)cameraDidSavePhotoAtPath:(NSURL *)assetURL
{
    NSLog(@"%s album path: %@", __PRETTY_FUNCTION__, assetURL);
}

- (void)cameraDidSavePhotoWithError:(NSError *)error
{
    NSLog(@"%s error: %@", __PRETTY_FUNCTION__, error);
}

#pragma mark -
#pragma mark - Private methods

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (UIImage *)addImage:(NSString *)picName WithName:(NSString *)name WithFrame:(CGRect )frame{
    UIImage *basicImage = [UIImage imageNamed:picName];
//    [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]]

    //    UIImage *tiezhi = [UIImage imageNamed:@"Trips"];
    CGSize finalSize = frame.size;
//    CGSize tiezhiSize = [tiezhi size];
    
    UIGraphicsBeginImageContext(finalSize);
    [basicImage drawInRect:CGRectMake(0,0,finalSize.width,finalSize.height)];
//    [tiezhi drawInRect:CGRectMake(100,100,tiezhiSize.width*2,tiezhiSize.height*2)];
    
    [[UIColor whiteColor] set];
    [name drawInRect:CGRectMake(0, FoodButtonRadiu/2-10, FoodButtonRadiu, 80) withFont:[UIFont systemFontOfSize:15]];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end