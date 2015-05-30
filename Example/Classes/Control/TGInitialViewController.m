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

@property (strong, nonatomic) IBOutlet UIImageView *photoView;
@property (strong, nonatomic) UIImageView *backgroundView;
@property (strong, nonatomic) UIButton *shotButton;
@property (strong, nonatomic) UIView *foodsImageView;

//- (IBAction)takePhotoTapped;

- (void)clearTapped;

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
    
    return self;
}

- (void)dealloc{
    self.location = nil;
    self.backgroundView = nil;
    self.shotButton = nil;
    self.foodsImageView = nil;
    
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
    self.backgroundView = [[UIImageView alloc]initWithFrame: CGRectMake(0, 20, ScreenWidth, 562/2)];
    self.backgroundView.image = [UIImage imageNamed:@"backgroundHeader"];
//    self.backgroundView.contentMode = UIViewContentModeCenter;
    [self.view addSubview:self.backgroundView];
    
    
    CGRect frame = CGRectMake((ScreenWidth - ShotButtonRadius)/2 , (562-ShotButtonRadius)/2+20, ShotButtonRadius, ShotButtonRadius);
    self.shotButton = [self makeRoundButton:ShotButtonRadius WithImage:[UIImage imageNamed:@"shotButton"] WithFrame:frame];
//    self.shotButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.shotButton setImage:[UIImage imageNamed:@"shotButton"] forState:UIControlStateNormal];
//    self.shotButton.frame = CGRectMake((ScreenWidth - ShotButtonRadius)/2 , (562-ShotButtonRadius)/2+20, ShotButtonRadius, ShotButtonRadius);
//    self.shotButton.clipsToBounds = YES;
//    self.shotButton.layer.cornerRadius = ShotButtonRadius/2.0f;
//    self.shotButton.layer.borderColor=[UIColor redColor].CGColor;
//    self.shotButton.layer.borderWidth=2.0f;
    [self.shotButton addTarget:self action:@selector(onShotButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.shotButton];

    self.foodsImageView = [[UIView alloc]initWithFrame:CGRectMake(0, (562+ShotButtonRadius)/2+20, ScreenWidth, ScreenHeight - (562+ShotButtonRadius)/2)];
    [self.view addSubview:self.foodsImageView];
    
    UIImageView *foodTitle = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 138/2+10)];
    foodTitle.image = [UIImage imageNamed:@"foodTitle"];
    [self.foodsImageView addSubview:foodTitle];
    
    UIButton *foodButton;
    for (int i = 0; i < 3; i++) {
        frame = CGRectMake((50+i*(FoodButtonRadiu+20)), 138/2+10, FoodButtonRadiu, FoodButtonRadiu);
        foodButton = [self makeRoundButton:FoodButtonRadiu WithImage:[UIImage imageNamed:@"shotButton"] WithFrame:frame];
        [self.foodsImageView addSubview:foodButton];
    }
    
    for (int i = 0; i < 3; i++) {
        frame = CGRectMake((50+i*(FoodButtonRadiu+20)), 138/2+30 + FoodButtonRadiu, FoodButtonRadiu, FoodButtonRadiu);
        foodButton = [self makeRoundButton:FoodButtonRadiu WithImage:[UIImage imageNamed:@"shotButton"] WithFrame:frame];
        [self.foodsImageView addSubview:foodButton];
    }
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLocationInfoGot:) name:@"TGLocationInfoGot" object:nil];
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
        [_locationManager requestAlwaysAuthorization];
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

- (void)clearTapped
{
    _photoView.image = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end