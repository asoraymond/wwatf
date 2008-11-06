require "runner.rb"

t0 = Time.now  

$wlog.level = MyLogger::DEBUG
$wlog.only "\n\n begin load testsuite from [CASE]"
loadTestCaseData(Dir.pwd+"/data/testcase.xls")     # load one file
$wlog.only "\n\n begin run testsuite from [CASE]"
launchBrowser
runScenarios($scenarios["CASE"],true )
t1 = Time.now 
puts  "this test spend:"
puts t1-t0


