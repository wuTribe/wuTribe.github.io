---
title: java操作office进行模板替换
date: 2021-8-3 22:12:20
categories:
- 学习/java
tags:
- java
- office
description: 被提了一个 word 编写一个模板，程序生成目标文档的需求
---

# java导出word的5种方式

## 1：Jacob

Java-COM Bridge的缩写，它在Java与微软的COM组件之间构建一座桥梁。通过Jacob实现了在Java平台上对微软Office的COM接口进行调用。

​		优点：调用微软Office的COM接口，生成的word文件格式规范。

​		缺点：服务器只能是windows平台，不支持unix和linux，且服务器上必须安装微软Office。

## 2：Apache POI

他包括一系列的API，它们可以操作基于MicroSoft OLE 2 Compound Document Format的各种格式文件，可以通过这些API在Java中读写Excel、Word等文件。

​		优点：跨平台支持windows、unix和linux。

​		缺点：相对与对word文件的处理来说，POI更适合excel处理，对于word实现一些简单文件的操作凑合，不能设置样式且生成的word文件格式不够规范。

## 3：Java2word

是一个在java程序中调用 MS Office Word 文档的组件(类库)。该组件提供了一组简单的接口，以便java程序调用他的服务操作Word 文档。 这些服务包括： 打开文档、新建文档、查找文字、替换文字，插入文字、插入图片、插入表格，在书签处插入文字、插入图片、插入表格等。

　　优点：足够简单，操作起来要比FreeMarker简单的多。

　　缺点：没有FreeMarker强大，不能够根据模版生成Word文档，word的文档的样式等信息都不能够很好的操作。

## 4：FreeMarker

生成word文档的功能是由XML+FreeMarker来实现的。先把word文件另存为xml，在xml文件中插入特殊的字符串占位符，将xml翻译为FreeMarker模板，最后用java来解析FreeMarker模板，编码调用FreeMarker实现文本替换并输出Doc。

​		优点：比Java2word功能强大，也是纯Java编程。

　　缺点：生成的文件本质上是xml，不是真正的word文件格式，有很多常用的word格式无法处理或表现怪异，比如：超链、换行、乱码、部分生成的文件打不开等。

## 5：PageOffice

PageOffice封装了微软Office繁琐的vba接口，提供了简洁易用的Java编程对象，支持生成word文件，同时实现了在线编辑word文档和读取word文档内容。

​		优点：跨平台支持windows、unix和linux，生成word文件格式标准，支持文本、图片、表格、字体、段落、颜色、超链、页眉等各种格式的操作，支持多word合并，无需处理并发，不耗费服务器资源，运行稳定。

​		缺点：必须在客户端生成文件（可以不显示界面），不支持纯服务器端生成文件。



由于我们的服务器不是 Windows 系统，pageOffice 是第三方要避免纠纷问题，所以 1,5 方案排除

# FreeMarker 操作

需要提前设计模板文档，并将文档转换成 xml 格式传递到服务器中，对模板设计者的操作多一些

