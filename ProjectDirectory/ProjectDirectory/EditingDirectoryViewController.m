//
// Created by ssyram on 2018/6/12.
// Copyright (c) 2018 ssyram. All rights reserved.
//

#import "EditingDirectoryViewController.h"
#import "TextCellDelegate.h"
#import "ImageCell.h"
#import "PlusCell.h"
#import "TextCell.h"
#import "TextCellWithMinusButton.h"
#import "DatabaseHandler.h"


bool tvalidPhoneNumberToken(char c){
    return ((c >= '0') && (c <= '9')) || (c == '+') || (c == '#') || (c == '*');
}
bool tvalidPhoneNumber(NSString *s){
    char *ns = (char *)s.UTF8String;
    for (NSUInteger i = 0; i < s.length; ++i)
        if(!tvalidPhoneNumberToken(ns[i]))
            return false;
    return true;
}

bool tisValidEmail(NSString *s){
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:s];
}

@interface EditingDirectoryViewController()<TextCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@end

@implementation EditingDirectoryViewController
{
    BOOL isNew;
    DatabaseFile *f;
    BOOL done;
    BOOL imageChanged;
}
@synthesize f = f;

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)prepareForRecall:(UIImage *)i andE:(NSError *)e andV:(void *)v
{
    NSLog(@"save image succeed!");
}
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *i = [info objectForKey:UIImagePickerControllerEditedImage];
#pragma warning do not set here
//    [f setImage:i];
    _doneButton.enabled = YES;
    done = YES;
    [[(ImageCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] imageButton] setBackgroundImage:i forState:UIControlStateNormal];
    imageChanged = YES;
    [self.tableView reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)pressDone:(id)sender {
//    void(^changeEmptyToNil)(NSString *s) = ^(NSString *s){
//        if ([s isEqualToString:@""])
//            s = nil;
//    };
    [self fillAllContent];
    if ([f.name isEqualToString:@""])
        f.name = nil;
    if ([f.birthday isEqualToString:@""])
        f.birthday = nil;
    if ([f.remarks isEqualToString:@""])
        f.remarks = nil;
    if (!f.name){
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Invalid Operation" message:@"A directory must at least have a name" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *a = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDestructive handler:nil];
        [ac addAction:a];
        
        [self presentViewController:ac animated:YES completion:nil];
        return;
    }
    
    if (isNew)
        f.pid = [DatabaseHandler assignNextPID];
    
    if (imageChanged){
        UIImage *i = [(ImageCell *)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] imageButton].currentBackgroundImage;
        [f setImage:i];
    }
    
    void(^removeNotMeaningfulObjects)(NSMutableArray *a) = ^(NSMutableArray<NSString *> *a){
        for (NSUInteger i = 0; i < a.count; ++i)
            if ([[a objectAtIndex:i] isEqualToString:@""]){
                [a removeObjectAtIndex:i];
                --i;
            }
    };
    void(^checkAllValidity)(void) = ^{
        for (NSUInteger i = 0; i < self->f.phoneNumberList.count; ++i)
            if (!tvalidPhoneNumber([self->f.phoneNumberList objectAtIndex:i]))
                @throw [NSException exceptionWithName:@"Invalid Operation" reason:@"Invalid Phone Number" userInfo:nil];
        
        for (NSUInteger i = 0; i < self->f.emailList.count; ++i)
            if (!tisValidEmail([self->f.emailList objectAtIndex:i]))
                @throw [NSException exceptionWithName:@"Invalid Operation" reason:@"Invalid E-mail Address" userInfo:nil];
    };
    
    removeNotMeaningfulObjects(f.phoneNumberList);
    removeNotMeaningfulObjects(f.emailList);
    
    if (!isNew)
        [DatabaseHandler deleteWithPID:f.pid];
    NSLog(@"clear finished!");
    @try{
        checkAllValidity();
    }
    @catch(NSException *e){
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:e.name message:e.reason preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *a = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDestructive handler:nil];
        [ac addAction:a];
        
        [self presentViewController:ac animated:YES completion:nil];
        return;
    }
    [DatabaseHandler insertWithDatabaseFile:f];
    toPass = f;
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad{
    if (toPass)
        isNew = false;
    else{
        isNew = true;
        toPass = [DatabaseFile new];
    }
    imageChanged = false;
    f = [toPass copy];
    done = false;
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
        case 1:
            return 1; //name
        case 2:
            return f.phoneNumberList.count + 1;
        case 3:
            return f.emailList.count + 1;
        case 4:
            return 2;
        default:
            @throw [NSException exceptionWithName:@"section index out of range" reason:nil userInfo:nil];
    }
}
- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath.section)
        return 270;
    return 45;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 20;
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger s = indexPath.section;
    if (!s){
        ImageCell *c = [tableView dequeueReusableCellWithIdentifier:@"image cell"];
        if (!c)
            c = [[ImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"image cell"];
        c.delegate = self;
        if (!isNew){
            UIImage *img = [f getImage];
            if (img)
                [c.imageButton setBackgroundImage:img forState:UIControlStateNormal];
        }
        return c;
    }
    if(s == 1 || s == 4){
        TextCell *c = [tableView dequeueReusableCellWithIdentifier:@"text cell"];
        if (!c)
            c = [[TextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"text cell"];
        c.delegate = self;
        c.indexPath = indexPath;
        if (s == 1){
            c.descriptionLabel.text = @"name";
            c.textField.placeholder = @"full name";
            c.textField.text = f.name;
            return c;
        }
        if (s == 4){
            if (indexPath.row){
                c.descriptionLabel.text = @"remarks";
                c.textField.placeholder = @"place a remarks about this people";
                c.textField.text = f.remarks;
                return c;
            }
            c.descriptionLabel.text = @"birthday";
            c.textField.placeholder = @"mm-dd, yyyy";
            c.textField.text = f.birthday;
            return c;
        }
    }
    if (indexPath.row == [self tableView:self.tableView numberOfRowsInSection:s] - 1){
        PlusCell *c = [tableView dequeueReusableCellWithIdentifier:@"plus cell"];
        if (!c)
            c = [[PlusCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"plus cell"];
        c.delegate = self;
        c.indexPath = indexPath;
        return c;
    }
    TextCellWithMinusButton *c = [tableView dequeueReusableCellWithIdentifier:@"minusable cell"];
    if (!c)
        c = [[TextCellWithMinusButton alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"minusable cell"];
    c.delegate = self;
    c.indexPath = indexPath;
    if (s == 2){ //phone number
        c.descriptionLabel.text = @"phone";
        c.textField.placeholder = @"phone number";
        c.textField.text = [f.phoneNumberList objectAtIndex:indexPath.row];
    }
    else{
        c.descriptionLabel.text = @"email";
        c.textField.placeholder = @"e-mail address";
        c.textField.text = [f.emailList objectAtIndex:indexPath.row];
    }
    return c;
}

- (IBAction)clickCancel:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)editDidChangedAtPath:(NSIndexPath *)indexPath
{
    if (!done){
        done = YES;
        self.doneButton.enabled = YES;
    }
}
- (void)fillAllContent
{
    [self fillContentForSection:1 andRow:0];
    [self fillContentForSection:4 andRow:0];
    [self fillContentForSection:4 andRow:1];
    for (NSUInteger i = 0; i < f.phoneNumberList.count; ++i)
        [self fillContentForSection:2 andRow:i];
    
    for (NSUInteger i = 0; i < f.emailList.count; ++i)
        [self fillContentForSection:3 andRow:i];

}
- (void)fillContentForSection:(NSInteger)s andRow:(NSInteger)r{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:r inSection:s];
    NSString *(^getContentText)(void) = ^NSString *{
        if ([[self.tableView cellForRowAtIndexPath:indexPath] isKindOfClass:[TextCell class]])
            return [(TextCell *)[self.tableView cellForRowAtIndexPath:indexPath] textField].text;
        else
            return [(TextCellWithMinusButton *)[self.tableView cellForRowAtIndexPath:indexPath] textField].text;
    };
    
    if (s == 1)
        f.name = getContentText();
    else if (s == 4)
        if (r == 0)
            f.birthday = getContentText();
        else
            f.remarks = getContentText();
        else if (s == 2)
            [f.phoneNumberList replaceObjectAtIndex:r withObject:getContentText()];
        else
            [f.emailList replaceObjectAtIndex:r withObject:getContentText()];
}
- (void)editDidEndAtPath:(NSIndexPath *)indexPath {
}

- (void)imageDidPressed {
    UIImagePickerController *c = [UIImagePickerController new];
    c.delegate = self;
    c.allowsEditing = YES;
    
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Select Media" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *atpa = [UIAlertAction actionWithTitle:@"Saved Photos Album" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self fillAllContent];
        c.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        [self presentViewController:c animated:YES completion:nil];
    }];
    
    UIAlertAction *atpl = [UIAlertAction actionWithTitle:@"Photo Library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        [self fillAllContent];
        c.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:c animated:YES completion:nil];
    }];
    
    [ac addAction:atpa];
    [ac addAction:atpl];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:nil];
    [ac addAction:cancel];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        UIAlertAction *atc = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [self fillAllContent];
            c.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:c animated:YES completion:nil];
        }];
        [ac addAction:atc];
    }
    
    [self presentViewController:ac animated:YES completion:nil];
}

- (void)minusDidPressedAtPath:(NSIndexPath *)indexPath {
    if (!done){
        done = YES;
        _doneButton.enabled = YES;
    }
    [self fillAllContent];
    if (indexPath.section == 2)
        [f.phoneNumberList removeObjectAtIndex:indexPath.row];
    else
        [f.emailList removeObjectAtIndex:indexPath.row];
    [self.tableView reloadData];
}

- (void)plusButtonDidPressedAtPath:(NSIndexPath *)indexPath {
    [self fillAllContent];
    if (indexPath.section == 2){
        [f.phoneNumberList addObject:@""];
        NSLog(@"objects count: %lu", (unsigned long)f.phoneNumberList.count);
    }
    else
        [f.emailList addObject:@""];
    
    [self.tableView reloadData];
}


@end
