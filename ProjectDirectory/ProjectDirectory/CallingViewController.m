//
//  SecondViewController.m
//  ProjectDirectory
//
//  Created by ssyram on 2018/6/10.
//  Copyright © 2018 ssyram. All rights reserved.
//

#import "CallingViewController.h"
#import "DatabaseHandler.h"
#import "IsCallingViewController.h"
#import <sqlite3.h>


@interface CallingViewController ()

@end

@implementation CallingViewController
{
    NSArray<DatabaseFile *> *sData; //search data
    NSArray<DatabaseFile *> *tData; //total data
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    void(^turningRound)(void) = ^{
        self.b1.layer.cornerRadius = 75.0/2;
        self.b2.layer.cornerRadius = 75.0/2;
        self.b3.layer.cornerRadius = 75.0/2;
        self.b4.layer.cornerRadius = 75.0/2;
        self.b5.layer.cornerRadius = 75.0/2;
        self.b6.layer.cornerRadius = 75.0/2;
        self.b7.layer.cornerRadius = 75.0/2;
        self.b8.layer.cornerRadius = 75.0/2;
        self.b9.layer.cornerRadius = 75.0/2;
        self.b0.layer.cornerRadius = 75.0/2;
        self.bs.layer.cornerRadius = 75.0/2;
        self.bsharp.layer.cornerRadius = 75.0/2;
        self.bc.layer.cornerRadius = 75.0/2;
        self.bp.layer.cornerRadius = 75.0/2;
    };
    
    turningRound();
    self.bbw.hidden = YES;
}

- (IBAction)tb1 {
    [self appendContent:@"1"];
}
- (IBAction)tb2 {
    [self appendContent:@"2"];
}
- (IBAction)tb3 {
    [self appendContent:@"3"];
}
- (IBAction)tb4 {
    [self appendContent:@"4"];
}
- (IBAction)tb5 {
    [self appendContent:@"5"];
}
- (IBAction)tb6 {
    [self appendContent:@"6"];
}
- (IBAction)tb7 {
    [self appendContent:@"7"];
}
- (IBAction)tb8 {
    [self appendContent:@"8"];
}
- (IBAction)tb9 {
    [self appendContent:@"9"];
}
- (IBAction)tb0 {
    [self appendContent:@"0"];
}
- (IBAction)tbs {
    [self appendContent:@"*"];
}
- (IBAction)tbsharp {
    [self appendContent:@"#"];
}
- (IBAction)tbc {
    [self call];
}
- (IBAction)tbbw {
    [self backward];
}

- (void)call{
    if(_bbw.hidden)
        return;
    
//    //declaration
    DatabaseFile *(^searchForNumber)(NSString *number) = ^DatabaseFile *(NSString *number){
        for (NSUInteger i = 0; i < directoryData.count; ++i)
            for (NSUInteger j = 0; j < [directoryData objectAtIndex:i].phoneNumberList.count; ++j)
                if ([[[directoryData objectAtIndex:i].phoneNumberList objectAtIndex:j] isEqualToString:number])
                    return [directoryData objectAtIndex:i];
        return nil;
    };
//    void(^turnToIsCallingViewController)(DatabaseFile *, NSString *) = ^(DatabaseFile *f, NSString *number){
//        IsCallingViewController *c = [self.storyboard instantiateViewControllerWithIdentifier:@"is calling"];
//        void (^completion)(void) = ^{
//            if(f && [f getImage]){
//                c.imageDisplay.image = [f getImage];
//                c.phoneNumberDisplay.text = f.name;
//            }
//            else
//                c.phoneNumberDisplay.text = number;
//        };
//
//
//
//        [self presentViewController:c
//                           animated:YES
//                         completion:completion];
//    };
//
//
//
//
//    //formally do
//    DatabaseFile *f = searchForNumber(_d.text);
//    turnToIsCallingViewController(f, _d.text);
    
    DatabaseFile *f = searchForNumber(_d.text);
    if (!f){
        f = [DatabaseFile new];
        f.name = _d.text;
    }
    toPass = f;
    
    IsCallingViewController *c = [self.storyboard instantiateViewControllerWithIdentifier:@"is calling"];
    [self presentViewController:c animated:YES completion:nil];
}
- (IBAction)tbp:(id)sender {
    [self appendContent:@"+"];
}
- (void)appendContent:(NSString *)content{
    if(!_d.text.length)
        _bbw.hidden = NO;
    _d.text = [_d.text stringByAppendingString:content];
}

- (void)backward{
    _d.text = [_d.text substringToIndex:_d.text.length - 1];
    if(!_d.text.length)
        _bbw.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
