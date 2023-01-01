---
layout: post
title: Quote Reader
category: works
css: |
  h1 {
    margin-bottom : 20px;
    font-size: 28px
  }
  p {
    font-size : 20px;
  }
  .content ul li{
    font-size : 20px;
  }
---

这大概是很久之前的一个想法了……可以追溯到 2020 年吧，当时看到一些爽哥语录（不），就想着能不能做一个语录提取器出来。

QQ 本体 (macOS/Windows) 确实存在表情快捷键这个说法，但 OCR 识别率不甚理想的同时也将手机端排除在外、也比较难实现语录的聚合；本项目预定实现多平台和便于聚合语录的特性。

- [规划](#规划)
- [前期工作](#前期工作)
  - [基本框架](#基本框架)
  - [输出文件](#输出文件)
- [后期工作](#后期工作)
  - [初稿绘制](#初稿绘制)
  - [组件库选用](#组件库选用)
  - [界面开发](#界面开发)
    - [布局](#布局)
    - [结构](#结构)
      - [BaseHeader](#baseheader)
      - [QuoteReader](#quotereader)
      - [BaseBottom](#basebottom)
  - [业务逻辑](#业务逻辑)
    - [表格数据填充](#表格数据填充)
    - [图片预览](#图片预览)
  - [打包分发](#打包分发)
  - [验证成果](#验证成果)

#  规划

我们现在所拥有的是一些语录图片，存放于文件夹中；前期需要做的准备工作是利用 Python 脚本生成 json 文件、将每个图片中的语录全文、关键字提取出来，对应到路径。

后期需要做的工作是利用 Vue.js 编写前端实现语录图片的筛选与复制。

本项目不使用任何数据库。

# 前期工作

首先是找到一个合格的 OCR 库。考虑到现实情况，显然不太可能自己去训练模型；本项目中使用的是 PaddleOCR，模型体积较小、输出结果较理想。

本文将不会详细介绍脚本具体工作原理与相关事项，具体请参阅项目[Quote_ocr](https://github.com/Mahayu/quote_ocr)。


## 基本框架

`getJson.py`是脚本入口，利用 PaddleOcr 批量识别/imgs/图片中的文字并且输出到 json 中。

`getQuote.py`是读取 Json 的脚本，可以利用该脚本实现初步的语录筛选、构建词云。

使用前请先利用 requirement.txt 安装相关的依赖，具体使用步骤与相关脚本下载、存在问题等请参阅
[Quote_ocr](https://github.com/Mahayu/quote_ocr)。

## 输出文件

输出的是一个 json 文件，其中对象有以下几个属性：

- id
  
  用于生成每一个图片特有的 id，不一定与图片名称相关。
- info

  语录全文
- keyword

  语录关键字
- path

  语录图片的路径

准备好输出文件与对应语录即可开始构建前端界面。


# 后期工作

笔者考虑到服务器租赁费用，不排除使用 Electron 构建本地应用的可能、同时打算使用 Vue3；因此使用了 Vite 一把梭，工程化处理本项目。

## 初稿绘制

采用了 figma 作前端界面的大致绘制。[项目链接](https://www.figma.com/file/cRllC4EyWSWpAWg3I4LaTF/Quote_reader)

整体上由三个部分组成：

- 顶栏
  
  为后期开发多页面而保留的导航栏。

- 描述性图文
  
  Logo 与标题、应用的具体描述。

- 主表格
  
  用于存放语录相关条目与搜索栏。

所有的内容均纵向排布，字体与相关配色方案将采用固定的组件库。

## 组件库选用

本项目使用[Element Plus](https://element-plus.org/)作为本项目的组件库。

克隆了[element-plus-vite-starter](https://github.com/element-plus/element-plus-vite-starter)仓库，在此基础上作进一步开发。

## 界面开发

根据前一阶段初稿绘制的成果，抽象出四种元素：菜单、按钮、段落图文、表格。

按照官方文档将相关元素依序写入即可。

### 布局

根据初稿绘制结果，给出详细布局。

### 结构

总体界面由
- `BaseHeader.vue` 
- `QuoteReader.vue` 
- `BaseBottom.vue`

三个文件组成，分别对应布局图中的顶栏、主容器、脚注。

文件内容如下：

#### BaseHeader

顶栏。利用的是 el-menu 组件，修改为深色配色方案以符合初稿。

#### QuoteReader

主容器。分为两个部分，图文段落与主表格、分别装入不同的 div 中。对于主表格，采用的是 el-table 组件；引入了搜索框与查看按钮的相关例程以实现对应功能。

#### BaseBottom

脚注，单独一个 div 装入文本。

## 业务逻辑

主要由两部分组成：表格数据填充与图片预览。

### 表格数据填充

首先明确：本项目中的表格数据填充，是通过双向绑定来进行的。

具体而言，监控搜索框内数据是否变动（用户是否输入了搜索关键词）；若是，则过滤掉无关内容、将数据实时更新到表格内。


若用户什么也不输入（或初始状态），则不过滤、将所有数据装入到表格内。

因此需要编写接口让 Computed 调用：
``` javascript
const tableData = quoteJson;  //上文提到的 json
interface Quote {
  id: number;
  info: string;
  keyWord: string[];
  path: string;
}
const filterTableData = computed(() =>
  tableData.filter(
    (data) => !search.value || data.keyWord.includes(search.value)
  )
);
```
HTML 中需要标注数据源：
```html
<el-table :data="filterTableData" max-height="450">
```

###  图片预览

这是本项目的核心功能，应用到的组件是[v-viewer](https://github.com/mirari/v-viewer/tree/v3)。

首先需要传入对应条目的数据。注意到相关 HTML 代码中有：
```html
<template #default="scope">
    <el-button size="small" @click="show(scope.row)"
        >查看
    </el-button>
</template>
```
将表格中特定行的数据（也就是上文提到的接口）传入到 show 函数当中。

接着，利用 Quote 中的 path 属性即可拿到对应条目的路径。将其传递到 api 当中，使用对应方法即可预览。
```javascript
  methods: {
    show(row: Quote) {
      this.$viewerApi({
        images: [row.path],
      });
    },
  },
```

## 打包分发

一般情况下利用`yarn build`命令即可打包完毕。

要利用 Electron 产生本地应用且实时调试，需要繁琐配置；本文暂不包括相关内容。

## 验证成果

使用`yarn dev --host`命令即可在局域网内调试。

(考虑到隐私问题图片暂不放出)

目前的问题有：

- Logo 不能适应多端设备，有些情形下过于模糊

暂时不能解决，唯一的办法是重新设计 logo。

- Electron 打包文件过大

暂时不能解决，似乎是通病。
