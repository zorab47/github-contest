
class Repo

    # % similarity
    def similar(other)

        sim = 0.0

        unless other.major_language.nil? || major_language.nil?
           if major_language.lang == other.major_language.lang
               sim += 0.05
               diff = major_language.lines > other.major_language.lines ? other.major_language.lines / major_language.lines : major_language.lines / other.major_language.lines
               sim += 0.15 * diff
           end
        end

        if owner
            if owner == other.owner
                sim += 0.25
            end
        end

        unless watchers.empty?

            # number of watchers
            if watchers.size > other.watchers.size
                sim += (0.25 * other.watchers.size / watchers.size)
            elsif watchers.size < other.watchers.size
                sim += (0.25 * watchers.size / other.watchers.size)
            else
                sim += 0.20
            end

            intersection = watchers & other.watchers

            if intersection.size > 0
                sim += 0.4
            end

        end



        unless forks.empty?

            # fork count
            if forks.size > other.forks.size
                sim += (0.25 * other.forks.size / forks.size)
            elsif forks.size < other.forks.size
                sim += (0.25 * forks.size / other.forks.size)
            else
                sim += 0.20
            end

            # fork of other or visa versa
            if forks.include?(other) || other.forks.include?(self)
                sim += 0.4
            end
        end

        sim

    end
end
