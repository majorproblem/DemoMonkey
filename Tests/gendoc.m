/*
 Write a .demoMonkey fixture in the current file format: the archive root is a
 dictionary of Steps plus the document's LineEnding.

     gendoc <path> [lineEnding]      0 = CR (default), 1 = LF, 2 = CRLF
 */
#import <Cocoa/Cocoa.h>
#import "Step.h"

static Step *MakeStep(NSString *summary, NSString *body) {
    Step *step = [[Step alloc] init];
    step.tableSummary = summary;
    step.body = body;
    step.tooltip = summary;
    return step;
}

int main(int argc, const char **argv) { @autoreleasepool {

    if (argc < 2) { fprintf(stderr, "usage: %s <path> [lineEnding]\n", argv[0]); return 2; }
    NSInteger lineEnding = (argc > 2) ? atoi(argv[2]) : 0;

    NSMutableArray *steps = [NSMutableArray array];
    [steps addObject:MakeStep(@"Three commands", @"show system\nshow users\nshow time")];
    [steps addObject:MakeStep(@"Single line",    @"directory [000000]")];
    // Source already has CRLF: must not come back out as CR CR LF.
    [steps addObject:MakeStep(@"CRLF source",    @"set default sys$login\r\ndirectory")];

    NSDictionary *root = [NSDictionary dictionaryWithObjectsAndKeys:
                          steps, @"Steps",
                          [NSNumber numberWithInteger:lineEnding], @"LineEnding",
                          nil];
    NSString *path = [NSString stringWithUTF8String:argv[1]];
    BOOL ok = [[NSKeyedArchiver archivedDataWithRootObject:root] writeToFile:path atomically:YES];
    printf("%s: %s (%lu steps, lineEnding=%ld)\n", argv[1], ok ? "OK" : "FAILED",
           (unsigned long)[steps count], (long)lineEnding);
    return ok ? 0 : 1;
} }
