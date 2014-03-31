#import <XCTest/XCTest.h>
#import "CSKuleChildInfo.h"


@interface CSKuleChildInfoTests : XCTestCase

@end

@implementation CSKuleChildInfoTests

- (void)testTrimNickLength
{
    CSKuleChildInfo *info = [[CSKuleChildInfo alloc] init];
    info.nick = @"很长很长的名字";
    info.birthday = @"2014-01-01";
    NSAssert([[info.displayNick substringToIndex:5] isEqualToString:@"很长很长 "], @"childinfo should truncate nick into 4 characters");
    NSAssert([self patternMatched:info.displayNick], @"childinfo nick display should match the pattern 'name yy岁xx个月'");
}

- (void)testNoTrimForNickWhichShorterThan4
{
    CSKuleChildInfo *info = [[CSKuleChildInfo alloc] init];
    info.nick = @"两个字";
    info.birthday = @"2014-01-01";
    NSAssert([[info.displayNick substringToIndex:4] isEqualToString:@"两个字 "], @"childinfo should not modify nick which is shorter than 4 characters");
    NSAssert([self patternMatched:info.displayNick], @"childinfo nick display should match the pattern 'name yy岁xx个月'");
}

- (BOOL)patternMatched:(NSString*)output {
    NSString *pattern = @"^\\w{0,4}\\s+\\d+岁\\d+个月$";
    NSRange   searchedRange = NSMakeRange(0, [output length]);
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern: pattern options:0 error:nil];
    NSArray* matches = [regex matchesInString:output options:0 range: searchedRange];
    return [matches count] > 0;
}

@end