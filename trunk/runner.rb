require "readXlsData.rb"

$IE_POPUP_TITLE = "Microsoft Internet Explorer"

def browserinput(input, expect="")
    if (input == nil)
     return
    end 
#   puts "Browser input --------" 
#   puts input["elementFindValue"]
    
    new_window = false
    input_window = $ie 
    if input["frame"] !="" 
      begin
        if input["frame"].match("NW:")  # new window
          a = input["frame"].split(":")
          input_window = Watir::IE.attach(:"#{a[1]}", Regexp.new(a[2]))
          new_window = true
        else              
          input_window = $ie.frame(input["frame"])
        end 
      rescue 
        puts "!no this frame can op "+input["frame"] 
        return 
      end 
    end 
    
    element_op =""
    element_type = input["elementType"]
    
    case element_type
      when "link","button"
          element_op = "click"
          if expect == "popupWindow"
            element_op = element_op+"_no_wait" 
          end;
       when  "radio" ,"checkbox"   # here some specifical process to radio and checkbox. 
          if input["set"] == "yes"
           element_op = "set";
         end
         if input["set"].to_i >0  
           input["elementFindValue"] = input["set"].to_i
           element_op = "set"
         end 
       when "text_field" ,"select_list"
          element_op = "set"
        else 
          puts "!error--------------not support element type" + element_type
          return 
    end 
    
    elementFindby = input["elementFindby"]
    if input["isvalue"] == "yes"
      (input_window.method(element_type).call(:"#{elementFindby}",input["elementFindValue"])).value = input["set"]
    else 
         if  element_op == "set"  and (element_type == "text_field" || element_type == "select_list")
           (input_window.method(element_type).call(:"#{elementFindby}",input["elementFindValue"])).method("set").call input["set"]
        else 
          (input_window.method(element_type).call(:"#{elementFindby}",input["elementFindValue"])).method(element_op).call
        end 
    end 
     
    if input["sleep"] != "" and input["sleep"] !=nil 
       sleep input["sleep"].to_i
    else
        if (element_type == "link" || element_type ==  "button")
          sleep 1 # 给页面的现实足够的时间
        end
    end 
end 


def runTestsuite(testsuite)  # login
  $wlog.info "runTestSuite: "+testsuite
  $testsuites[testsuite]["testcases"].each do |key,value|
    runTestCase(testsuite+"."+key)
  end 
  $wlog.info  "runTestSuite: end"
end


def runScenarios(scenarios, first_level=false) 

  scenarios.each do |x|   

    #scenarios:Scenario_zujuan1=> login , jiaoshizhujuan 
      if $scenarios[x] != nil
        if first_level == true 
          $wlog.fatal  "scenario: "+x
        else  
          $wlog.warn "scenarios:"+x
        end 
        runScenarios($scenarios[x]) 
      else
        if $testsuites[x] != nil
          
          runTestsuite(x)
        else 
          if (checkTestCase(x))
            runTestCase(x)
          else  
            puts "failed to run scenario:"+x
          end
        end   
    end 
  end
end

def checkTestCase(x)
  _tc = x.split(".")
   if $testsuites[_tc[0]]["testcases"][_tc[1]] != nil 
    return true 
  end 
  return false
end

def testcaseStartup(testsuite)
# enter the case   , now only process sheet:    login  
  _startpoint = testsuite["startPoint"]
#  puts "\nTestcaseStart  at:" + _startpoint
  if _startpoint=~ /http:/ 
    $ie.goto(_startpoint)
  end
end 

def testcaseTeardown(testcase) 
#  puts "\nTestcase Teardown ----------" 
      for i in 1..10
        begin 
          pass = true 
          browserinput(testcase["resetop"])
        rescue 
          sleep 1
          pass = false
          putsHash input
          puts ("!error input"+i.to_s+", current IE window not refresh:" + input["name"])
        end 
        if pass == true 
          break
        end 
     end 
  
end 



def runTestCase(x)  # login.正确登录
# comment	expect	expectFrame	popupText	resetop	inputs[username,passwd]	op        
  $wlog.warn "runTestCase: "+x
  _tc = x.split(".")
  
  
  testcaseStartup($testsuites[_tc[0]]) 

  #begin input ---------------  
   testcase = $testsuites[_tc[0]]["testcases"][_tc[1]]  
#   puts "\ntestcase input start-------------"
   testcase["inputs"].each do |input| # 太经典了，这就是典型的错误重发机制
      pass = true 
      for i in 1..10
        begin 
          pass = true 
          browserinput(input)
        rescue 
          sleep 1
          pass = false
          putsHash input
          puts ("!error input"+i.to_s+", current IE window not refresh:" + input["name"])
        end 
        if pass == true 
          break
        end 
     end 
     if pass == false 
        puts("!error input "+i.to_s+ " may  performance issue:"+ input["name"]) 
     end
    end 
#        putsHash input         
   browserinput(testcase["op"],testcase["expect"])
   # all input end 
   $wlog.warn "-----EXPECT -----------" + testcase["expect"];
   
   #if (_tc[0] == "login" and (testcase["comment"].match("正常登录" )))   # bug dissappeard   
   #   $ie.refresh     # now here is a bug. 
   #   puts "refresh IE"
   #end
   check_window = $ie 
   
   if testcase["expectFrame"] !="" 
        if testcase["expectFrame"] .match("NW:")  # new window
          a = testcase["expectFrame"] .split(":")
          check_window = Watir::IE.attach(:"#{a[1]}", Regexp.new(a[2]))
          
        else              
           check_window = $ie.frame(testcase["expectFrame"])
          end 
    end 
    
    printTestResult((check_window.text.include?(testcase["expect"])) ,$IE_POPUP_TITLE, testcase["comment"],testcase["expect"], check_window,testcase["popupText"])
  
#  printTestResult(should,popup_title, funcname,expect_text="", ie=nil,popupText=nil,_button="确定")

  testcaseTeardown(testcase) 
  $stdout.flush

end



