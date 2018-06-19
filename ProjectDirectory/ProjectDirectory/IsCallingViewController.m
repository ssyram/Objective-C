//
// Created by ssyram on 2018/6/12.
// Copyright (c) 2018 ssyram. All rights reserved.
//

#import "IsCallingViewController.h"
#import "DatabaseHandler.h"


@implementation IsCallingViewController

- (void)viewDidLoad
{
    UIImage *i = [toPass getImage];
    if (i)
        self.imageDisplay.image = i;
    self.phoneNumberDisplay.text = toPass.name;
}

- (IBAction)clickCutButton:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
