#### <font color="blue">gin-vue-admin安装和启动</font>

---

1. [环境配置](https://www.gin-vue-admin.com/docs/env/)
2. 统一数据库字符集为utf8

	```js
	+--------------------------+-----------------------------------------------------------+
	| Variable_name            | Value                                                     |
	+--------------------------+-----------------------------------------------------------+
	| character_set_client     | utf8                                                      |
	| character_set_connection | utf8                                                      |
	| character_set_database   | utf8                                                      |
	| character_set_filesystem | binary                                                    |
	| character_set_results    | utf8                                                      |
	| character_set_server     | utf8                                                      |
	| character_set_system     | utf8                                                      |
	| character_sets_dir       | /usr/local/mysql-5.7.28-macos10.14-x86_64/share/charsets/ |
	+--------------------------+-----------------------------------------------------------+
	```
	
2. 初始化数据库，在数据库中导入项目下的`.docker-compose/docker-entrypoint-initdb.d/init.sql`
	* 具体的数据库地址为`server/config.yaml`中`mysql`部分指定的数据库
	
2. 进入`server`目录，启动后台项目
	* `go list`拉取依赖
	* `go get -u github.com/swaggo/swag/cmd/swag` && `swag init` 创建自动化文档
	* `go run main.go`运行后台项目(生产环境也可执行`go build`后生成二进制文件`gin-vue-admin`来运行)
	
3. 将前端目录`web`拖拽到HBuilderX中启动
	* 在HBuilderX的终端中输入`npm install`安装包
	* 执行`npm run serve`启动前台项目(生产环境也可执行`npm run build`生成dist目录用于部署)
	* 启动后会自动在默认浏览器中弹出登录页面`localhost:8080`
	
---

> 参考链接：
> 
> * [gva详细教程](https://www.gin-vue-admin.com/docs/help)