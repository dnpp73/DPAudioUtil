#import <Foundation/Foundation.h>


#if TARGET_OS_IPHONE


#import <AVFoundation/AVFoundation.h>


@protocol DPAudioRouteChangeDetectorObserver <NSObject>
@optional
- (void)audioRouteChangeDetectorDidDetectAudioSessionPropertyChangeWithReason:(AVAudioSessionRouteChangeReason)reason
                                                                 notification:(NSNotification*)notification;
@end


@interface DPAudioRouteChangeDetector : NSObject

+ (instancetype)sharedDetector;

- (void)addObserver:(__weak id<DPAudioRouteChangeDetectorObserver>)observer;
- (void)removeObserver:(__weak id<DPAudioRouteChangeDetectorObserver>)observer;

@end


#endif