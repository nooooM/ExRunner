/*
 Copyright (C) 2011-2013 Stig Brautaset. All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:

 * Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.

 * Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.

 * Neither the name of the author nor the names of its contributors
   may be used to endorse or promote products derived from this
   software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

 */


#import "SBJson.h"

@interface JsonCheckerSuite : SenTestCase
@end

@implementation JsonCheckerSuite {
    SBJsonParser *parser;
    NSUInteger count;
}

- (void)setUp {
    count = 0;
    parser = [[SBJsonParser alloc] init];
    parser.maxDepth = 19;
}

- (void)foreachFilePrefixedBy:(NSString*)prefix apply:(void(^)(NSString*))block {
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *rootPath = [[bundle resourcePath] stringByAppendingPathComponent:@"jsonchecker"];
    
    for (NSString *file in [[NSFileManager defaultManager] enumeratorAtPath:rootPath]) {
        if (![file hasPrefix:prefix])
            continue;

        NSString *path = [rootPath stringByAppendingPathComponent:file];
        if ([[NSFileManager defaultManager] isReadableFileAtPath:path]) {
            block(path);
            count++;
        }
    }
}

- (void)testPass {
    [self foreachFilePrefixedBy:@"pass" apply:^(NSString* path) {
        NSError *error = nil;
        NSString *input = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
        STAssertNotNil(input, @"%@ - %@", path, error);

        id object = [parser objectWithString:input];
        STAssertNotNil(object, path);
        STAssertNil(parser.error, path);

    }];
    STAssertEquals(count, (NSUInteger)3, nil);
}

- (void)testFail {
    [self foreachFilePrefixedBy:@"fail" apply:^(NSString* path) {
        NSError *error = nil;
        NSString *input = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
        STAssertNotNil(input, @"%@ - %@", path, error);

        STAssertNil([parser objectWithString:input], @"%@ - %@", input, path);
        STAssertNotNil(parser.error, @"%@ at %@", input, path);
    }];

    STAssertEquals(count, (NSUInteger)33, nil);
}

@end
