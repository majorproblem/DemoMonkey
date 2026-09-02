/*
 Invoke one of DemoMonkey's Services by name and show what came back, with line
 endings made visible.  Lets the Services be exercised without iTerm.

     svc "DemoMonkey/Get Next Line"
     svc "DemoMonkey/Create New Step" "text to capture"

 With input text the pasteboard is seeded and used as the Service's argument;
 without it the pasteboard is left deliberately empty, so anything read back is
 known to have come from the application rather than from this harness.
 */
#import <Cocoa/Cocoa.h>

int main(int argc, const char **argv) { @autoreleasepool {

    if (argc < 2) {
        fprintf(stderr, "usage: %s \"<service name>\" [input text]\n", argv[0]);
        return 2;
    }

    [NSApplication sharedApplication];

    NSString *service = [NSString stringWithUTF8String:argv[1]];
    NSPasteboard *pboard = [NSPasteboard pasteboardWithUniqueName];
    [pboard clearContents];

    if (argc > 2) {
        [pboard declareTypes:[NSArray arrayWithObject:NSPasteboardTypeString] owner:nil];
        [pboard setString:[NSString stringWithUTF8String:argv[2]] forType:NSPasteboardTypeString];
    }

    BOOL performed = NSPerformService(service, pboard);
    NSString *returned = (argc > 2) ? nil : [pboard stringForType:NSPasteboardTypeString];

    printf("%-30s %s", [service UTF8String], performed ? "OK" : "FAILED");
    if (returned != nil) {
        NSMutableString *visible = [NSMutableString string];
        for (NSUInteger i = 0; i < [returned length]; i++) {
            unichar c = [returned characterAtIndex:i];
            if (c == '\r')      [visible appendString:@"<CR>"];
            else if (c == '\n') [visible appendString:@"<LF>"];
            else                [visible appendFormat:@"%C", c];
        }
        printf("  | %s", [visible UTF8String]);
    }
    printf("\n");
    return performed ? 0 : 1;
} }
