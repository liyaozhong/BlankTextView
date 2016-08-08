//
//  ViewController.m
//  BlankTextView
//
//  Created by joshuali on 16/8/8.
//  Copyright © 2016年 joshuali. All rights reserved.
//

#import "ViewController.h"
#import "BlankTextView.h"
@interface ViewController ()<BlankTextViewDelegate>
{
    BlankTextView * view;
    NSMutableArray * blanks;
    NSString * contentStr;
    NSMutableArray * blankPoints;
    NSLayoutConstraint * blankHeightConstraint;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    view = [BlankTextView new];
    view.blankDelegate = self;
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:view];
    NSMutableArray * constraints = [NSMutableArray new];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:100]];
    blankHeightConstraint = [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:100];
    [constraints addObject:blankHeightConstraint];
    
    [NSLayoutConstraint activateConstraints:constraints];
    
    blanks = [NSMutableArray new];
    contentStr = @"This chapter## will hopefully have helped you understand the various new text Kit features such as dynamic type, font descriptors and letterpress, that you will no-doubt find # #   use for in practically ever app you write. However, Text Kit has so much more to#  # offer! If ##you’d like to learn more about Text Kit, check out our book iOS 7 By Tutorials.";
    NSMutableString * str = [NSMutableString new];
    NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:@" *#(\\s|\\w+)*# *" options:0 error:nil];
    __block NSUInteger index = 0;
    blankPoints = [NSMutableArray new];
    [regex enumerateMatchesInString:contentStr options:0 range:NSMakeRange(0, contentStr.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        NSRange matchRange = [result rangeAtIndex:0];
        [str appendString:[contentStr substringWithRange:NSMakeRange(index, matchRange.location - index)]];
        [str appendString:@" "];
        index = matchRange.location + matchRange.length;
        [blankPoints addObject:[NSNumber numberWithUnsignedInteger:str.length]];
    }];
    [str appendString:[contentStr substringWithRange:NSMakeRange(index, contentStr.length - index)]];
    
    contentStr = str;
    [blanks addObject:[[Blank alloc] initWithIndex:[[blankPoints firstObject] unsignedIntegerValue] width : 200.0f]];
    blankHeightConstraint.constant = [view setInitialText:contentStr withWidth:self.view.bounds.size.width];
    [view setUpBlanks:blanks];
}

- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [blanks removeAllObjects];
    NSUInteger index = [[blankPoints objectAtIndex:(random()%blankPoints.count)] unsignedIntegerValue];
    [blanks addObject:[[Blank alloc] initWithIndex:index width : random()%200]];
    [view setUpBlanks:blanks];
}

- (void) blankTextView:(BlankTextView *)blankView heightChanged:(CGFloat)height
{
    blankHeightConstraint.constant = height;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
