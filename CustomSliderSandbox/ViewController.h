//
//  ViewController.h
//  CustomSliderSandbox
//
//  Created by Davide Benini on 14/02/12.
//  Copyright (c) 2012 Davide Benini. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBIndexedSlider.h"
@interface ViewController : UIViewController {
    IBOutlet DBIndexedSlider* slider;
    IBOutlet UILabel* label;
    IBOutlet UILabel* indexLabel;
}
-(IBAction)updateValue:(id)sender;
-(IBAction)updateLabel:(id)sender;
-(IBAction)updateIndicator:(id)sender;
-(IBAction)updateSteps:(id)sender;
-(IBAction)updateFont:(id)sender;
-(IBAction)updateLabelOffset:(id)sender;
-(IBAction)updatePadding:(id)sender;
-(IBAction)updateColor:(id)sender;
-(IBAction)updateSelectedColor:(id)sender;
@end
