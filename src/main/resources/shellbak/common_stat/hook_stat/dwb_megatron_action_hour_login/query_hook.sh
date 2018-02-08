#!/bin/sh
#source ~/.bashrc #很重要,不然hive指令不执行

source ~/.bash_profile;
BASEDIR=`dirname $0`
cd $BASEDIR

#分隔符
yesterday=`date -d last-day +%Y%m%d`
#如果脚本传入指定日期参数,覆盖默认的设置
if [ "$#" -eq 1 ]; then
   yesterday=$1
fi

echo "正在导入${yesterday}的埋点PV和UV数据"
 
#埋点统计
baseTableCond="from dwb.dwb_megatron_action_hour where dt = '${yesterday}' and country = 'cn' and app_name = 'vipCashier'"
echo ${dataPath}


#弹窗页面 登录
hive -e"
select '${yesterday}', count(distinct a.letv_cookie) regshow, count(distinct b.letv_cookie) regshow_login, count(distinct c.letv_cookie) regshow_login_succ, count(distinct d.userid) regshow_succ_order, 'regshow_login1', '显示注册弹窗页面登录' from (
	select distinct letv_cookie $baseTableCond and props = 'ch=zhifu&pg=tobuy&bk=goLogin&link=regshow'
) a left join (
	select distinct letv_cookie $baseTableCond and props = 'ob_ca=login1'
) b on a.letv_cookie = b.letv_cookie left join (
	select distinct letv_cookie, uid_cookie $baseTableCond and uid_cookie <> '-'
) c on b.letv_cookie = c.letv_cookie left join (
	select distinct userid from dm_boss.t_new_order_4_data where status > 0 and orderpaytype = 2 and money > 0 and paychannel not in (47, 58) and ordertype in (2, 3, 5, 52) and terminal = 112
) d on c.uid_cookie = d.userid
" > ./data/query_hook_data.${yesterday}

#弹窗页面 需要短信验证码登录
hive -e"
select '${yesterday}', count(distinct a.letv_cookie) regshow, count(distinct b.letv_cookie) regshow_login, count(distinct c.letv_cookie) regshow_login_succ, count(distinct d.userid) regshow_succ_order, 'regshow_loginSMS', '显示注册弹窗页面需要短信验证码登录' from (
	select distinct letv_cookie $baseTableCond and props = 'ch=zhifu&pg=tobuy&bk=goLogin&link=regshow'
) a left join (
	select distinct letv_cookie $baseTableCond and props = 'ob_ca=login1'
) e on a.letv_cookie = e.letv_cookie left join (
	select distinct letv_cookie $baseTableCond and props = 'ob_ca=loginSMS'
) b on e.letv_cookie = b.letv_cookie left join (
	select distinct letv_cookie, uid_cookie $baseTableCond and uid_cookie <> '-'
) c on b.letv_cookie = c.letv_cookie left join (
	select distinct userid from dm_boss.t_new_order_4_data where status > 0 and orderpaytype = 2 and money > 0 and paychannel not in (47, 58) and ordertype in (2, 3, 5, 52) and terminal = 112
) d on c.uid_cookie = d.userid
" >> ./data/query_hook_data.${yesterday}

#弹窗页面 立即注册
hive -e"
select '${yesterday}', count(distinct a.letv_cookie) regshow, count(distinct b.letv_cookie) regshow_login, count(distinct c.letv_cookie) regshow_login_succ, count(distinct d.userid) regshow_succ_order, 'regshow_singUp1', '显示注册弹窗页面立即注册登录' from (
	select distinct letv_cookie $baseTableCond and props = 'ch=zhifu&pg=tobuy&bk=goLogin&link=regshow'
) a left join (
	select distinct letv_cookie $baseTableCond and props = 'ob_ca=signUp1'
) b on a.letv_cookie = b.letv_cookie left join (
	select distinct letv_cookie, uid_cookie $baseTableCond and uid_cookie <> '-'
) c on b.letv_cookie = c.letv_cookie left join (
	select distinct userid from dm_boss.t_new_order_4_data where status > 0 and orderpaytype = 2 and money > 0 and paychannel not in (47, 58) and ordertype in (2, 3, 5, 52) and terminal = 112
) d on c.uid_cookie = d.userid
" >> ./data/query_hook_data.${yesterday}

