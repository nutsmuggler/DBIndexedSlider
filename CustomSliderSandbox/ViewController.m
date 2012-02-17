//
//  ViewController.m
//  CustomSliderSandbox
//
//  Created by Davide Benini on 14/02/12.
//  Copyright (c) 2012 Davide Benini. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateLabel:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}



-(IBAction)updateLabel:(id)sender {
    label.text = slider.value;
    indexLabel.text = [NSString stringWithFormat:@"%i", slider.indexValue];
}

-(IBAction)updateValue:(id)sender {
    UIButton* button = (UIButton*)sender;
    [slider setValue:[button titleForState:UIControlStateNormal] animated:YES];
}
-(IBAction)updateIndicator:(id)sender {
    UIButton* button = (UIButton*)sender;
    [slider setIndicatorImage:[button imageForState:UIControlStateNormal]];
}
-(IBAction)updateSteps:(id)sender {
    UIButton* button = (UIButton*)sender;
    NSString* title = [button titleForState:UIControlStateNormal];
    NSArray* elements = [title componentsSeparatedByString:@","];
    [slider setSteps:elements];
}
-(IBAction)updateFont:(id)sender {
    UIButton* button = (UIButton*)sender;
    slider.textFont = button.titleLabel.font;

}
-(IBAction)updateLabelOffset:(id)sender {
    UIButton* button = (UIButton*)sender;
    slider.textOffset = [[button titleForState:UIControlStateNormal] intValue];
}
-(IBAction)updatePadding:(id)sender {
    UIButton* button = (UIButton*)sender;
    slider.padding = [[button titleForState:UIControlStateNormal] intValue];

}
-(IBAction)updateColor:(id)sender {
    UIButton* button = (UIButton*)sender;
    slider.textColor = [button backgroundColor];
}
-(IBAction)updateSelectedColor:(id)sender {
    UIButton* button = (UIButton*)sender;
    slider.textHighlightedColor = [button backgroundColor];
}

@end
