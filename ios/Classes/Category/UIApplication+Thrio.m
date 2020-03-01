//
//  UIApplication+Thrio.m
//  thrio
//
//  Created by foxsofter on 2019/12/17.
//

#import "UIApplication+Thrio.h"

@implementation UIApplication (Thrio)

- (UIViewController *)topmostViewController {
  UIViewController *topmostViewController = self.delegate.window.rootViewController;
  while (true) {
    if (topmostViewController.presentedViewController) {
      topmostViewController = topmostViewController.presentedViewController;
    } else if ([topmostViewController isKindOfClass:[UINavigationController class]]) {
      UINavigationController *navigationController = (UINavigationController *)topmostViewController;
      topmostViewController = navigationController.topViewController;
    } else if ([topmostViewController isKindOfClass:[UITabBarController class]]) {
      UITabBarController *tabBarController = (UITabBarController *)topmostViewController;
      topmostViewController = tabBarController.selectedViewController;
    } else {
      break;
    }
  }
  return topmostViewController;
}

- (UINavigationController * _Nullable)topmostNavigationController {
  UINavigationController* topmostNavigationController = nil;
  UIViewController *topmostViewController = self.delegate.window.rootViewController;
  while (true) {
    if ([topmostViewController isKindOfClass:[UINavigationController class]]) {
      topmostNavigationController = (UINavigationController *)topmostViewController;
    }
    if (topmostViewController.presentedViewController) {
      topmostViewController = topmostViewController.presentedViewController;
    } else if ([topmostViewController isKindOfClass:[UITabBarController class]]) {
      UITabBarController *tabBarController = (UITabBarController *)topmostViewController;
      topmostViewController = tabBarController.selectedViewController;
    } else {
      break;
    }
  }
  return topmostNavigationController;

}

@end
