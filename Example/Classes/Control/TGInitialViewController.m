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

@interface TGInitialViewController () <TGCameraDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *photoView;


- (IBAction)takePhotoTapped;

- (void)clearTapped;

@end



@implementation TGInitialViewController {
    CLLocationManager *_locationManager;
    
    BOOL _updatingLocation;
    NSError *_lastLocationError;
    
    
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        _locationManager = [[CLLocationManager alloc] init];
    }
    return  self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self startLocationManager];
    
    [TGCamera setOption:kTGCameraOptionSaveImageToAlbum value:[NSNumber numberWithBool:YES]];
    
    _photoView.clipsToBounds = YES;
    
    UIBarButtonItem *clearButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                 target:self
                                                                                 action:@selector(clearTapped)];
    
    self.navigationItem.rightBarButtonItem = clearButton;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLocationInfoGot:) name:@"TGLocationInfoGot" object:nil];
}

- (void) onLocationInfoGot:(NSNotification*)notification {
    if ([notification.name isEqualToString:@"TGLocationInfoGot"]){
        NSLog(@"%@" , notification.object);
        
        STPicInfo *info = (STPicInfo *)notification.object;
        if (![info isGpsSetted]){
            info.gps = self.location.coordinate;
        }
    
        MCShituViewController *controller = [MCShituViewController createWebViewPageWithGPS:info.gps andImageUrl:info.url];
        [self.navigationController pushViewController:controller animated:NO];
    }
//    NSLog(@"%@, %@, %@", self.uploadedUrl, self.latitude, self.longitude);
    
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.location = nil;
}


- (void)viewDidDisappear:(BOOL)animated {
    [self stopLocationManager];
}

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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
#pragma mark - Actions

- (IBAction)takePhotoTapped
{    
    TGCameraNavigationController *navigationController = [TGCameraNavigationController newWithCameraDelegate:self];
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark -
#pragma mark - Private methods

- (void)clearTapped
{
    _photoView.image = nil;
}

@end