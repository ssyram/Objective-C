//
// Created by ssyram on 2018/6/17.
// Copyright (c) 2018 ssyram. All rights reserved.
//

#import "ImageCell.h"


@implementation ImageCell {

}

- (IBAction)goChangePicture:(id)sender {
    [_delegate imageDidPressed];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        //布局cell内部控件
        self.imageButton = [[UIButton alloc] initWithFrame:CGRectMake(87, 24, 200, 200)];
        [self.imageButton addTarget:self action:@selector(goChangePicture:) forControlEvents:UIControlEventTouchUpInside];
        [self.imageButton setBackgroundImage:[UIImage imageNamed:@"defaultIcon.png"] forState:UIControlStateNormal];
        
        [self.contentView addSubview:self.imageButton];
    }
    return self;
}

@end
