#!/usr/bin/env ruby

# file: rscript.rb

# created:  1-Jul-2009
# updated: 28-Jul-2018

# modification:

  # 28-Jul-2018: feature: Jobs are now looked up from a Hash object
  # 13-Jul-2018: bug fix: The use of a cache is now optional
  # 10-Jul-2018: feature: Attributes can now be read from the job
  # 24-Mar-2018: Bug fix: Public method run() can now correctly 
  #               handle a param value of nil
  # 07-Nov-2017: feature: The log object is now passed into initialize()
  # 24-Dec-2016: Bug fix: An argument can now include an integer
  # 12-Dec-2016: The cache size can now be changed from initialize()
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

  def initialize(log: nil, pkg_src: '', cache: 5, debug: false, type: 'job')
    
    @log = log
    @cache = cache
    @rsf_cache = HashCache.new({cache: cache}) if cache and cache > 0
    @debug = debug
    @jobname = type
    
  end
  
  def read(raw_args=[])
      
    args = raw_args.clone
    @log.info 'RScript/read: args: '  + args.inspect if @log
    
    threads = []
    
    if args.to_s[/\/\/#{@jobname}:/] then 
     ajob = '' 
      args.each_index do |i| 
        if args[i].to_s[/\/\/#{@jobname}:/] then          
          ajob = $'; args[i] = nil
        end
      end

      args.compact!
      
      a = read_rsfdoc(args)      
      job = a.assoc(ajob.to_sym)
      out, attr = job[:code], job[:attributes]

      raise "job not found" unless out.length > 0
      out
      
    else    
      out = read_rsfdoc(args).map {|x| x.last[:code]}.join("\n")
    end    
          
    @log.info 'RScript/read: code: '  + out.inspect if @log

    [out, args, attr]
  end

  def reset()
    @rsf_cache.reset
  end

  # note: run() was copied from the development file rscript-wrapper.rb
  def run(raw_args, params={}, rws=self)

    @log.info 'RScript/run: raw_args: ' + raw_args.inspect if @log
    puts 'raw_args: ' + raw_args.inspect if @debug
    
    if params and params[:splat] then
      params.each do  |k,v|
        params.delete k unless k == :splat or k == :package or k == :job or k == :captures
      end
    end

    if params and params[:splat] and params[:splat].length > 0 then
      h = params[:splat].first[1..-1].split('&').inject({}) do |r,x| 
        k, v = x.split('=')
        v ? r.merge(k[/\w+$/].to_sym => v) : r
      end
      params.merge! h
    end            
    
    code2, args, attr = self.read raw_args.clone
    puts 'code2 : ' + code2.inspect if @debug
    @log.info 'RScript/run: code2: ' + code2 if @log
    
    begin
      
      r = eval code2

      params = {}

      return r          

    rescue Exception => e  
      params = {}
      err_label = e.message.to_s + " :: \n" + e.backtrace.join("\n")      
      @log.debug 'rscrcript/error: ' + err_label
      return err_label
    end

  end  
  
  private    
  
  def build_a(rsfile)
    
    buffer = read_sourcecode(rsfile) 
    doc =  Rexle.new(buffer)

    doc.root.xpath("//#{@jobname}").inject([]) do |r,x|
      codeblock = x.xpath('//script')\
          .map {|s| read_script(s)}.join("\n")
      r << [x.attributes[:id].to_sym, {attributes: x.attributes, 
                                            code: codeblock}]
    end        
    
  end      
  
  def read_rsfdoc(args=[])
    
    puts 'args: ' + args.inspect if @debug
    rsfile = args[0]; args.shift
    
    $rsfile = rsfile[/[^\/]+(?=\.rsf)/]
    
    a = @cache ? @rsf_cache.read(rsfile) { build_a(rsfile) } : build_a(rsfile)

    @url_base = rsfile[/\w+:\/\/[^\/]+/]
    
    return a

  end    
  
end

if __FILE__ == $0 then
  raw_args = ARGV
  rs = RScript.new()
  code, args = rs.read(raw_args)
  puts eval(code).join("\n")
end
