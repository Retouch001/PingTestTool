//
//  HistoricalReportTableViewController.m
//  ping检测工具
//
//  Created by 方景琦 on 2016/12/7.
//  Copyright © 2016年 Retouch. All rights reserved.
//

#import "HistoricalReportTableViewController.h"
#import "STDPingServices.h"
#import "HistoricalReportTableViewCell.h"
#import "OriginalDataTableViewController.h"
#import "ScreenDataTableViewController.h"

#import "SVProgressHUD.h"

#define UIColorFromHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s & 0xFF00) >> 8))/255.0 blue:((s & 0xFF))/255.0  alpha:1.0]


@interface HistoricalReportTableViewController (){
    YYCache *cache;
}

@property(nonatomic,strong)NSMutableArray *dataArray;

@end

@implementation HistoricalReportTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setMinimumDismissTimeInterval:1];
    
    cache = [YYCache cacheWithName:@"mydb"];

}


-(void)viewWillAppear:(BOOL)animated{
    
    
    [cache objectForKey:@"pingItemArray" withBlock:^(NSString * _Nonnull key, id<NSCoding>  _Nonnull object) {
                
        if (object) {
            self.dataArray = (NSMutableArray *)object;
        }else{
            self.dataArray = [NSMutableArray array];
        }
        
        [self.tableView reloadData];
    }];
}


-(NSString*)changeDateToStringWithDate:(NSDate *)date {
    
    NSDateFormatter*formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyy-MM-dd HH:mm:ss"];
    
    NSString*dateTime = [formatter stringFromDate:date];
    
    return dateTime;
    
}

- (IBAction)deleteAllData:(id)sender {
    
    dispatch_queue_t queue = dispatch_get_main_queue();

    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"警告" message:@"此操作将删除你本地保存的所有数据且不可恢复,请慎重选择" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        [cache removeAllObjectsWithProgressBlock:^(int removedCount, int totalCount) {
            
            dispatch_async(queue, ^{
                
                [SVProgressHUD showProgress:removedCount status:@"正在删除中..."];
                
            });

            
            
        } endBlock:^(BOOL error) {
            
            dispatch_async(queue, ^{
                
                
                self.dataArray = [NSMutableArray array];
                [self.tableView reloadData];
                
                [SVProgressHUD showSuccessWithStatus:@"完成"];

             });
            

        }];
        
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        
    }];

    
    
    [alert addAction:action];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HistoricalReportTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSArray *array = [self.dataArray objectAtIndex:indexPath.row];
    
    STDPingItem *item ;
    for (STDPingItem *tempItem in array) {
        if (tempItem.IPAddress) {
            item = tempItem;
            break;
        }
    }
    
    
    
    cell.startTimeLable.text = [self changeDateToStringWithDate:item.date];
    cell.ipLabel.text = [NSString stringWithFormat:@"IP:%@",item.IPAddress];
    
    __block NSInteger receivedCount = 0, allCount = 0;
    __block double allTimeMilliseconds = 0.,heighestTimeMilliseconds = 0,lowestTimeMilliseconds = 100000;
    [array enumerateObjectsUsingBlock:^(STDPingItem *obj, NSUInteger idx, BOOL *stop) {
        
        if (obj.status != STDPingStatusFinished && obj.status != STDPingStatusError) {
            
            allCount ++;
            if (obj.status == STDPingStatusDidReceivePacket) {
                receivedCount ++;
                
                allTimeMilliseconds += obj.timeMilliseconds;
                
                heighestTimeMilliseconds = obj.timeMilliseconds>heighestTimeMilliseconds?obj.timeMilliseconds:heighestTimeMilliseconds;
                lowestTimeMilliseconds = obj.timeMilliseconds<lowestTimeMilliseconds?obj.timeMilliseconds:lowestTimeMilliseconds;
            }
            
            
        }
    }];
    CGFloat lossPercent = (CGFloat)(allCount - receivedCount) / MAX(1.0, allCount) * 100;
    double averageTimeMilliSeconds = (double)(allTimeMilliseconds/receivedCount);


    cell.packetLossLable.text = [NSString stringWithFormat:@"丢包率:%.1f%%",lossPercent];
    cell.h_delayLabel.text = [NSString stringWithFormat:@"最高延迟时间:%.1fms",heighestTimeMilliseconds];
    cell.l_delayLabel.text = [NSString stringWithFormat:@"最低延迟时间:%.1fms",lowestTimeMilliseconds];
    cell.averageDelayTimeLable.text = [NSString stringWithFormat:@"平均延迟时间:%.1fms",averageTimeMilliSeconds];
    
    cell.scoreLabel.text = [NSString stringWithFormat:@"%d",[self calcucateNetworkScoreWithItemArray:array]];
    
    
    
    
    return cell;
}





