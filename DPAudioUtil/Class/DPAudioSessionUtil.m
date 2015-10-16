#import "DPAudioSessionUtil.h"


#if TARGET_OS_IPHONE


#import "dp_exec_block_on_main_thread.h"


@implementation DPAudioSessionUtil

+ (void)requestRecordPermissionWithCallback:(void (^)(BOOL))callback
{
    // iOS 7.0 未満
    if (NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_7_0) {
        if (callback) {
            dp_exec_block_on_main_thread(^{
                callback(YES);
            });
        }
    }
    // iOS 7.0 以降
    else if (NSFoundationVersionNumber_iOS_7_0 <= NSFoundationVersionNumber) {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted){
            if (callback) {
                dp_exec_block_on_main_thread(^{
                    callback(granted);
                });
            }
        }];
    }
}

+ (BOOL)setAudioSessionCategory:(NSString*)category withOptions:(AVAudioSessionCategoryOptions)options
{
    BOOL success = NO;
    NSError* error = nil;
    success = [[AVAudioSession sharedInstance] setCategory:category withOptions:options error:&error];
    if(success == NO || error){
        NSLog(@"setCategory:withOption: failure, error: %@", error);
    }
    return success;
}

+ (BOOL)setAudioSessionCategoryIfNeeded:(NSString*)category withOptions:(AVAudioSessionCategoryOptions)options
{
    if ([[[AVAudioSession sharedInstance] category] isEqualToString:category]) {
        return YES;
    }
    else {
        return [self setAudioSessionCategory:category withOptions:options];
    }
}

+ (BOOL)setAudioSessionCategoryAmbientIfNeeded
{
    return [self setAudioSessionCategoryIfNeeded:AVAudioSessionCategoryAmbient withOptions:AVAudioSessionCategoryOptionMixWithOthers];
}

+ (BOOL)setAudioSessionCategorySoloAmbientIfNeeded
{
    return [self setAudioSessionCategoryIfNeeded:AVAudioSessionCategorySoloAmbient withOptions:AVAudioSessionCategoryOptionMixWithOthers];
}

+ (BOOL)setAudioSessionCategoryPlaybackIfNeeded
{
    return [self setAudioSessionCategoryIfNeeded:AVAudioSessionCategoryPlayback withOptions:0];
}

+ (BOOL)setAudioSessionCategoryRecordIfNeeded
{
    return [self setAudioSessionCategoryIfNeeded:AVAudioSessionCategoryRecord withOptions:0];
}

+ (BOOL)setAudioSessionCategoryPlayAndRecordIfNeeded
{
    return [self setAudioSessionCategoryIfNeeded:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker];
}

+ (BOOL)setAudioSessionActive:(BOOL)active
{
    BOOL success = NO;
    NSError* error = nil;
    success = [[AVAudioSession sharedInstance] setActive:YES error:&error];
    if (success == NO || error) {
        NSLog(@"setActive: failure, error: %@", error);
    }
    return success;
}

+ (BOOL)isOutputNotWiredHeadphones
{
    BOOL isOutputNotWiredHeadphones = NO;
    for (AVAudioSessionPortDescription* outputPortDescription in [[[AVAudioSession sharedInstance] currentRoute] outputs]) {
        if (![outputPortDescription.portType isEqualToString:AVAudioSessionPortHeadphones]) {
            isOutputNotWiredHeadphones = YES;
        }
    }
    return isOutputNotWiredHeadphones;
}

+ (BOOL)isInputMicrophoneWiredAndOutputWiredHeadphones
{
    // 下二つやらないとちゃんと返ってこない
    if (![self setAudioSessionCategoryPlayAndRecordIfNeeded]){
        return NO;
    }
    if (![self setAudioSessionActive:YES]) {
        return NO;
    }
    
    BOOL isInputMicrophoneWired  = NO;
    BOOL isOutputWiredHeadphones = NO;
    
    for (AVAudioSessionPortDescription* inputPortDescription in [[[AVAudioSession sharedInstance] currentRoute] inputs]) {
        if ([inputPortDescription.portType isEqualToString:AVAudioSessionPortHeadsetMic]) {
            isInputMicrophoneWired = YES;
        }
    }
    for (AVAudioSessionPortDescription* outputPortDescription in [[[AVAudioSession sharedInstance] currentRoute] outputs]) {
        if ([outputPortDescription.portType isEqualToString:AVAudioSessionPortHeadphones]) {
            isOutputWiredHeadphones = YES;
        }
    }
    
    return (isInputMicrophoneWired & isOutputWiredHeadphones);
}

@end


#endif