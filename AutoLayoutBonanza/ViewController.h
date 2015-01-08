//
//  ViewController.h
//  AutoLayoutBonanza
//
//  Created by Matthew Hanlon on 1/7/15.
//  Copyright (c) 2015 Q.I. Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (nonatomic, strong) NSDictionary* viewDictionary;

- (IBAction)switchLayout:(id)sender;
- (IBAction)switchContent:(id)sender;

@end

