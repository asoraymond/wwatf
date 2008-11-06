require 'watir'
require 'watir/contrib/enabled_popup'


def launchBrowser
    begin 
      $ie = Watir::IE.attach(:url, /exam/)
    rescue
      $ie = Watir::IE.new 
    end
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

$count =1
def printTestResult(should,popup_title, funcname,expect_text="", ie=nil,popupText=nil,_button="确定")
  if expect_text == "popupWindow"
    should = clickMsgBox(ie,popup_title,popupText,_button)
  else 
    if !should
      words = expect_text.split #<div align="center">0</div>
      if (expect_text.match("<") != nil)
        if ie.html.match(expect_text)
          should = true
        end 
      else  
        if words.length>1 
          should = true 
          words.each do |word|      # lookup for all the words. 
            if !ie.contains_text(word)
              reg = Regexp.new(word);
              if ie.html !~ reg
                 puts "!DEBUG:"+word+"!ie htmltext\n"
                 should = false
                 break
              end 
            end  
         end #end of words.each
        else 
          puts "!DEBUG:"+ie.text
       end #endif of words.length>1 
      end # endif of (expect_text.match("<") != nil)
    end # end of !should 
  end  #  endof expect_text="popupWindow"
  
  if should 
      $wlog.only "-Passed "+$count.to_s+" "+funcname
  else
      $wlog.only "-Failed "+$count.to_s+" "+funcname
  end 
  $count+=1
  return should
end
 

def clickMsgBox(ie,popup_title, text=nil, _button="确定")
      hwnd = ie.enabled_popup(6) # 查找popup
      if (hwnd)  #yeah! a popup
        w= WinClicker.new
        handle = w.getWindowHandle(popup_title)  #按title 取popup
        
        w.makeWindowActive(handle)
        a= w.getStaticText(popup_title)
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
      ai = WIN32OLE.new("AutoItX3.Control")
      ai.WinWait("文件下载", "", 4)
      ai.ControlFocus("文件下载", "", "保存(&S)")
      sleep 1
      result= ai.ControlClick("文件下载", "", "保存(&S)")
#      puts "control click SAVE result"+result.to_s
      ai.WinWait("另存为", "", 1)
      sleep 1
      result = ai.ControlSend("另存为", "", "Edit1",filepath)
#      puts "control click SAVEAS FILE result"+result.to_s
      result = ai.ControlClick("另存为", "","保存(&S)", "left")
#      puts "control click SAVEAS SAVE result"+result.to_s      
      ai.WinWait("下载完毕", "", 1)
      ai.ControlClick("下载完毕", "", "关闭")
      sleep 3
      begin 
      File.delete(filepath)
      rescue
      puts "delete file failed"
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

