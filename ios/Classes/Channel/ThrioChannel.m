//
//  ThrioChannel.m
//  Pods-Runner
//
//  Created by foxsofter on 2019/12/9.
//

#import <Flutter/Flutter.h>

#import "ThrioChannel.h"
#import "ThrioRegistryMap.h"
#import "ThrioRegistrySetMap.h"
#import "ThrioPlugin.h"

NS_ASSUME_NONNULL_BEGIN

@interface ThrioChannel ()

@property (nonatomic, copy) NSString *channelName;

@property (nonatomic, strong) NSObject<FlutterBinaryMessenger> *messenger;

@property (nonatomic, strong) FlutterMethodChannel *methodChannel;

@property (nonatomic, strong) ThrioRegistryMap *methodHandlers;

@property (nonatomic, strong) FlutterEventChannel *eventChannel;

@property (nonatomic, strong) ThrioRegistrySetMap *eventHandlers;

@property (nonatomic, strong) FlutterEventSink eventSink;

@end

static NSString *const kDefaultChannelName = @"__thrio__";

static NSString *const kEventNameKey = @"__event_name__";

@implementation ThrioChannel

+ (instancetype)channel {
  return [self channelWithName:@""];
}

+ (instancetype)channelWithName:(NSString *)channelName {
  if (!channelName || channelName.length < 1) {
    channelName = kDefaultChannelName;
  }
  return [[ThrioChannel alloc] initWithName:channelName];
}

- (instancetype)initWithName:(NSString *)channelName {
  self = [super init];
  if (self) {
    _channelName = channelName;
  }
  return self;
}

#pragma mark - method channel methods

- (void)invokeMethod:(NSString*)method
           arguments:(id _Nullable)arguments {
  return [_methodChannel invokeMethod:method
                            arguments:arguments];
}

- (void)invokeMethod:(NSString*)method
           arguments:(id _Nullable)arguments
              result:(FlutterResult _Nullable)callback {
  return [_methodChannel invokeMethod:method
                            arguments:arguments
                               result:callback];
}

- (ThrioVoidCallback)registryMethodCall:(NSString *)method
                                handler:(ThrioMethodHandler)handler {
  return [_methodHandlers registry:method value:handler];
}

- (void)setupMethodChannel:(NSObject<FlutterBinaryMessenger> *)messenger {
  _methodHandlers = [ThrioRegistryMap map];
  
  NSString *methodChannelName = [NSString stringWithFormat:@"_method_%@", _channelName];
  _methodChannel = [FlutterMethodChannel methodChannelWithName:methodChannelName
                                               binaryMessenger:messenger];
  __weak typeof(self) weakself = self;
  [_methodChannel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call,
                                         FlutterResult  _Nonnull result) {
    __strong typeof(self) strongSelf = weakself;
    ThrioMethodHandler handler = strongSelf.methodHandlers[call.method];
    if (handler) {
        handler(call.arguments, ^(BOOL r){
            result(@(r));
        });
    }
  }];
}

#pragma mark - event channel methods

- (void)sendEvent:(NSString *)name arguments:(id _Nullable)arguments {
  if (self.eventSink) {
    id args = [NSMutableDictionary dictionaryWithDictionary:arguments];
    [args setValue:name forKey:kEventNameKey];
    self.eventSink(args);
  }
}

- (ThrioVoidCallback)registryEventHandling:(NSString *)name
                                   handler:(ThrioEventHandler)handler {
  return [_eventHandlers registry:name value:handler];
}

- (void)setupEventChannel:(NSObject<FlutterBinaryMessenger> *)messenger {
  _eventHandlers = [ThrioRegistrySetMap map];
  
  NSString *eventChannelName = [NSString stringWithFormat:@"_event_%@", _channelName];
  _eventChannel = [FlutterEventChannel eventChannelWithName:eventChannelName
                                            binaryMessenger:messenger];
  [_eventChannel setStreamHandler:self];
}

#pragma mark - FlutterStreamHandler methods

- (FlutterError * _Nullable)onListenWithArguments:(id _Nullable)arguments
                                        eventSink:(nonnull FlutterEventSink)events {
  self.eventSink = events;
  return nil;
}

- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
  return nil;
}

@end

NS_ASSUME_NONNULL_END
