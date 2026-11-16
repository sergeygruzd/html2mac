// Draws a 1024x1024 macOS-style app icon PNG.
// Build: clang -fobjc-arc make_icon.m -o make_icon -framework Cocoa
// Usage: ./make_icon <out.png> <house|AnyName>   ("house" draws a house; anything else draws its first letter)
#import <Cocoa/Cocoa.h>

static NSColor *rgb(double r, double g, double b) { return [NSColor colorWithSRGBRed:r green:g blue:b alpha:1]; }

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        if (argc < 3) return 1;
        NSString *out = @(argv[1]); NSString *style = @(argv[2]);
        CGFloat S = 1024;
        NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL pixelsWide:S pixelsHigh:S
            bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES isPlanar:NO colorSpaceName:NSCalibratedRGBColorSpace bytesPerRow:0 bitsPerPixel:0];
        [NSGraphicsContext saveGraphicsState];
        [NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithBitmapImageRep:rep]];

        NSRect rect = NSMakeRect(100, 100, S - 200, S - 200);
        NSBezierPath *shape = [NSBezierPath bezierPathWithRoundedRect:rect xRadius:185 yRadius:185];

        if ([style isEqualToString:@"house"]) {
            [[[NSGradient alloc] initWithStartingColor:rgb(0.10, 0.62, 0.56) endingColor:rgb(0.05, 0.36, 0.44)] drawInBezierPath:shape angle:-70];
            [[NSColor whiteColor] setFill];
            NSBezierPath *roof = [NSBezierPath bezierPath];
            [roof moveToPoint:NSMakePoint(512, 770)]; [roof lineToPoint:NSMakePoint(250, 545)]; [roof lineToPoint:NSMakePoint(774, 545)]; [roof closePath];
            [roof fill];
            [[NSBezierPath bezierPathWithRoundedRect:NSMakeRect(305, 270, 414, 300) xRadius:26 yRadius:26] fill];
            [rgb(0.05, 0.36, 0.44) setFill];
            [[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(372, 410, 90, 90)] fill];
            [[NSBezierPath bezierPathWithOvalInRect:NSMakeRect(562, 410, 90, 90)] fill];
            [[NSBezierPath bezierPathWithRoundedRect:NSMakeRect(352, 270, 130, 120) xRadius:58 yRadius:58] fill];
            [[NSBezierPath bezierPathWithRoundedRect:NSMakeRect(542, 270, 130, 120) xRadius:58 yRadius:58] fill];
        } else {
            // Generic icon: a gradient tile with the app's first letter.
            [[[NSGradient alloc] initWithStartingColor:rgb(0.20, 0.32, 0.62) endingColor:rgb(0.10, 0.14, 0.32)] drawInBezierPath:shape angle:-70];
            NSString *letter = [[style substringToIndex:1] uppercaseString];
            NSDictionary *attrs = @{NSFontAttributeName: [NSFont systemFontOfSize:520 weight:NSFontWeightBold],
                                    NSForegroundColorAttributeName: [NSColor whiteColor]};
            NSSize sz = [letter sizeWithAttributes:attrs];
            [letter drawAtPoint:NSMakePoint((S - sz.width) / 2, (S - sz.height) / 2) withAttributes:attrs];
        }
        [NSGraphicsContext restoreGraphicsState];
        NSData *png = [rep representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
        return [png writeToFile:out atomically:YES] ? 0 : 2;
    }
}
