//
//  JWAsync.m
//  AsyncTools
//
//  Created by Jason Whitehorn on 6/6/14.
//  Copyright (c) 2014-2018, [Jason Whitehorn](http://jason.whitehorn.us)
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
//  * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "JWAsync.h"

@implementation JWAsync

static dispatch_queue_t queue;

+ (void) initialize {
    queue = dispatch_queue_create("JWAsync", DISPATCH_QUEUE_CONCURRENT);
}

+ (void) forever:(void (^)(ContinuationBlock))block onError:(ContinuationBlock)exitBlock {
    dispatch_async(queue, ^{
        block(^(NSError *err){
            dispatch_async(queue, ^{
                if(err){
                    exitBlock(err); return;
                }
                [JWAsync forever:block onError:exitBlock];
            });
        });
    });
}

+ (void) whilst:(TruthBlock)truthBlock performAction:(void (^)(ContinuationBlock))block onCompletion:(ContinuationBlock)exitBlock {
    dispatch_async(queue, ^{
        truthBlock( ^(bool keepGoing){
            dispatch_async(queue, ^{
                if(!keepGoing){
                    exitBlock(nil); return;
                }
                block(^(NSError *err){
                    dispatch_async(queue, ^{
                        if(err){
                            exitBlock(err); return;
                        }
                        [JWAsync whilst:truthBlock performAction:block onCompletion:exitBlock];
                    });
                });
            });
        });
    });
}

+ (void) map:(NSArray *) array transform:(TransformationBlock)map onCompletion:(CallbackBlock)callback {
    NSMutableArray *result = [NSMutableArray new];
    [self each:array onEach:^(id thing, ContinuationBlock next){

    } onCompletion:^(NSError *err){
        callback(err, result);
    }];
}

+ (void) reduce:(NSArray *)array startingState:(id)startingState transform:(ReductionBlock)reduceBlock onCompletion:(CallbackBlock)exitBlock {
    __block id currentState = startingState;
    [self each:array onEach:^(id item, ContinuationBlock next){
        reduceBlock(currentState, item, ^(NSError *err, id newState){
            currentState = newState;
            next(err);
        });
    } onCompletion:^(NSError *err){
        exitBlock(err, currentState);
    }];
}

+ (void) series:(NSArray *) blocks onCompletion:(ContinuationBlock)exitBlock {
    [self each:blocks onEach:^(void (^ block)(ContinuationBlock), ContinuationBlock next){
        block(next);
    } onCompletion:exitBlock];
}

+ (void) each:(NSArray *) array onEach:(ItteratorBlock)itterator onCompletion:(ContinuationBlock)exitBlock {
    dispatch_async(queue, ^{
        if(!array || [array count] == 0){
            exitBlock(nil); return;
        }
        NSMutableArray *arr = [array mutableCopy];
        id item = [arr objectAtIndex:0];
        [arr removeObjectAtIndex:0];

        itterator(item, ^(NSError *err){
            dispatch_async(queue, ^{
                if(err){
                    exitBlock(err); return;
                }
                [JWAsync each:arr onEach:itterator onCompletion:exitBlock];
            });
        });
    });
}

@end
