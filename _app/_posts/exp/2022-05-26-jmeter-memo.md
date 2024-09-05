---
layout: post
title: Jmeter Memo
category: exp
scheme-text: "#666c7b"
scheme-code: "#0f95b0"
scheme-bg: "#fff"
scheme-list-color: "code"
---

这里写一点关于 Jmeter 的技巧备忘，随用随写。
> jmeter 5.4.3

- [UI 配置](#ui-配置)
- [form-data 类型编码](#form-data-类型编码)
- [数值传参](#数值传参)

## UI 配置

虽然Jmeter本质是个CLI程序，但是手写测试计划也太折磨人了。

因此还是用GUI制定测试计划比较好一些，一个比较好的UI配置可以显著提升使用体验。

相关配置文件位于 `.../bin/jmeter.properties` 中。

> 分辨率 1920*1080 124% 缩放比例。

```properties
# Line 173,177
jmeter.hidpi.mode=true  # 开启HiDPI模式
jmeter.hidpi.scale.factor=1.4  # 缩放倍率。数值供参考

# Line 1094
sampleresult.default.encoding=UTF-8  #返回的取样器结果编码设置
```

修改这么几个地方的数值即可获得比较不错的体验。


## form-data 类型编码

Jmeter 在这里的处理与其他测试软件有所差异：

需要使用 form-data 发送请求的情况，需要把请求头的 Content-Type 类删除。

再勾选请求内的"对 post 使用 multipart/form-data"选项，填写相应参数即可正常发送请求。


## 数值传参

对于特定的场合，需要向服务器提交请求后拿到一个ID值、再将其置入下一个请求的消息体当中。

使用内置的JSON提取器，插入到查询之后即可。

配置十分简单，需要注意的是"JSON Path Expression"为需要提取的属性路径：使用$代表 `this`，详细文档与例程可参阅 [JSONPath](https://support.smartbear.com/alertsite/docs/monitors/api/endpoint/jsonpath.html)。

假定提取的相关变量名为 `extractId` ,写入下一个消息体的JSON时如此表示即可:
```JSON
{
    ...
    "personId" : ${extractId}
    ...
}
```

需要注意到，这个${extractId}本身就是语义化的，因此要传字符串形态的数字的场合，使用`"${extractId}"`即可。

其他需要使用数值传参的场合，例如内置的计时器配置项，也可以利用`${}`的语法来传参，链接参数类似。