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

- (void)pageView:(LPageView *)pageView didSelectForIndex:(NSInteger)index;

- (void)pageView:(LPageView *)pageView didScrollToIndex:(NSInteger)index;

@end

@protocol LPageViewDataSource <NSObject>

@required

- (NSInteger)numberOfLPageView;

- (UIView *)pageView:(LPageView *)pageView viewForIndex:(NSInteger)index;

@end


@interface LPageView : UIView

@property (assign, nonatomic) IBInspectable NSUInteger  direction;

//@property (assign, nonatomic) IBInspectable BOOL autoSlide;
//
//@property (assign, nonatomic) IBInspectable float slideTime;
//
//@property (assign, nonatomic) IBInspectable float slideInteval;

@property (assign, nonatomic, readonly) NSInteger index;

@property (weak, nonatomic) id<LPageViewDelegate> delegate;

@property (weak, nonatomic) id<LPageViewDataSource> dataSource;

- (void)registerClassName:(nullable NSString *)className;
- (void)registerNibName:(nullable NSString *)nibName;

- (UIView *)dequeueReusableView;

@end
