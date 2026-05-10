# 东方理工网络打印文件自动化上传工具
1. **功能：** 将要打印的文件自动上传到papercut网页

2. **准备工作：**
    1. **安装依赖环境：** playwright-cli, Node.js $\geq$ 18 （playwright-cli 依赖Node.js环境）
	    1. 安装Node.js (官网：https://nodejs.org/zh-cn)
	    2. 安装playwright-cli：运行`npm install -g @playwright/cli@latest`。
	       关于playwright-cli的详细说明，参考https://github.com/microsoft/playwright-cli

    2. **配置用户名和密码：**
       用记事本打开.cmd文件，把`set "PAPERCUT_USER=用户名"`和`set "PAPERCUT_PASS=密码"`中的用户名和密码替换成你自己的。

    3. **修改默认打印机：**
       可以修改`set "DEFAULT_CHOICE=1"`，把1改成你想要的默认打印机编号。编号对应如下：
       
        1：win-vccfcnbjej2\PaperCut-WebPrint （虚拟） 
        
        2：win-vccfcnbjej2\PaperCut-WebPrint-彩色双面 （虚拟） 
        
        3：win-vccfcnbjej2\PaperCut-WebPrint-黑白 （虚拟）	 
        
        4：win-vccfcnbjej2\PaperCut-WebPrint-黑白双面 （虚拟）

    5. **设置使用的浏览器：**
       本程序默认使用Edge浏览器。若使用其他浏览器，可以手动修改`set "BROWSER=msedge"`，把msedge替换为chrome, firefox 或 webkit。

3. **使用方法**
    
    **法1：** 直接把要打印的文件拖到`papercut-upload.cmd` 上（可选中多文件后一起拖入），输入打印机编号，按回车后会自动把要打印的文件上传到papercut网页。若直接输入回车，会选择默认打印机打印。
    
    **法2：** 在命令行运行（可多文件）：papercut-upload.cmd "C:\path\a.pdf" "C:\path\b.docx"

4. **补充说明：**
	1. 本程序没有修改打印份数的功能，所以打印份数默认为1，可以在打印的时候直接在打印机上修改打印份数。
 	2. 建议把.cmd文件放在一个文件夹中使用，因为程序运行会自动产生.playwright-cli文件夹
  	3. 电脑需连接校园网才能使用网络打印
 	4. 文件上传成功后直接到打印机上登陆账号，审批后即可打印，无需在网页中审批。

