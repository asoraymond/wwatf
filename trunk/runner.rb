require "util/checktable"
require "loadCaseFromMultiFile.rb"
#require "loadCaseFromMultiFile.rb"


$values_saved={}  # for store variable 


def getCommandFromFile # because not success in get input from console via multithread
  sleep 2
  old_command  = ""
  go_out = false 
  loop do 
   begin
      file = File.open("console.txt","r")
      command = file.gets.chomp
      file.close
      $stdout.flush
      if (command !=old_command)
        case command 
          when "pause","p"
            p "pause"
          when "resume","r"
            p "resume" 
            go_out = true 
            break
          when "stop","s"
            exit
          when "loadconf","l"
            p "reload config file"
            loadTestCaseFromMultiFile($maincasepath,$load_from_multicase_dir) 
          else
          end
          old_command = command
        end 
        p 2
      if (command =="" || go_out == true )
        break
      end 
    rescue 
      p "no command file"
    end 
  end 
end 


def getTableLocation(elementFindValue,inputwindow)
      specialinput = elementFindValue.split(":")  
      
      if specialinput.length>2  # TABLE:3:论语考试:1:1:0 button
         if specialinput[0]=="col"
           return getTableLocationByCol(inputwindow,elementFindValue)
         end 
         rowindex = getIndexFromTablebyText(inputwindow,specialinput[2],specialinput[1].to_i)
         if specialinput.length>3 
         startindex = specialinput[3].to_i;
         else 
           startindex = 1
         end 
         if specialinput.length>4 
           stepindex = specialinput[4].to_i;
         else
           stepindex = 1
         end 
         if specialinput.length>5  # TABLE:3:论语考试:1:1:0 button
           subtract_titleline = specialinput[5].to_i;
         else 
           subtract_titleline =0 
         end 
         $wlog.warn "getTableLocationSource:"+elementFindValue+" = "+(startindex+(rowindex-1-subtract_titleline)*stepindex).to_s
         return    startindex+(rowindex-1-subtract_titleline)*stepindex 
       end 
       # not parser the elementFindValue :TABLE:3:论语考试:1:1:0 button  or col:试卷开放日期:2008-12-04:0:table:3
       return 0
end 

def getSaveValue(checkwindow, elementFindby, elementFindValue)
#      考试结果录入-录入页面.定位奥数考试:NotInputMark.*>:[0-9]+
# "2:NotInputMark.*>:[0-9]+:mainFrame"
      $wlog.warn elementFindby 
      $wlog.warn elementFindValue
      distillmark = elementFindby.split(":")
      if distillmark.length<2
        $wlog.fatal "getSaveValue's elementFindby should contain prefix:suffix  "
        return 
      end 
      if elementFindValue != ""  and (elementFindValue.gsub(/[0-9]*/,'') !="")

        index =getTableLocation(elementFindValue,checkwindow)  -1
          # because  
          #             1-   array start from 0 
        $wlog.warn "getTableLocation:"+elementFindValue+" index:"+index.to_s 
      else 
        index = elementFindValue.to_i
        if index > 0
          index = index -1
        end
      end
      
      reg0=Regexp.new(distillmark[0]+distillmark[1])
      reg1= Regexp.new(distillmark[0])
      s = checkwindow.html
      matched=s.scan(reg0)
#      matched.each{|m| p m}
      s0 = matched[index]
      if (s0==nil)
        p "Failed on getSaveValue mark:"+distillmark[0]+distillmark[1]
        p checkwindow.html
        return ""
      end 
      s1= s0.scan(reg1)[0]
      $wlog.warn "getSaveValue:"+s0[s1.length..s0.length-1]
      return s0[s1.length..s0.length-1]
end 
   

def reliable_browserinput(input,expect="")
  # 太经典了，这就是典型的错误重发机制
#      puts  input
      
      pass = true 
      for i in 1..6
        begin 
          pass = true 
          result= browserinput(input,expect)
        rescue =>exDetail
          sleep 1

          if exDetail.backtrace[0].match("assert_enabled") && expect.match("disablebutton:")
            pass = true 
            result = true 
            break
          else
            if  i==6
              p exDetail.backtrace[0]
            end 
            pass = false
            putsHash input
          end 
          $wlog.warn "!error input"+i.to_s+",current IE window not refresh:"+input["name"]
          $stdout.flush
        end 
        if pass == true 
          break
        end 
     end 
     if pass == false 
#        p $ie.frame("mainFrame").html
        if $wlog.level < MyLogger::FATAL
          return browserinput(input,expect)
        end 
        puts("!error input "+i.to_s+ " may  performance issue:"+ input["name"]) 
        if !$run_unbreak
          exit 
        end 

      end
      return result
