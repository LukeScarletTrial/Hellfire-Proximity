#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>
#import <UIKit/UIKit.h>

@interface HFInputManager : RCTEventEmitter <RCTBridgeModule>
@end

@implementation HFInputManager

RCT_EXPORT_MODULE();

// Listen for hardware changes
- (void)startObserving {
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(handleInputUpdate) 
                                                 name:UISceneWillConnectNotification 
                                               object:nil];
}

RCT_EXPORT_METHOD(checkHardware:(RCTResponseSenderBlock)callback) {
    BOOL hasMouse = NO;
    if (@available(iOS 13.4, *)) {
        // In a real DeX environment, we check for pointer support
        hasMouse = [UIApplication sharedApplication].connectedScenes.anyObject != nil;
    }
    
    callback(@[@(hasMouse)]);
}

// Next-level: Bridge specific keys (Cmd+W to close windows)
// This is done via UIKeyCommand in AppDelegate.mm
@end
