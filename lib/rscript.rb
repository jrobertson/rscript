#!/usr/bin/ruby
#file: rscript.rb

# created:  1-Jul-2009
# updated: 09-Jul-2010

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

class RScript < RScriptBase

  def initialize()
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
  
  private
      
  def read_rsf(args=[])
    rsfile = args[0]; args.shift

    $rsfile = rsfile[/[a-zA-z0-9]+(?=\.rsf)/]
    yield(Document.new(read_sourcecode(rsfile)))
  end
          
  
end

if __FILE__ == $0 then
  raw_args = ARGV
  rs = RScript.new()
  code, args = rs.read(raw_args)
  puts eval(code).join("\n")
end
