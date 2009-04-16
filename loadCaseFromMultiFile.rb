require "util/mylogger"  
require "util/XlsEx"
require "util/util"  

# call method: loadTestCaseData  
# now we got $scenario and $testsuites.


###############################
# testcase.key = login.登录用户已经离校不能登录系统
# testcase.value = { op  expectFrame popupText expect resetop comment  inputs = [{key.value}]}
###############################
def getTestsuitsFromFile(sheet,dict, xls)
#    p "getTestsuitsFromFile:"+ sheet 
      if $testsuites[sheet]!=nil
        return 
      end 
      
      $wlog.info " Enter  load TestSuits--   start.... "+ sheet;   $stdout.flush

      if xls == nil   #for load from multifile   , but CASE scenarios file xls is not nil 
          $wlog.info "testcase-"+sheet+" file:"+fileOfScenario(sheet)
          xls = $filedescs[fileOfScenario(sheet)]
          _mydict = xls.getRowRecordsHash("A",1, "DICT")[0]
          _mydict.each do |key,value|
                $dict[key]= value
          end
          if xls == nil 
            p "Error , can not find scenario file"+sheet
          end 
      end 

      testsuite = xls.getHash("A1:B2",sheet)
      $testsuites[sheet]=testsuite
      rh = xls.getRowRecordsHash("A",4, sheet)
      testcases = rh[0]
      headerArray = rh[1]
      headerLength = headerArray.length
#      putsHash testcases

      testcases.each do |key,testcase|  # loop for good process.
        $wlog.info testcase["comment"]
        putsHash testcase
         ###################
         # key= login.一二三年级的语文教研组长朱海霞正确登录
         # value = { comment	expect	expectFrame	popupText	resetop	username	passwd	op }       example process 
         # #####################
         #  
         #### get "resetop" data from dict 
         if testcase["resetop"] !=""  && testcase["resetop"]!=nil
            if dict[sheet+"."+testcase["resetop"]] == nil
              $wlog.only "!:1:dict ndef:resetop\t"+sheet+"."+testcase["resetop"]
            else 
              testcase["resetop"] =dict[sheet+"."+testcase["resetop"]]
            end  
         else 
           testcase["resetop"] = nil
         end

         input_list = Array.new
         input_range_1_0 = 5..headerLength-2
         input_range_2_0 = 2..headerLength-6
         input_range = input_range_1_0
         
         if testcase["step"]!= nil 
           input_range = input_range_2_0
         end 
         
         headerArray[input_range].each do |input|     # every header should be single  
           begin 
           
           if testcase[input] !="" 
              setvalue = testcase[input]
              if (input.match("action")) 
                if dict[sheet+"."+setvalue] != nil 
                  testcase[input] = dict[sheet+"."+setvalue].clone    # for a serial op named by action1. to do serial op .  

                else
                  $wlog.only "!:2:dict ndef:action*\t"+sheet+"."+setvalue    
                end 
              else 
                if dict[sheet+"."+input] != nil
                  testcase[input] =dict[sheet+"."+input].clone          # spend 8 hours  , 真是奇耻大辱，为什么不能好好分析一下，直接定位呢？
                  testcase[input]["set"]=setvalue
                else
                  $wlog.only "!:3:dict ndef:input\t"+sheet+"."+input   
                end
              end 
#              testcase[input].each {|k,v| p k+v }
              input_list << testcase[input]
            end
            rescue
               $wlog.only "--error sheet:"+sheet+" input:"+input  
               puts testcase[input]
            end 
          end 
         
         #=============getSaveDesktopFromOP(testcase["op"])
         #split( saveDesktop;维护课程资源1;saveDesktop .";")
         # testcase["saveDesktopPreOP"]="yes" 
         # testcase["saveDesktopPostOP"]="yes" 
         # testcase["op"]
         
         
         if testcase["op"] !=""  && testcase["op"] !=nil
#           puts testcase["op"] 
          if dict[sheet+"."+testcase["op"]] == nil    
              $wlog.only("!:4:dict ndef:op\t"+sheet+"."+testcase["op"])
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

