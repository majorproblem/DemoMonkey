/*
 Write a .demoMonkey fixture in the ORIGINAL file format, where the archive root
 is a bare array of Steps with no document settings.  Used to check that
 -readFromData:ofType:error: still opens pre-existing documents and seeds them
 from the defaultLineEnding preference.

     genlegacy <path>
 */
#import <Cocoa/Cocoa.h>
#import "Step.h"

int main(int argc, const char **argv) { @autoreleasepool {

    if (argc < 2) { fprintf(stderr, "usage: %s <path>\n", argv[0]); return 2; }

    Step *step = [[Step alloc] init];
    step.tableSummary = @"Legacy step";
    step.tooltip = @"legacy";
    step.body = @"legacy one\nlegacy two";

    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[NSArray arrayWithObject:step]];
    BOOL ok = [data writeToFile:[NSString stringWithUTF8String:argv[1]] atomically:YES];
    printf("%s: %s (legacy bare-array root)\n", argv[1], ok ? "OK" : "FAILED");
    return ok ? 0 : 1;
} }
