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

#define DEFAULT_FONT_SIZE  20

@implementation Blank

- (instancetype) initWithIndex : (NSInteger) index blankContent : (NSString *) blankContent
{
    return [self initWithIndex:index blankContent:blankContent isDefault:NO];
}

- (instancetype) initWithIndex : (NSInteger) index blankContent : (NSString *) blankContent isDefault : (BOOL) isDefault
{
    self = [super init];
    if(self){
        self.index = index;
        self.blankContent = blankContent;
        self.isDefault = isDefault;
    }
    return self;
}
@end

@interface BlankTextView ()
{
    CGFloat singleLineHeight;
    CGFloat viewWidth;
    CGFloat selectionMargin;
    NSString * content;
    NSDictionary * attributes;
    BOOL defaultLayout;
}
@property (nonatomic, strong) NSMutableArray * defaultBlanks;
@property (nonatomic, strong) NSMutableArray * blanks;
@end

@implementation BlankTextView

- (CGFloat) setInitialText : (NSString *) text withWidth : (CGFloat) width defaultBlanks : (NSArray<Blank*> *) defaultBlanks
{
    viewWidth = width;
    if(!text){
        return 0;
    }
    self.defaultBlanks = [NSMutableArray arrayWithArray:defaultBlanks];
    content = text;
    self.editable = NO;
    self.selectable = NO;
    [self resetView];
    attributes = @{NSFontAttributeName : [UIFont systemFontOfSize:DEFAULT_FONT_SIZE]};
    [self.textStorage setAttributedString:[[NSAttributedString alloc] initWithString:text attributes:attributes]];
    singleLineHeight = [self.text sizeWithAttributes:attributes].height;
    CGSize afterSize = [self sizeThatFits:CGSizeMake(width, MAXFLOAT)];
    defaultLayout = YES;
    [self setNeedsLayout];
    return afterSize.height;
}

- (void) resetView
{
    for(UIView * view in self.subviews){
        if(view.tag >= BLANK_TAG){
            [view removeFromSuperview];
        }
    }
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    if(defaultLayout){
        defaultLayout = NO;
        [self setUpBlanks:self.defaultBlanks];
    }
}

- (void) setUpBlanks : (NSArray<Blank *> *) blanks
{
    if(!_blanks){
        _blanks = [NSMutableArray new];
    }
    [_blanks removeAllObjects];
    [_blanks addObjectsFromArray:blanks];
    [self resetView];
    [self.textStorage replaceCharactersInRange:NSMakeRange(0, self.textStorage.length) withString:content];
    NSInteger inc = 0;
    for(NSUInteger i = 0; i < self.blanks.count; i ++){
        Blank * blank = [self.blanks objectAtIndex:i];
        inc += [self fillBlank:(blank.index + inc) blankContent:blank.blankContent tag:i];
    }
    if(self.blankDelegate){
        CGSize size = [self sizeThatFits:CGSizeMake(viewWidth, MAXFLOAT)];
        [self.blankDelegate blankTextView:self heightChanged:size.height + selectionMargin];
    }
}

- (NSUInteger)fillBlank : (NSInteger) index blankContent : (NSString *) blankContent tag : (NSUInteger) tagIndex
{
    NSRange range = [self.layoutManager glyphRangeForCharacterRange:NSMakeRange(index, 1) actualCharacterRange:NULL];
    CGPoint origin = [self.layoutManager boundingRectForGlyphRange:range inTextContainer:self.textContainer].origin;
    
    CGSize size = [blankContent sizeWithAttributes:attributes];
    
    BOOL newLine = NO;
    if(size.width + origin.x > (self.bounds.size.width - self.textContainerInset.right - self.textContainer.lineFragmentPadding) || size.height > singleLineHeight){
        newLine = YES;
        blankContent = [NSString stringWithFormat:@"\n%@\n", blankContent];
    }else{
        blankContent = [NSString stringWithFormat:@"%@ ", blankContent];
    }
    
    [self.textStorage insertAttributedString:[[NSAttributedString alloc] initWithString:blankContent attributes:attributes] atIndex:index];

    range = [self.layoutManager glyphRangeForCharacterRange:NSMakeRange(index + (newLine ? 1 : 0), blankContent.length - (newLine ? 2 : 1)) actualCharacterRange:NULL];
    CGRect rect = [self.layoutManager boundingRectForGlyphRange:range inTextContainer:self.textContainer];
    
    UIControl * blankView = [UIControl new];
    [blankView addTarget:self action:@selector(onBlankClick:) forControlEvents:UIControlEventTouchUpInside];
    blankView.tag = BLANK_TAG + tagIndex;
    blankView.layer.cornerRadius = 4;
    blankView.layer.borderWidth = 1;
    blankView.layer.borderColor = [UIColor blackColor].CGColor;
    [self addSubview:blankView];
    rect.origin.y += self.textContainerInset.top;
    blankView.frame = rect;
    return blankContent.length;
}

- (void) onBlankClick : (UIControl *) blankView
{
    if(self.blankDelegate){
        [self.blankDelegate blankTextView:self blankSelected:(blankView.tag-BLANK_TAG)];
    }
}

@end
