//
// Created by ssyram on 2018/6/12.
// Copyright (c) 2018 ssyram. All rights reserved.
//

#import "DetailDirectoryViewController.h"
#import "EditingDirectoryViewController.h"
#import "IsCallingViewController.h"
#import "DatabaseHandler.h"

@interface DetailDirectoryViewController()
@end

@implementation DetailDirectoryViewController
{
    DatabaseFile *f;
}
@synthesize f = f;
- (void)viewDidLoad
{
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    int section3Rows = 0;
    switch (section) {
        case 0:
            return 2;
        case 1:
            return self.f.phoneNumberList.count;
        case 2:
            return self.f.emailList.count;
        case 3:
            if (self.f.birthday)
                ++section3Rows;
            if (self.f.remarks)
                ++section3Rows;
            return section3Rows;
        default:
            break;
    }
    @throw [NSException exceptionWithName:@"section out of range" reason:nil userInfo:nil];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (toPass)
        f = toPass;
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath.section && !indexPath.row)
        return 200;
    return 75;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *c = (indexPath.section == 0 && indexPath.row == 0) ? [tableView dequeueReusableCellWithIdentifier:@"icon & name cell"] : [tableView dequeueReusableCellWithIdentifier:@"detail cell"];
    UIImage *img;
    switch (indexPath.section) {
        case 0:
            if (!indexPath.row){
                img = [f getImage];
                if (img)
                    c.imageView.image = img;
                c.textLabel.text = nil;
                break;
            }
            c.textLabel.text = @"name";
            c.detailTextLabel.text = f.name;
            break;
        case 1:
            c.textLabel.text = @"phone number";
            c.detailTextLabel.text = [f.phoneNumberList objectAtIndex:indexPath.row];
            break;
        case 2:
            c.textLabel.text = @"email";
            c.detailTextLabel.text = [f.emailList objectAtIndex:indexPath.row];
            break;
        case 3:
            if (indexPath.row == 1 || !f.birthday){
                c.textLabel.text = @"remarks";
                c.detailTextLabel.text = f.remarks;
            }
            else{
                c.textLabel.text = @"birthday";
                c.detailTextLabel.text = f.birthday;
            }
            break;
        default:
            @throw [NSException exceptionWithName:@"path out of range" reason:nil userInfo:nil];
    }
    return c;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1){
        IsCallingViewController *c = [self.storyboard instantiateViewControllerWithIdentifier:@"is calling"];
        [self presentViewController:c animated:YES completion:^{
            
        }];
    }
}

- (IBAction)clickEditButton:(id)sender {
    EditingDirectoryViewController *c = [self.storyboard instantiateViewControllerWithIdentifier:@"edit view controller"];
    toPass = self->f;
    void(^completion)(void) = ^{
        
    };
    
    [self presentViewController:c animated:YES completion:completion];
}

@end
