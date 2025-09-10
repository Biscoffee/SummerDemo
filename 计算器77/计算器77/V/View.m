//
//  View.m
//  计算器77
//
//  Created by 吴桐 on 2025/7/26.
//

#import "View.h"
#import "Masonry.h"
//定义这个常量，就可以不用在开发过程中使用mas_前缀。
#define MAS_SHORTHAND
//定义这个常量，就可以让Masonry帮我们自动把基础数据类型的数据，自动装箱为对象类型。
#define MAS_SHORTHAND_GLOBALS
//定义屏幕宽度和高度
#define WIDTH  self.frame.size.width
#define HEIGHT self.frame.size.height

@implementation View

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(!self) return nil;
    
    self.backgroundColor = [UIColor blackColor];
    
    _topLabel = [[UILabel alloc] init];
    _topLabel.text = @"0";
    _topLabel.font = [UIFont systemFontOfSize:60];
    _topLabel.textColor = [UIColor whiteColor];
    _topLabel.textAlignment = NSTextAlignmentRight;//右对齐
    _topLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:_topLabel];
        
    [_topLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-20);
        make.top.equalTo(self).offset(220);
        make.height.mas_equalTo(80);
    }];
    
    _array = @[@"AC", @"(", @")", @"/",
                        @"7", @"8", @"9", @"*",
                        @"4", @"5", @"6", @"-",
                        @"1", @"2", @"3", @"+",
                        @"0", @" ", @".", @"="];
    UIView* lastRow = nil;
    CGFloat btnSpacing = 21;
    CGFloat btnHeight = 75;
    
    for (int i = 0; i < 5; i++) {
        UIView* rowView = [[UIView alloc] init];
        [self addSubview:rowView];
        [rowView mas_makeConstraints:^(MASConstraintMaker *make) {
            if (lastRow) {
                make.top.equalTo(lastRow.mas_bottom).offset(btnSpacing);
            } else {
                make.top.equalTo(_topLabel.mas_bottom).offset(40);
            }
            make.left.right.equalTo(self).inset(20);
            make.height.mas_equalTo(btnHeight);
        }];
        lastRow = rowView;
        UIView* lastButton = nil;
        int buttonsInRow = 4;
        if (i == 4) buttonsInRow = 3;
        for (int j = 0; j < buttonsInRow; j++) {
            NSInteger index = i * 4 + j;
            if (i == 4 && j >= 1) {
                index = i * 4 + j + 1;
            }
            NSString* title = _array[index];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = 100 + index;
            [button setTitle:title forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            button.layer.cornerRadius = btnHeight / 2;
            button.titleLabel.font = [UIFont systemFontOfSize:42];
            button.clipsToBounds = YES;
            [button addTarget:self action:@selector(return:) forControlEvents:UIControlEventTouchUpInside];
            if (i == 0) {
                button.backgroundColor = [UIColor colorWithWhite:0.6 alpha:1];
            } else if (j == 3 && i != 4) {
                button.backgroundColor = [UIColor colorWithRed:236/255.0 green:146/255.0 blue:47/255.0 alpha:1];
            } else {
                button.backgroundColor = [UIColor colorWithWhite:0.3 alpha:1];
            }
            
            [rowView addSubview:button];
            
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.equalTo(rowView);
                
                if (i == 4) {
                    if (j == 0) {
                        make.left.equalTo(rowView);
                        make.width.equalTo(rowView).multipliedBy(0.5).offset(-btnSpacing/2);
                    } else {
                        make.left.equalTo(lastButton.mas_right).offset(btnSpacing);
                        make.width.equalTo(rowView).multipliedBy(0.25).offset(-btnSpacing*0.75);
                    }
                } else {
                    if (lastButton) {
                        make.left.equalTo(lastButton.mas_right).offset(btnSpacing);
                    } else {
                        make.left.equalTo(rowView);
                    }
                    make.top.bottom.equalTo(rowView);
                    make.width.equalTo(@(btnHeight));
                }
            }];
            lastButton = button;
        }
    }
    return self;
}

- (void)return:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(pressChange:)]) {
        [self.delegate pressChange:button];
    }
}

@end
