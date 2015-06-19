//
//  LPageView.m
//  Example
//
//  Created by zhanglei on 19/05/2015.
//  Copyright © 2015 loftor. All rights reserved.
//

#import "LPageView.h"

@interface LPageView ()

@property (nonatomic, strong) UIView * viewLeft;

@property (nonatomic, strong) UIView * viewCenter;

@property (nonatomic, strong) UIView * viewRight;

@property (nonatomic, strong) UIView * tmp;

@property (nonatomic, assign) NSUInteger nums;

@property (nonatomic, strong) NSString * className;

@property (nonatomic, strong) NSString * nibName;

@property (nonatomic, assign) CGPoint point;

@property (nonatomic, strong) dispatch_source_t timer;

@end

@implementation LPageView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

static NSUInteger currentInterval;

- (instancetype)initWithFrame:(CGRect)frame{
    if (self == [super initWithFrame:frame]) {
        [self initPageView];
    }
    return self;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    [self initPageView];
}

- (void)initPageView{
    
    _slideInteval = 3;
    
    self.autoSlide = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [self addGestureRecognizer:tap];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [self addGestureRecognizer:pan];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:swipeRight];

    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGesture:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:swipeLeft];
    
}

- (void)setDataSource:(id<LPageViewDataSource>)dataSource{
    
    
    if (dataSource && [dataSource respondsToSelector:@selector(numberOfLPageView)] && [dataSource respondsToSelector:@selector(pageView:viewForIndex:)]) {
        _dataSource = dataSource;
        [self loadData];
    }
    
    
}

- (dispatch_source_t)timer{
    if (_timer == nil) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_timer(_timer, dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC), 1 * NSEC_PER_SEC, 0);
        dispatch_source_set_event_handler(_timer, ^{
            
            currentInterval++;
            if (currentInterval == _slideInteval) {
                currentInterval = 0;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self moveToRight];
                    [self movetoDefault];
                });
                
            }
            
            
        });
    }
    return _timer;
}

- (void)cancelTimer{
    if (_timer) {
        dispatch_source_cancel(_timer);
        self.timer = nil;
    }
}

- (void)loadData{
    
    if (_dataSource == nil) {
        return;
    }
    
    for (UIView * view in self.subviews) {
        [view removeFromSuperview];
    }
    
    self.nums = [_dataSource numberOfLPageView];
    
    if (_nums < 2) {
        self.autoSlide = NO;
    }
    
    if (_index>=_nums) {
        _index = 0;
    }
    
    if (_nums == 0) {
        return;
    }
    if (_nums > 0) {
        self.viewCenter = [_dataSource pageView:self viewForIndex:_index];
        _viewCenter.frame = self.bounds;
        [self addSubview:_viewCenter];
        
        if (_delegate) {
            [_delegate pageView:self didScrollToIndex:_index];
        }
    }
    if (_nums > 1) {
        self.viewLeft = [_dataSource pageView:self viewForIndex:[self getLeftIndex]];
        [self addSubview:_viewLeft];
        
        self.viewRight = [_dataSource pageView:self viewForIndex:[self getRightIndex]];
        [self addSubview:_viewRight];
        
        switch (_direction) {
            case LPageViewDirectionHorizontal:
                _viewLeft.frame = CGRectMake(-self.bounds.size.width-_interSpacing, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
                _viewRight.frame = CGRectMake(self.bounds.size.width+_interSpacing, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
                break;
            case LPageViewDirectionVertical:
                _viewLeft.frame = CGRectMake(self.bounds.origin.x, -self.bounds.size.height-_interSpacing, self.bounds.size.width, self.bounds.size.height);
                _viewRight.frame = CGRectMake(self.bounds.origin.x, self.bounds.size.height+_interSpacing, self.bounds.size.width, self.bounds.size.height);
                break;
                
            default:
                break;
        }
    }
    
    if (_autoSlide) {
        dispatch_resume(self.timer);
    }
}


- (void)registerClassName:(NSString *)className{
    
    self.className = className;
    
}

- (void)registerNibName:(NSString *)nibName{
    
    self.nibName = nibName;
    
}

- (UIView *)dequeueReusableView {
    
    if (_tmp) {
        return _tmp;
    }
    
    if (_className) {
        return [[NSClassFromString(_className) alloc]init];
    }
    
    if (_nibName) {
        NSArray *nibView =  [[NSBundle mainBundle] loadNibNamed:_nibName owner:nil options:nil];
        return [nibView objectAtIndex:0];
    }
    return nil;
}




- (void)tapAction:(UITapGestureRecognizer *)sender {
    
    if (_delegate) {
        [_delegate pageView:self didSelectForIndex:_index];
    }
    
}

- (void)panAction:(UIPanGestureRecognizer *)sender{

    if (_nums<2) {
        return;
    }
    
    if(_autoSlide){
        currentInterval = 0;
    }
    
    CGPoint pt = [sender translationInView:self];
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.point = pt;
            
        }
            break;
        case UIGestureRecognizerStateChanged:
        {

            switch (_direction) {
                case LPageViewDirectionHorizontal:
                    {
                        self.viewCenter.center = CGPointMake(self.viewCenter.center.x+pt.x-_point.x, self.viewCenter.center.y);
                        self.viewLeft.center = CGPointMake(self.viewLeft.center.x+pt.x-_point.x, self.viewLeft.center.y);
                        self.viewRight.center = CGPointMake(self.viewRight.center.x+pt.x-_point.x, self.viewRight.center.y);

                    }
                    break;
                case LPageViewDirectionVertical:
                    {
                        self.viewCenter.center = CGPointMake(self.viewCenter.center.x, self.viewCenter.center.y+pt.y-_point.y);
                        self.viewLeft.center = CGPointMake(self.viewLeft.center.x, self.viewLeft.center.y+pt.y-_point.y);
                        self.viewRight.center = CGPointMake(self.viewRight.center.x, self.viewRight.center.y+pt.y-_point.y);
                    }
                    break;
                default:
                    break;
            }

            self.point = pt;
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            
            BOOL bChange = NO;
            BOOL bLeftTop = NO;
            switch (_direction) {
                case LPageViewDirectionHorizontal:
                    bChange = fabs(pt.x) >= self.frame.size.width/4;
                    bLeftTop = pt.x > 0;
                    break;
                case LPageViewDirectionVertical:
                    bChange = fabs(pt.y) >= self.frame.size.height/4;
                    bLeftTop = pt.y > 0;
                    break;
            }
            
            if (bChange) {
                
                if (bLeftTop) {
                
                    [self moveToLeft];
                    
                }
                else{
                    [self moveToRight];
                }
                
            }
            
            
            [self movetoDefault];
        }
        default:
            break;
    }


}

