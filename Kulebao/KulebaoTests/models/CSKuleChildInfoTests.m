#import <XCTest/XCTest.h>
#import "CSKuleChildInfo.h"


@interface CSKuleChildInfoTests : XCTestCase

@end

@implementation CSKuleChildInfoTests

- (void)testTrimNickLength
{
    CSKuleChildInfo *info = [[CSKuleChildInfo alloc] init];
    info.nick = @"veryverylongnickname";
    NSAssert([info.nick isEqualToString:@"very"], @"childinfo should truncate nick into 4 characters");
}

- (void)testNoTrimForNickWhichShorterThan4
{
    CSKuleChildInfo *info = [[CSKuleChildInfo alloc] init];
    info.nick = @"2c";
    NSAssert([info.nick isEqualToString:@"2c"], @"childinfo should not modify nick which is shorter than 4 characters");
}

@end