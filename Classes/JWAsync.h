//
//  JWAsync.h
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

#import <Foundation/Foundation.h>

typedef void (^ CallbackBlock)(NSError *, id);
typedef void (^ ContinuationBlock)(NSError *);
typedef void (^ ItteratorBlock)(id, ContinuationBlock);
typedef void (^ ReductionBlock)(id, id, CallbackBlock);
typedef void (^ TransformationBlock)(id, CallbackBlock);
typedef void (^ TruthBlock)(void (^)(bool));
typedef void (^ EmptyBlock)(void);
#define CompletionBlock ContinuationBlock


extern void UI_THREAD(EmptyBlock block);

@interface JWAsync : NSObject

+ (void) forever:(void (^)(ContinuationBlock))block onError:(ContinuationBlock)exitBlock;
+ (void) whilst:(TruthBlock)truthBlock performAction:(void (^)(ContinuationBlock))block onCompletion:(ContinuationBlock)exitBlock;
+ (void) map:(NSArray *) array transform:(TransformationBlock)map onCompletion:(CallbackBlock)callback;
+ (void) reduce:(NSArray *)array startingState:(id)startingState transform:(ReductionBlock)reduceBlock onCompletion:(CallbackBlock)exitBlock;
+ (void) series:(NSArray *) blocks onCompletion:(ContinuationBlock)exitBlock;
+ (void) each:(NSArray *) array onEach:(ItteratorBlock)itterator onCompletion:(ContinuationBlock)exitBlock;

@end
