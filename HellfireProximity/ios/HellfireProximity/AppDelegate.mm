#import "AppDelegate.h"
#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>
#import <AVFoundation/AVFoundation.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.moduleName = @"HellfireProximity";
  self.initialProps = @{};

  // --- AUDIO SESSION CONFIG (Optimized for Games) ---
  AVAudioSession *session = [AVAudioSession sharedInstance];
  // PlayAndRecord allows for game chat, DefaultToSpeaker ensures it doesn't just play in the earpiece
  [session setCategory:AVAudioSessionCategoryPlayAndRecord 
           withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker | AVAudioSessionCategoryOptionAllowBluetooth 
                 error:nil];
  [session setActive:YES error:nil];

  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge
{
  return [self getBundleURL];
}

- (NSURL *)getBundleURL
{
#if DEBUG
  return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index"];
#else
  return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
#endif
}

// --- HELLFIRE HARDWARE INTERFACE ---

// Listen for Hardware Keyboard Shortcuts (iPad Magic Keyboard / Bluetooth)
- (NSArray<UIKeyCommand *> *)keyCommands {
  return @[
    // Cmd + W: Close Active Window
    [UIKeyCommand keyCommandWithInput:@"w" modifierFlags:UIKeyModifierCommand action:@selector(hw_closeWindow)],
    // Cmd + N: Global "New" Command
    [UIKeyCommand keyCommandWithInput:@"n" modifierFlags:UIKeyModifierCommand action:@selector(hw_newTerminal)]
  ];
}

- (void)hw_closeWindow {
  dispatch_async(dispatch_get_main_queue(), ^{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    // Look for our custom windows (CornerRadius 14.0 from our latest HFWindowManager)
    for (UIView *view in [keyWindow.subviews reverseObjectEnumerator]) {
      if (view.layer.cornerRadius == 14.0) {
        [view removeFromSuperview];
        break; 
      }
    }
  });
}

- (void)hw_newTerminal {
  // This sends a signal that React Native can listen to
  [[NSNotificationCenter defaultCenter] postNotificationName:@"HellfireExternalCommand" 
                                                      object:nil 
                                                    userInfo:@{@"command": @"launch_terminal"}];
}

@end
