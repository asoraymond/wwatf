def getTableIndex s, indexstr
# if index  = 0 , then get no index 
# usage:
# indexstr1 = "col:试卷开放日期:2008-12-04:0:table:3"  # 最后的数字： 前面还有几个类似元素，例如button ,  if need table , use old way : table:3:table:3:奥数考试_now:1:1
# indexstr2 = "col:试卷开放日期:2008-12-03:1" if need table , use old way : table:3:table:3:奥数考试_now:1:1
    startindex = 0
    a = indexstr.split(":")
    if a.length >3
      startindex = a[3].to_i
    end 
    s= s.gsub("\n","")
#    p startindex 
    lines= s.scan(/<TR.*?\/TR>/) 
    index =1
    begin_count = false 
    tdindex = 0 
    gotindex = false
#    p indexstr
    lines.each do |line|
#      p "line:"+line
      if line.match(a[1])  
        begin_count = true
        index = 0
        tds = line.scan(/<TD.*?\/TD>/)
        tdindex = 0 
        tds.each do |td|
           if td.match(a[1])
              break
           else 
             tdindex +=1
           end 
         end 
         #p "tdindex:"+tdindex.to_s 
      else

        if begin_count
          #p line 
          index+=1
          tds = line.scan(/<TD.*?\/TD>/)
#          p tds.length
          #p tdindex
          if tds[tdindex].match(a[2])  
             gotindex = true 
             break
          end 
        end 
      end 
    end  #end of lines.each
    if gotindex == true 
      return index+startindex
    else 
      return 0 
    end 
end

def checkTableValue s, indexstr
# return value:     true       false 
# usage:
# indexstr1 =  "colall:出卷人:李:0:table:3" # 最后的数字： 前面还有几个类似元素，例如button ,  if need table , use old way : table:3:table:3:奥数考试_now:1:1
# indexstr2 =  "colexist:出卷人:李:0:table:3" if need table , use old way : table:3:table:3:奥数考试_now:1:1
    startindex = 0
    a = indexstr.split(":")
    if a.length >3
      startindex = a[3].to_i
    end 
    s= s.gsub("\n","")
#    p startindex 
    lines= s.scan(/<TR.*?\/TR>/) 
    index =1
    begin_count = false 
    tdindex = 0 
    result = false
    exist_result = false
    lines.each do |line| 
#      p line 
      if line.match(a[1])  
        begin_count = true
        index = 1 
        tds = line.scan(/<TD.*?\/TD>/)
        tdindex = 0 
        tds.each do |td|
           if td.match(a[1])
              break
           else 
             tdindex +=1
           end 
         end 
         #p "tdindex:"+tdindex.to_s 
      else 
        if begin_count
          #########################################
#          p line 
          tds = line.scan(/<TD.*?\/TD>/)
#          p tds.length
#          p tdindex
          
          if tds[tdindex].match(a[2])  and a[0]=="colexist"
#             p tds[tdindex]
             result = true
             break
          else 
            if !tds[tdindex].match(a[2])  and  a[0]=="colall"
#              p a[0]
              break
            else 
              if tds[tdindex].match(a[2]) 
                exist_result = true 
              end 
            end 
            index+=1
          end
          ########################################
        end 
      end 
    end  #end of lines.each
    if a[0]=="colall" and exist_result == true 
      result = true 
    end 
    return result 
  end



def test_checktable 
  
