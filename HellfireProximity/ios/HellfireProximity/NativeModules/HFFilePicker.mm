#import <React/RCTBridgeModule.h>
#import <UIKit/UIKit.h>

@interface HFFilePicker : NSObject <RCTBridgeModule, UIDocumentPickerDelegate>
@end

@implementation HFFilePicker

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(pickLinuxFile:(RCTResponseSenderBlock)callback) {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.item"] inMode:UIDocumentPickerModeImport];
        picker.delegate = self;
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:picker animated:YES completion:nil];
    });
}

// You would add the delegate method here to copy the file to the app's Documents folder
@end
