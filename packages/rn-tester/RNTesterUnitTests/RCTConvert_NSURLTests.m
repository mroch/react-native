/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import <XCTest/XCTest.h>

#import <React/RCTConvert.h>
#import <React/RCTUtils.h>

@interface RCTConvert_NSURLTests : XCTestCase

@end

@implementation RCTConvert_NSURLTests

#define TEST_URL(name, _input, _expectedURL)                    \
  -(void)test_##name                                            \
  {                                                             \
    NSURL *result = [RCTConvert NSURL:_input];                  \
    XCTAssertEqualObjects(result.absoluteString, _expectedURL); \
  }

#define TEST_PATH(name, _input, _expectedPath)         \
  -(void)test_##name                                   \
  {                                                    \
    NSURL *result = [RCTConvert NSURL:_input];         \
    XCTAssertEqualObjects(result.path, _expectedPath); \
  }

#define TEST_BUNDLE_PATH(name, _input, _expectedPath) \
  TEST_PATH(name, _input, [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:_expectedPath])

// Basic tests
TEST_URL(basic, @"http://example.com", @"http://example.com")
TEST_URL(null, (id)kCFNull, nil)

// Resource files
TEST_PATH(fileURL, @"file:///blah/hello.jsbundle", @"/blah/hello.jsbundle")
TEST_BUNDLE_PATH(filePath, @"blah/hello.jsbundle", @"blah/hello.jsbundle")
TEST_BUNDLE_PATH(filePathWithSpaces, @"blah blah/hello.jsbundle", @"blah blah/hello.jsbundle")
TEST_BUNDLE_PATH(filePathWithEncodedSpaces, @"blah%20blah/hello.jsbundle", @"blah blah/hello.jsbundle")
TEST_BUNDLE_PATH(imageAt2XPath, @"images/foo@2x.jpg", @"images/foo@2x.jpg")
TEST_BUNDLE_PATH(imageFile, @"foo.jpg", @"foo.jpg")

TEST_BUNDLE_PATH(imageFileWithSemicolon, @"folder/foo:bar-baz.jpg", @"folder/foo:bar-baz.jpg")
TEST_URL(filePathWithSemicolon, @"/folder/foo:bar-baz.jpg", @"file:///folder/foo:bar-baz.jpg")

// User documents
TEST_PATH(
    documentsFolder,
    @"~/Documents",
    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject])

// Remote files
TEST_URL(fullURL, @"http://example.com/blah/hello.jsbundle", @"http://example.com/blah/hello.jsbundle")
TEST_URL(urlWithSpaces, @"http://example.com/blah blah/foo", @"http://example.com/blah%20blah/foo")
TEST_URL(urlWithEncodedSpaces, @"http://example.com/blah%20blah/foo", @"http://example.com/blah%20blah/foo")
TEST_URL(imageURL, @"http://example.com/foo@2x.jpg", @"http://example.com/foo@2x.jpg")
TEST_URL(imageURLWithSpaces, @"http://example.com/blah foo@2x.jpg", @"http://example.com/blah%20foo@2x.jpg")

// Unicode
TEST_URL(
    unicodeURL,
    @"https://ru.wikipedia.org/wiki/\u0417\u0430\u0433\u043B\u0430\u0432"
     "\u043D\u0430\u044F_\u0441\u0442\u0440\u0430\u043D\u0438\u0446\u0430",
    @"https://ru.wikipedia.org/wiki/%D0%97%D0%B0%D0%B3%D0%BB%D0%B0%D0%B2"
     "%D0%BD%D0%B0%D1%8F_%D1%81%D1%82%D1%80%D0%B0%D0%BD%D0%B8%D1%86%D0%B0")

// Data URLs
- (void)testDataURL
{
  NSURL *expectedURL = RCTDataURL(@"text/plain", [@"abcde" dataUsingEncoding:NSUTF8StringEncoding]);
  NSURL *testURL = [NSURL URLWithString:@"data:text/plain;base64,YWJjZGU="];
  XCTAssertEqualObjects([testURL absoluteString], [expectedURL absoluteString]);
}

// Escaping edge cases
TEST_URL(
    urlWithMultipleHashes,
    @"https://example.com/#/abc/#test:example.com",
    @"https://example.com/#/abc/%23test:example.com")
TEST_URL(urlWithEqualsInQuery, @"https://example.com/abc.def?ghi=1234", @"https://example.com/abc.def?ghi=1234")
TEST_URL(
    urlWithEscapedCharacterInFragment,
    @"https://example.com/abc/def.ghi#jkl-mno%27p-qrs",
    @"https://example.com/abc/def.ghi#jkl-mno%27p-qrs")
TEST_URL(
    urlWithLongQuery,
    @"https://example.com/abc?q=def+ghi+jkl&mno=p-q-r-s&tuv=wxy&z_=abc&abc=5",
    @"https://example.com/abc?q=def+ghi+jkl&mno=p-q-r-s&tuv=wxy&z_=abc&abc=5")
TEST_URL(
    urlWithEscapedCharacterInPathFragment,
    @"https://example.com/#/abc/%23def%3Aghi.org",
    @"https://example.com/#/abc/%23def%3Aghi.org")
TEST_URL(
    urlWithEscapedCharacterInQuery,
    @"https://site.com/script?foo=bar#this_ref",
    @"https://site.com/script?foo=bar#this_ref")
TEST_URL(
    urlWithUnescapedJson,
    @"https://example.com/?{\"key\":\"value\"}",
    @"https://example.com/?%7B%22key%22:%22value%22%7D")
TEST_URL(
    urlWithPartiallyEscapedData,
    @"https://example.com/?{%22key%22:%22value%22}",
    @"https://example.com/?%7B%22key%22:%22value%22%7D")
// NOTE: This is illegal per RFC 3986, but earlier URL specs allowed it
TEST_URL(urlWithSquareBracketInPath, @"http://www.foo.com/file[.html", @"http://www.foo.com/file%5B.html")

@end
