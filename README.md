# LGridView
实现page功能,无限循环

# 引用方式
pod 'LPageView', :git => 'https://github.com/loftor/LPageView.git', :tag => 'v4.0'

# 使用方式
1、修改类名LPageView

2、调用registerClassName（注册类名）/registerNibName（注册xib名）

3、实现LPageViewDataSource下面的代理方法，viewForIndex请使用dequeueReusableView方法获取view