end 

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
          b = input["frame"].split(".")
          input_window = $ie
          b.each do |frmname|
            input_window = input_window.frame(frmname)
          end
        end 
      rescue 
        puts "!no this frame can op "+input["frame"] 
        return 
      end 
    end 
    
    element_op =input["set"]
    element_type = input["elementType"]
    elementFindby = input["elementFindby"]
    elementFindValue= input["elementFindValue"]
    if (elementFindby=="index") and (elementFindValue.gsub(/[\-0-9]*/,'') !="")
      elementFindValue=getTableLocation(elementFindValue,input_window)
      if  elementFindValue<0
        elementFindValue = 1
      end 
    end
    

    if element_type =="savevalue" 
      curvalue =  getSaveValue(input_window, elementFindby, elementFindValue)
      oldvalue =  $values_saved[input["name"]]

      if oldvalue !=nil 
        $wlog.warn input["name"]+"oldvalue: "+oldvalue + " curvalue:"+curvalue
        if  oldvalue.gsub(/[\-0-9]*/,'') ==""  # is digital 
          return (curvalue.to_i - oldvalue.to_i  ).to_s
        else
          return (oldvalue==curvalue)     # is string 
        end 
      else              # first time get value
        $wlog.warn input["name"]+": oldvalue is nil "+curvalue
        $values_saved[input["name"]]=curvalue
        return ""
      end 
    end 
    

    case element_type
      when "link","button","image","li"
          element_op = "click"
#          p expect
          if expect.match("opupWindow")
            element_op = element_op+"_no_wait" 
          end;
          if expect.match("saveFileWindow")
            element_op = element_op+"_no_wait" 
          end
       when  "radio" ,"checkbox"   # here some specifical process to radio and checkbox. 
         
         if input["set"].gsub(/[\-0-9]*/,'') ==""   # 为正负整数
            if input["set"].to_i >0  
             elementFindValue = input["set"].to_i
             element_op = "set"
             end
             if input["set"].to_i <0  
               elementFindValue = input_window.radios.length
               element_op = "set"
             end 
         else 
            if input["set"] == "yes"
              element_op = "set";
            end
         end 
       when "text_field" ,"select_list","file_field"
        element_op = "set"
        if input["set"] == "nil" or input["set"]=="NIL"
              input["set"] = "";
        end
       when "keypress"
        
       else 
          if input["sleep"] != "" and input["sleep"] !=nil 
            sleep input["sleep"].to_i 
          end 
          puts "!error--------------not support element type:" + element_type
          return 
        end 
     if elementFindValue.kind_of?String
         if elementFindby == nil 
            elementFindby= "NIL"
          end 
         if element_op == nil 
            element_op= "nil"
          end 
          $wlog.warn "input:"+element_type+"|"+elementFindby+"|"+elementFindValue+"|"+element_op
        else 
          $wlog.warn "input:"+element_type+"|"+elementFindby+"|"+elementFindValue.to_s+"|"+element_op
        end 

    $stdout.flush
    if element_type == "keypress"
      $ie.send_keys(elementFindValue)
    else
      if input["isvalue"] == "yes"  || (input["isvalue"]!="" and input["isvalue"]!=nil)
        (input_window.method(element_type).call(:"#{elementFindby}",elementFindValue)).value = input["set"]
      else 
           if  element_op == "set"  and (element_type=="text_field"|| element_type=="select_list"||element_type=="file_field")
             (input_window.method(element_type).call(:"#{elementFindby}",elementFindValue)).method("set").call input["set"]
          else 
            (input_window.method(element_type).call(:"#{elementFindby}",elementFindValue)).method(element_op).call
          end 
        end
    end       
     
    if input["sleep"] != "" and input["sleep"] !=nil 
       sleep input["sleep"].to_i
    else
         if (element_type == "link" || element_type ==  "button")

           $stdout.flush
          sleep $action_sleep_time # 给页面的现实足够的时间
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

def pringScenarios(scenarios)
  scenarios.each do |x|
    puts x
  end
end

$top_scenario_count =0
$scenario_count =0
def runScenarios(scenarios, first_level=false) 
  
  str = "|--"
  for i in 1..40
    str+="--"
  end
  str +="|"
  scenarios.each do |x|   
    
   if  x[0,1] == "#"
      if first_level == true
        puts "\n\n"
        x = x[1...x.length]
#        puts str
        $wlog.only "Not execute"+ x
