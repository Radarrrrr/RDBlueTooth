//
//  ViewController.m
//  RDBlueToothDemo
//
//  Created by radar on 2018/3/17.
//  Copyright © 2018年 radar. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UITableView *listTable;
@property (nonatomic, copy)   NSArray *listArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    float w = [UIScreen mainScreen].bounds.size.width;
    float h = [UIScreen mainScreen].bounds.size.height;
    
    self.listTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, w, h) style:UITableViewStyleGrouped];
    _listTable.backgroundColor = [UIColor whiteColor];
    _listTable.delegate = self;
    _listTable.dataSource = self;
    [self.view addSubview:_listTable];
    
    //开始扫描设备
    [[RDBlueTooth sharedInstance] startScaningForTarget:self];
}


- (void)RDBlueToothDidDiscoverNewPeripheral:(NSDictionary*)periDic allDiscoveredPeripherals:(NSMutableArray*)allPeriDics
{
    self.listArray = allPeriDics;
    [_listTable reloadData];
}




#pragma mark -
#pragma mark Table View DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [_listArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *kCellID = @"listCell";
    
    UITableViewCell *cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:kCellID];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellID];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        
    }
    
    //：@{@"peripheral":peripheral, @"RSSI":RSSI, @"advertisementData":advertisementData}
    
    NSDictionary *dict = _listArray[indexPath.row];
    CBPeripheral *per  = [dict objectForKey:@"peripheral"];
    NSNumber *rssi     = [dict objectForKey:@"RSSI"];
    
    cell.textLabel.text = per.name;
    cell.detailTextLabel.text = [rssi stringValue];
    
    return cell;
}


#pragma mark -
#pragma mark Table View Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}



@end
