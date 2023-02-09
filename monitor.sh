# 获取tomcat进程ID
TomcatID=$(ps -ef|grep tomcat|grep -v 'grep'|awk '{print $2}') 
# tomcat启动程序 
StartTomcat=~/apache-tomcat-8.5.78/bin/startup.sh 
TomcatCache=~/apache-tomcat-8.5.78/work 
#定义要监控的页面地址 
WebUrl=http://localhost:80 
#日志输出 
mkdir -p "temp" 
GetPageInfo=temp/Monitor.Info
TomcatMonitorLog=temp/Monitor.log

#存放系统用户列表位置
UserList=./userlist
TempUserList=./temp/userlist

# Check system
System()
{
  echo "--------------------------"
  echo "[info]获取系统信息..."
  OS=$(uname -o)
  Kernel=$(uname -s)
  Release=$(uname -r)
  Hostname=$(uname -n)
  Hardware=$(uname -m)
  Processor=$(uname -p)

  echo "操作系统: " $OS
  echo "内核: " $Kernel
  echo "发行版本: " $Release
  echo "主机名称: " $Hostname
  echo "机器名称: " $Hardware
  echo "处理器: " $Processor
}


# Check user
User()
{
  # 获取现在登录的用户并和用户列表对比
  echo "--------------------------"
  #CurrentUser=$(users|sort -u)
  CurrentUser=$(w|tail -n +3|awk '{print $1}'|sort -u)
  echo "[info]现在登录系统的用户有:" $CurrentUser
  echo $CurrentUser > $TempUserList
  DiffUser=$(cat $TempUserList $UserList $UserList|sort|uniq -u)
  if [ $DiffUser ];then
    echo "[info]存在列表之外用户登录系统:" $DiffUser
  fi
}

# Check threads of Tomcat
Thread()
{
  echo "--------------------------"
  echo "[info]检查线程占用情况..."
  ps -T -p $TomcatID 
}

# Check Port Status
Port()
{ 
  echo "--------------------------"
  echo "[info]检查端口连接状态..."
  netstat -nat|grep -w "80"
}

Monitor()
{
  echo "--------------------------"
  echo "[$(date +'%F %H:%M:%S')]"
  echo "[info]开始执行巡检..."
  System
  User
  if [ $TomcatID ];then #这里判断Tomcat进程是否存在
  echo "--------------------------"
    echo "[info]当前tomcat进程ID为:$TomcatID,继续检测页面..."
    # 检测是否启动成功(成功的话页面会返回状态"200")
    TomcatServiceCode=$(curl -s -o $GetPageInfo -m 10 --connect-timeout 10 $WebUrl -w %{http_code})
    if [ $TomcatServiceCode -eq 200 ];then
      echo "[info]页面返回码为$TomcatServiceCode，tomcat启动成功，测试页面正常"
      Thread
      Port
    else
      echo "[error]tomcat页面出错，请注意...状态码为$TomcatServiceCode，错误日志已输出到$GetPageInfo"
      echo "[error]页面访问出错，开始重启tomcat"
      kill -9 $TomcatID # 杀掉原tomcat进程
      sleep 3
      rm -rf $TomcatCache # 清理tomcat缓存
      $StartTomcat
    fi
  else
    echo "[error]tomcat进程不存在!tomcat开始自动重启..."
    echo "[info]$StartTomcat，请稍候..."
    rm -rf $TomcatCache
    $StartTomcat
  fi
  echo "--------------------------"
}
Monitor>>$TomcatMonitorLog

