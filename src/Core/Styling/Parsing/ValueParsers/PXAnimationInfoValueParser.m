//
//  PXAnimationInfoValueParser.m
//  PixateAnimationModule
//
//  Created by Kevin Lindsey on 12/10/13.
//  Copyright (c) 2013 Pixate, Inc. All rights reserved.
//

#import "PXAnimationInfoValueParser.h"
#import "PXAnimationInfo.h"
#import "PXStylesheetTokenType.h"
#import "PXValueParserManager.h"

#import "PXAnimationDirectionValueParser.h"
#import "PXAnimationFillModeValueParser.h"
#import "PXAnimationPlayStateValueParser.h"
#import "PXAnimationTimingFunctionValueParser.h"

@implementation PXAnimationInfoValueParser

// NOTE: we assume we'll be able to parse something, so no override of canParse here

- (id)parse
{
    static NSSet *KEYWORDS;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        NSMutableSet *set = [[NSMutableSet alloc] init];

        [set addObjectsFromArray:[ANIMATION_DIRECTION_MAP allKeys]];
        [set addObjectsFromArray:[ANIMATION_FILL_MODE_MAP allKeys]];
        [set addObjectsFromArray:[ANIMATION_PLAY_STATE_MAP allKeys]];
        [set addObjectsFromArray:[ANIMATION_TIMING_FUNCTION_MAP allKeys]];

        KEYWORDS = [NSSet setWithSet:set];
    });

    // grab dependent parsers
    PXValueParserManager *manager = [PXValueParserManager sharedInstance];
    id<PXValueParserProtocol> secondsParser = [manager parserForName:kPXValueParserSeconds withLexer:self.lexer];
    id<PXValueParserProtocol> timingFunctionParser = [manager parserForName:kPXValueParserAnimationTimingFunction withLexer:self.lexer];
    id<PXValueParserProtocol> directionParser = [manager parserForName:kPXValueParserAnimationDirection withLexer:self.lexer];
    id<PXValueParserProtocol> fillModeParser = [manager parserForName:kPXValueParserAnimationFillMode withLexer:self.lexer];
    id<PXValueParserProtocol> playStateParser = [manager parserForName:kPXValueParserAnimationPlayState withLexer:self.lexer];

    // create empty result value
    PXAnimationInfo *info = [[PXAnimationInfo alloc] init];

    // parse values and add to result

    // name
    if ([self isType:PXSS_IDENTIFIER] && ![KEYWORDS containsObject:self.currentLexeme.value])
    {
        info.animationName = self.currentLexeme.value;
        [self advance];
    }

    // duration
    if ([secondsParser canParse])
    {
        NSNumber *seconds = [secondsParser parse];

        info.animationDuration = [seconds floatValue];
    }

    // timing function
    if ([timingFunctionParser canParse])
    {
        NSNumber *timing = [timingFunctionParser parse];

        info.animationTimingFunction = (int) [timing integerValue];
    }

    // delay
    if ([secondsParser canParse])
    {
        NSNumber *seconds = [secondsParser parse];

        info.animationDelay = [seconds floatValue];
    }

    // iteration count
    if ([self isType:PXSS_NUMBER])
    {
        NSNumber *number = self.currentLexeme.value;

        info.animationIterationCount = (int) number.floatValue;

        [self advance];
    }

    // animation direction
    if ([directionParser canParse])
    {
        NSNumber *direction = [directionParser parse];

        info.animationDirection = (int) [direction integerValue];
    }

    // fill mode
    if ([fillModeParser canParse])
    {
        NSNumber *fill = [fillModeParser parse];

        info.animationFillMode = (int) [fill integerValue];
    }

    // play state
    if ([playStateParser canParse])
    {
        NSNumber *playState = [playStateParser parse];

        info.animationPlayState = (int) [playState integerValue];
    }
    
    return info;
}

@end
