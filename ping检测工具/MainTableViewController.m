//
//  MainTableViewController.m
//  ping检测工具
//
//  Created by 方景琦 on 2016/12/6.
//  Copyright © 2016年 Retouch. All rights reserved.
//

#import "MainTableViewController.h"

#import "STDebugFoundation.h"
#import "STDPingServices.h"


@interface MainTableViewController (){
    BOOL isStart;
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *leftBarBtn;

@property (weak, nonatomic) IBOutlet UITextField *ipAdressTf;

@property (weak, nonatomic) IBOutlet UILabel *startOrStop;
@property (weak, nonatomic) IBOutlet UITextField *monitorTimeTf;
@property (weak, nonatomic) IBOutlet STDebugTextView *consoleTextView;


@property(nonatomic, strong) STDPingServices    *pingServices;

@end

@implementation MainTableViewController

- (void)dealloc {
    [self.pingServices cancel];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    isStart = YES;
}

- (IBAction)selectIPAcion:(id)sender {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"IP地址的选择,现只提供开放的几个IP地址,也可自定义填写" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *takePhotoAction = [UIAlertAction actionWithTitle:@"客户服务器IP地址" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        self.ipAdressTf.text = @"117.78.49.136";
        
    }];
    
    UIAlertAction *photoAction = [UIAlertAction actionWithTitle:@"开发服务器IP地址" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        self.ipAdressTf.text = @"117.78.48.143";
    }];
    
    
    UIAlertAction *testAction = [UIAlertAction actionWithTitle:@"测试服务器IP地址" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.ipAdressTf.text = @"117.78.48.140";
        
    }];

    
    
    
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertVC addAction:takePhotoAction];
    [alertVC addAction:photoAction];
    [alertVC addAction:testAction];
    [alertVC addAction:cancleAction];
    [self presentViewController:alertVC animated:YES completion:nil];

}


- (void)pingActionFired {
    [self.ipAdressTf resignFirstResponder];
    if (isStart) {
        
        self.consoleTextView.text = nil;
        
        __weak MainTableViewController *weakSelf = self;
        self.startOrStop.text = @"Stop";
        
        isStart = NO;
        self.pingServices = [STDPingServices startPingAddress:self.ipAdressTf.text monitorTime:[self.monitorTimeTf.text intValue] callbackHandler:^(STDPingItem *pingItem, NSArray *pingItems) {
            
            
            if (pingItem.status != STDPingStatusFinished) {
                [weakSelf.consoleTextView appendText:pingItem.description];
                
            } else {
                
                [weakSelf.consoleTextView appendText:[STDPingItem statisticsWithPingItems:pingItems]];
                self.startOrStop.text = @"Go to Test";
                isStart = YES;
                weakSelf.pingServices = nil;
            }
            
        }];

    }else{
        [self.pingServices cancel];

    }
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
        [self pingActionFired];
    }
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
