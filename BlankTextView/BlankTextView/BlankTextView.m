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
    self = [super init];
    if(self){
        self.index = index;
        self.blankContent = blankContent;
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
    content = text;
    for(UIView * view in self.subviews){
        if(view.tag == BLANK_TAG){
            [view removeFromSuperview];
        }
    }
    self.editable = NO;
    self.selectable = NO;
    attributes = @{NSFontAttributeName : [UIFont systemFontOfSize:DEFAULT_FONT_SIZE], NSUnderlineStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle]};
    [self.textStorage setAttributedString:[[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:DEFAULT_FONT_SIZE]}]];
    singleLineHeight = [self.text sizeWithAttributes:attributes].height;
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
    for(UIView * view in self.subviews){
        if(view.tag == BLANK_TAG){
            [view removeFromSuperview];
        }
    }
    [self.textStorage replaceCharactersInRange:NSMakeRange(0, self.textStorage.length) withString:content];
    NSInteger inc = 0;
    for(Blank * blank in self.blanks){
        inc += [self fillBlank:(blank.index + inc) blankContent:blank.blankContent];
    }
    if(self.blankDelegate){
        CGSize size = [self sizeThatFits:CGSizeMake(viewWidth, MAXFLOAT)];
        [self.blankDelegate blankTextView:self heightChanged:size.height + selectionMargin];
    }
}

- (NSUInteger)fillBlank : (NSInteger) index blankContent : (NSString *) blankContent
{
    NSRange range = [self.layoutManager glyphRangeForCharacterRange:NSMakeRange(index, 1) actualCharacterRange:NULL];
    CGPoint origin = [self.layoutManager boundingRectForGlyphRange:range inTextContainer:self.textContainer].origin;
    
    CGSize size = [blankContent sizeWithAttributes:attributes];
    
    BOOL newLine = NO;
    if(size.width + origin.x > (self.bounds.size.width - self.textContainerInset.right - self.textContainer.lineFragmentPadding) || size.height > singleLineHeight){
        newLine = YES;
        blankContent = [NSString stringWithFormat:@"\n%@\n", blankContent];
    }else{
        blankContent = [NSString stringWithFormat:@" %@ ", blankContent];
    }
    
    [self.textStorage insertAttributedString:[[NSAttributedString alloc] initWithString:blankContent attributes:attributes] atIndex:index];

    NSRange rrr;
    range = [self.layoutManager glyphRangeForCharacterRange:NSMakeRange(index + (newLine ? 1 : 0), blankContent.length - (newLine ? 2 : 0)) actualCharacterRange:&rrr];
    CGRect rect = [self.layoutManager boundingRectForGlyphRange:range inTextContainer:self.textContainer];
    
    UIView * blankView = [UIView new];
    blankView.tag = BLANK_TAG;
    blankView.layer.cornerRadius = 4;
    blankView.layer.borderWidth = 1;
    blankView.layer.borderColor = [UIColor blackColor].CGColor;
    [self addSubview:blankView];
    rect.origin.y += self.textContainerInset.top;
    blankView.frame = rect;
    return blankContent.length;
}

@end
