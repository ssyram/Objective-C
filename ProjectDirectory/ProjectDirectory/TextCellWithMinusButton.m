//
// Created by ssyram on 2018/6/17.
// Copyright (c) 2018 ssyram. All rights reserved.
//

#import "TextCellWithMinusButton.h"


@interface TextCellWithMinusButton()
@end

@implementation TextCellWithMinusButton {

}

- (IBAction)editDidEnd:(id)sender {
    [_delegate editDidEndAtPath:self.indexPath];
}
- (IBAction)minusDidPressed:(id)sender {
    [_delegate minusDidPressedAtPath:self.indexPath];
}
- (IBAction)editChanged:(id)sender{
    [_delegate editDidChangedAtPath:self.indexPath];
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        //布局cell内部控件
        self.descriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 12, 81, 21)];
        
        self.textField = [[UITextField alloc] initWithFrame:CGRectMake(116, 6, 200, 30)];
        [self.textField addTarget:self action:@selector(editDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
        [self.textField addTarget:self action:@selector(editChanged:) forControlEvents:UIControlEventEditingChanged];
        self.minusButton = [[UIButton alloc] initWithFrame:CGRectMake(324, 4, 35, 35)];
        [self.minusButton addTarget:self action:@selector(minusDidPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.minusButton setBackgroundImage:[UIImage imageNamed:@"minus.png"] forState:UIControlStateNormal];
        
        [self.contentView addSubview:self.descriptionLabel];
        [self.contentView addSubview:self.textField];
        [self.contentView addSubview:self.minusButton];
    }
    return self;
}

@end