-(void)swipeGesture:(UISwipeGestureRecognizer *)sender
{

    if (_nums<2) {
        return;
    }
    
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
        [self moveToRight];
    }
    if (sender.direction == UISwipeGestureRecognizerDirectionRight) {
        [self moveToLeft];
    }
    
    [self movetoDefault];
    
    
}

- (NSUInteger)getRightIndex{
    if (_index<_nums-1) {
        return _index+1;
    }
    else{
        return 0;
    }
}

- (NSUInteger)getLeftIndex{
    if (_index==0) {
        return _nums-1;
    }
    else{
        return _index-1;
    }
}

- (void)moveToLeft{
    _index = [self getLeftIndex];
    
    self.tmp = _viewRight;
    
    self.viewRight = _viewCenter;
    self.viewCenter = _viewLeft;
    self.viewLeft = [_dataSource pageView:self viewForIndex:[self getLeftIndex]];
    switch (_direction) {
        case LPageViewDirectionHorizontal:
            _viewLeft.frame = CGRectMake(_viewCenter.frame.origin.x-_viewCenter.frame.size.width-_interSpacing, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
            break;
        case LPageViewDirectionVertical:
            _viewLeft.frame = CGRectMake(_viewCenter.frame.origin.x, self.bounds.origin.y-_viewCenter.frame.size.height-_interSpacing, self.bounds.size.width, self.bounds.size.height);
            break;
            
    }
    
    if (_delegate) {
        [_delegate pageView:self didScrollToIndex:_index];
    }
}

- (void)moveToRight{
    _index = [self getRightIndex];
    self.tmp = _viewLeft;
    
    self.viewLeft = _viewCenter;
    self.viewCenter = _viewRight;
    self.viewRight = [_dataSource pageView:self viewForIndex:[self getRightIndex]];
    
    switch (_direction) {
        case LPageViewDirectionHorizontal:
            _viewRight.frame = CGRectMake(_viewCenter.frame.origin.x+_viewCenter.frame.size.width+_interSpacing, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
            break;
        case LPageViewDirectionVertical:
            _viewRight.frame = CGRectMake(_viewCenter.frame.origin.x, self.bounds.origin.y+_viewCenter.frame.size.height+_interSpacing, self.bounds.size.width, self.bounds.size.height);
            break;
            
    }
    
    if (_delegate) {
        [_delegate pageView:self didScrollToIndex:_index];
    }
}

- (void)movetoDefault{
    [UIView animateWithDuration:0.25 delay:0 options:9 << 16 animations:^{
        switch (_direction) {
            case LPageViewDirectionHorizontal:
                _viewCenter.frame = self.bounds;
                _viewLeft.frame = CGRectMake(-self.bounds.size.width-_interSpacing, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
                _viewRight.frame = CGRectMake(self.bounds.size.width+_interSpacing, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
                break;
            case LPageViewDirectionVertical:
                _viewCenter.frame = self.bounds;
                _viewLeft.frame = CGRectMake(self.bounds.origin.x, -self.bounds.size.height-_interSpacing, self.bounds.size.width, self.bounds.size.height);
                _viewRight.frame = CGRectMake(self.bounds.origin.x, self.bounds.size.height+_interSpacing, self.bounds.size.width, self.bounds.size.height);
                break;
                
            default:
                break;
        }
    } completion:^(BOOL finished) {
        if(_autoSlide){
            currentInterval = 0;
        }
    }];
    
}

- (void)dealloc{
    [self cancelTimer];
}

@end
