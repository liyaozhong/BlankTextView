//
//  BlankTextView.h
//  test
//
//  Created by joshuali on 16/8/8.
//  Copyright © 2016年 joshuali. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BlankTextView;
@protocol BlankTextViewDelegate <NSObject>

- (void) blankTextView : (BlankTextView *) blankView heightChanged : (CGFloat) height;
- (void) blankTextView : (BlankTextView *) blankView blankSelected : (NSUInteger) index;
@end

@interface Blank : NSObject
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, copy) NSString * blankContent;
@property (nonatomic, assign) BOOL isDefault;
- (instancetype) initWithIndex : (NSInteger) index blankContent : (NSString *) blankContent;
- (instancetype) initWithIndex : (NSInteger) index blankContent : (NSString *) blankContent isDefault : (BOOL) isDefault;
@end

@interface BlankTextView : UITextView
@property (nonatomic, weak) id<BlankTextViewDelegate> blankDelegate;
- (CGFloat) setInitialText : (NSString *) text withWidth : (CGFloat) width defaultBlanks : (NSArray<Blank*> *) defaultBlanks;
- (void) setUpBlanks : (NSArray<Blank *> *) blanks;
@end
