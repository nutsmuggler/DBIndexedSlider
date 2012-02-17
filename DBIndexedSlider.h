//
//  CustomSlider.h
//  CustomSliderSandbox
//
//  Created by Davide Benini on 14/02/12.
//  Copyright (c) 2012 Davide Benini. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBIndexedSlider : UIControl {
    UISlider* slider;
    UIImageView* trackView;
    UIImageView* indicatorView;
    NSMutableArray* buttons;
    NSUInteger _selectedStepIndex;
    UIImage* ghostImage;
    UIImage* _indicatorImage;
    NSArray* _steps;
    UIFont* _textFont;
    CGFloat _labelOffset;
    CGFloat _padding;
    UIColor* _textColor;
    UIColor* _textHighlightedColor;

}
@property(nonatomic,weak) UIImage* trackImage;
@property(nonatomic,weak) UIImage* indicatorImage;

@property(nonatomic, strong) NSArray* steps;
@property(nonatomic, strong) UIColor* textColor;
@property(nonatomic, strong) UIColor* textHighlightedColor;
@property(nonatomic, strong) UIFont* textFont;

@property(assign) CGFloat padding;
@property(assign) CGFloat labelOffset;

@property(readonly) NSString* value;
@property(readonly) NSUInteger indexValue;

-(void)setValue:(NSString*)value animated:(BOOL)animated;
-(void)setIndexValue:(NSUInteger)indexValue animated:(BOOL)animated;

//- (id)initWithIndicatorImage:(UIImage*)image;

@end
