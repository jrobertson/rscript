#!/usr/bin/env ruby

# file: rscript_base.rb

require 'cgi'
require 'open-uri'
require 'rxfhelper'

class RScriptBase
  using ColouredText
  
  def initialize(debug: false)
    @debug = debug
  end
  
  def read(doc)
    doc.root.xpath('//script').map {|s| run_script(s)}.join(';')
  end
  
  protected
  
  def read_script(script)
    puts 'inside read_script'.info if @debug
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
    
    puts 'inside read_sourcecode'.info if @debug
    #@log.debug 'rsf: ' + rsf.inspect if @log
    #@log.debug 'url_base: ' + @url_base.inspect if @log
    
    path = case rsf
    when /^\// 
      @url_base =~ /^\// ? rsf : File.join(@url_base, rsf) 
    when /\w+:/ then rsf  
    else
      File.join(@url_base, @url_dir, rsf)
    end
    
    buffer, _ = RXFHelper.read path, auto: false
    return buffer
  end          
  
end
