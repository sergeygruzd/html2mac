// A tiny native macOS shell: one window with a WKWebView showing the bundled index.html.
// Window title and size come from Info.plist keys: WebShellTitle, WebShellWidth, WebShellHeight.
// Build: clang -fobjc-arc -O2 WebShell.m -o WebShell -framework Cocoa -framework WebKit
#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, WKUIDelegate>
@property (strong) NSWindow *window;
@property (strong) WKWebView *webView;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)note {
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *title = info[@"WebShellTitle"] ?: @"App";
    double w = [info[@"WebShellWidth"] doubleValue] ?: 1100;
    double h = [info[@"WebShellHeight"] doubleValue] ?: 760;

    [self buildMenu:title];

    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.websiteDataStore = [WKWebsiteDataStore defaultDataStore];   // saved data persists between launches
    config.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;
    [config.preferences setValue:@YES forKey:@"allowFileAccessFromFileURLs"];

    self.webView = [[WKWebView alloc] initWithFrame:NSZeroRect configuration:config];
    self.webView.UIDelegate = self;
    [self.webView setValue:@NO forKey:@"drawsBackground"];
    if (@available(macOS 13.3, *)) { self.webView.inspectable = YES; }

    self.window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, w, h)
        styleMask:(NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable)
        backing:NSBackingStoreBuffered defer:NO];
    self.window.title = title;
    self.window.minSize = NSMakeSize(380, 560);
    self.window.contentView = self.webView;
    [self.window center];
    [self.window setFrameAutosaveName:[title stringByAppendingString:@"MainWindow"]];
    [self.window makeKeyAndOrderFront:nil];
    [self.window makeFirstResponder:self.webView];   // keyboard input goes to the page

    NSURL *res = [[NSBundle mainBundle] resourceURL];
    NSURL *page = [res URLByAppendingPathComponent:@"index.html"];
    [self.webView loadFileURL:page allowingReadAccessToURL:res];
    [NSApp activateIgnoringOtherApps:YES];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender { return YES; }

// target=_blank / external links open in the default browser
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration
   forNavigationAction:(WKNavigationAction *)action windowFeatures:(WKWindowFeatures *)features {
    if (action.request.URL) [[NSWorkspace sharedWorkspace] openURL:action.request.URL];
    return nil;
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message
 initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))done {
    NSAlert *a = [[NSAlert alloc] init]; a.messageText = message; [a runModal]; done();
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message
 initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))done {
    NSAlert *a = [[NSAlert alloc] init]; a.messageText = message;
    [a addButtonWithTitle:@"OK"]; [a addButtonWithTitle:@"Cancel"];
    done([a runModal] == NSAlertFirstButtonReturn);
}

- (void)reloadPage:(id)sender { [self.webView reload]; }
- (void)toggleFull:(id)sender { [self.window toggleFullScreen:nil]; }

- (void)buildMenu:(NSString *)name {
    NSMenu *main = [[NSMenu alloc] init];

    NSMenuItem *appItem = [[NSMenuItem alloc] init]; [main addItem:appItem];
    NSMenu *appMenu = [[NSMenu alloc] init];
    [appMenu addItemWithTitle:[@"About " stringByAppendingString:name] action:@selector(orderFrontStandardAboutPanel:) keyEquivalent:@""];
    [appMenu addItem:[NSMenuItem separatorItem]];
    [appMenu addItemWithTitle:[@"Hide " stringByAppendingString:name] action:@selector(hide:) keyEquivalent:@"h"];
    [appMenu addItemWithTitle:[@"Quit " stringByAppendingString:name] action:@selector(terminate:) keyEquivalent:@"q"];
    appItem.submenu = appMenu;

    NSMenuItem *editItem = [[NSMenuItem alloc] init]; [main addItem:editItem];
    NSMenu *edit = [[NSMenu alloc] initWithTitle:@"Edit"];
    [edit addItemWithTitle:@"Undo" action:@selector(undo:) keyEquivalent:@"z"];
    [edit addItemWithTitle:@"Redo" action:@selector(redo:) keyEquivalent:@"Z"];
    [edit addItem:[NSMenuItem separatorItem]];
    [edit addItemWithTitle:@"Cut" action:@selector(cut:) keyEquivalent:@"x"];
    [edit addItemWithTitle:@"Copy" action:@selector(copy:) keyEquivalent:@"c"];
    [edit addItemWithTitle:@"Paste" action:@selector(paste:) keyEquivalent:@"v"];
    [edit addItemWithTitle:@"Select All" action:@selector(selectAll:) keyEquivalent:@"a"];
    editItem.submenu = edit;

    NSMenuItem *viewItem = [[NSMenuItem alloc] init]; [main addItem:viewItem];
    NSMenu *view = [[NSMenu alloc] initWithTitle:@"View"];
    [[view addItemWithTitle:@"Reload" action:@selector(reloadPage:) keyEquivalent:@"r"] setTarget:self];
    NSMenuItem *fs = [view addItemWithTitle:@"Enter Full Screen" action:@selector(toggleFull:) keyEquivalent:@"f"];
    fs.keyEquivalentModifierMask = NSEventModifierFlagCommand | NSEventModifierFlagControl; fs.target = self;
    viewItem.submenu = view;

    NSMenuItem *winItem = [[NSMenuItem alloc] init]; [main addItem:winItem];
    NSMenu *win = [[NSMenu alloc] initWithTitle:@"Window"];
    [win addItemWithTitle:@"Minimize" action:@selector(performMiniaturize:) keyEquivalent:@"m"];
    [win addItemWithTitle:@"Close" action:@selector(performClose:) keyEquivalent:@"w"];
    winItem.submenu = win;

    NSApp.mainMenu = main;
}
@end

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        NSApplication *app = [NSApplication sharedApplication];
        AppDelegate *d = [[AppDelegate alloc] init];
        app.delegate = d;
        [app setActivationPolicy:NSApplicationActivationPolicyRegular];
        [app run];
    }
    return 0;
}
