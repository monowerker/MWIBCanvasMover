//
//  MWIBCanvasMover.m
//  MWIBCanvasMover
//
//  Created by Daniel Ericsson on 2014-06-30.
//  Copyright (c) 2014 MONOWERKS. Licensed under the MIT license.
//

#import "MWIBCanvasMover.h"
#import <Aspects/Aspects.h>

static MWIBCanvasMover *sharedPlugin;

@interface MWIBCanvasMover()

@property (nonatomic, readwrite, assign) BOOL spaceBarDown;

@end

@implementation MWIBCanvasMover

+ (void)pluginDidLoad:(NSBundle *)plugin {
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[self alloc] initWithBundle:plugin];
        });
    }
}

- (id)initWithBundle:(NSBundle *)plugin {
    if (self = [super init]) {
        id class = NSClassFromString(@"IBCanvasView");
        NSError *error;

        [class aspect_hookSelector:@selector(mouseDown:) withOptions:AspectPositionInstead usingBlock:
         ^(id<AspectInfo> aspectInfo) {
             if (self.spaceBarDown) {
                 return;
             } else {
                 [[aspectInfo originalInvocation] invoke];
             }

         } error:&error];

        [class aspect_hookSelector:@selector(mouseDragged:) withOptions:AspectPositionInstead usingBlock:
         ^(id<AspectInfo> aspectInfo) {
             if (self.spaceBarDown) {
                 id event = [[aspectInfo arguments] lastObject];
                 id scrollView = [[[aspectInfo originalInvocation] target] valueForKey:@"_scrollView"];

                 CGPoint newOrigin = [[scrollView contentView] bounds].origin;
                 newOrigin.x -= [event deltaX];
                 newOrigin.y -= [event deltaY];

                 [[scrollView contentView] scrollToPoint:newOrigin];
             } else {
                 [[aspectInfo originalInvocation] invoke];
             }

         } error:&error];

        [class aspect_hookSelector:@selector(keyDown:) withOptions:AspectPositionInstead usingBlock:
         ^(id<AspectInfo> aspectInfo) {
             id event = [[aspectInfo arguments] lastObject];

             if ([event keyCode] == 49) {
                 self.spaceBarDown = YES;
             } else {
                 [[aspectInfo originalInvocation] invoke];
             }

         } error:&error];

        [class aspect_hookSelector:@selector(keyUp:) withOptions:AspectPositionInstead usingBlock:
         ^(id<AspectInfo> aspectInfo) {
             id event = [[aspectInfo arguments] lastObject];

             if ([event keyCode] == 49) {
                 self.spaceBarDown = NO;
             } else {
                 [[aspectInfo originalInvocation] invoke];
             }
             
         } error:&error];

    }

    return self;
}


@end
