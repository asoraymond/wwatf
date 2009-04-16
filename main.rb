require 'util/XlsEx.rb'
require "runner.rb"


$IE7_POPUP_TITLE = "Windows Internet Explorer"
$IE6_POPUP_TITLE = "Microsoft Internet Explorer"


$wlog = MyLogger.new(STDOUT)#"./run.log")



#===================================================================
# �����Ҫ�޸ĵĲ���
#===================================================================
$startsheet_name = "CASE"                 # ����case ��
$action_sleep_time =1                         # �����ť�������Ӻ�ĵȴ�ʱ��
$no_input_sleep_time=2                       # û������ʱ�ĵȴ�ʱ�� 
$IE_POPUP_TITLE = $IE6_POPUP_TITLE  # IE �ĵ������ڱ���
$wlog.level = MyLogger::FATAL           # ���Լ���  #DEBUG ������Ϣ #WARN ���Լ���   #FATAL ���м���
$maincasepath=Dir.pwd+"/data/������������.xls" # "/commoncase"# ��Ҫ���е���xls Ŀ¼����xls �ļ�
#$maincasepath=Dir.pwd+ "/fh" # ��Ҫ���е���xls Ŀ¼����xls �ļ�
#$maincasepath=Dir.pwd+ "/fn/����ѧ����Դ.xls."#������������.xls" # ��Ҫ���е���xls Ŀ¼����xls �ļ�
$load_from_multicase_dir = false          # true �Ӷ��case ��β��Ŀ¼װ�ز�������  ; false ��һ���ļ�����Ŀ¼��װ��
$check_xls_data = false                      #  �Ƿ�������xls ����
$run_unbreak = false                         #  �����Ƿ��ȥ���ܹرյĴ���

#==================================================================

if $run_unbreak
  $wlog.level = MyLogger::FATAL
  exec('ruby monitorpopup.rb') if fork == nil
end 

#==============================================================================

$wlog.only "\n\n begin load testsuite from [CASE]"
loadTestCaseFromMultiFile($maincasepath,$load_from_multicase_dir)     # load one file or one dir 


#==============================================================================
launchBrowser  1024,768,"exam"          #   ����IE �ķֱ��ʺ�url pattern

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
