//
//  ScreenDataTableViewController.m
//  ping检测工具
//
//  Created by 方景琦 on 2016/12/8.
//  Copyright © 2016年 Retouch. All rights reserved.
//

#import "ScreenDataTableViewController.h"
#import "ScreenDataTableViewCell.h"
#import "STDPingServices.h"

#define UIColorFromHex(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s & 0xFF00) >> 8))/255.0 blue:((s & 0xFF))/255.0  alpha:1.0]



@interface ScreenDataTableViewController ()
@property (weak, nonatomic) IBOutlet UITextField *smallValueTf;
@property (weak, nonatomic) IBOutlet UITextField *largeValueTf;

@property(nonatomic,strong)NSMutableArray *resultArray;

@end

@implementation ScreenDataTableViewController

-(void)viewWillAppear:(BOOL)animated{
    self.resultArray = [NSMutableArray array];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self.tableView registerNib:[UINib nibWithNibName:@"ScreenDataTableViewCell" bundle:nil] forCellReuseIdentifier:@"staticCell"];
    
}
- (IBAction)searchAction:(id)sender {
    self.resultArray = [NSMutableArray array];

    
    for (STDPingItem *item in self.itemArray) {
        if (item.timeMilliseconds >= [self.smallValueTf.text intValue]&&item.timeMilliseconds <= [self.largeValueTf.text intValue]) {
            [self.resultArray addObject:item];
        }
    }
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 1) {
        return self.resultArray.count;
    }
    
    return [super tableView:tableView numberOfRowsInSection:section];
}



- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        return [super tableView:tableView indentationLevelForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    }
    return [super tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section == 1&&self.resultArray.count>0) {
        
        
        float result = (float)self.resultArray.count/(self.itemArray.count-1);
        
        Retouch_Log(@"%f---%lu----%lu",result,(unsigned long)self.resultArray.count,(unsigned long)self.itemArray.count-1);
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
        label.text = [NSString stringWithFormat:@"   搜索的数据数量占总数据量的%.1f%%",result*100];
        label.textColor = [UIColor lightGrayColor];
        label.font = [UIFont systemFontOfSize:13];
        
        return label;
    }
    return [super tableView:tableView viewForHeaderInSection:section];
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        return 50;
    }
    return [super tableView:tableView heightForHeaderInSection:section];

}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 1) {
        ScreenDataTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"staticCell" forIndexPath:indexPath];
        
        STDPingItem *item = [self.resultArray objectAtIndex:indexPath.row];
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@---延迟时间%.f---第%ld个数据(%lu)",[self changeDateToStringWithDate:item.date],item.timeMilliseconds,(long)item.ICMPSequence,(unsigned long)self.itemArray.count-1];
        cell.textLabel.textColor = UIColorFromHex(0x999999);
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        return cell;
        
    }
    
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 1) {
        return 50;
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


-(NSString*)changeDateToStringWithDate:(NSDate *)date {
    
    NSDateFormatter*formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyy-MM-dd HH:mm:ss"];
    
    NSString*dateTime = [formatter stringFromDate:date];
    
    return dateTime;
    
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
