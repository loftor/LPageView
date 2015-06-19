//
//  LPageView.h
//  Example
//
//  Created by zhanglei on 19/05/2015.
//  Copyright © 2015 loftor. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LPageView;

typedef NS_ENUM(NSUInteger, LPageDirection) {
    LPageViewDirectionHorizontal,
    LPageViewDirectionVertical,
};

@protocol LPageViewDelegate <NSObject>

- (void)pageView:(LPageView *)pageView didSelectForIndex:(NSUInteger)index;

- (void)pageView:(LPageView *)pageView didScrollToIndex:(NSUInteger)index;

@end

@protocol LPageViewDataSource <NSObject>

@required

- (NSUInteger)numberOfLPageView;

- (UIView *)pageView:(LPageView *)pageView viewForIndex:(NSUInteger)index;

@end


@interface LPageView : UIView

@property (assign, nonatomic) IBInspectable NSUInteger  direction;

@property (assign, nonatomic) IBInspectable BOOL autoSlide;

@property (assign, nonatomic) IBInspectable NSUInteger slideInteval;

@property (assign, nonatomic) float interSpacing;

@property (assign, nonatomic) NSUInteger index;

@property (weak, nonatomic) id<LPageViewDelegate> delegate;

@property (weak, nonatomic) id<LPageViewDataSource> dataSource;

- (void)registerClassName:(nullable NSString *)className;

- (void)registerNibName:(nullable NSString *)nibName;

- (UIView *)dequeueReusableView;

- (void)loadData;

@end
