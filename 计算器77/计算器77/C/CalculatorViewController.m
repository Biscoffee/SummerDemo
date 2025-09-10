//
//  CalculatorViewController.m
//  计算器77
//
//  Created by 吴桐 on 2025/7/26.
//
#import "CalculatorViewController.h"
#import "View.h"
#import "CalculatorModel.h"
#define WIDTH  [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

@interface CalculatorViewController ()<ViewDelegate>
@property (nonatomic, strong) View* calView;
@property (nonatomic, strong) CalculatorModel* model;
@property (nonatomic, strong) NSMutableArray* calArray;
@property (nonatomic, assign) BOOL pointFlag;
@property (nonatomic, assign) BOOL operatorFlag;
@property (nonatomic, assign) BOOL equalFlag;
@property (nonatomic, assign) NSInteger left;
@property (nonatomic, assign) NSInteger right;
@end

@implementation CalculatorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _calView = [[View alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    _calView.delegate = self;
    [self.view addSubview:_calView];

    self.model = [[CalculatorModel alloc] init];
    self.calArray = [NSMutableArray array];

    self.pointFlag = NO;
    self.operatorFlag = NO;
    self.equalFlag = NO;
    self.left = 0;
    self.right = 0;
}


- (void)pressChange:(UIButton *)button {
    NSString *title = button.currentTitle;
    NSLog(@"按钮被点击: %@", title);
    
    if (self.equalFlag) {
        if ([title isEqualToString:@"="]) {
            return;
        } else if ([self isOperator:title]) {
            self.equalFlag = NO;
        } else {
            [self.calArray removeAllObjects];
            self.equalFlag = NO;
        }
    }
    if ([title isEqualToString:@"AC"]) {
        self.calView.topLabel.text = @"0";
        [self.calArray removeAllObjects];
        self.pointFlag = NO;
        self.operatorFlag = NO;
        self.equalFlag = NO;
        self.left = 0;
        self.right = 0;
        return;
    } else if ([title isEqualToString:@"="]) {
        if (self.left != self.right) {
            NSLog(@"当前左括号数量 left = %ld，右括号数量 right = %ld", (long)self.left, (long)self.right);

            self.calView.topLabel.text = @"ERROR brackets not match!";
            return;
        }
        if (self.calArray.count == 0) {
            self.calView.topLabel.text = @"0";
            
            return;
        }

        NSString *last = [self.calArray lastObject];
        if ([self isOperator:last] || [last isEqualToString:@"("]) {
            self.calView.topLabel.text = @"ERROR，NO Calculator or (";
            return;
        }
        NSString *expression = [self.calArray componentsJoinedByString:@""];
        expression = [expression stringByReplacingOccurrencesOfString:@"×" withString:@"*"];
        expression = [expression stringByReplacingOccurrencesOfString:@"÷" withString:@"/"];

        NSLog(@"计算表达式：%@", expression);
        NSLog(@"当前左括号数量 left = %ld，右括号数量 right = %ld", (long)self.left, (long)self.right);

        NSString *result = [self.model calculate:expression];

        self.calView.topLabel.text = result;
        [self.calArray removeAllObjects];
        [self.calArray addObject:result];
        self.equalFlag = YES;
        self.pointFlag = NO;
        self.operatorFlag = NO;
        self.left = 0;
        self.right = 0;
        return;
    } else if ([title isEqualToString:@"."]) {
        NSString *last = [self.calArray lastObject];
        if (!last) {
            self.pointFlag = YES;
            [self.calArray addObject:@"0."];
        } else if (!self.pointFlag && ![self isOperator:last] && ![last isEqualToString:@"("] && ![last isEqualToString:@")"]) {
            self.pointFlag = YES;
            NSString *newStr = [last stringByAppendingString:@"."];
            [self.calArray removeLastObject];
            [self.calArray addObject:newStr];
        } else if (!self.pointFlag && ![last isEqualToString:@")"]) {
            self.pointFlag = YES;
            [self.calArray addObject:@"0."];
        }
        self.calView.topLabel.text = [self.calArray componentsJoinedByString:@""];
        return;
    }
    
    
    else if ([title isEqualToString:@"("]) {
        NSString* last = [self.calArray lastObject];
        if (last && ![self isOperator:last] && ![last isEqualToString:@"("]) {
            return;
        }
        self.left++;
        [self.calArray addObject:title];
        self.operatorFlag = NO;
        self.pointFlag = NO;
        self.calView.topLabel.text = [self.calArray componentsJoinedByString:@""];
        return;
    } else if ([title isEqualToString:@")"]) {
        if (self.left > self.right) {
            
            NSString* last = [self.calArray lastObject];
            if ([self isOperator:last] || [last isEqualToString:@"("]) {
                return;
            }
            self.right++;
            [self.calArray addObject:title];
            self.calView.topLabel.text = [self.calArray componentsJoinedByString:@""];
        }
        return;
    } else if ([self isOperator:title]) {
        NSString *last = [self.calArray lastObject];
        // kong
        if (!last) {
            if ([title isEqualToString:@"-"]) {
                [self.calArray addObject:title];
                self.calView.topLabel.text = [self.calArray componentsJoinedByString:@""];
            }
            return;
        }
        if ([self isOperator:last]) {
                [self.calArray removeLastObject];
                [self.calArray addObject:title];
                self.calView.topLabel.text = [self.calArray componentsJoinedByString:@""];
            return;
        }
        if ([last isEqualToString:@"("]) {
            if ([title isEqualToString:@"-"]) {
                [self.calArray addObject:title];
                self.calView.topLabel.text = [self.calArray componentsJoinedByString:@""];
            }
            return;
        }
        [self.calArray addObject:title];
        self.pointFlag = NO;
        self.operatorFlag = YES;
        self.calView.topLabel.text = [self.calArray componentsJoinedByString:@""];
    } else {
        NSString *last = [self.calArray lastObject];
        if (!last || [self isOperator:last] || [last isEqualToString:@"("] || [last isEqualToString:@")"]) {
            [self.calArray addObject:title];
        } else {
            NSString *newStr = [last stringByAppendingString:title];
            [self.calArray removeLastObject];
            [self.calArray addObject:newStr];
        }
        self.operatorFlag = NO;
        self.calView.topLabel.text = [self.calArray componentsJoinedByString:@""];
    }
}

- (BOOL)isOperator:(NSString *)str {
    return [@[@"+", @"-", @"*", @"/"] containsObject:str];
}

- (BOOL)isValidExpression:(NSString *)expression {
    return ![expression containsString:@"++"] &&
           ![expression containsString:@"--"] &&
           ![expression containsString:@"**"] &&
           ![expression containsString:@"//"] &&
           ![expression containsString:@"××"] &&
           ![expression containsString:@"÷÷"];
}
    @end
    