![image-20210804164852090](https://gitee.com/wuTribe/images/raw/master/img/image-20210804164852090.png)

![image-20210804162838146](https://gitee.com/wuTribe/images/raw/master/img/image-20210804162838146.png)

然后将该文件提交到服务器，服务器将 xml 文件转为 ftl 转存本地，然后进行替换即可

工具类

```java
public class WordUtil {
    /**
     *
     * 使用FreeMarker自动生成Word文档
     *
     * @param dataMap  生成Word文档所需要的数据
     * @param outFileName 生成Word文档的全路径名称
     * @throws Exception Exception
     */
    public static void generateWord(Map<String, Object> dataMap, String outFileName)
            throws Exception {
        // 设置FreeMarker的版本和编码格式
        Configuration configuration = new Configuration(new Version("2.3.28"));
        configuration.setDefaultEncoding("UTF-8");

        // 设置FreeMarker生成Word文档所需要的模板的路径
        configuration.setDirectoryForTemplateLoading(new File("自己的模板的路径"));
        // 设置FreeMarker生成Word文档所需要的模板
        Template t = configuration.getTemplate("WordTemplate.ftl", "UTF-8");
        // 创建一个Word文档的输出流
        Writer out = new BufferedWriter(new OutputStreamWriter(
                new FileOutputStream(new File(outFileName)), 
                StandardCharsets.UTF_8)
        );
        //FreeMarker使用Word模板和数据生成Word文档
        t.process(dataMap, out);
        out.flush();
        out.close();
    }
}
```

测试：

```java
public class WordTest {
    public static void main(String[] args) throws Exception {
        // 自动生成Word文档，注意：生成的文档的后缀名需要为doc
        // 而不能为docx，否则生成的Word文档会出错
        WordUtil.generateWord(getWordData(), "D:/User.doc");
    }
    
    /**
     * 获取生成Word文档所需要的数据
     */
    public static Map<String, Object> getWordData() {
        /*
         * 创建一个Map对象，将Word文档需要的数据都保存到该Map对象中
         */
        Map<String, Object> dataMap = new HashMap<>();

        /*
         * 直接在map里保存一个用户的各项信息
         * 该用户信息用于Word文档中FreeMarker普通文本处理
         * 模板文档占位符${name}中的name即指定使用这里的name属性的值"用户1"替换
         */
        dataMap.put("name", "用户1");
        dataMap.put("sex", "男");
        dataMap.put("birthday", "1991-01-01");
        // 自己的测试数据
        dataMap.put("username", "jjjjj");
        dataMap.put("reason", "哦哦哦哦哦");
        dataMap.put("date", "2021年8月4日15:48:33");
        dataMap.put("time", "2021-8-4 15:48:36");
        dataMap.put("startTime", "(¦3[▓▓] 晚安");
        dataMap.put("dept", "对对对对对");
        dataMap.put("company", "反反复复");

        // 将用户的各项信息封装成对象，然后将对象保存在map中，
        // 该用户对象用于Word文档中FreeMarker表格和图片处理
        // 模板文档占位符${userObj.name}中的userObj
        // 即指定使用这里的userObj属性的值(即user2对象)替换
        User user2 = new User();
        user2.setName("用户2");
        user2.setSex("女");
        user2.setBirthday("1992-02-02");
        // 使用FreeMarker在Word文档中生成图片时，需要将图片的内容转换成Base64编码的字符串
        user2.setPhoto(ImageUtil.getImageBase64String("E:/Word/Images/photo.jpg"));
        dataMap.put("userObj", user2);

        /*
         * 将多个用户对象封装成List集合，然后将集合保存在map中
         * 该用户集合用于Word文档中FreeMarker表单处理
         * 模板文档中使用<#list userList as user>循环遍历集合
         * 即指定使用这里的userList属性的值(即userList集合)替换
         */
        List<User> userList = new ArrayList<>();
        User user3 = new User();
        user3.setName("用户3");
        user3.setSex("男");
        user3.setBirthday("1993-03-03");
        User user4 = new User();
        user4.setName("用户4");
        user4.setSex("女");
        user4.setBirthday("1994-04-04");
        userList.add(user3);
        userList.add(user4);
        dataMap.put("userList", userList);
        return dataMap;
    }
}
```

因为 word 有时候会将 `${xxx}` 拆分开，测试的过程中可能会报错，解决办法就是将中间的内容删除，重新生成

![image-20210804164457201](https://gitee.com/wuTribe/images/raw/master/img/image-20210804164457201.png)

# Apache POI 操作

和上面的类似，都是根据语法替换，而 POI 的语法是 `{{}}`，但是这种方式转换不完全

```xml
<dependency>
    <groupId>cn.afterturn</groupId>
    <artifactId>easypoi-base</artifactId>
    <version>4.1.0</version>
</dependency>
<dependency>
    <groupId>org.apache.poi</groupId>
    <artifactId>poi-ooxml</artifactId>
    <version>3.17</version>
</dependency>
<!--xls-->
<dependency>
    <groupId>org.apache.poi</groupId>
    <artifactId>poi</artifactId>
    <version>3.17</version>
</dependency>
```



```java
/**
 * @author wu
 */
public class EasyPoiUtils {

    public static void main(String[] args) {
        WordUtil.exportWord(
                "自己的文件路径",
                "D:/",
                "生成文件.docx"
        );
    }

    /**
     * Word文档工具类
     *
     * @author wu
     */
    public static class WordUtil {

        public static void exportWord(String templatePath, String temDir, String fileName) {
            Map<String, Object> map = new HashMap<>();
            map.put("username", "张三");
            map.put("company", "xx公司");
            map.put("date", "2020-04-20");
            map.put("dept", "IT部");
            map.put("startTime", "2020-04-20 08:00:00");
            map.put("endTime", "2020-04-20 08:00:00");
            map.put("reason", "外出办公");
            map.put("time", "2020-04-22");
            exportWord(templatePath, temDir, fileName, map);
        }

        /**
         * 生成word
         */
        public static void exportWord(String templatePath, String temDir, String fileName, Map<String, Object> params) {
            Assert.notNull(templatePath, "模板路径不能为空");
            Assert.notNull(temDir, "临时文件路径不能为空");
            Assert.notNull(fileName, "导出文件名不能为空");
            Assert.isTrue(fileName.endsWith(".docx"), "word导出请使用docx格式");
            if (!temDir.endsWith("/")) {
                temDir = temDir + File.separator;
            }
            File dir = new File(temDir);
            if (!dir.exists()) {
                dir.mkdirs();
            }
            try {
                XWPFDocument doc = WordExportUtil.exportWord07(templatePath, params);

                String tmpPath = temDir + fileName;
                FileOutputStream fos = new FileOutputStream(tmpPath);
                doc.write(fos);
                fos.flush();
                fos.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }
}

```





# Java2word 操作

先留着空



# 个人问题

我的需求是：

1. 有一个模板人员使用邮件方式创建 word 模板，然后将模板提交到服务器
2. 其他人员选择模板和数据，服务器根据选择生成结果

## 方式一：

模板制作人员按邮件方式创建模板，然后提交到服务器

由于 word 中的邮件功能可以导入数据源，然后将模板标签进行替换，所以我们可以利用这个功能

![image-20210804145147553](https://gitee.com/wuTribe/images/raw/master/img/image-20210804145147553.png)

![image-20210804145254273](https://gitee.com/wuTribe/images/raw/master/img/image-20210804145254273.png)

![image-20210804145447051](https://gitee.com/wuTribe/images/raw/master/img/image-20210804145447051.png)

但是，这个方法被否决了，因为对其他人员来说可能有些麻烦



## 方式二：

我们可以根据方式一得到另一种方案，可以让模板制作人员根据 word 语法制作完模板之后选择合并，生成系统解析的语法文档，然后再将所生成的文档提交到服务器，这样服务器直接就可以根据模板生成目标文档

数据源：

![image-20210804150411734](https://gitee.com/wuTribe/images/raw/master/img/image-20210804150411734.png)

模板：

![image-20210804150647344](https://gitee.com/wuTribe/images/raw/master/img/image-20210804150647344.png)

替换结果：

![image-20210804150705115](https://gitee.com/wuTribe/images/raw/master/img/image-20210804150705115.png)

这样服务器就能直接解析

但是还是前面说到多几个空格会存在无法解析问题

## 方式三：

因为`{{}},${}`占位符会被拆分，所以考虑占位符改用一个特殊的符号代替，然后再转换为`{{}},${}`，但是这个方式被否决了



---

参考文章

[java导出word的5种方式](https://blog.csdn.net/zi_wu_xian/article/details/80320520)

[Java使用FreeMarker自动生成Word文档（带图片和表单）](https://blog.csdn.net/weixin_44516305/article/details/88049964)