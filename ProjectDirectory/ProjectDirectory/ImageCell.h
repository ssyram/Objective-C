//
// Created by ssyram on 2018/6/17.
// Copyright (c) 2018 ssyram. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextCellDelegate.h"


@interface ImageCell : UITableViewCell

@property (nonatomic, strong) id<TextCellDelegate> delegate;
@property (nonatomic, strong) IBOutlet UIButton *imageButton;

@end
