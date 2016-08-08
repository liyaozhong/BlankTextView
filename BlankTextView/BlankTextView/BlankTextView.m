//
//  BlankTextView.m
//  test
//
//  Created by joshuali on 16/8/8.
//  Copyright © 2016年 joshuali. All rights reserved.
//

#import "BlankTextView.h"
#import <CoreText/CoreText.h>

#define BLANK_TAG   999

@implementation Blank
- (instancetype) initWithIndex : (NSInteger) index width : (CGFloat) width
{
    self = [super init];
    if(self){
        self.index = index;
        self.width = width;
    }
    return self;
}
@end

@interface BlankTextView ()
{
    CGFloat singleLineHeight;
    NSMutableArray * exclusionPaths;
    CGFloat viewWidth;
}
@property (nonatomic, strong) NSMutableArray * blanks;
@end

@implementation BlankTextView

- (CGFloat) setInitialText : (NSString *) text withWidth : (CGFloat) width
{
    viewWidth = width;
    if(!text){
        return 0;
    }
    for(UIView * view in self.subviews){
        if(view.tag == BLANK_TAG){
            [view removeFromSuperview];
        }
    }
    if(!exclusionPaths){
        exclusionPaths = [NSMutableArray new];
    }
    self.editable = NO;
    self.selectable = NO;
    [self.textStorage setAttributedString:[[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:20]}]];
    singleLineHeight = [self.text sizeWithAttributes:@{NSFontAttributeName : self.font, NSUnderlineStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle]}].height;
    CGSize afterSize = [self sizeThatFits:CGSizeMake(width, MAXFLOAT)];
    return afterSize.height;
}

- (void) setUpBlanks : (NSArray<Blank *> *) blanks
{
    if(!_blanks){
        _blanks = [NSMutableArray new];
    }
    [_blanks removeAllObjects];
    [_blanks addObjectsFromArray:blanks];
    [self setNeedsLayout];
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    if(!exclusionPaths){
        return;
    }
    for(UIView * view in self.subviews){
        if(view.tag == BLANK_TAG){
            [view removeFromSuperview];
        }
    }
    [exclusionPaths removeAllObjects];
    self.textContainer.exclusionPaths = exclusionPaths;
    for(Blank * blank in self.blanks){
        [self fillBlank:blank.index length:blank.width];
    }
    self.textContainer.exclusionPaths = exclusionPaths;
    if(self.blankDelegate){
        CGSize size = [self sizeThatFits:CGSizeMake(viewWidth, MAXFLOAT)];
        [self.blankDelegate blankTextView:self heightChanged:size.height];
    }
}

- (void) renderInTextView: (UIView *) blankView
{
    CGRect frame = [self convertRect:blankView.bounds fromView:blankView];
    frame.origin.x -= self.textContainerInset.left;
    frame.origin.y -= self.textContainerInset.top;
    [exclusionPaths addObject:[UIBezierPath bezierPathWithRect:frame]];
}

- (void)fillBlank : (NSInteger) index length : (CGFloat) length
{
    CGPoint origin = [self.layoutManager boundingRectForGlyphRange:NSMakeRange(index, 1) inTextContainer:self.textContainer].origin;
    if(length + origin.x > self.bounds.size.width){
        origin.x = self.textContainerInset.left + self.textContainer.lineFragmentPadding;
        origin.y += singleLineHeight;
    }
    UIView * blankView = [UIView new];
    blankView.tag = BLANK_TAG;
    blankView.layer.cornerRadius = 4;
    blankView.layer.borderWidth = 1;
    blankView.layer.borderColor = [UIColor blackColor].CGColor;
    [self addSubview:blankView];
    blankView.frame = CGRectMake(origin.x, origin.y + self.textContainerInset.top, length, singleLineHeight);
    [self renderInTextView:blankView];
}
@end