#弹窗页面 QQ 微信 新浪 支付宝 百度 人人 登录
hive -e"
select '${yesterday}', count(distinct a.letv_cookie) regshow, count(distinct b.letv_cookie) regshow_login, count(distinct c.letv_cookie) regshow_login_succ, count(distinct d.userid) regshow_succ_order, 'regshow_loginOther', '显示注册弹窗页面QQ微信等其他方式登录' from (
	select distinct letv_cookie $baseTableCond and props = 'ch=zhifu&pg=tobuy&bk=goLogin&link=regshow'
) a left join (
	select distinct letv_cookie $baseTableCond and props in ('ob_ca=qq', 'ob_ca=weixin', 'ob_ca=sina', 'ob_ca=alipay', 'ob_ca=baidu', 'ob_ca=renren')
) b on a.letv_cookie = b.letv_cookie left join (
	select distinct letv_cookie, uid_cookie $baseTableCond and uid_cookie <> '-'
) c on b.letv_cookie = c.letv_cookie left join (
	select distinct userid from dm_boss.t_new_order_4_data where status > 0 and orderpaytype = 2 and money > 0 and paychannel not in (47, 58) and ordertype in (2, 3, 5, 52) and terminal = 112
) d on c.uid_cookie = d.userid
" >> ./data/query_hook_data.${yesterday}



#弹窗页面 登录
hive -e"
select '${yesterday}', count(distinct a.letv_cookie) reghide, count(distinct b.letv_cookie) reghide_login, count(distinct c.letv_cookie) reghide_login_succ, count(distinct d.userid) reghide_succ_order, 'reghide_login1', '隐藏注册弹窗页面登录' from (
	select distinct letv_cookie $baseTableCond and props = 'ch=zhifu&pg=tobuy&bk=goLogin&link=reghide'
) a left join (
	select distinct letv_cookie $baseTableCond and props = 'ob_ca=login1'
) b on a.letv_cookie = b.letv_cookie left join (
	select distinct letv_cookie, uid_cookie $baseTableCond and uid_cookie <> '-'
) c on b.letv_cookie = c.letv_cookie left join (
	select distinct userid from dm_boss.t_new_order_4_data where status > 0 and orderpaytype = 2 and money > 0 and paychannel not in (47, 58) and ordertype in (2, 3, 5, 52) and terminal = 112
) d on c.uid_cookie = d.userid
" >> ./data/query_hook_data.${yesterday}

#弹窗页面 需要短信验证码登录
hive -e"
select '${yesterday}', count(distinct a.letv_cookie) reghide, count(distinct b.letv_cookie) reghide_login, count(distinct c.letv_cookie) reghide_login_succ, count(distinct d.userid) reghide_succ_order, 'reghide_loginSMS', '隐藏注册弹窗页面需要短信验证码登录' from (
	select distinct letv_cookie $baseTableCond and props = 'ch=zhifu&pg=tobuy&bk=goLogin&link=reghide'
) a left join (
	select distinct letv_cookie $baseTableCond and props = 'ob_ca=login1'
) e on a.letv_cookie = e.letv_cookie left join (
	select distinct letv_cookie $baseTableCond and props = 'ob_ca=loginSMS'
) b on e.letv_cookie = b.letv_cookie left join (
	select distinct letv_cookie, uid_cookie $baseTableCond and uid_cookie <> '-'
) c on b.letv_cookie = c.letv_cookie left join (
	select distinct userid from dm_boss.t_new_order_4_data where status > 0 and orderpaytype = 2 and money > 0 and paychannel not in (47, 58) and ordertype in (2, 3, 5, 52) and terminal = 112
) d on c.uid_cookie = d.userid
" >> ./data/query_hook_data.${yesterday}

#弹窗页面 QQ 微信 新浪 支付宝 百度 人人 登录
hive -e"
select '${yesterday}', count(distinct a.letv_cookie) reghide, count(distinct b.letv_cookie) reghide_login, count(distinct c.letv_cookie) reghide_login_succ, count(distinct d.userid) reghide_succ_order, 'reghide_loginOther', '显示注册弹窗页面QQ微信等其他方式登录' from (
	select distinct letv_cookie $baseTableCond and props = 'ch=zhifu&pg=tobuy&bk=goLogin&link=reghide'
) a left join (
	select distinct letv_cookie $baseTableCond and props in ('ob_ca=qq', 'ob_ca=weixin', 'ob_ca=sina', 'ob_ca=alipay', 'ob_ca=baidu', 'ob_ca=renren')
) b on a.letv_cookie = b.letv_cookie left join (
	select distinct letv_cookie, uid_cookie $baseTableCond and uid_cookie <> '-'
) c on b.letv_cookie = c.letv_cookie left join (
	select distinct userid from dm_boss.t_new_order_4_data where status > 0 and orderpaytype = 2 and money > 0 and paychannel not in (47, 58) and ordertype in (2, 3, 5, 52) and terminal = 112
) d on c.uid_cookie = d.userid
" >> ./data/query_hook_data.${yesterday}
