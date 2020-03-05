//
//  ThrioViewController2.m
//  Runner
//
//  Created by foxsofter on 2019/12/25.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "ThrioViewController2.h"
#import <thrio/Thrio.h>

@interface ThrioViewController2 ()

@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation ThrioViewController2

- (IBAction)pushFlutterPage:(id)sender {
  [ThrioNavigator pushUrl:@"biz2/flutter2"];
}
- (IBAction)popFlutter1:(id)sender {
  [ThrioNavigator removeUrl:@"biz2/flutter2"];
}
- (IBAction)pushNativePage:(id)sender {
  [ThrioNavigator pushUrl:@"native1"];
}
- (IBAction)popNative1:(id)sender {
  [ThrioNavigator removeUrl:@"native1"];
}
- (IBAction)popToNative1:(id)sender {
  [ThrioNavigator popToUrl:@"native1"];
}
- (IBAction)pop:(id)sender {
  [ThrioNavigator pop];
}
- (IBAction)willPopYESNative2:(id)sender {
  self.thrio_willPopBlock = ^(ThrioBoolCallback _Nonnull result) {
    result(YES);
  };
}
- (IBAction)willPopNONative2:(id)sender {
  self.thrio_willPopBlock = ^(ThrioBoolCallback _Nonnull result) {
    result(NO);
  };
}
- (IBAction)willPopNilNative2:(id)sender {
  self.thrio_willPopBlock = nil;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  if (self.thrio_firstRoute.settings) {
    NSString *txt = [NSString stringWithFormat:@"native page: %@ \n index: %@",
                     self.thrio_firstRoute.settings.url,
                     self.thrio_firstRoute.settings.index];
    [self.label setText:txt];
  }
  
  self.thrio_willPopBlock = ^(ThrioBoolCallback _Nonnull result) {
    result(NO);
  };
}

@end
