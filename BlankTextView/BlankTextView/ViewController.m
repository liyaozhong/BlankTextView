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
    NSArray * selections;
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
    
    UIView * answersView = [UIView new];
    answersView.backgroundColor = [UIColor brownColor];
    answersView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:answersView];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:answersView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:answersView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:answersView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
    NSLayoutConstraint * answersHeightConstraint = [NSLayoutConstraint constraintWithItem:answersView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:0];
    [constraints addObject:answersHeightConstraint];
    
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
    blankHeightConstraint.constant = [view setInitialText:contentStr withWidth:self.view.bounds.size.width];
    [view setUpBlanks:blanks];
    
    
    //layout selection views
    selections = @[@"1234567890",@"0987654321",@"qwer",@"asdfghjkl", @"zxcvbnmlkjhgfdsaqwertyuiop-zxcvbnmlkjhgfdsaqwertyuiop-zxcvbnmlkjhgfdsaqwertyuiop-zxcvbnmlkjhgfdsaqwertyuiop", @"zxcvbnmlkjhgfdsaqwertyuiop"];
    CGFloat horizontalGap = 10;
    CGFloat verticalGap = 5;
    CGFloat height = verticalGap;
    CGFloat calTop = height;
    CGFloat width = self.view.bounds.size.width;
    CGFloat calX = width;
    for(int i = 0; i < selections.count; i ++){
        NSString * selection = [selections objectAtIndex:i];
        UILabel * label = [UILabel new];
        label.userInteractionEnabled = YES;
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSelection:)];
        [label addGestureRecognizer:tap];
        label.numberOfLines = 0;
        label.layer.borderColor = [UIColor grayColor].CGColor;
        label.layer.borderWidth = 1;
        label.layer.cornerRadius = 3;
        label.layer.masksToBounds = YES;
        label.font = [UIFont systemFontOfSize:20];
        label.text = selection;
        label.tag = i;
        [answersView addSubview:label];
        CGSize size = [label sizeThatFits:CGSizeMake(width, MAXFLOAT)];
        if(size.width < calX){
            label.frame = CGRectMake(width - calX, calTop, size.width, size.height);
            calX -= size.width + horizontalGap;
            if(calTop == height){
                height += size.height;
            }
        }else{
            height += verticalGap;
            label.frame = CGRectMake(0, height, size.width, size.height);
            calX = 0;
            calTop = height;
            height += size.height;
        }
    }
    height += verticalGap;
    answersHeightConstraint.constant = height;
}

- (void) blankTextView:(BlankTextView *)blankView heightChanged:(CGFloat)height
{
    blankHeightConstraint.constant = height;
}

- (void) tapSelection : (UITapGestureRecognizer *) gesture
{
    if(blanks.count == blankPoints.count){
        return;
    }
    NSUInteger index = [[blankPoints objectAtIndex:blanks.count] unsignedIntegerValue];
    [blanks addObject:[[Blank alloc] initWithIndex:index blankContent:[selections objectAtIndex:gesture.view.tag]]];
    [view setUpBlanks:blanks];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
