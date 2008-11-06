require 'watir'

@ie = Watir::IE.new 
@ie.goto("http://www.baidu.com")

elementIdType="id"
@ie.text_field(:"#{elementIdType}","kw").set("text");






