//
//  UINavigationController+ThrioNavigator.h
//  thrio
//
//  Created by foxsofter on 2019/12/17.
//

#import <UIKit/UIKit.h>
#import "ThrioTypes.h"

NS_ASSUME_NONNULL_BEGIN

@interface UINavigationController (Navigator)

- (void)thrio_pushUrl:(NSString *)url
               params:(NSDictionary *)params
             animated:(BOOL)animated
               result:(ThrioBoolCallback)result;

- (BOOL)thrio_notifyUrl:(NSString *)url
                  index:(NSNumber *)index
                   name:(NSString *)name
                 params:(NSDictionary *)params;

- (void)thrio_popAnimated:(BOOL)animated
                   result:(ThrioBoolCallback)result;

- (void)thrio_popToUrl:(NSString *)url
                 index:(NSNumber *)index
              animated:(BOOL)animated
                result:(ThrioBoolCallback)result;

- (void)thrio_removeUrl:(NSString *)url
                  index:(NSNumber *)index
               animated:(BOOL)animated
                 result:(ThrioBoolCallback)result;

- (void)thrio_didPushUrl:(NSString *)url index:(NSNumber *)index;

- (void)thrio_didPopUrl:(NSString *)url index:(NSNumber *)index;

- (void)thrio_didPopToUrl:(NSString *)url index:(NSNumber *)index;

- (void)thrio_didRemoveUrl:(NSString *)url index:(NSNumber *)index;

- (NSNumber *)thrio_lastIndex;

- (NSNumber *)thrio_getLastIndexByUrl:(NSString *)url;

- (NSArray *)thrio_getAllIndexByUrl:(NSString *)url;

- (BOOL)thrio_ContainsUrl:(NSString *)url;

- (BOOL)thrio_ContainsUrl:(NSString *)url index:(NSNumber *)index;

- (void)thrio_didShowViewController:(UIViewController *)viewController animated:(BOOL)animated;

- (UIViewController * _Nullable)getViewControllerByUrl:(NSString *)url
                                                 index:(NSNumber *)index;

@end

NS_ASSUME_NONNULL_END
