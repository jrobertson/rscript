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

    out_buffer = if src then
      read_sourcecode(script.attributes[:src].to_s)
    else
      script.texts.join("\n")
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