require 'util/XlsEx.rb'
require "runner.rb"


$IE7_POPUP_TITLE = "Windows Internet Explorer"
$IE6_POPUP_TITLE = "Microsoft Internet Explorer"


$wlog = MyLogger.new(STDOUT)#"./run.log")



#===================================================================
# 你可能要修改的参数
#===================================================================
$startsheet_name = "CASE"                 # 启动case 名
$action_sleep_time =1                         # 点击按钮或者链接后的等待时间
$no_input_sleep_time=2                       # 没有输入时的等待时间 
$IE_POPUP_TITLE = $IE6_POPUP_TITLE  # IE 的弹出窗口标题
$wlog.level = MyLogger::FATAL           # 调试级别  #DEBUG 所有信息 #WARN 调试级别   #FATAL 运行级别
$maincasepath=Dir.pwd+"/data/测试用例例子.xls" # "/commoncase"# 我要运行的主xls 目录或者xls 文件
#$maincasepath=Dir.pwd+ "/fh" # 我要运行的主xls 目录或者xls 文件
#$maincasepath=Dir.pwd+ "/fn/广义学区资源.xls."#测试用例例子.xls" # 我要运行的主xls 目录或者xls 文件
$load_from_multicase_dir = false          # true 从多个case 结尾的目录装载测试用例  ; false 从一个文件或者目录中装载
$check_xls_data = false                      #  是否仅仅检查xls 数据
$run_unbreak = false                         #  设置是否点去不能关闭的窗口

#==================================================================

if $run_unbreak
  $wlog.level = MyLogger::FATAL
  exec('ruby monitorpopup.rb') if fork == nil
end 

#==============================================================================

$wlog.only "\n\n begin load testsuite from [CASE]"
loadTestCaseFromMultiFile($maincasepath,$load_from_multicase_dir)     # load one file or one dir 


#==============================================================================
launchBrowser  1024,768,"exam"          #   设置IE 的分辨率和url pattern

#Now we have  $scenarios     $testsuites

if $check_xls_data == true 
  exit 
end 

$wlog.only "\n\n begin run testsuite from [CASE]" 

#for i in 1..1000 do 
t0 = Time.now  
runScenarios($scenarios[$startsheet_name],true )
t1 = Time.now 
p "this test spend:"+(t1-t0).to_s
#end 