-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *array = [self.dataArray objectAtIndex:indexPath.row];

    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"原始数据被存储到了本地,每段数据为一整体" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *takePhotoAction = [UIAlertAction actionWithTitle:@"查看原始数据" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        OriginalDataTableViewController *viewController =     [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"hello"];
        
        viewController.itemArray = array;
        

        
        //[self presentViewController:viewController animated:YES completion:NULL];
        [self.navigationController pushViewController:viewController animated:YES];

        
    }];
    
    UIAlertAction *photoAction = [UIAlertAction actionWithTitle:@"自定义筛选数据" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        
        ScreenDataTableViewController *viewController =  [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"hello1"];
        
        viewController.itemArray = (NSMutableArray *)array;

        [self.navigationController pushViewController:viewController animated:YES];
    }];
    
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertVC addAction:takePhotoAction];
    [alertVC addAction:photoAction];
    [alertVC addAction:cancleAction];
    [self presentViewController:alertVC animated:YES completion:nil];
    
    
    return;

}



-(int)calcucateNetworkScoreWithItemArray:(NSArray *)array{
    
    int worst = 0 , worse = 0 ,better = 0,most = 0 ,noResponse = 0;
    
    for (STDPingItem *tempItem in array) {
        
        if (tempItem.status == 4) {
            noResponse ++;
        }
        
        if (tempItem.timeMilliseconds>200) {
            worst++;
        }else if (tempItem.timeMilliseconds > 100&&tempItem.timeMilliseconds <= 200){
            worse ++;
        }else if (tempItem.timeMilliseconds >50 &&tempItem.timeMilliseconds <= 100){
            better++;
        }else{
            most++;
        }
    }
    
    double worstPercent = (double) worst/array.count;
    double wosePercent =  (double)worse/array.count;
    double betterPercent =  (double)better/array.count;
    //double mostPercent =  (double)most/array.count;
    double noResponsePercent = (double)noResponse/array.count;
    
    double score = 100-worstPercent*100-(wosePercent/2)*100-(betterPercent/4)*100-(noResponsePercent*2)*100;
    
//    Retouch_Log(@"%f------%f----%f---------%f",worstPercent,wosePercent,betterPercent,noResponsePercent);
    
    return score<0?0:score;
}



- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    // 添加一个删除按钮
    UITableViewRowAction *deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        // 1. 更新数据
        
        [self.dataArray removeObjectAtIndex:indexPath.row];
        
        
        [cache setObject:self.dataArray forKey:@"pingItemArray"];
        
        
        // 2. 更新UI
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    }];
    
    //这个可以用来刷新特定行
    //[tableView reloadRowsAtIndexPaths:@[indexPath]withRowAnimation:UITableViewRowAnimationAutomatic];
    
    UITableViewRowAction *topRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"置顶" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        // 1. 更新数据
        
        [self.dataArray exchangeObjectAtIndex:indexPath.row withObjectAtIndex:0];
        
        
        [cache setObject:self.dataArray forKey:@"pingItemArray"];
        
        
        // 2. 更新UI
        
        NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:indexPath.section];
        
        [tableView moveRowAtIndexPath:indexPath toIndexPath:firstIndexPath];
        
        
    }];
    deleteRowAction.backgroundColor = UIColorFromHex(0xD83938);
    topRowAction.backgroundColor = UIColorFromHex(0x3190e8);
    
    return @[deleteRowAction, topRowAction];
    
}




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
