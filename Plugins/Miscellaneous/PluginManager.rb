module PluginManager
    def self.compare_versions(v1, v2)
        d1 = v1.split("")
        d1.insert(0, "0") if d1[0] == "."          # Turn ".123" into "0.123"
        while d1[-1] == "."; d1 = d1[0..-2]; end   # Turn "123." into "123"
        d2 = v2.split("")
        d2.insert(0, "0") if d2[0] == "."          # Turn ".123" into "0.123"
        while d2[-1] == "."; d2 = d2[0..-2]; end   # Turn "123." into "123"
       
        # Compare by period seperated sections if possible
        if d1.include?(".")
            d1Split = d1.join("").split(/\./,-1)
            d2Split = d2.join("").split(/\./,-1)
            for i in 0...[d1Split.length, d2Split.length].max # Compare each subsection in turn
                s1 = d1Split[i] || nil
                s2 = d2Split[i] || nil
                if !s1.nil?
                    return 1 if s2.nil?
                    comparison = compare_number_arrays(s1.split(""),s2.split(""))
                    if comparison != 0
                        return comparison
                    end
                else
                    return -1 if !s2.nil?
                end
            end
        else
            return compare_number_arrays(d1,d2)
        end
        
        return 0
    end

    def self.compare_number_arrays(s1, s2)
        return 1 if s1.size > s2.size
        return -1 if s1.size < s2.size

        for i in 0...s1.size   # Compare each digit in turn
            c1 = s1[i]
            c2 = s2[i]
            if c1
              return 1 if !c2
              return 1 if c1.to_i(16) > c2.to_i(16)
              return -1 if c1.to_i(16) < c2.to_i(16)
            else
              return -1 if c2
            end
        end
        return 0
    end
end