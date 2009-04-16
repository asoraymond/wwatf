require 'rexml/document'
def LoadXmlAndInput(filename,ie)
  begin

    inputXml = open("data\\"+filename) { |f| f.read }
    inputs = REXML::Document.new(inputXml)
    inputs.root.each_element do |node| 
      if node.attributes['type'] == ("textbox")
        if node.attributes['p_name'] == ("name")
          ie.text_field(:name,node.attributes['p_value']).value = node.attributes['set']
        end
        if node.attributes['p_name'] == ("id")
          ie.text_field(:id,node.attributes['p_value']).value = node.attributes['set']
        end
        if node.attributes['p_name'] == ("index")
          ie.text_field(:index,node.attributes['p_value']).value = node.attributes['set']
        end
      end
      if node.attributes['type'] == ("selectlist")
        if node.attributes['isvalue'] == ("yes") 
          if node.attributes['p_name'] == ("name")
            ie.select_list(:name,node.attributes['p_value']).select_value(node.attributes['set'])
          end
          if node.attributes['p_name'] == ("id")
            ie.select_list(:id,node.attributes['p_value']).select_value(node.attributes['set'])
          end
          if node.attributes['p_name'] == ("index")
            ie.select_list(:index,node.attributes['p_value']).select_value(node.attributes['set'])
          end
        else
          if node.attributes['p_name'] == ("name")
            ie.select_list(:name,node.attributes['p_value']).select(node.attributes['set'])
          end
          if node.attributes['p_name'] == ("id")
            ie.select_list(:id,node.attributes['p_value']).select(node.attributes['set'])
          end
          if node.attributes['p_name'] == ("index")
            ie.select_list(:index,node.attributes['p_value']).select(node.attributes['set'])
          end
        end
      end
      if node.attributes['type'] == ("radio")
        if node.attributes['p_name'] == ("name")
          if node.attributes['set'] == ("set")
            ie.radio(:name,node.attributes['p_value']).set
          end
          if node.attributes['set'] == ("clear")
            ie.radio(:name,node.attributes['p_value']).clear
          end
          if node.attributes['set'] == ("click")
            ie.radio(:name,node.attributes['p_value']).click
          end
        end
        if node.attributes['p_name'] == ("id")
          if node.attributes['set'] == ("set")
            ie.radio(:id,node.attributes['p_value']).set
          end
          if node.attributes['set'] == ("clear")
            ie.radio(:id,node.attributes['p_value']).clear
          end
          if node.attributes['set'] == ("click")
            ie.radio(:id,node.attributes['p_value']).click
          end
        end
        if node.attributes['p_name'] == ("index")
          if node.attributes['set'] == ("set")
            ie.radio(:index,node.attributes['p_value']).set
          end
          if node.attributes['set'] == ("clear")
            ie.radio(:index,node.attributes['p_value']).clear
          end
          if node.attributes['set'] == ("click")
            ie.radio(:index,node.attributes['p_value']).click
          end
        end
      end
      if node.attributes['type'] == ("checkbox")
        if node.attributes['p_name'] == ("name")
          if node.attributes['set'] == ("set")
            ie.checkbox(:name,node.attributes['p_value']).set
          end
          if node.attributes['set'] == ("clear")
            ie.checkbox(:name,node.attributes['p_value']).clear
          end
          if node.attributes['set'] == ("click")
            ie.checkbox(:name,node.attributes['p_value']).click
          end
        end
        if node.attributes['p_name'] == ("id")
          if node.attributes['set'] == ("set")
            ie.checkbox(:id,node.attributes['p_value']).set
          end
          if node.attributes['set'] == ("clear")
            ie.checkbox(:id,node.attributes['p_value']).clear
          end
          if node.attributes['set'] == ("click")
            ie.checkbox(:id,node.attributes['p_value']).click
          end
        end
        if node.attributes['p_name'] == ("index")
          if node.attributes['set'] == ("set")
            ie.checkbox(:index,node.attributes['p_value']).set
          end
          if node.attributes['set'] == ("clear")
            ie.checkbox(:index,node.attributes['p_value']).clear
          end
          if node.attributes['set'] == ("click")
            ie.checkbox(:index,node.attributes['p_value']).click
          end
        end
      end
      if node.attributes['sleep'] == ("yes")
        sleep 5
      end
    end
  end
end