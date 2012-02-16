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
    NSMutableArray* labels;
    NSUInteger _selectedStepIndex;
    UIImage* ghostImage;
    UIImage* _indicatorImage;
    NSArray* _steps;
    UIFont* _labelFont;
    CGFloat _labelOffset;
    CGFloat _padding;
    UIColor* _labelColor;
    UIColor* _labelHighlightedColor;

}
@property(nonatomic,weak) UIImage* trackImage;
@property(nonatomic,weak) UIImage* indicatorImage;

@property(nonatomic, strong) NSArray* steps;
@property(nonatomic, strong) UIColor* labelColor;
@property(nonatomic, strong) UIColor* labelHighlightedColor;
@property(nonatomic, strong) UIFont* labelFont;

@property(assign) CGFloat padding;
@property(assign) CGFloat labelOffset;

@property(readonly) NSString* value;
@property(readonly) NSUInteger indexValue;


//- (id)initWithIndicatorImage:(UIImage*)image;

@end
