require 'rubygems'
require 'watir'
#require 'watir/contrib/enabled_popup'


def launchBrowser(x=1024,y=786,titlestring="exam")
    begin 
      regexp = Regexp.new(titlestring)
      $ie = Watir::IE.attach(:url, regexp)
      $ie.frame("leftFrame").link(:text,"退出").click
    rescue
      $ie = Watir::IE.new 
    end
     
    title = $ie.title
    if title =="" 
      title = "about:blank"
    end 
#    p title
    ai = WIN32OLE.new("AutoItX3.Control")
    ai.WinWait(title, "", 10)
    ai.WinMove(title, "", 0, 0,x,y)
end
  
def login(name,pass)
       begin 
          $ie = Watir::IE.attach(:url, /course/)
       rescue
          $ie = Watir::IE.new 
       ensure
          $ie.goto $login_page
       end 
       $ie.text_field(:name,"j_username").set name
       $ie.text_field(:name,"j_password").set pass 
       $ie.button(:name, "submit").click  
       printTestResult(($ie.text.include? "当前学年学段"),name+"登录系统")
end  #end of login
     
def logout
      $ie.link(:href,$test_site+"j_acegi_logout").click
end   #end of logout


def printTestResult(should,popup_title, funcname,expect_text="", ie=nil,popupText=nil,_button="确定")
  error_info =""
  i = 0 
   for i in 1..3
    
    
    error_info = try_printTestResult(should,popup_title, funcname,expect_text, ie,popupText,_button)
#    p should 
#    p error_info
    if error_info =="" or expect_text.match("Window")
      break
    end
    sleep 1
  end 

  if error_info ==""  
      $wlog.only "-Passed "+funcname
  else
      try_str = ""
      if i > 1 
        try_str = " after try "+i.to_s
      end 
      $wlog.fatal error_info.gsub("\n","_")
      $wlog.only "-Failed "+funcname+ try_str
  end  
end  

def try_printTestResult(should,popup_title, funcname,expect_text="", ie=nil,popupText=nil,_button="确定")
#  p 15;$stdout.flush
#  p should 
  error_info =""
  if should == false    # only process  比较保存数字的情况 ， 如果是错误的，则先预置错误信息
    error_info ="error"
  end 
  if ie !=nil 
   if expect_text.match("saveFileWindow")
#    p "save_file:"+popupText
    should = save_file(popupText)
    if !should 
        error_info =  "!DEBUG:expect:"+expect_text+" but not get."
    else 
      error_info =""
    end 
   else
    if expect_text.match("opupWindow") 
      if expect_text == "cancelPopupWindow"
        _button = "取消"
      end 
      if expect_text != "popupWindow:popupWindow"
        should = clickMsgBox(ie,popup_title,popupText,_button)
      else
        should = clickMsgBox(ie,popup_title,"",_button)
        sleep 1
        should = clickMsgBox(ie,popup_title,popupText,_button)
      end 
      if !should 
        error_info =  "!DEBUG:expect:"+expect_text+" but not get."
      else 
        error_info =""
      end 
    else
      if !should
        if (expect_text.match("colexist|colall"))  ######### table column col colexist colall
          return checktablecolumn(ie,expect_text) # error_info
        end 
        if (expect_text.match("<") != nil  || expect_text.match("\\*") != nil || expect_text.match("=") != nil) 
                                           ############ regexp parttern
          #<div align="center">0</div>
          #李颖(.|\n)*退出
          ie_html = ie.html.gsub(/[\r\n\""]/,"")
          expect_text=expect_text.gsub("\"","")
          if ie_html.match(expect_text)
            should = true 
          else 
            error_info =  expect_text+" not in html:"+ie_html
          end
        else  ######################## multi-words 

         words = expect_text.split 
         if words.length>1 || words[0][0].chr == '!'  
            should = true 
            error_info = ""
            words.each do |word|      # lookup for all the words.
 #             $wlog.only  word 
#              $wlog.only ie.text
              if word[0].chr == '!'
                r = ie.text.match(word[1..word.length-1])
#                p ie.contains_text("aaaa")
              else
                r = !ie.text.match(word)
#                p ie.contains_text(word)
              end 
              if r 
                error_info =  "!DEBUG:expect:"+word+" ie htmltext:"+ie.text
                should = false
                break
              end 
             end #end of words.each
         else 
            error_info =  "!DEBUG:expect:"+expect_text+" ie.text:"+ie.text
         end #endif of words.length>1 
        end # endif of (expect_text.match("<") != nil)
      end # end of !should 
    end  #  endof expect_text="popupWindow"
   end  #end of saveFileWindow   
  end  #end of ie 
  return error_info 
end

 
def clickMsgBox(ie,popup_title, text=nil, _button="确定")

      ret = true
      ai = WIN32OLE.new("AutoItX3.Control")
      
      result = ai.WinWait(popup_title, text, 15)

      curtext=text
      if result== 0
        curtext = ""
        $wlog.fatal text + "!= current popup window text"
        ret = false
      end 
      ai.ControlFocus(popup_title,curtext, _button)
      result= ai.ControlClick(popup_title, curtext, _button)
      sleep 1
      
     return ret
