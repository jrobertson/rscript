#!/usr/bin/ruby
#file: rscript_base.rb

require 'cgi'
require 'open-uri'
require 'rexml/document'
include REXML

class RScriptBase

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
    if rsf[/https?:\/\//] then
      @url_base = rsf[/\w+:\/\/[^\/]+/]
      return open(rsf, "UserAgent" => "Ruby-SourceCodeReader").read
    elsif rsf[/^\//]
      return open(@url_base + rsf, "UserAgent" => "Ruby-SourceCodeReader").read
    else
      return File.open(rsf,'r').read
    end
  end          
  
end

