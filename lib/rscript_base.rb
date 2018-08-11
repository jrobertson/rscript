#!/usr/bin/env ruby

# file: rscript_base.rb

require 'cgi'
require 'open-uri'
require 'rxfhelper'

class RScriptBase
  
  def initialize(debug: false)
    @debug = debug
  end
  
  def read(doc)
    doc.root.xpath('//script').map {|s| run_script(s)}.join(';')
  end
  
  protected
  
  def read_script(script)
    puts 'inside read_script' if @debug
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
    puts 'inside read_sourcecode' if @debug
    buffer, _ = RXFHelper.read rsf, auto: false
    return buffer
  end          
  
end
