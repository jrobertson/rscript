#!/usr/bin/env ruby

# file: rscript_base.rb

require 'cgi'
require 'open-uri'
require 'rxfhelper'

class RScriptBase
  
  def initialize()
  end
  
  def read(doc)
    doc.root.xpath('//script').map {|s| run_script(s)}.join(';')
  end
  
  protected
  
  def read_script(script)  
    out_buffer = ''

    src = script.attributes[:src]

    if src then

      out_buffer = read_sourcecode(script.attributes[:src].value.to_s)
    else
      code = script.text.strip.length > 0 ? script.text : script.cdatas.join.strip
      out_buffer = code
    end
    out_buffer
  end
        
  def read_sourcecode(rsf)
    
    buffer, type = RXFHelper.read rsf
    
    case type
      when :url, :file
        buffer
      when :relative_url
        open(@url_base + rsf, "UserAgent" => "rscript"){|x| x.read}
    end
  end          
  
end