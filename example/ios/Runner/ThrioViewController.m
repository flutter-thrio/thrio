//
//  ThrioViewController.m
//  Runner
//
//  Created by foxsofter on 2019/12/25.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "ThrioViewController.h"
#import <thrio/Thrio.h>

@interface ThrioViewController ()

@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation ThrioViewController

- (IBAction)pushFlutterPage:(id)sender {
  [ThrioNavigator pushUrl:@"biz1/flutter1"];
}
- (IBAction)popFlutter1:(id)sender {
  [ThrioNavigator removeUrl:@"biz1/flutter1"];
}
- (IBAction)pushNativePage:(id)sender {
  [ThrioNavigator pushUrl:@"native1"];
}
- (IBAction)popNative1:(id)sender {
  [ThrioNavigator removeUrl:@"native1"];
}
- (IBAction)pushNative2:(id)sender {
  [ThrioNavigator pushUrl:@"native2"];
}
- (IBAction)popNative2:(id)sender {
  [ThrioNavigator removeUrl:@"native2"];
}
- (IBAction)pop:(id)sender {
  [ThrioNavigator pop];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  if (self.thrio_firstRoute.settings) {
    NSString *txt = [NSString stringWithFormat:@"native page: %@ \n index: %@", self.thrio_firstRoute.settings.url, self.thrio_firstRoute.settings.index];
    [self.label setText:txt];
  } else {
    [self thrio_pushUrl:@"native1" index:@1 params:@{} animated:NO result:^(BOOL r) {
      
    }];
  }
}

@end