def getSubcasesFromeFile(scenario_name,scenarios,dict, xls,multifile) # 取得子用例
#   p "enter subcases"
   _xls = xls 
   if xls == nil 
     fileOfScenario_sheet_name = fileOfScenario(scenario_name)
     if fileOfScenario_sheet_name ==nil 
       p "getSubcasesFromeFile: no this _sheet_name"
     end 
     _xls = $filedescs[fileOfScenario_sheet_name]
   end 
   rh = _xls.explore2DArray("A",1, scenario_name,"END")  # ["x""y""values"]
   _scenario_name = ""
   2.upto rh["y"] do  |i|    
     # 子用例标识号  	场景/条件	测试流所在页面	测试流步骤
#      p rh["values"][i-1][0]+" "+ rh["values"][i-1][1]+" "+ rh["values"][i-1][2] +" "+ rh["values"][i-1][3]

      if rh["values"][i-1][0] != ""
       _scenario_name = scenario_name+"."+rh["values"][i-1][0]
       $scenarios[_scenario_name]=[]
      end 
      if rh["values"][i-1][2] != ""
         $scenarios[_scenario_name] << rh["values"][i-1][2]+"."+rh["values"][i-1][3]
           if multifile 
                   getTestsuitsFromFile(rh["values"][i-1][2],dict, nil) 
           else 
                   getTestsuitsFromFile(rh["values"][i-1][2],dict, xls) 
           end
      end 
 #     p _scenario_name+"...start.............\n";      $scenarios[_scenario_name].each do |x|      p x        end ;        p _scenario_name+"..end..............\n"
   end 

end 

def getScenariosAndTestSuitsFromFile(scenario_name,scenarios,dict, xls,multifile= true)
      
      if ($scenarios[scenario_name]!=nil  || $testsuites[scenario_name]!=nil) 
        return 
      end
      print "getScenariosAndTestSuitsFromFile."+scenario_name+"\n"
      time0 = time1=time2=time3=Time.now
      
      $wlog.warn "load scenario:"+scenario_name
      $wlog.info "EnterSheet-- "+ scenario_name
      $stdout.flush
      if (scenarios[0] =="startPoint")
          getTestsuitsFromFile(scenario_name,dict, xls)
      else     # scenario page 
          if (scenarios[0] =="子用例标识号")
             getSubcasesFromeFile(scenario_name,scenarios,dict, xls,multifile)
          else 
              $wlog.info " ....  scenario array-"+(scenarios.join("|"))
              $scenarios[scenario_name]=scenarios
              (0..scenarios.length-1).each do |scenario|
                _sheet = scenarios[scenario].split('.')  # login.***  etc.
                _sheet_name = _sheet[0]  
                fileOfScenario_sheet_name = fileOfScenario(_sheet_name)
                #puts _sheet_name
                #puts scenario_name 
                #puts fileOfScenario(_sheet_name)
                if xls == nil   #for load from multifile   , but CASE scenarios file xls is not nil 
                  
                   time1 = Time.now
                   if (fileOfScenario_sheet_name==nil)
                     $wlog.info "no scenario-"+scenario_name+" file:"+_sheet_name
                     next
                   end
                   time2 = Time.now
                   $wlog.info "scenario-"+scenario_name+" file:"+fileOfScenario_sheet_name
                  _xls = $filedescs[fileOfScenario_sheet_name]
                  _insheet_array= _xls.get1DColumnArray("A",1,_sheet_name)
                else 
                  _insheet_array= xls.get1DColumnArray("A",1,_sheet_name)
                end 
                
                if _insheet_array!=nil && _insheet_array.length > 0 && _insheet_array[0] !=""
                      $wlog.info "\nscenario-"+scenario_name+" :"+_insheet_array.join("|")
                      if multifile 
                        getScenariosAndTestSuitsFromFile(_sheet_name,_insheet_array,dict,nil,multifile)
                      else 
                        getScenariosAndTestSuitsFromFile(_sheet_name,_insheet_array,dict,xls,multifile)
                      end
                  else
                      $wlog.only "null sheet: "+_sheet_name  
                end 
              end 
            end 
        end 
        time3 = Time.now
        
#        p scenario_name+" total time=" +(time3-time0).to_s+" getfiletime:"+(time2-time1).to_s
end

  


def caseFilter(cases) 
  startcase = 0
  if cases[0][0..5] == "start:"
    startcase = (cases[0][6..cases[0].size].to_i)-1
    if startcase < 1 
      startcase =1
    end 
  end
  endcase = -1 
  if cases[1][0..3] == "end:"
    endcase = (cases[1][4..cases[1].size].to_i)    -1 
    if startcase < 2 
      startcase = 2
    end 
  end 
