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

-(void)layoutLabels;
-(void)updateLabelColors:(BOOL)animated;
-(void)generateGhostImage;
- (NSUInteger) estimatedStepNumberForPosition:(CGFloat)aPosition;
-(float)xPositionForStep:(NSUInteger)step;
-(float)valueForStep:(NSUInteger)step;

-(NSInteger)centerXForValue:(float)value;
-(void)refreshGhostImage;
@end

@implementation DBIndexedSlider
@synthesize trackImage;



- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        labels = [[NSMutableArray alloc] initWithCapacity:5];

        self.indicatorImage = [UIImage imageNamed:@"sliderIndicator.png"];
        self.trackImage = [[UIImage imageNamed:@"stretchableTrack.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:2];
        _labelColor = [UIColor colorWithWhite:0.800 alpha:1.000];
        _labelHighlightedColor = [UIColor colorWithWhite:0.400 alpha:1.000];
        _labelOffset = 40;
        _labelFont = [UIFont systemFontOfSize:20];
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
    
    [self layoutLabels];

    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

#pragma mark - properties

-(NSArray*)steps {
    return  _steps;
}
-(void)setSteps:(NSArray *)steps {
    _selectedStepIndex = 0;
    _steps = steps;
    [self layoutLabels];
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
    if([labels count])
        [self layoutLabels];

}
-(UIFont*)labelFont {
    return _labelFont;
}
-(void)setLabelFont:(UIFont *)labelFont {
    if (_labelFont == labelFont) {
        return;
    }
    _labelFont = labelFont;
    [self layoutLabels];
}

-(UIColor*)labelColor {
    return _labelColor;
}
-(void)setLabelColor:(UIColor *)labelColor {
    if([_labelColor isEqual:labelColor])
        return;
    
    _labelColor = labelColor;
    [self updateLabelColors:NO];
}

-(UIColor*)labelHighlightedColor {
    return _labelHighlightedColor;
}
-(void)setLabelHighlightedColor:(UIColor *)labelHighlightedColor {
    if([_labelHighlightedColor isEqual:labelHighlightedColor])
        return;
    
    _labelHighlightedColor = labelHighlightedColor;
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
    [self layoutLabels];
}

-(CGFloat)labelOffset {
    return _labelOffset;
}
-(void)setLabelOffset:(CGFloat)labelOffset {
    if (labelOffset == _labelOffset) {
        return;
    }
    _labelOffset = labelOffset;
    [self layoutLabels];
}

#pragma mark - value

//
// Gets the value from the selected step label
//
-(NSString*)value {
    return [self.steps objectAtIndex:_selectedStepIndex];
}
//
// Gets the selected step index
//
-(NSUInteger)indexValue {
    return _selectedStepIndex;
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

    [UIView animateWithDuration:.2 
                     animations:^{
                         slider.value =  [self valueForStep:_selectedStepIndex];;
                         indicatorView.frame = [self indicatorRect];
    }
                     completion:^(BOOL finished) {
                         [self sendActionsForControlEvents:UIControlEventEditingDidEnd];
    }];
}

-(void)updateLabelColors:(BOOL)animated {
    
    AnimationBlock block = ^ {
        [labels makeObjectsPerformSelector:@selector(setTextColor:) withObject:self.labelColor];
        [[labels objectAtIndex:_selectedStepIndex] setTextColor:self.labelHighlightedColor];
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
-(void)layoutLabels {
    [labels makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [labels removeAllObjects];
    int i = 0;
    for (NSString* step in _steps) {
        UILabel* stepLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        stepLabel.backgroundColor = [UIColor clearColor];
        stepLabel.textColor = self.labelColor;
        stepLabel.font = _labelFont;
        stepLabel.text = step;
        [stepLabel sizeToFit];
        CGPoint center = stepLabel.center;
        center.x = [self centerXForValue:[self valueForStep:i]];
        center.y = self.labelOffset;
        stepLabel.center = center;
        [labels addObject:stepLabel];
        [self addSubview:stepLabel];
        i++;
    }
    _selectedStepIndex = 0;
    
    slider.value = 0;
    indicatorView.frame = [self indicatorRect];
    [labels makeObjectsPerformSelector:@selector(setTextColor:) withObject:self.labelColor];
    [[labels objectAtIndex:_selectedStepIndex] setTextColor:self.labelHighlightedColor];
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

#pragma mark - ghost thumb image
-(void)refreshGhostImage {
    UIGraphicsBeginImageContext(self.indicatorImage.size);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    UIView* canvas = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.indicatorImage.size.width, self.indicatorImage.size.height)];
    [canvas.layer renderInContext:currentContext];
    
    ghostImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

}
@end
