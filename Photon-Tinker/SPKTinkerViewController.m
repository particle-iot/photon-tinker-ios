//
//  SPKTinkerViewController.m
//  Spark IOS
//
//  Copyright (c) 2013 Spark Devices. All rights reserved.
//

#import "SPKTinkerViewController.h"
#import "Spark-SDK.h"
#import "SPKCorePin.h"
#import "SparkDevice+pins.h"
//#import "Photon_Tinker-Swift.h"
#import "PinView.h"

@interface SPKTinkerViewController () <UITextFieldDelegate>

@property (nonatomic, strong) NSMutableDictionary *pinViews;
@property (nonatomic, weak) IBOutlet SPKPinFunctionView *pinFunctionView;
@property (nonatomic, weak) IBOutlet UIView *firstTimeView;
@property (nonatomic, weak) IBOutlet UIImageView *tinkerLogoImageView;
@property (weak, nonatomic) IBOutlet UITextField *deviceNameTextField;
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *deviceIDLabel;
@property (weak, nonatomic) IBOutlet UIView *chipView;
@property (weak, nonatomic) IBOutlet UIImageView *chipShadowImageView;

@property (weak, nonatomic) IBOutlet UIView *deviceView;
@property (nonatomic) BOOL editingDeviceName;
@end


@implementation SPKTinkerViewController

- (void)viewDidLoad
{
    self.pinViews = [NSMutableDictionary dictionaryWithCapacity:16];
    self.pinFunctionView.delegate = self;

    // background image
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"imgBackgroundOrange"]];
    backgroundImage.frame = [UIScreen mainScreen].bounds;
    backgroundImage.contentMode = UIViewContentModeScaleToFill;
    backgroundImage.alpha = 0.9;
    [self.view addSubview:backgroundImage];
    [self.view sendSubviewToBack:backgroundImage];
    
    // first time view
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissFirstTime)];
    [self.firstTimeView addGestureRecognizer:tap];

    // inititalize pins
    [self.device configurePins:SparkDeviceTypePhoton];//self.device.type]; // TODO: fix when device type becomes available
    
    self.deviceIDLabel.text = [self.device.id uppercaseString];
    
    // initialize pin views
    /*
    for (SPKCorePin *pin in self.device.pins) {
        SPKCorePinView *v = [[SPKCorePinView alloc] init];
        [self.chipView insertSubview:v aboveSubview:self.chipShadowImageView];
        v.pin = pin;
        v.delegate = self;
        self.pinViews[pin.label] = v;
        
    }
     */
    
    for (SPKCorePin *pin in self.device.pins) {
        PinView *v = [[PinView alloc] initWithPin:pin];
        CGFloat y_spacing = MIN(v.frame.size.height, (self.chipShadowImageView.bounds.size.height / (self.device.pins.count/2))); // assume even amount of pins per row
        CGFloat y_offset = abs(self.chipShadowImageView.frame.origin.y - self.chipView.frame.origin.y);
        NSLog(@"y spacing %f / y_ofs %f",y_spacing, y_offset);
        
//        CGRect frame = v.frame;
        //        frame.origin.y = pin.row*50+y_offset;
        //        frame.origin.x = pin.side == SPKCorePinSideLeft ? 0 : self.chipShadowImageView.bounds.size.width - 80;
        //        [v setFrame:frame];
        [self.chipView insertSubview:v aboveSubview:self.chipShadowImageView];
        
        v.translatesAutoresizingMaskIntoConstraints = NO;
        NSLayoutAttribute xPosAttribute = (pin.side == SPKCorePinSideLeft) ? NSLayoutAttributeLeading : NSLayoutAttributeTrailing;
        [self.chipView addConstraint:[NSLayoutConstraint constraintWithItem:v
                                                                  attribute:xPosAttribute
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.chipView
                                                                  attribute:xPosAttribute
                                                                 multiplier:1.0
                                                                   constant:0]];
        
        [self.chipView addConstraint:[NSLayoutConstraint constraintWithItem:v
                                                                  attribute:NSLayoutAttributeTop
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.chipView
                                                                  attribute:NSLayoutAttributeTop
                                                                 multiplier:1.0
                                                                   constant:pin.row*y_spacing + y_offset]];
        
        [v addConstraint:[NSLayoutConstraint constraintWithItem:v
                                                      attribute:NSLayoutAttributeWidth
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:nil
                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                     multiplier:1.0
                                                       constant:50]];
        
        [v addConstraint:[NSLayoutConstraint constraintWithItem:v
                                                      attribute:NSLayoutAttributeHeight
                                                      relatedBy:NSLayoutRelationEqual
                                                         toItem:nil
                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                     multiplier:1.0
                                                       constant:50]];

        [self.chipView setNeedsLayout];
        
        //        v.delegate = self;
//        self.pinViews[pin.label] = v;
    }

    
    
}



