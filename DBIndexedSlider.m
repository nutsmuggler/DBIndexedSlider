//
//  CustomSlider.m
//  CustomSliderSandbox
//
//  Created by Davide Benini on 14/02/12.
//  Copyright (c) 2012 Davide Benini. All rights reserved.
//

#import "DBIndexedSlider.h"
#import <QuartzCore/QuartzCore.h>

static const int kSliderPadding = 20;
typedef void (^AnimationBlock)(void);


@interface DBIndexedSlider (Private)
-(void)setupSubviews;
-(CGRect)trackRect;
-(CGRect)indicatorRect;
-(CGRect)sliderRect;
-(float)sliderWidth;

-(void)layoutButtons;
-(void)updateLabelColors:(BOOL)animated;
-(void)generateGhostImage;
- (NSUInteger) estimatedStepNumberForPosition:(CGFloat)aPosition;
-(float)xPositionForStep:(NSUInteger)step;
-(float)valueForStep:(NSUInteger)step;

-(NSInteger)centerXForValue:(float)value;
-(void)refreshGhostImage;
-(void)refreshButtonColors;
-(void)moveToSelectedIndex:(BOOL)animated;
@end

@implementation DBIndexedSlider
@synthesize trackImage;



- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        buttons = [[NSMutableArray alloc] initWithCapacity:5];

        self.indicatorImage = [UIImage imageNamed:@"sliderIndicator.png"];
        self.trackImage = [[UIImage imageNamed:@"stretchableTrack.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:2];
        _textColor = [UIColor colorWithWhite:0.800 alpha:1.000];
        _textHighlightedColor = [UIColor colorWithWhite:0.400 alpha:1.000];
        _textOffset = 40;
        _textFont = [UIFont systemFontOfSize:20];
        _padding = 10;
        _steps = [NSArray arrayWithObjects:@"0",@"1",@"2",@"3", nil];
        _selectedStepIndex = 0;

        [self setupSubviews];
    }
    return self;
}
-(void)setupSubviews {
    //self.backgroundColor = [UIColor clearColor];



    slider = [[UISlider alloc] initWithFrame:[self sliderRect]];
    [slider setThumbImage:ghostImage forState:UIControlStateNormal];
    slider.backgroundColor = [UIColor clearColor];
    [self addSubview:slider];
        
    trackView = [[UIImageView alloc] initWithFrame:[self trackRect]];
    trackView.image = self.trackImage; 
    [self addSubview:trackView];

    indicatorView = [[UIImageView alloc] initWithFrame:[self indicatorRect]];
    indicatorView.image = self.indicatorImage;
    [self addSubview:indicatorView];
    
    [slider addTarget:self action:@selector(sliderUpdated:) forControlEvents:UIControlEventValueChanged];
    [slider addTarget:self action:@selector(sliderFinishedUpdating:) forControlEvents:UIControlEventTouchUpInside];
    [slider addTarget:self action:@selector(sliderFinishedUpdating:) forControlEvents:UIControlEventTouchUpOutside];
    [self layoutButtons];

    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

#pragma mark - properties

-(NSArray*)steps {
    return  _steps;
}
-(void)setSteps:(NSArray *)steps {
    _selectedStepIndex = 0;
    _steps = steps;
    [self layoutButtons];
}

-(UIImage*)indicatorImage {
    return _indicatorImage;
}
-(void)setIndicatorImage:(UIImage *)indicatorImage {
    _indicatorImage = indicatorImage;
    indicatorView.image = self.indicatorImage;

    [self refreshGhostImage];
    [slider setThumbImage:ghostImage forState:UIControlStateNormal];
    indicatorView.frame = [self indicatorRect];
    if([buttons count])
        [self layoutButtons];

}
-(UIFont*)textFont {
    return _textFont;
}
-(void)setTextFont:(UIFont *)textFont {
    if (_textFont == textFont) {
        return;
    }
    _textFont = textFont;
    [self layoutButtons];
}

-(UIColor*)textColor {
    return _textColor;
}
-(void)setTextColor:(UIColor *)textColor {
    if([_textColor isEqual:textColor])
        return;
    
    _textColor = textColor;
    [self refreshButtonColors];

    [self updateLabelColors:NO];
    
}

-(UIColor*)textHighlightedColor {
    return _textHighlightedColor;
}
-(void)setTextHighlightedColor:(UIColor *)textHighlightedColor {
    if([_textHighlightedColor isEqual:textHighlightedColor])
        return;
    
    _textHighlightedColor = textHighlightedColor;
    [self refreshButtonColors];

    [self updateLabelColors:NO];
}

-(CGFloat)padding {
    return _padding;
}
- (void)setPadding:(CGFloat)padding {
    if (padding == _padding) {
        return;
    }
    _padding = padding;
    //trackView.frame = [self trackRect];
    slider.frame = [self sliderRect];
    [self layoutButtons];
}

-(CGFloat)textOffset {
    return _textOffset;
}
-(void)setTextOffset:(CGFloat)textOffset {
    if (textOffset == _textOffset) {
        return;
    }
    _textOffset = textOffset;
    [self layoutButtons];
}

#pragma mark - value

//
// Gets the value from the selected step label
//
-(NSString*)value {
    return [self.steps objectAtIndex:_selectedStepIndex];
}

-(void)setValue:(NSString *)value animated:(BOOL)animated {
    int i = 0;
    for (UIButton* button in buttons) {
        if ([[button titleForState:UIControlStateNormal] isEqualToString:value]) {
            break;
        }
        i++;
    }
    // not match
    if (i == [buttons count]) {
        return;
    }
    [self setIndexValue:i animated:animated];
}

//
// Gets the selected step index
//
-(NSUInteger)indexValue {
    return _selectedStepIndex;
}


-(void)setIndexValue:(NSUInteger)indexValue animated:(BOOL)animated {
    if (indexValue == _selectedStepIndex) {
        return;
    }
    _selectedStepIndex = indexValue;
    [self moveToSelectedIndex:animated]; 
}

#pragma mark - Slider logic

-(void)sliderUpdated:(id)sender {
    indicatorView.frame = [self indicatorRect];
    NSUInteger index = [self estimatedStepNumberForPosition:slider.value];

    if (index != _selectedStepIndex) {
        _selectedStepIndex = index;
        [self updateLabelColors:YES];
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

-(void)sliderFinishedUpdating:(id)sender {
    _selectedStepIndex = [self estimatedStepNumberForPosition:slider.value];
    [self moveToSelectedIndex:YES];

}

-(void)updateLabelColors:(BOOL)animated {
    
    AnimationBlock block = ^ {
        for (UIButton* button in buttons) {
            button.selected = NO;
        }
        [[buttons objectAtIndex:_selectedStepIndex] setSelected:YES];
    };
    if (animated) {
        [UIView animateWithDuration:2 animations:block];
    } else {
        block();
    }

}
#pragma mark - layout and rects

-(CGRect)trackRect {
    CGRect frame = self.bounds;
    frame.origin.y = 6;
    frame.size.height = 10;
    return frame;
}
-(CGRect)sliderRect {
    CGRect frame = self.bounds;
    frame.origin.x = self.padding;
    frame.size.width -= 2*self.padding;
    frame.size.height = self.indicatorImage.size.height;
    return frame;
}
-(CGRect)indicatorRect {
    CGRect frame = indicatorView.frame;
    frame.origin.x = [self centerXForValue:slider.value] - self.indicatorImage.size.width/2;
    frame.origin.y  = 11 - self.indicatorImage.size.height/2;
    frame.size = self.indicatorImage.size;
    return  frame;
}
-(void)layoutButtons {
    [buttons makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [buttons removeAllObjects];
    int i = 0;
    for (NSString* step in _steps) {
    
        UIButton* stepButton = [UIButton buttonWithType:UIButtonTypeCustom];
        stepButton.backgroundColor = [UIColor clearColor];
        stepButton.titleLabel.font = _textFont;
        [stepButton setTitle:step forState:UIControlStateNormal];
        [stepButton sizeToFit];
        CGRect frame = stepButton.frame;
        CGFloat originalH = frame.size.height;
        if(frame.size.width < 30)
            frame.size.width = 30;
        if(frame.size.height < 30)
            frame.size.height = 30;
        stepButton.frame = frame;
        
        CGFloat extraOffset = (stepButton.frame.size.height - originalH)/2;
        CGPoint center = stepButton.center;
        center.x = [self centerXForValue:[self valueForStep:i]];
        center.y = self.textOffset + extraOffset;
        stepButton.center = center;
        
        [stepButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [buttons addObject:stepButton];
        [self addSubview:stepButton];
        i++;
    }
    _selectedStepIndex = 0;
    
    slider.value = 0;
    indicatorView.frame = [self indicatorRect];
    [self refreshButtonColors];
}
-(void)buttonPressed:(id)sender {
    UIButton* button = (UIButton*)sender;
    int i = [buttons indexOfObject:button];
    [self setIndexValue:i animated:YES];
}

- (NSUInteger)estimatedStepNumberForPosition:(CGFloat)aPosition {
    if (!self.steps)
        return 0;
    
    CGFloat roughEstimation = (([self.steps count] - 1) * aPosition);
    
    if (roughEstimation == 0)
        return (NSUInteger)floorf(roughEstimation);
    else if (roughEstimation == ([self.steps count] - 1))
        return (NSUInteger)ceilf(roughEstimation);
    else
        return (NSUInteger)roundf(roughEstimation);
    
}

-(float)xPositionForStep:(NSUInteger)step {
    return [self centerXForValue:[self valueForStep:step]];
}

-(float)valueForStep:(NSUInteger)step {
    int count = [self.steps count] - 1;
    float pace = 1 / (float)count;
    return pace * step;
}

-(NSInteger)centerXForValue:(float)value {
    CGRect frame = [slider thumbRectForBounds:slider.bounds trackRect:[slider trackRectForBounds:slider.bounds] value:value];
    frame.size.width = self.indicatorImage.size.width;
    int x = self.padding + frame.origin.x + frame.size.width/2;
    return x;
}

-(void)moveToSelectedIndex:(BOOL)animated {
    AnimationBlock moveToSelected = ^ {
        slider.value =  [self valueForStep:_selectedStepIndex];
        indicatorView.frame = [self indicatorRect];
        [self updateLabelColors:NO];
    }; 
    if (animated) {
        [UIView animateWithDuration:.2 
                         animations:moveToSelected
                         completion:^(BOOL finished) {
                             [self sendActionsForControlEvents:UIControlEventEditingDidEnd];
                         }];
    } else {
        moveToSelected();
        [self sendActionsForControlEvents:UIControlEventEditingDidEnd];
    }
}
#pragma mark - ghost thumb image
-(void)refreshButtonColors {
    for (UIButton* button in buttons) {
        [button setTitleColor:self.textColor forState:UIControlStateNormal];
        [button setTitleColor:self.textHighlightedColor forState:UIControlStateHighlighted];
        [button setTitleColor:self.textHighlightedColor forState:UIControlStateSelected];
    }
}
-(void)refreshGhostImage {
    UIGraphicsBeginImageContext(self.indicatorImage.size);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    UIView* canvas = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.indicatorImage.size.width, self.indicatorImage.size.height)];
    [canvas.layer renderInContext:currentContext];
    
    ghostImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

}
@end
