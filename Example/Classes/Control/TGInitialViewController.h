//
//  TGInitialViewController.h
//  TGCameraViewController
//
//  Created by Bruno Furtado on 15/09/14.
//  Copyright (c) 2014 Tudo Gostoso Internet. All rights reserved.
//

@import UIKit;
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreLocation/CoreLocation.h>

@interface TGInitialViewController : UIViewController<CLLocationManagerDelegate>

@property(nonatomic, retain) CLLocation *location;

@end