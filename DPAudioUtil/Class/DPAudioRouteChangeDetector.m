#import "DPAudioRouteChangeDetector.h"


#if TARGET_OS_IPHONE


@interface DPAudioRouteChangeDetector ()
{
    NSHashTable* _observers;
}
@end


@implementation DPAudioRouteChangeDetector

#pragma mark - Singleton Patter

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
}

+ (instancetype)sharedDetector
{
    static id sharedDetector = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDetector = [[self alloc] initSharedDetector];
    });
    return sharedDetector;
}

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (instancetype)initSharedDetector
{
    self = [super init];
    if (self) {
        _observers = [NSHashTable weakObjectsHashTable];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioSessionDidChangeProperty:) name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
    }
    return self;
}

#pragma mark - NSNotification

- (void)audioSessionDidChangeProperty:(NSNotification*)notification
{
    if (_observers.count == 0) {
        return;
    }
    AVAudioSessionRouteChangeReason routeChangeReason = [notification.userInfo[AVAudioSessionRouteChangeReasonKey] unsignedIntegerValue];
    for (id<DPAudioRouteChangeDetectorObserver> observer in _observers) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([observer respondsToSelector:@selector(audioRouteChangeDetectorDidDetectAudioSessionPropertyChangeWithReason:notification:)]) {
                [observer audioRouteChangeDetectorDidDetectAudioSessionPropertyChangeWithReason:routeChangeReason notification:notification];
            }
        });
    }
}

#pragma mark - Observers

- (void)addObserver:(__weak id<DPAudioRouteChangeDetectorObserver>)observer
{
    if ([observer conformsToProtocol:@protocol(DPAudioRouteChangeDetectorObserver)] && [_observers containsObject:observer] == NO) {
        [_observers addObject:observer];
    }
}

- (void)removeObserver:(__weak id<DPAudioRouteChangeDetectorObserver>)observer
{
    if ([_observers containsObject:observer]) {
        [_observers removeObject:observer];
    }
}

@end


#endif