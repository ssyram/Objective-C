//
//  FirstViewController.m
//  ProjectDirectory
//
//  Created by ssyram on 2018/6/10.
//  Copyright © 2018 ssyram. All rights reserved.
//

#import "MainDirectoryViewController.h"
#import "EditingDirectoryViewController.h"
#import "DatabaseHandler.h"
#import "DetailDirectoryViewController.h"


@interface MainDirectoryViewController ()<UISearchControllerDelegate, UISearchResultsUpdating>

@end

@implementation MainDirectoryViewController
{
    NSArray<DatabaseFile *> *sdata; //search data
    UISearchController *sc;
}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    void (^initSearchController)(void) = ^{
        self->sc = [[UISearchController alloc] initWithSearchResultsController:nil];
        self->sc.delegate = self;
        self->sc.searchResultsUpdater = self;
        self->sc.dimsBackgroundDuringPresentation = NO;
        self.tableView.tableHeaderView = self->sc.searchBar;
    };
    
    NSString *dPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *fullPath = [dPath stringByAppendingPathComponent:@"imageContent"];
//    [[NSFileManager defaultManager] removeItemAtPath:fullPath error:nil];
    [[NSFileManager defaultManager] createDirectoryAtPath:fullPath withIntermediateDirectories:NO attributes:nil error:nil];
    
    initSearchController();
    
//    [[NSFileManager defaultManager] removeItemAtPath:[DatabaseHandler databasePath] error:nil];
    
    BOOL isNew = [[NSFileManager defaultManager] fileExistsAtPath:[DatabaseHandler databasePath]];
    
    [DatabaseHandler tryInitTables];
    directoryData = [DatabaseHandler getInitData];
    if (!isNew)
        [self tryAppendSomeRecord];
}

- (void)tryAppendSomeRecord{
    DatabaseFile *longaotian = [DatabaseFile new];
    longaotian.pid = [DatabaseHandler assignNextPID];
    longaotian.name = [NSString stringWithUTF8String:"aotian long"];
    [longaotian setBirthdayWithYear:1000 andMonth:1 andDay:1];
    longaotian.remarks = [NSString stringWithUTF8String:"king"];
    [longaotian addPhoneNumber:@"++123456789++"];
    [longaotian addEmail:@"aotian@long.com"];
    
    DatabaseFile *zhaoritian = [DatabaseFile new];
    zhaoritian.pid = [DatabaseHandler assignNextPID];
    zhaoritian.name = [NSString stringWithUTF8String:"rt zhao"];
    [zhaoritian addPhoneNumber:@"*+1257+*"];
    
    DatabaseFile *caocao = [DatabaseFile new];
    caocao.pid = [DatabaseHandler assignNextPID];
    caocao.name = [NSString stringWithUTF8String:"cao cao"];
    [caocao addPhoneNumber:@"9999+"];
    
    DatabaseFile *soseki = [DatabaseFile new];
    soseki.pid = [DatabaseHandler assignNextPID];
    soseki.name = @"soseki natsume";
    [soseki addPhoneNumber:@"5464897+"];
    soseki.remarks = @"tsuki ga kirei";
    
    [DatabaseHandler insertWithDatabaseFile:longaotian];
    [DatabaseHandler insertWithDatabaseFile:zhaoritian];
    [DatabaseHandler insertWithDatabaseFile:caocao];
    [DatabaseHandler insertWithDatabaseFile:soseki];
    [self.tableView reloadData];
}

- (IBAction)clickPlus:(id)sender {
    EditingDirectoryViewController *c = [self.storyboard instantiateViewControllerWithIdentifier:@"edit view controller"];
    
    toPass = nil;
    void(^completion)(void) = ^{
    };
    
    [self presentViewController:c animated:YES completion:completion];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DatabaseFile *f = sc.active ? [sdata objectAtIndex:indexPath.row] : [directoryData objectAtIndex:indexPath.row];
    UITableViewCell *c = [tableView dequeueReusableCellWithIdentifier:@"directory cell"];
    
    UIImage *img = [f getImage];
    if (img)
        c.imageView.image = img;
    
    c.textLabel.text = f.name;
    
    if (f.phoneNumberList.count)
        c.detailTextLabel.text = f.phoneNumberList.firstObject;
    
    return c;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DatabaseFile *f = sc.active ? [sdata objectAtIndex:indexPath.row] : [directoryData objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"open detail directory" sender:f];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"open detail directory"]){
        if (sc.active)
            sc.active = NO;
        toPass = sender;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    sdata = [directoryData filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name contains %@", sc.searchBar.text]];
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [DatabaseHandler deleteWithIndex:indexPath.row];
        [self.tableView reloadData];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return sc.active ? sdata.count : directoryData.count;
}

@end
