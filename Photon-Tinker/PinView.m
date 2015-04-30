//
//  PinView.m
//  Photon-Tinker
//
//  Created by Ido on 4/29/15.
//  Copyright (c) 2015 spark. All rights reserved.
//

#import "PinView.h"

@interface PinView()
@property (nonatomic, strong) UIButton *innerPinButton;
@property (nonatomic, strong) UIButton *outerPinButton;
@property (nonatomic, strong) UILabel *label;
//@property (nonatomic, strong) UILabel *valueLabel;

//slider...

@end

@implementation PinView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


-(id)initWithPin:(SPKCorePin *)pin
{
    if (self = [super init])
    {
        _pin = pin;
        [self setFrame:CGRectMake(0, 0, 50, 50)];
        
        self.innerPinButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.innerPinButton setFrame:CGRectMake(11, 8, 30, 30)];
        [self.innerPinButton setImage:[UIImage imageNamed:@"imgCircle"] forState:UIControlStateNormal];
        [self.innerPinButton setTitle:@"" forState:UIControlStateNormal];
        self.innerPinButton.tintColor = [UIColor whiteColor];
        [self.innerPinButton addTarget:self action:@selector(pinTapped:) forControlEvents:UIControlEventTouchUpInside];

        self.outerPinButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.outerPinButton setFrame:CGRectMake(7, 4, 38, 38)];
        [self.outerPinButton setImage:[UIImage imageNamed:@"imgCircleHollow"] forState:UIControlStateNormal];
        [self.outerPinButton setTitle:@"" forState:UIControlStateNormal];
        self.outerPinButton.tintColor = [UIColor blueColor];
        self.outerPinButton.userInteractionEnabled = NO;
        
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 16)];
        self.label.center = self.innerPinButton.center;
        self.label.text = self.pin.label;
        if (self.pin.label.length <= 2)
            self.label.font = [UIFont fontWithName:@"Gotham-Medium" size:14.0];
        else
            self.label.font = [UIFont fontWithName:@"Gotham-Medium" size:12.0];
        self.label.textColor = [UIColor blackColor];
        self.label.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:self.outerPinButton];
        [self addSubview:self.innerPinButton];
        [self addSubview:self.label];
        
    }
    
    return self;
}

-(void)pinTapped:(PinView *)sender
{
    [self.delegate pinViewTapped:sender];
}


@end
