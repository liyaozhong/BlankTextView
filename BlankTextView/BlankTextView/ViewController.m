//
//  ViewController.m
//  BlankTextView
//
//  Created by joshuali on 16/8/8.
//  Copyright © 2016年 joshuali. All rights reserved.
//

#import "ViewController.h"
#import "BlankTextView.h"

#define DEFAULT_BLANK_CONTENT  @"MMMM"

@interface ViewController ()<BlankTextViewDelegate>
{
    BlankTextView * view;
    UIView * answersView;
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
    
    answersView = [UIView new];
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
    for(NSNumber * index in blankPoints){
        Blank * blank = [[Blank alloc] initWithIndex:[index unsignedIntegerValue] blankContent:DEFAULT_BLANK_CONTENT isDefault:YES];
        [blanks addObject:blank];
    }
    blankHeightConstraint.constant = [view setInitialText:contentStr withWidth:self.view.bounds.size.width defaultBlanks:blanks];
    
    //layout selection views
    selections = @[@"1234567890",@"0987654321",@"qwer",@"asdfghjkl", @"zxcvbnmlkjhgfdsaqwertyuiop-zxcvbnmlkjhgfdsaqwertyuiop-zxcvbnmlkjhgfdsaqwertyuiop-zxcvbnmlkjhgfdsaqwertyuiop", @"zxcvbnmlkjhgfdsaqwertyuiop", @"  ", @"   "];
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
        UIPanGestureRecognizer * panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        [label addGestureRecognizer:panGesture];
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

- (void) blankTextView:(BlankTextView *)blankView blankSelected:(NSUInteger)index
{
    if(index < blanks.count){
        Blank * blank = blanks[index];
        if(!blank.isDefault){
            blank.isDefault = YES;
            blank.blankContent = DEFAULT_BLANK_CONTENT;
        }
    }
    [view setUpBlanks:blanks];
}

- (void) tapSelection : (UITapGestureRecognizer *) gesture
{
    for(Blank * blank in blanks){
        if(blank.isDefault){
            blank.blankContent = [selections objectAtIndex:gesture.view.tag];
            blank.isDefault = NO;
            break;
        }
    }
    [view setUpBlanks:blanks];
}

UILabel * dragingLable;
CGPoint originPan;
CGRect originFrame;
NSInteger curIndex;
- (void) pan : (UIPanGestureRecognizer *) gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        originPan = [gesture locationInView:self.view];
        if(dragingLable){
            [dragingLable removeFromSuperview];
        }
        UILabel * originLabel = (UILabel *) gesture.view;
        originFrame = originLabel.frame;
        dragingLable = [[UILabel alloc] initWithFrame:originFrame];
        dragingLable.alpha = 0.8f;
        dragingLable.numberOfLines = 0;
        dragingLable.layer.borderColor = [UIColor grayColor].CGColor;
        dragingLable.layer.borderWidth = 1;
        dragingLable.layer.cornerRadius = 3;
        dragingLable.layer.masksToBounds = YES;
        dragingLable.font = [UIFont systemFontOfSize:20];
        dragingLable.text = originLabel.text;
        [answersView addSubview:dragingLable];
    }else if(gesture.state == UIGestureRecognizerStateEnded){
        if(dragingLable){
            [dragingLable removeFromSuperview];
        }
        [view finishDrag];
        if(curIndex != NSNotFound){
            if(curIndex < blanks.count && curIndex >= 0){
                Blank * blank = blanks[curIndex];
                blank.isDefault = NO;
                blank.blankContent = dragingLable.text;
            }
            [view setUpBlanks:blanks];
        }
    }else{
        CGPoint origin = [gesture locationInView:self.view];
        CGRect frame = originFrame;
        frame.origin.x += origin.x - originPan.x;
        frame.origin.y += origin.y - originPan.y;
        dragingLable.frame = frame;
        CGPoint center = dragingLable.center;
        center.y += blankHeightConstraint.constant;
        curIndex = [view checkBlank:center];
        if(curIndex != NSNotFound){
            dragingLable.textColor = [UIColor redColor];
        }else{
            dragingLable.textColor = [UIColor blackColor];
        }
    }
}

@end