#        puts str
#        if $scenarios[x]!=nil 
#          puts str
#          puts $scenarios[x]
#          puts str
#        end 
        next
      else
        next
      end
    end
 

    #scenarios:Scenario_zujuan1=> login , jiaoshizhujuan 
      if $scenarios[x] != nil

        if first_level == true 
          $top_scenario_count +=1
          $wlog.only  "\nRunning Top scenario :"+$top_scenario_count.to_s+": "+x
        else  
          $scenario_count +=1
          $wlog.only "\nRunning scenario :"+$scenario_count.to_s+": "+x
        end 
        runScenarios($scenarios[x]) 
      else
        if $testsuites[x] != nil
          runTestsuite(x)
        else 
          if (checkTestCase(x))
            runTestCase(x)
          else  
            $scenario_count +=1
            puts "failed to run scenario:"+$scenario_count.to_s+": "+x
          end
        end   
    end 
  end
end

def checkTestCase(x)
  _tc = x.split(".")

#  p _tc[0]+" "+_tc[1]
#  p "checkTestcase:"+_tc.join("-")
  if _tc.length == 1
     return false
   end
   
   if $testsuites[_tc[0]] != nil and $testsuites[_tc[0]]["testcases"][_tc[1]] != nil 
    return true 
  end
  $wlog.only  "no this case:"+_tc[0]+"."+_tc[1] +"\n"
  return false
end

   
def testcaseStartup(testsuite)
  putsHash testsuite
# enter the case   , now only process sheet:    login  
  _startpoint = testsuite["startPoint"]
#  puts "\nTestcaseStart  at:" + _startpoint
  if _startpoint=~ /http:/ 
    $ie.goto(_startpoint)
    $wlog.warn  "\nTestcaseStart  at:" + _startpoint
  end
end 

def testcaseTeardown(testcase) 
#  puts "\nTestcase Teardown ----------" 
  reliable_browserinput(testcase["resetop"])
end 



def runTestCase(x)  # login.正确登录
  
# comment   expect  expectFrame popupText   resetop inputs[username,passwd] op        
  $wlog.warn "runTestCase: "+x
  
  return #########for debug ***********************
  
  
  _tc = x.split(".")
  
  $input_num = 0 
  testcaseStartup($testsuites[_tc[0]]) 
#p 11;$stdout.flush
  #begin input ---------------  
   testcase = $testsuites[_tc[0]]["testcases"][_tc[1]]  
#   puts "\ntestcase input start-------------"
   testcase["inputs"].each do |input| 
     reliable_browserinput(input)
     $input_num+=1
   end 
#        putsHash input         
#p 12;$stdout.flush
         # testcase["saveDesktopPreOP"]="yes" 
         
   opresult = reliable_browserinput(testcase["op"],testcase["expect"])
   # testcase["saveDesktopPostOP"]="yes" 
   if (testcase["op"] != "" && testcase["op"]!= nil)
     $input_num+=1
   end 
   if $input_num ==0
     p "no input"
     sleep $no_input_sleep_time
   end
#  p 13;$stdout.flush
   # all input end 
   
   #if (_tc[0] == "login" and (testcase["comment"].match("正常登录" )))   # bug dissappeard   
   #   $ie.refresh     # now here is a bug. 
   #   puts "refresh IE"
   #end
   check_window = $ie 
#p 14;$stdout.flush
   begin 
       if testcase["expect"].match("opupWindow")==nil
        if testcase["expectFrame"] !=""
          if testcase["expectFrame"] .match("NW:")  # new window
              a = testcase["expectFrame"] .split(":")
              check_window = Watir::IE.attach(:"#{a[1]}", Regexp.new(a[2]))
            else
              b = testcase["expectFrame"].split(".")
              b.each do |frmname|
                check_window = check_window.frame(frmname)
              end  
            end 
          end 
       end 
   rescue=>exDetail
        p exDetail.backtrace[0]
        if !$run_unbreak
          exit 
        end 
   end
 
#p 145;p 1231231232;$stdout.flush    
   $wlog.warn "EXPECT:" + testcase["expect"]+"|"+testcase["expectFrame"];  
   $result_comment = x
   if testcase["step"] !=nil 
     $result_comment  = x+" "+testcase["comment"]
   end 
   if opresult.kind_of?String   # String for  integer compare result  ; true/false for string; nil for no savedvalue list
     $wlog.warn opresult ;
     printTestResult(opresult ==testcase["expect"], $IE_POPUP_TITLE, $result_comment)
   else 
     expect = testcase["expect"]
     if (opresult==true && expect.match("disablebutton:"))
       expect =  expect.gsub("disablebutton:","")
     end
     printTestResult((check_window.text.include?(expect)) ,$IE_POPUP_TITLE, $result_comment,testcase["expect"], check_window,testcase["popupText"])
  end
#  printTestResult(should,popup_title, funcname,expect_text="", ie=nil,popupText=nil,_button="确定")

  testcaseTeardown(testcase) 
  $stdout.flush
end



