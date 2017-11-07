# Introducing the RScript gem


## Usage

    require 'rscript'

    a = %w(//job:time http://rorbuilder.info/r/utility.rsf)
    code, args = RScript.new.read a

    puts eval code
    #=> <job>2017-11-07 11:05:26 +0000</job>
    

## Resources

* rscript https://rubygems.org/gems/rscript

rscript job package script run
