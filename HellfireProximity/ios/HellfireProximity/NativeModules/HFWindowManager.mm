#import "HFWindowManager.h"
#import <React/RCTLog.h>

@implementation HFWindowManager

RCT_EXPORT_MODULE(HellfireWindowManager);

// Ensure all UI operations happen on the Main Thread
- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

RCT_EXPORT_METHOD(createWindow:(NSString *)title url:(NSString *)urlStr) {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
        
        // Instead of just [webView loadRequest:request], use this to allow file access:
        NSURL *folderURL = [url URLByDeletingLastPathComponent]; // The directory containing the game
        [webView loadFileURL:url allowingReadAccessToURL:folderURL];


        // 1. SETUP JIT-OPTIMIZED WEBVIEW CONFIG
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        
        // Critical for WASM/Emscripten performance (Half-Life Engine)
        if ([config.preferences respondsToSelector:NSSelectorFromString(@"setJavaScriptCanOpenWindowsAutomatically:")]) {
            [config.preferences setValue:@YES forKey:@"javaScriptCanOpenWindowsAutomatically"];
        }
        
        // Allow inline media playback (Good for game audio)
        config.allowsInlineMediaPlayback = YES;
        config.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;

        // 2. MAIN WINDOW CONTAINER
        UIView *windowView = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 650, 450)];
        windowView.backgroundColor = [UIColor blackColor];
        windowView.layer.cornerRadius = 14.0;
        
        // macOS/DeX Depth Shadow
        windowView.layer.shadowColor = [UIColor blackColor].CGColor;
        windowView.layer.shadowOpacity = 0.6;
        windowView.layer.shadowOffset = CGSizeMake(0, 15);
        windowView.layer.shadowRadius = 25;
        windowView.layer.masksToBounds = NO;

        // 3. TITLE BAR (The Drag Handle)
        UIView *titleBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 650, 38)];
        titleBar.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.12];
        
        // Round only the top corners of the title bar
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:titleBar.bounds
                                                       byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
                                                             cornerRadii:CGSizeMake(14.0, 14.0)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.path = maskPath.CGPath;
        titleBar.layer.mask = maskLayer;

        [self addTrafficLights:titleBar];

        // 4. THE VIEWPORT (The "Linux" Engine Layer)
        WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 38, 650, 412) configuration:config];
        webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        webView.scrollView.bounces = NO; 
        webView.backgroundColor = [UIColor clearColor];
        webView.opaque = NO;
        
        // Load the URL (Half-Life WASM, Browser, or Local File)
        NSURL *url = [NSURL URLWithString:urlStr];
        [webView loadRequest:[NSURLRequest requestWithURL:url]];

        // 5. RESIZE HANDLE (Bottom Right Corner)
        UIView *resizeHandle = [[UIView alloc] initWithFrame:CGRectMake(630, 430, 20, 20)];
        resizeHandle.backgroundColor = [UIColor clearColor];
        resizeHandle.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;

        // 6. GESTURE REGISTRATION
        // Dragging
        UIPanGestureRecognizer *dragGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDrag:)];
        [titleBar addGestureRecognizer:dragGesture];

        // Resizing
        UIPanGestureRecognizer *resizeGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleResize:)];
        [resizeHandle addGestureRecognizer:resizeGesture];

        // Focus (Bring to front)
        UITapGestureRecognizer *focusTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFocus:)];
        [windowView addGestureRecognizer:focusTap];

        // ASSEMBLY
        [windowView addSubview:titleBar];
        [windowView addSubview:webView];
        [windowView addSubview:resizeHandle];
        [keyWindow addSubview:windowView];
        
        RCTLogInfo(@"Hellfire: Window '%@' spawned successfully.", title);
    });
}

#pragma mark - Gesture Handlers

- (void)handleDrag:(UIPanGestureRecognizer *)gesture {
    UIView *titleBar = gesture.view;
    UIView *window = titleBar.superview;
    CGPoint translation = [gesture translationInView:window.superview];
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [window.superview bringSubviewToFront:window];
    }
    
    if (gesture.state == UIGestureRecognizerStateChanged) {
        window.center = CGPointMake(window.center.x + translation.x, window.center.y + translation.y);
        [gesture setTranslation:CGPointZero inView:window.superview];
    }
}

- (void)handleResize:(UIPanGestureRecognizer *)gesture {
    UIView *handle = gesture.view;
    UIView *window = handle.superview;
    CGPoint translation = [gesture translationInView:window.superview];
    
    if (gesture.state == UIGestureRecognizerStateChanged) {
        CGRect newFrame = window.frame;
        newFrame.size.width += translation.x;
        newFrame.size.height += translation.y;
        
        // Minimum window size constraints
        if (newFrame.size.width > 300 && newFrame.size.height > 200) {
            window.frame = newFrame;
        }
        [gesture setTranslation:CGPointZero inView:window.superview];
    }
}

- (void)handleFocus:(UITapGestureRecognizer *)gesture {
    [gesture.view.superview bringSubviewToFront:gesture.view];
}

#pragma mark - Helpers

- (void)addTrafficLights:(UIView *)bar {
    NSArray *colors = @[[UIColor systemRedColor], [UIColor systemYellowColor], [UIColor systemGreenColor]];
    for (int i = 0; i < 3; i++) {
        UIView *dot = [[UIView alloc] initWithFrame:CGRectMake(14 + (i * 22), 12, 12, 12)];
        dot.backgroundColor = colors[i];
        dot.layer.cornerRadius = 6;
        
        // Add Close logic to the red button
        if (i == 0) {
            UITapGestureRecognizer *closeTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeWindow:)];
            [dot addGestureRecognizer:closeTap];
            dot.userInteractionEnabled = YES;
        }
        
        [bar addSubview:dot];
    }
}

- (void)closeWindow:(UITapGestureRecognizer *)gesture {
    [gesture.view.superview.superview removeFromSuperview];
}

@end
