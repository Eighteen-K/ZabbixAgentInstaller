#/bin/bash
echo "关闭selinux"
sed -i '/SELINUX/s/enforcing/disabled/' /etc/selinux/config
setenforce 0
#yum clean all

checkwget=`rpm -qa wget`
if [ -z $checkwget ];then
  yum  install wget -y  
fi

echo "下载zabbix-agent"
OSVERSION=`cat /etc/redhat-release |awk -F "release " '{print $2}'|awk -F "." '{print $1}'`
wget -P /opt http://repo.zabbix.com/zabbix/5.4/rhel/$OSVERSION/x86_64/zabbix-agent-5.4.3-1.el$OSVERSION.x86_64.rpm
#wget -P /opt http://192.168.99.107/software/zabbix-agent-5.4.3-1.el$OSVERSION.x86_64.rpm
rpm -ivh /opt/zabbix-agent-5.4.3-1.el$OSVERSION.x86_64.rpm
#rm -rf /opt/zabbix-agent-5.4.3-1.el$OSVERSION.x86_64.rpm

echo "修改zabbix-agent配置文件"
ipaddr=$(ip a show |grep ens|grep inet |awk '{print $2}'|awk -F '/' '{print $1}')
zabbix_server='10.2.3.233'
hostname=$(hostname)

sed -i "s/^Server=127.0.0.1/Server=${zabbix_server}/g" /etc/zabbix/zabbix_agentd.conf
sed -i "s/^ServerActive=127.0.0.1/ServerActive=${zabbix_server}/g" /etc/zabbix/zabbix_agentd.conf
sed -i "s/Hostname=Zabbix server/Hostname=${hostname}/g" /etc/zabbix/zabbix_agentd.conf
sed -i "s/# HostMetadata=/HostMetadata=Linux/g" /etc/zabbix/zabbix_agentd.conf

echo "防火墙放行zabbix-agent端口"
#firewall-cmd --permanent --add-port=10050-10051/tcp
#firewall-cmd --reload
echo "启动zabbix-agent服务"
systemctl start zabbix-agent && systemctl  enable zabbix-agent

zabbixagentpid=`ps -ef |grep zabbix_agentd|grep -w 'zabbix_agentd'|grep -v 'grep'|awk '{print $2}'`
if [ "$zabbixagentpid" ];then
      echo "zabbix agent is running "
   else
    echo "zabbix agent 安装失败！！！"
 fi
