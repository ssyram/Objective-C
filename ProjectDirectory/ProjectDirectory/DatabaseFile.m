//
// Created by ssyram on 2018/6/12.
// Copyright (c) 2018 ssyram. All rights reserved.
//

#import "DatabaseFile.h"

bool validPhoneNumberToken(char c){
    return ((c >= '0') && (c <= '9')) || (c == '+') || (c == '#') || (c == '*');
}
bool validPhoneNumber(NSString *s){
    for (NSUInteger i = 0; i < s.length; ++i)
        if(!validPhoneNumberToken([s characterAtIndex:i]))
            return false;
    return true;
}

bool isValidEmail(NSString *s){
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:s];
}

@implementation DatabaseFile

- (NSMutableArray<NSString *> *)emailList{
    if (!_emailList)
        _emailList = [NSMutableArray new];
    return _emailList;
}

- (NSMutableArray<NSString *> *)phoneNumberList{
    if (!_phoneNumberList)
        _phoneNumberList = [NSMutableArray new];
    return _phoneNumberList;
}

- (NSString *)imagePath
{
    NSString *iName = [NSString stringWithFormat:@"%lu.png", (unsigned long)self.pid];
    NSString *iPath = [[DatabaseFile imageContentPath] stringByAppendingPathComponent:iName];
    return iPath;
}

- (void)setImage:(UIImage *)image
{
    NSString *iPath = [self imagePath];
    
    if ([UIImagePNGRepresentation(image) writeToFile:iPath atomically:YES])
        NSLog(@"save to local path succeed!");
}

- (UIImage *)getImage{
    NSString *iPath = [self imagePath];
    
    NSData *pd = [NSData dataWithContentsOfFile:iPath];
    return  [UIImage imageWithData:pd];
}

+ (NSString *)imageContentPath
{
    NSString *dPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *fullPath = [dPath stringByAppendingPathComponent:@"imageContent"];
    return fullPath;
}

- (void)setBirthdayWithYear:(int)y andMonth:(int)m andDay:(int)d{
    _birthday = [NSString stringWithFormat:@"%d-%d, %d", m, d, y];
}
- (void)addPhoneNumber:(NSString *)phoneNumber{
    if(!validPhoneNumber(phoneNumber))
        @throw [NSException exceptionWithName:@"not a valid phone number" reason:nil userInfo:nil];
    [self.phoneNumberList addObject:phoneNumber];
}
- (void)addEmail:(NSString *)email{
    if (!isValidEmail(email))
        @throw [NSException exceptionWithName:@"not a valid email address" reason:nil userInfo:nil];
    [self.emailList addObject:email];
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    DatabaseFile *f = [DatabaseFile new];
    
    f.pid = _pid;
    f.name = _name;
    f.phoneNumberList = [_phoneNumberList mutableCopy];
    f.emailList = [_emailList mutableCopy];
    f.birthday = _birthday;
    f.remarks = _remarks;
    
    return f;
}

@end
