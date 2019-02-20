//
//  HistoricalReportTableViewCell.h
//  ping检测工具
//
//  Created by 方景琦 on 2016/12/7.
//  Copyright © 2016年 Retouch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoricalReportTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *ipLabel;
@property (weak, nonatomic) IBOutlet UILabel *startTimeLable;
@property (weak, nonatomic) IBOutlet UILabel *packetLossLable;
@property (weak, nonatomic) IBOutlet UILabel *averageDelayTimeLable;
@property (weak, nonatomic) IBOutlet UILabel *h_delayLabel;
@property (weak, nonatomic) IBOutlet UILabel *l_delayLabel;
@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;

@end
