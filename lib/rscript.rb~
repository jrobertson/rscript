#!/usr/bin/env ruby

#file: rscript.rb

# created:  1-Jul-2009
# updated: 08-Aug-2013

# modification:

  # 08-Aug-2013: re-enabled the hashcache;
  # 24-Jun-2011: disabled the hashcache

# description
#  - This script executes Ruby script contained within an XML file.
#  - The XML file can be stored locally or on a website.
#  - The 'require' statement for foreign scripts has been replaced 
#      with the script tag (e.g. <script src="rexml_helper.rb"/>)

# arguments:
# - *job, the filename, and the *script arguments (* (asterisk) denotes 
#     these arguments  are optional.

# usage:
# - rscript //job:xxxx script_file.rsf [script arguments]

# MIT license - basically you can do anything you like with the script.
#  http://www.opensource.org/licenses/mit-license.php

require 'rscript_base'
require 'hashcache'


class RScript < RScriptBase

  def initialize(opt={})
    @rsf_cache = HashCache.new({cache: 5}.merge(opt))
  end
  
  def read(args=[])
    threads = []
    if args.to_s[/\/\/job:/] then 

      ajob = []
      
      args.each_index do |i| 
        if args[i][/\/\/job:/] then          
          ajob << "@id='#{$'}'"; args[i] = nil
        end
      end

      args.compact!

      out = read_rsf(args) do |doc|
        doc.root.elements.to_a("//job[#{ajob.join(' or ')}]").map do |job|
          job.elements.to_a('script').map {|s| read_script(s)}.join("\n")
        end.join("\n")
      end
      
    else    
      out = read_rsf(args) {|doc| doc.root.elements.to_a('//script').map {|s| read_script(s)}}    
    end 

    [out, args]
  end

  def reset()
    @rsf_cache.reset
  end

  # note: run() was copied from the development file rscript-wrapper.rb
  def run(raw_args, params={}, rws=nil)

    if params[:splat] then
      params.each do  |k,v|
        params.delete k unless k == :splat or k == :package or k == :job or k == :captures
      end
    end

    if params[:splat] and params[:splat].length > 0 then
      h = params[:splat].first[1..-1].split('&').inject({}) do |r,x| 
        k, v = x.split('=')
        v ? r.merge(k[/\w+$/].to_sym => v) : r
      end
      params.merge! h
    end            

    code2, args = self.read raw_args
    
    begin

      r = eval code2
      params = {}
      return r          

    rescue Exception => e  
      params = {}
      err_label = e.message.to_s + " :: \n" + e.backtrace.join("\n")      
      return err_label
    end        
  end  
  
  private

  def read_doc_rsf(args=[])
    rsfile = args[0]; args.shift

    $rsfile = rsfile[/[a-zA-z0-9]+(?=\.rsf)/]

    @url_base = rsfile[/\w+:\/\/[^\/]+/]
    buffer = @rsf_cache.read(rsfile) {read_sourcecode(rsfile) }
    #jr080813 buffer = read_sourcecode(rsfile) 

    doc =  Document.new(buffer)
    yield(doc)

  end
  
      
  def read_rsf(args=[])
    rsfile = args[0]; args.shift

    $rsfile = rsfile[/[^\/]+(?=\.rsf)/]
    buffer = @rsf_cache.read(rsfile) {read_sourcecode(rsfile) }
    #jr080813 buffer = read_sourcecode(rsfile) 
    @url_base = rsfile[/\w+:\/\/[^\/]+/]
    doc =  Document.new(buffer)
    yield(doc)

  end          
  
end

if __FILE__ == $0 then
  raw_args = ARGV
  rs = RScript.new()
  code, args = rs.read(raw_args)
  puts eval(code).join("\n")
end
