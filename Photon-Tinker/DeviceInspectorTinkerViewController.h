//
//  DeviceInspectorTinkerViewController.h
//  Particle Photon Tinker for iOS
//
//  Copyright (c) 2015 Particle Devices. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PinView.h"
#import "PinFunctionView.h"
#import "ParticleDevice+pins.h"

@class DeviceListViewController;

@interface DeviceInspectorTinkerViewController : UIViewController

@property (nonatomic, strong) ParticleDevice *device;

@end
