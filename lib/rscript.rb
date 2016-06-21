#!/usr/bin/env ruby

# file: rscript.rb

# created:  1-Jul-2009
# updated: 21-Jun-2016

# modification:

  # 21-Jun-2016: Replaced the initialize hash options with inline named params
  # 29-Jan-2015: Replaced REXML with Rexle
  # 06-Nov-2013: An error is now raised if the job doesn't exist
  # 02-Nov-2013: Replaced XThreads with a simle thread
  # 01-Nov-2013: XThreads now handles the execution of eval statements;
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
require 'rexle'


class RScript < RScriptBase

  def initialize(logfile: '', logrotate: 'daily', pkg_src: '', cache: true)
    
    @logger = Logger.new logfile, logrotate unless logfile.empty?
    @cache = cache
    @rsf_cache = HashCache.new({cache: 5}) if cache
    
  end
  
  def read(args=[])

    if @logger then
      
      @logger.debug 'inside RScript#read' 
      @logger.debug 'RScript -> args: ' + args.inspect
      
    end
    
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
        doc.root.xpath("//job[#{ajob.join(' or ')}]").map do |job|
          job.xpath('script').map {|s| read_script(s)}.join("\n")
        end.join("\n")        
      end

      raise "job not found" unless out.length > 0
      out
      
    else    
      out = read_rsf(args) {|doc| doc.root.xpath('//script').map {|s| read_script(s)}}.join("\n")   
    end
    
    @logger.debug 'RScript -> out: ' + out.inspect[0..250] if @logger

    [out, args]
  end

  def reset()
    @rsf_cache.reset
  end

  # note: run() was copied from the development file rscript-wrapper.rb
  def run(raw_args, params={}, rws=nil)

    if @logger then
      @logger.debug 'inside RScript#run' 
      @logger.debug 'RScript -> raw_args: ' + raw_args.inspect
    end
    
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
    @logger.debug 'RScript -> code2: ' + code2.inspect[0..250] if @logger
    
    begin
      
=begin      
      thread = Thread.new(code2) do |x| 
        
        begin
          Thread.current['result'] = eval x
        rescue
          @logger.debug('RScript -> eval: ' + ($!).inspect) if @logger
        end
        
      end
      thread.join
=end      
      #puts 'code2 :'  + code2.inspect
      r = eval code2
      #r = thread['result']

      params = {}

      return r          

    rescue Exception => e  
      params = {}
      err_label = e.message.to_s + " :: \n" + e.backtrace.join("\n")      
      return err_label
    end

  end  
  
  private    
      
  def read_rsf(args=[])
    
    rsfile = args[0]; args.shift
    
    $rsfile = rsfile[/[^\/]+(?=\.rsf)/]
    
    buffer = if @cache then
      @rsf_cache.read(rsfile) {read_sourcecode(rsfile) }
    else
      read_sourcecode(rsfile)
    end

    @url_base = rsfile[/\w+:\/\/[^\/]+/]

    doc =  Rexle.new(buffer)
    yield(doc)

  end          
  
end

if __FILE__ == $0 then
  raw_args = ARGV
  rs = RScript.new()
  code, args = rs.read(raw_args)
  puts eval(code).join("\n")
end