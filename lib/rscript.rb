#!/usr/bin/env ruby

# file: rscript.rb

# created:  1-Jul-2009
# updated: 11-Aug-2018

# modification:

  # 11-Aug-2018: Added the keyword auto: false to RxfHelper for clarity
  # 30-Jul-2018: feature: A list of job ids can now be returned
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