- (IBAction)editDeviceNameButtonTapped:(id)sender
{
    if (!self.editingDeviceName)
    {
        self.deviceNameLabel.hidden = YES;
        self.deviceNameTextField.hidden = NO;
        self.deviceNameTextField.text = self.deviceNameLabel.text;
        self.deviceNameTextField.delegate = self;
        self.editingDeviceName = YES;
        [self.deviceNameTextField becomeFirstResponder];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField;
{
    if (textField==self.deviceNameTextField)
    {
        [self.deviceNameTextField resignFirstResponder];
        self.editingDeviceName = NO;
        self.device.name = self.deviceNameTextField.text; // TODO: verify correctness
        self.deviceNameLabel.text = self.deviceNameTextField.text;
        self.deviceNameLabel.hidden = NO;
        self.deviceNameTextField.hidden = YES;

    }
    return YES;
}


- (IBAction)backButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)helpButtonTapped:(id)sender {
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    for (SPKCorePin *pin in self.device.pins) {
        SPKCorePinView *v = self.pinViews[pin.label];
        v.pin = pin;
    }

    if ((self.device.name) && (![self.device.name isEqualToString:@""]))
    {
        self.deviceNameLabel.text = self.device.name;
    }
    else
    {
        self.deviceNameLabel.text = @"<no name>";
    }

//    self.firstTimeView.hidden = ![SPKSpark sharedInstance].user.firstTime;
    self.tinkerLogoImageView.hidden = NO;
//    self.deviceNameLabel.hidden = NO;
}


/*
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    
    if (!isiPhone5) {
        CGRect f = self.nameLabel.frame;
        f.origin.y = 340.0;
        self.nameLabel.frame = f;

        f = self.firstTimeView.frame;
        f.origin.y += 1.0;
        self.firstTimeView.frame = f;

        f = self.tinkerLogoImageView.frame;
        f.origin.y -= 30.0;
        self.tinkerLogoImageView.frame = f;
    }
}
*/

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Pin Function Delegate

- (void)pinFunctionSelected:(SPKCorePinFunction)function
{
    SPKCorePin *pin = self.pinFunctionView.pin;
    pin.selectedFunction = function;
    self.pinFunctionView.pin = pin;

    SPKCorePinView *pinView = self.pinViews[pin.label];
    [pinView.pin resetValue];
    [pinView refresh];
}

#pragma mark - Core Pin View Delegate

- (void)pinViewAdjusted:(SPKCorePinView *)pinView newValue:(NSUInteger)newValue
{
    [pinView.pin adjustValue:newValue];

    [pinView noslider];
    [pinView refresh];
    [pinView activate];
    [self pinCallHome:pinView];
    for (SPKCorePinView *pv in self.pinViews.allValues) {
        [pv showDetails];
    }
}


- (void)pinViewHeld:(SPKCorePinView *)pinView
{
    if (![self slidingAnalogWritePinView] && !pinView.active) {
        [self showFunctionView:pinView];
    }
}


- (void)pinViewTapped:(SPKCorePinView *)pinView inPin:(BOOL)inPin
{
    if (!self.pinFunctionView.hidden) {
        self.pinFunctionView.hidden = YES;
        for (SPKCorePinView *pv in self.pinViews.allValues) {
            pv.alpha = 1.0;
        }
        self.tinkerLogoImageView.hidden = NO;
//        self.deviceNameLabel.hidden = NO;
    } else if (!pinView.active) {
        SPKCorePinView *slidingAnalogWritePinView = [self slidingAnalogWritePinView];

        if (!slidingAnalogWritePinView && pinView.pin.selectedFunction == SPKCorePinFunctionAnalogWrite) {
            for (SPKCorePinView *pinView in self.pinViews.allValues) {
                [pinView hideDetails];
            }

            self.tinkerLogoImageView.hidden = YES;
//            if (!isiPhone5) {
//                self.nameLabel.hidden = YES;
//            }
            [self.view bringSubviewToFront:pinView];
            [pinView slider];
        } else if (!slidingAnalogWritePinView && inPin && pinView.pin.selectedFunction == SPKCorePinFunctionNone) {
            [self showFunctionView:pinView];
        } else if (!slidingAnalogWritePinView && pinView.pin.selectedFunction == SPKCorePinFunctionDigitalWrite) {
            if (!pinView.pin.valueSet) {
                [pinView.pin adjustValue:1];
            } else {
                [pinView.pin adjustValue:!pinView.pin.value];
            }

            [pinView refresh];
            [pinView activate];
            [self pinCallHome:pinView];
        } else if (!slidingAnalogWritePinView && inPin) {
            if (pinView.pin.selectedFunction == SPKCorePinFunctionAnalogRead || pinView.pin.selectedFunction == SPKCorePinFunctionDigitalRead) {
                [pinView showDetails];
                [self.view bringSubviewToFront:pinView];
                [pinView activate];
                [self pinCallHome:pinView];
            }
        } else if (slidingAnalogWritePinView && pinView != slidingAnalogWritePinView) {
            [slidingAnalogWritePinView noslider];
            [slidingAnalogWritePinView refresh];
            [slidingAnalogWritePinView activate];
            [self pinCallHome:slidingAnalogWritePinView];
            for (SPKCorePinView *pinView in self.pinViews.allValues) {
                [pinView showDetails];
            }
        }
    }
}

#pragma mark - Private Methods

- (void)dismissFirstTime
{
    self.firstTimeView.hidden = YES;
//    [SPKSpark sharedInstance].user.firstTime = NO;
}

- (void)showFunctionView:(SPKCorePinView *)pinView
{
    if (self.pinFunctionView.hidden) {
        self.tinkerLogoImageView.hidden = YES;
//        if (!isiPhone5) {
//            self.nameLabel.hidden = YES;
//        }
        self.pinFunctionView.pin = pinView.pin;
        self.pinFunctionView.hidden = NO;
        for (SPKCorePinView *pv in self.pinViews.allValues) {
            if (pv != pinView) {
                pv.alpha = 0.1;
            }
        }
        [self.view bringSubviewToFront:self.pinFunctionView];
    }
}

- (SPKCorePinView *)slidingAnalogWritePinView
{
    for (SPKCorePinView *pv in self.pinViews.allValues) {
        if (pv.pin.selectedFunction == SPKCorePinFunctionAnalogWrite && pv.sliding) {
            return pv;
        }
    }

    return nil;
}

- (void)pinCallHome:(SPKCorePinView *)pinView
{
    [self.device updatePin:pinView.pin.label function:pinView.pin.selectedFunction value:pinView.pin.value success:^(NSUInteger value) {
        ///
        dispatch_async(dispatch_get_main_queue(), ^{
            if (pinView.pin.selectedFunction == SPKCorePinFunctionDigitalWrite || pinView.pin.selectedFunction == SPKCorePinFunctionAnalogWrite) {
                if (value == -1) {
                    [[[UIAlertView alloc] initWithTitle:@"Core Pin" message:@"There was a problem writing to this pin." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                    [pinView.pin resetValue];
                }
            } else {
                [pinView.pin adjustValue:value];
            }

            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            [pinView deactivate];
            self.tinkerLogoImageView.hidden = NO;
//            self.deviceNameLabel.hidden = NO;
            [pinView refresh];
            [CATransaction commit];
        });
    } failure:^(NSString *errorMessage) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[[UIAlertView alloc] initWithTitle:@"Core Pin" message:errorMessage delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            [pinView.pin resetValue];
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            [pinView deactivate];
            self.tinkerLogoImageView.hidden = NO;
//            self.deviceNameLabel.hidden = NO;
            [pinView refresh];
            [CATransaction commit];
        });
    }];
}

@end