#  p startcase;  p endcase ;  p $cases 
  $cases = cases[startcase..endcase]
#  p $cases 
end 

def loadTestCaseData(filefullpath) 
  $scenarios={}
  $testsuites={}
  $worksheets = {} # file => worksheets 
  $filedescs = {} # file => filedesc
  $dict = {}
  xlFile = XLSEx.new(filefullpath)
  begin
    $cases = xlFile.get1DColumnArray("A",1, $startsheet_name)  # get 1D array from A1
    caseFilter($cases) 
    $dict = xlFile.getRowRecordsHash("A",1, "DICT")[0]  # get dict { login.登录=>name,elementtype,elementname,value }
    getScenariosAndTestSuitsFromFile($startsheet_name,$cases,$dict, xlFile,false)
    $wlog.info "\n-scenarios-----------------------"
    putsHash $scenarios
    $wlog.info "-print test suites-------------------------------------------"
  #  putsHash $testsuites 
#    printTestCases($testsuites)  
  ensure 
    xlFile.close
  end 
end

def loadTestCaseFromMultiFile(filefullpath, multicasedir = false) 
  $scenarios={}
  $testsuites={}
  $worksheets = {} # file => worksheets 
  $filedescs = {} # file => filedesc
  $dict = {}

  if !FileTest.directory?(filefullpath)
    loadTestCaseData(filefullpath) 
    return 
  end

  if multicasedir
    scanMultiPrjExcelSheetName(".")
  else 
    scanExcelSheetName(filefullpath)
  end 
  
  fn = fileOfScenario($startsheet_name,filefullpath)
  if  fn == nil 
    p "Error: can not find CASE sheet"
    return 
  end 
  
  $cases = $filedescs[fn].get1DColumnArray("A",1, $startsheet_name)  # get 1D array from A1     
############to support case start and case end. 
  caseFilter($cases) 
    
  getScenariosAndTestSuitsFromFile($startsheet_name,$cases,$dict,nil)
  $wlog.info "\n-scenarios-----------------------"
  putsHash $scenarios
  
  closeAllXlsFile
  
end 

def scanExcelSheetName(dir)
  puts "!scan excel sheet name :"+dir
  dir +="/"
  oldpath = Dir.pwd
  Dir.chdir dir
  $all_xlsfile = Dir["*.xls*"]
  $all_xlsfile.each  do |filename|
    if filename.match("~")
      next
    end
    xlFile = XLSEx.new(dir  +filename)
    _sheets =  xlFile.worksheets

    if _sheets != ""
      $worksheets[dir+filename]  = _sheets.gsub(/\|/,"-")  # | is regular symbol 
      $filedescs[dir+filename] = xlFile
      puts "scan:"+dir+filename
      puts  filename+":"+$worksheets[dir+filename]
    end
  end
  Dir.chdir oldpath
end 

def scanMultiPrjExcelSheetName(dir)
#  puts "!multi scan excel sheet name :"+dir
  dir +="/"
  oldpath = Dir.pwd
  Dir.chdir dir
  
  $alldir = Dir["*case"]
  $alldir.each do |d|
        scanExcelSheetName(Dir.pwd+"/"+d)
  end
  Dir.chdir oldpath
#  putsHash  $worksheets
  
end 


def closeAllXlsFile()
  $filedescs.each do |key,value|
    begin 
    $wlog.warn key+":"+value.to_s
    value.close
    rescue
     p key+" closed!"
    end 
#    break  
    # if you close one xls , all the excel program will be close, only need close one time
  end 
end 


def fileOfScenario(scenarioname,dir="") 
  if scenarioname == nil
    puts "CASE sheet no scenario!"
  end 
  matchstring ="-"+scenarioname +"-"
  
  $worksheets.each { |key,value|
#    puts key +"-"+  value+ "-"+ matchstring
    if value.match(matchstring)
      if  (dir == "") || (dir !=""and key.match(dir))
        $wlog.info "got key:"+key
        return key
      end 
    end 
  }
  return nil
end 
#$wlog.level = MyLogger::DEBUG
#loadTestCaseFromMultiFile Dir.pwd+"/examcase/" 
 
