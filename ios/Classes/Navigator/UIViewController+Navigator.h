//
//  UIViewController+ThrioPage.h
//  thrio
//
//  Created by foxsofter on 2019/12/16.
//

#import <UIKit/UIKit.h>

#import "ThrioTypes.h"
#import "NavigatorPageRoute.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (Navigator)

@property (nonatomic, strong, nullable) NSNumber *thrio_hidesNavigationBar;

@property (nonatomic, strong, readonly, nullable) NavigatorPageRoute *thrio_firstRoute;

@property (nonatomic, strong, readonly, nullable) NavigatorPageRoute *thrio_lastRoute;

- (void)thrio_pushUrl:(NSString *)url
                index:(NSNumber *)index
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

- (NavigatorPageRoute * _Nullable)thrio_getRouteByUrl:(NSString *)url index:(NSNumber *)index;

- (NSNumber *)thrio_getLastIndexByUrl:(NSString *)url;

- (NSArray *)thrio_getAllIndexByUrl:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
