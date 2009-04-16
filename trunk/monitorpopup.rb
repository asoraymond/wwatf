require "rubygems"
require "watir"
require 'RMagick'
require 'win32screenshot'

def save_desktop
      width, height, bitmap = Win32::Screenshot.desktop
      imgl = Magick::ImageList.new.from_blob(bitmap)
      time_stamp_s = Time.new.strftime('%m%d_%H%M_%S')
      screenshot_filename = "#{time_stamp_s}.png"
      imgl.write(File.join("./snap/",screenshot_filename))
end 

$IE7_POPUP_TITLE = "Windows Internet Explorer"
$IE6_POPUP_TITLE = "Microsoft Internet Explorer"
$IE_POPUP_TITLE = $IE6_POPUP_TITLE   # or  $IE7_POPUP_TITLE
#save_desktop 

def monitorAndClickPopupwindow(popup_title,_button="ȷ��")
      ai = WIN32OLE.new("AutoItX3.Control")
      w= WinClicker.new
      $keep_monitor  = true 
      old_windowtext = ""
      check_window_title = popup_title
      click_button = _button
      while true 
        #p "MonitorPopupThread: loop "
        result = ai.WinWait(check_window_title, "",10)
        if result== 0
          check_window_title = "�ļ�����"  #ѡ���ļ� #���Ϊ
          click_button = "����(&S)"
          result= ai.WinWait(check_window_title, "",10)
          if result== 0  
                old_windowtext = ""
                if $keep_monitor 
                  sleep 1
                else
                  break
                end
          end 
        end 
        if result>0
          handle = w.getWindowHandle(check_window_title)  #��title ȡpopup
          w.makeWindowActive(handle)
          window_text= w.getStaticText(check_window_title).join
          if (window_text == old_windowtext)
            save_desktop
            time_stamp_s = Time.new.strftime('%m%d_%H:%M')
            p time_stamp_s+" MonitorPopupThread: a popupwindow exist 10 seconds with text:"+window_text     

            ai.ControlFocus(check_window_title, "", click_button)
            ai.ControlClick(check_window_title, "", click_button)
            if check_window_title == "�ļ�����"
                  ai.WinWait("���Ϊ", "", 5)
                  result = ai.ControlSend("���Ϊ", "", "Edit1","c:\\1.tmp")
                  result = ai.ControlClick("���Ϊ", "","����(&S)", "left")
                  ai.WinWait("�������", "", 5)
                  ai.ControlClick("�������", "", "�ر�")
                  begin 
#                    p Dir["c:/1.tmp*"][0]
                    File.delete(Dir["c:\\1.tmp*"][0])
                  rescue
                    p  "ɾ���ļ�ʧ��:"+Dir["c:\\1.tmp*"][0]
                  end
            end 
            old_windowtext = ""
          else
            #p "MonitorPopupThread: get a popupwindow with text:"+window_text             
            old_windowtext = window_text
          end 
          sleep 20
        end  #end of if result == 0 
  #      ai.ControlFocus(popup_title,"", "")
  #      result= ai.ControlClick(popup_title,"", _button)

       $stdout.flush
      end  #end of while  true 
      p 'monitor thread exit!'
    end
    
monitorAndClickPopupwindow $IE_POPUP_TITLE


   