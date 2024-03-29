## 2.1.0
* 支持三方数据接入
* 支持数据传输加密
* 支持userUniqAppend
* 优化数据停止/暂停上报接口
* 优化获取预制属性接口
* 自动采集事件支持自定义静态属性
* 获取静态公共属性接口

## 2.0.3
* 修改安卓SDK混淆文件

## 2.0.2
* 修复libversion问题

## 2.0.1
* 新增获取预置属性接口

## 2.0.0
* 适配 flutter 2.0 null-safety

# 1.3.3
* 适配iOS 5G网络
* 优化install,start事件上报逻辑
* 优化数据传输格式
* 默认网络上报策略调整为2G/3G/4G/5G/WIFI

# 1.3.2
* 修复特殊事件不设置timeZone导致上报数据出现错误的#zone_offset的问题.
* iOS原生SDK版本号修改为v2.6.1, Android原生SDK版本号修改为v2.6.0

## 1.3.0
* 支持首次事件, 允许传入自定义的 ID 校验是否首次上报
* 支持可更新、可重写的事件

## 1.2.1
* 优化代码：避免极端情况下的空指针异常

## 1.2.0
* 优化 Debug 模式，配合后台埋点管理
* 支持 #system_language 属性

## 1.1.1
* 修复 Android 平台 DEBUG 模式事件上报 BUG

## 1.1.0
* 支持使用服务端时间校准 SDK 时间

## 1.0.0
* 支持事件和用户属性数据上报
* 支持多实例和轻实例
* 支持公共事件属性和动态公共属性
* 支持自动采集事件
* 支持 Debug 模式
* 支持设置默认时区
