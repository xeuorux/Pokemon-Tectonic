module PBDebug
    @@log = []
  
    def self.logonerr
      begin
        yield
        return true
      rescue
        PBDebug.log("")
        PBDebug.log("**Exception: #{$!.message}")
        PBDebug.log("#{$!.backtrace.inspect}")
        PBDebug.log("")
  #      if $INTERNAL
          pbSEPlay("PC close")
          pbPrintException($!)
  #      end
        PBDebug.flush
        return false
      end
    end
end