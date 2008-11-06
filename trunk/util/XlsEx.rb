require 'util/Xls.rb'


  #Excel extention interface class.
  #This class provides many simple methods to reading data records from Excel spreadsheets.
  #Below is a bief example of how to use this class (see unit test (test_XLS.rb) for more usage examples)
      # require 'xls'
      # xlFile = XLS.new('c:\myData.xls')
      # myData = xlFile.get2DArray('B1:D3','Sheet 1')
      # xlFile.close
      # doSomething(myData)
      
  class XLSEx < XLS
#
# explorer array in excel 
#     $case = xlFile.get1DColumnArray("A",1, "CASE")

    def get1DColumnArray(x,y,sheet=nil)
    @log.info("get1DColumnArray(myRange=#{x}#{y}, sheet = #{sheet}")
    result = explore2DArray(x,y,sheet)
    if getWorksheet(sheet) == nil 
      return nil
    end 
    a = []
    result["values"].each do |r|
       a << r[0]
    end
 #   puts a[0]
    return a
  end
  
  def getRowRecordsEx(x='A',y=1,sheet=nil) 
       $result = explore2DArray(x,y,sheet)
       ah= convert2DArrayToArrayHash($result["values"],true)
#       puts $result["values"][0]
       
       return [ah,$result["values"][0]]
  end
  
  #
  # return
  #   { login.login1=>[username,passwd,expect], login.login2=>[username,passwd,expect], }
  #  + headarray..........................
  #
  def getRowRecordsHash(x='A',y=1,sheet=nil) 
       
#       puts "enter getRowRecordHash "+sheet
       r = getRowRecordsEx(x,y,sheet)
       myArray = r[0];
#       puts myArray
       headerArray= r[1];
       hashArray={}
       hashname = headerArray[0]
       _sheet = ""
       # top SHEET no Ç°×º or must changed to DICT.login.·µ»Ø 
       # comment for not add it before every case 
       # if (sheet != "DICT" and sheet !="CASE")  
       #       _sheet=sheet+"."
       # end 
       ##############################
       (0..myArray.length-1).each do |i|
            hashArray[_sheet+myArray[i][hashname]] = myArray[i]
#            puts myArray[i]["name"];
          end
#      puts hashArray
       
       return [hashArray,headerArray]
  end
  
  def explore2DArray(x='A',y=1,sheet=nil)
    explorer_y = y;
    if getWorksheet(sheet) == nil 
      return nil
    end 
    while  1    # explorer Y coordinate 
      
      explorer_y += 1;
      test_range = x+(y.to_s) +":"+x+(explorer_y.to_s)
      $content=get2DArray(test_range,sheet);
#      puts  explorer_y  -y 
#      puts $content
      break if  $content[explorer_y-y] == nil  or  $content[explorer_y-y][0] == ""
    end
    explorer_y-=1
    
    explorer_x = x
    x_len = 1
    while  1    # explorer Y coordinate 
      
      last_x= explorer_x;
      explorer_x = explorer_x.succ;
      test_range = x+(y.to_s) +":"+explorer_x+(y.to_s)
      $content=get2DArray(test_range,sheet);
      break if  $content[0] == nil  or $content[0][$content[0].length-1] ==""
      x_len += 1;
    end
    explorer_x = last_x

    real_range = x+(y.to_s) +":"+explorer_x+(explorer_y.to_s)  
    h = {}
    h["x"]=x_len
    h["y"]=explorer_y - y +1
    h["values"]=get2DArray(real_range,sheet)
    return h # [x_len,explorer_y - y +1, get2DArray(real_range,sheet)]
  end

#outputs a 2DArray *myArray* to a CSV file specified by *file*.
  def saveToTXT(file)
      myFile = File.open(file,'w')
      #  myFile.puts(myArray[i].join(',')) unless myArray[i].nil?
      myFile.puts ":1:ExcelFile <"+file+">===================="
      
      @workbook.Worksheets.each do |s|
        myFile.puts "\n>worksheet:["+s.Name+"]"
        myArray = get2DArray("",s.Name)
        (0..myArray.length-1).each do |i|
          myFile.puts(myArray[i].join(',')) unless myArray[i].nil?
        end
      end
      myFile.close
  end
def worksheets
      _names ="|" 
      @workbook.Worksheets.each do |s|
        _names +=s.Name+"|"
      end
      if _names == "|"
        return ""
      else 
        return _names
      end 
  end
end