titlerow = '<TR><TD bgColor="#f2f2f2" height="35">\n<DIV align="center">选项</DIV></TD><TD bgColor="#f2f2f2"><DIV align="center">学科</DIV></TD><TD bgColor="#f2f2f2"><DIV align="center">年级</DIV></TD><TD bgColor="#f2f2f2"><DIV align="center">试卷名称</DIV></TD><TD bgColor="#f2f2f2"><DIV align="center">难易程度</DIV></TD><TD bgColor="#f2f2f2"><DIV align="center">出卷人</DIV></TD><TD bgColor="#f2f2f2"><DIV align="center">出卷时间</DIV></TD><TD bgColor="#f2f2f2"><DIV align="center">试卷开放日期</DIV></TD></TR>'
row ='<TR class="e_2" onmouseover="this.className=\'e_1\'" onmouseout="this.className=\'e_2\'" bgColor="#ffffff"><TD class="td_hight" height="22"><DIV align="center"><INPUT onclick="writeSelectedPaperId(328, 10010);" type="radio" name="paperId" value="328" /> </DIV></TD><TD><DIV align="center">数学 </DIV></TD><TD><DIV align="center">二年级 </DIV></TD><TD><DIV class="STYLE9" align="center"><A title="未安排考试。" onclick="showPaperDetail(328);" href="http://192.168.0.122:8081/exam/teachertestpaper/TeacherTestpaperAction.a#"><SPAN style="COLOR: red">test</SPAN></A></DIV></TD><TD><DIV align="center"></DIV></TD><TD><DIV align="center">李颖</DIV></TD><TD><DIV align="center"></DIV></TD><TD><DIV align="center">2008-12-04</DIV></TD></TR><TR class="e_2" onmouseover="this.className=\'e_1\'" onmouseout="this.className=\'e_2\'" bgColor="#ffffff"><TD class="td_hight" height="22"><DIV align="center"><INPUT onclick="writeSelectedPaperId(328, 10010);" type="radio" name="paperId" value="328" /> </DIV></TD><TD><DIV align="center">数学 </DIV></TD><TD><DIV align="center">二年级 </DIV></TD><TD><DIV class="STYLE9" align="center"><A title="未安排考试。" onclick="showPaperDetail(328);" href="http://192.168.0.122:8081/exam/teachertestpaper/TeacherTestpaperAction.a#"><SPAN style="COLOR: red">test</SPAN></A></DIV></TD><TD><DIV align="center"></DIV></TD><TD><DIV align="center">李颖</DIV></TD><TD><DIV align="center"></DIV></TD><TD><DIV align="center">2008-12-03</DIV></TD></TR>'

row_line_break ='<TR class="e_2" 
onmouseover="this.className=\'e_1\'" 
onmouseout="this.className=\'e_2\'" 
bgColor="#ffffff"><TD class="td_hight" height="22"><DIV align="center"><INPUT onclick="writeSelectedPaperId(328, 10010);" type="radio" name="paperId" value="328" /> </DIV></TD><TD><DIV align="center">数学 </DIV></TD><TD><DIV align="center">二年级 </DIV></TD><TD><DIV class="STYLE9" align="center"><A title="未安排考试。" onclick="showPaperDetail(328);" href="http://192.168.0.122:8081/exam/teachertestpaper/TeacherTestpaperAction.a#"><SPAN style="COLOR: red">test</SPAN></A></DIV></TD><TD><DIV align="center"></DIV></TD><TD><DIV align="center">李颖</DIV></TD><TD><DIV align="center"></DIV></TD><TD><DIV align="center">2008-12-04</DIV></TD></TR><TR class="e_2" onmouseover="this.className=\'e_1\'" onmouseout="this.className=\'e_2\'" bgColor="#ffffff"><TD class="td_hight" height="22"><DIV align="center"><INPUT onclick="writeSelectedPaperId(328, 10010);" type="radio" name="paperId" value="328" /> </DIV></TD><TD><DIV align="center">数学 </DIV></TD><TD><DIV align="center">二年级 </DIV></TD><TD><DIV class="STYLE9" align="center"><A title="未安排考试。" onclick="showPaperDetail(328);" href="http://192.168.0.122:8081/exam/teachertestpaper/TeacherTestpaperAction.a#"><SPAN style="COLOR: red">test</SPAN></A></DIV></TD><TD><DIV align="center"></DIV></TD><TD><DIV align="center">李颖</DIV></TD><TD><DIV align="center"></DIV></TD><TD><DIV align="center">2008-12-03</DIV></TD></TR>'


table= titlerow+row_line_break

indexstr1 = "col:试卷开放日期:2008-12-04:0:table:3" 
indexstr2 = "col:试卷开放日期:2008-12-03:0:table:3"
indexstr3 = "col:试卷开放日期:2008-12-06:0:table:3"
checkvaluestr1 = "colall:出卷人:李颖:0:table:3"
checkvaluestr2 = "colexist:出卷人:李颖:0:table:3"
checkvaluestr2 = "colexist:出卷人:李:0:table:3"
checkvaluestr3 = "colexist:试卷开放日期:2008-12-06:0:table:3"
checkvaluestr4 = "colall:试卷开放日期:2008-12-03:0:table:3"
checkvaluestr5 = "colexist:试卷开放日期:2008-12-03:0:table:3"



p   checkvaluestr3
p checkTablevalue(table ,checkvaluestr3)
p   checkvaluestr4
p checkTablevalue(table ,checkvaluestr4)
p   checkvaluestr5
p checkTablevalue(table ,checkvaluestr5)

p getTableIndex(table,indexstr1);
p getTableIndex(table,indexstr2);
p getTableIndex(table,indexstr3);
p   checkvaluestr1
p checkTablevalue(table ,checkvaluestr1)
p   checkvaluestr2
p checkTablevalue(table ,checkvaluestr2)
end 

#test_checktable 






