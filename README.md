# 巡检脚本说明

巡检脚本会检查：
- 系统信息
- 获取用户列表以及当前登录用户，并找到用户列表中不存在的登录用户
- 测试Tomcat是否启动，若不启动则重启Tomcat
- 测试Tomcat页面，将错误日志输出到`temp/Monitor.Info`
- 获取Tomcat线程使用情况
- 获取端口使用情况

以上信息会输出到`temp/Monitor.log`文件中

用户列表保存在`./userlist`中

# 使用说明
1.切换到脚本所在路径下

2.

运行巡检脚本（以下任意一条命令）
```
make 
make run
```

查看输出日志`Monitor.log`
```
make check
```

运行巡检脚本并查看输出日志
```
make test
```

清空输出日志
```
make clean
```


