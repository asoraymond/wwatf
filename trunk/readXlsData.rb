require "util/mylogger"  
require 'logger'

require "util/XlsEx"
require "util/util"  


# call method: loadTestCaseData  
# now we got $scenario and $testsuites.

$wlog = MyLogger.new(STDOUT)
$wlog.level = MyLogger::DEBUG


###############################
# testcase.key = login.登录用户已经离校不能登录系统
# testcase.value = { op  expectFrame popupText expect resetop comment  inputs = [{key.value}]}
###############################
def getTestsuitsFromFile(sheet,dict, xls)
      
      $wlog.info " Enter  load TestSuits--   start.... "+ sheet;   $stdout.flush
      testsuite = xls.getHash("A1:B2",sheet)
      $testsuites[sheet]=testsuite
      rh = xls.getRowRecordsHash("A",4, sheet)
      testcases = rh[0]
      headerArray = rh[1]
      headerLength = headerArray.length
      
#      putsHash testcases
      testcases.each do |key,testcase|  # loop for good process.
         
         ###################
         # key= login.一二三年级的语文教研组长朱海霞正确登录
         # value = { comment	expect	expectFrame	popupText	resetop	username	passwd	op }       example process 
         # #####################
         #  
         #### get "resetop" data from dict 
         if testcase["resetop"] !=""  
            if dict[sheet+"."+testcase["resetop"]] == nil
              $wlog.only "!1dict ndef:resetop\t"+sheet+"."+testcase["resetop"]
            else 
              testcase["resetop"] =dict[sheet+"."+testcase["resetop"]]
            end  
         else 
           testcase["resetop"] = nil
         end
         
         input_list = Array.new
         headerArray[5..headerLength-2].each do |input|     # every header should be single  
           begin 
           
           if testcase[input] !="" 
              setvalue = testcase[input]
              if (input.match("action")) 
                if dict[sheet+"."+setvalue] != nil 
                  testcase[input] = dict[sheet+"."+setvalue].clone    # for a serial op named by action1. to do serial op .  
                else

                  $wlog.only "!2dict ndef:action*\t"+sheet+"."+setvalue    
                end 
              else 
                if dict[sheet+"."+input] != nil
                  testcase[input] =dict[sheet+"."+input].clone          # spend 8 hours  , 真是奇耻大辱，为什么不能好好分析一下，直接定位呢？
                  testcase[input]["set"]=setvalue
                else
                  $wlog.fatal "!3dict ndef:input\t"+sheet+"."+input   
                end
              end 
              input_list << testcase[input]
            end
            rescue
               $wlog.only "--error sheet:"+sheet+" input:"+input  
               puts testcase[input]
            end 
          end 
          
         if testcase["op"] !=""  
          if dict[sheet+"."+testcase["op"]] == nil    
              $wlog.only("!4dict ndef:op\t"+sheet+"."+testcase["op"])
          else 
            testcase["op"] =dict[sheet+"."+testcase["op"]]
          end
         else 
           testcase["op"] = nil
         end 
         testcase["inputs"]= input_list;   
#         puts dict["login.username"]["set"]
#         puts "inputs:"
#         puts input_list
       end
       
#       testcases.each do |key,testcase|  # loop for good process.  
#         puts "testcase username:"+testcase["username"]["set"]
#       end
       
       
       testsuite["testcases"] = testcases
       $wlog.info " Quit  load TestSuits-- "+ sheet;   $stdout.flush
end

def getScenariosAndTestSuitsFromFile(scenario_name,scenarios,dict, xls)
#      puts scenario_name
      if ($scenarios[scenario_name]!=nil  || $testsuites[scenario_name]!=nil) 
        return 
      end
      $wlog.info "EnterSheet-- "+ scenario_name
      $stdout.flush
      if (scenarios[0] =="startPoint")
          getTestsuitsFromFile(scenario_name,dict, xls)
      else     # scenario page 
 #         puts " ....  scenario array-"+ (scenarios.join("|"))
          $scenarios[scenario_name]=scenarios
          (0..scenarios.length-1).each do |scenario|
            _sheet = scenarios[scenario].split('.')  # login.***  etc.
            _sheet_name = _sheet[0]
            _insheet_array= xls.get1DColumnArray("A",1,_sheet_name)
            getScenariosAndTestSuitsFromFile(_sheet_name,_insheet_array,dict, xls)
          end 
      end 
end

def printTestCases(testsuites)
  return 
  testsuites.each do |key1,testsuite|   
      
      testsuite.each do |key2 , testcases|
        puts ""+key1+"--"+key2
        if (key2 =="testcases")   # login.testcases
         puts "\n" 
        testcases.each do |key3 , testcase| # login.testcases.一年级数学老师王彦燕正确登录
            puts "********"+key3 
=begin
            testcase.each do |key,value|       
              puts key+"=" 
              if key == "inputs" #login.testcases.一年级数学老师王彦燕正确登录.inputs
                puts "--input ---------------------------------------"
                value.each do |input|
                  putsHash input
                end 
              else 
              puts value
              end 
            end 
         
            testcase["inputs"].each do |input|
                putsHash input
             end 
=end                
        end 
        end 
      end 
  end 
end 

def loadTestCaseData(filename) 
  xlFile = XLSEx.new(filename)

  begin
  $cases = xlFile.get1DColumnArray("A",1, "CASE")  # get 1D array from A1
  $dict = xlFile.getRowRecordsHash("A",1, "DICT")[0]  # get dict { login.登录=>name,elementtype,elementname,value }
  $scenarios={}
  $testsuites={}

  getScenariosAndTestSuitsFromFile("CASE",$cases,$dict, xlFile)
  $wlog.info "\n-scenarios-----------------------"
  putsHash $scenarios
  $wlog.info "-print test suites-------------------------------------------"
#  putsHash $testsuites 
  printTestCases($testsuites)  
  rescue
   p "can not open "+ filename
  ensure 
  xlFile.close
  end 
end
 
#loadTestCaseData  "1.12testCaseData.xls"

#  call method: loadTestCaseData  "1.1testCaseData.xls"
# now we got $scenario and $testsuites.
 
