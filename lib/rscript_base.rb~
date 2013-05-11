#!/usr/bin/env ruby
#file: rscript_base.rb

require 'cgi'
require 'open-uri'
require 'rxfhelper'
require 'rexml/document'
#include REXML

class RScriptBase
  include REXML
  
  def initialize()
  end
  
  def read(doc)
    doc.root.elements.to_a('//script').map {|s| run_script(s)}.join(';')
  end
  
  protected
  
  def read_script(script)  
    out_buffer = ''
    src = script.attribute('src')

    if src then
      out_buffer = read_sourcecode(script.attribute('src').value.to_s)
    else
      code = script.text.to_s.strip.length > 0 ? script.text : script.cdatas.join.strip
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
        open(@url_base + rsf, "UserAgent" => "rscript").read
    end
  end          
  
end