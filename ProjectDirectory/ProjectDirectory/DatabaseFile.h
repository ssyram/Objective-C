//
// Created by ssyram on 2018/6/12.
// Copyright (c) 2018 ssyram. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DatabaseFile : NSObject<NSCopying>

- (UIImage *)getImage;
- (void)setImage:(UIImage *)image;
@property (nonatomic) NSMutableArray<NSString *> *phoneNumberList, *emailList;
@property NSString *birthday, *name, *remarks;
@property NSUInteger pid;

+ (NSString *)imageContentPath;
- (void)setBirthdayWithYear:(int)y andMonth:(int)m andDay:(int)d;
- (void)addPhoneNumber:(NSString *)phoneNumber;
- (void)addEmail:(NSString *)email;

@end