end
    

def old_clickMsgBox(ie,popup_title, text=nil, _button="确定")
#      p "16";  $stdout.flush 
      hwnd = ie.enabled_popup(6) # 查找popup
      if (hwnd)  #yeah! a popup
#        p "2"
        $stdout.flush 
        w= WinClicker.new
        handle = w.getWindowHandle(popup_title)  #按title 取popup
#         p handle 
#         $stdout.flush 
        w.makeWindowActive(handle)
        a= w.getStaticText(popup_title)
        
#        w.clickWindowsButton_hwnd(hwnd,_button) 
#        w.clickWindowsButton(popup_title,_button)
        w.clickWindowsButton_hwnd(handle,_button) 

#        puts ("current "+_button)
       
        if  text && (!a.join.match(text))
            puts "DEBUG:msgbox "+text+" !=" + a.join
            hwnd = nil
          end
       else 
        puts "error find window"
      end
      if hwnd == nil
        return false
      else
        return true
      end
end
    
 def save_file(filepath) 
#    $wlog.warn filepath
      if filepath==""
        filepath="c:\\1.tmp"
      end 
      begin
#      p 1 
      ai = WIN32OLE.new("AutoItX3.Control")
      ai.WinWait("文件下载", "", 10)
#      p 2
      ai.ControlFocus("文件下载", "", "保存(&S)")
#      p 3
      sleep 4
      result= ai.ControlClick("文件下载", "", "保存(&S)")
#      puts "control click SAVE result"+result.to_s
      ai.WinWait("另存为", "", 4)
      result = ai.ControlSend("另存为", "", "Edit1",filepath)
#      puts "control click SAVEAS FILE result"+result.to_s
      result = ai.ControlClick("另存为", "","保存(&S)", "left")
#      puts "control click SAVEAS SAVE result"+result.to_s      
#      p 4
      ai.WinWait("下载完毕", "", 5)
      ai.ControlClick("下载完毕", "", "关闭")
      sleep 1
      rescue
      $wlog.warn "保存文件失败"
      return false 
    end 
        begin 
          File.delete(filepath)
          return true
        rescue
          $wlog.warn "删除文件失败:"+filepath
        return false
      end
    end

 def print_file 
      ai = WIN32OLE.new("AutoItX3.Control")
      ai.WinWait("打印", "", 2)
      ai.ControlFocus("打印", "", "打印(&P)")
      sleep 3
      ai.ControlClick("打印", "", "打印(&P)","left")
end

#_hash ={"test"=>"1","test2"=>"2"}  
def putsHash( _hash)
#    puts "Print hash"
    if _hash.kind_of?Hash
      myKeys = _hash.keys
      myKeys.each do |key|
        if _hash[key].kind_of?Array
          $wlog.info  key +"=>"+ _hash[key].join("|")
        else 
          $wlog.info  key +"=>  "
          $wlog.info  _hash[key]
        end
      end
    else 
      if _hash.kind_of?Array
        $wlog.info  _hash.join("|")
      else 
        puts _hash
      end 
    end 
end

def getTableLocationByCol(checkwindow,indexstr)
  a= indexstr.split(":")
  if a.length==6
    s=checkwindow.table(:index,a[5].to_i).html
  else 
    s= checkwindow.html
  end 
  index = getTableIndex(s,indexstr)
  return index 
end 
 
 
def checktablecolumn(checkwindow,expect_text)
  a= expect_text.split(":")
  if a.length==6
    s=checkwindow.table(:index,a[5].to_i).html
  else 
    s= checkwindow.html
  end 
  result = checkTableValue(s,expect_text)
  if result 
    return ""
  else
    return "checktablecolumn:"+expect_text+" failed"
  end 
end 

def getIndexFromTablebyText(checkwindow,text,tableindex=3,elementtype="radio")
  index =0
  tablehtml= checkwindow.table(:index,tableindex).html
  tablehtml= tablehtml.gsub("\r","")
  tablehtml= tablehtml.gsub("\n","")
  
  index = 0
  $wlog.info tablehtml
  aline= tablehtml.scan(/<TR.*?\/TR>/)
  while aline.length > 0
    
#    p aline.length
#    p index.to_s+":"+aline[0]
#    p aline[0].length
    if elementtype !=nil and (aline[0].match(elementtype))
      index +=1
    else 
      index+=1;
    end 
    if aline[0].match(text)
      break
    end 
    sbegin = tablehtml=~ /<TR.*?\/TR>/
    tablehtml = tablehtml[sbegin+aline[0].length..tablehtml.length]
    aline= tablehtml.scan(/<TR.*?\/TR>/)
#    p tablehtml
  end 
  $wlog.info index

  if aline.length >0
    return index
  else 
    return -1
  end
end 


