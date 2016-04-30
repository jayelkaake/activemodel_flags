require 'active_support/concern'
module ActivemodelFlags
  module HasFlags
    extend ActiveSupport::Concern

    module ClassMethods

      ##
      # This will add the ability for the model to set and read flags.
      # @note: The model must have the 'flags' column. Use rails g activemodel_flags:column *model_name* to generate the migration for the flags column
      #
      def has_flags
        include LocalInstanceMethods

        before_create :init_flags
        after_initialize :init_flags
        serialize :flags, JSON

        scope :that_have?, -> (key) {
          where("flags LIKE '%\"#{key}\":true%'")
        }
        scope :that_havent?, -> (key) {
          where("flags NOT LIKE '%\"#{key}\":true%'")
        }
        scope :that_have_not?, -> (key) { that_havent?(key) }

        scope :that_have_any_flags, -> {
          where("flags != '{}' AND flags IS NOT NULL")
        }

        scope :all_have!, -> (flag) {
          self.reset_flags!(flag)
          self.update_all("flags = REPLACE(flags, '}', '\"#{flag}\":true}')")
        }
        scope :all_have_not!, -> (flag) {
          self.reset_flags!(flag)
          self.update_all("flags = REPLACE(flags, '}', '\"#{flag}\":false}')")
        }

        def self.flags_used
          all_flags = {}

          self.that_have_any_flags.each do |obj|
            obj.flags.keys.each do |key|
              all_flags[key] = true unless all_flags[key]
            end
          end

          all_flags.keys
        end

        def self.reset_flags!(flag)
          self.update_all("flags = REPLACE(\
                                     REPLACE(\
                                       REPLACE(\
                                         REPLACE(
                                          flags, '\"#{flag}\":false', ''\
                                         ), '\"#{flag}\":false,', ''\
                                       ), '\"#{flag}\":true,', ''\
                                     ), '\"#{flag}\":true', ''\
                                    )")
        end

        def self.reset_all_flags!
          self.update_all(flags: '{}')
        end
      end
    end

    module LocalInstanceMethods

      #### getters
      def has_flag?(flag)
        self.flags[flag.to_s] != nil
      end
      def has?(flag)
        self.flags[flag.to_s]
      end

      def hasnt?(flag)
        !has?(flag)
      end
      alias_method :has_not?, :hasnt?


      #### setters

      def has(flag)
        old_flags = self.flags

        self.flags[flag.to_s] = true

        on_flag_change(old_flags[flag.to_s], self.flags[flag.to_s]) unless old_flags == self.flags
      end

      def has!(flag)
        has(flag)

        self.save!
      end

      def hasnt!(flag)
        old_flags = self.flags

        self.flags[flag.to_s] = false

        on_flag_change(old_flags[flag.to_s], self.flags[flag.to_s]) unless old_flags == self.flags
        self.save!
      end
      alias_method :has_not!, :hasnt!

      def unset_flag!(flag)
        old_flags = self.flags

        self.flags.delete(flag.to_s)

        on_flag_change(old_flags[flag.to_s], self.flags[flag.to_s]) unless old_flags == self.flags
        self.save!
      end

      # TODO implement the ability to
      # def method_missing(method)
      #   if method.to_s =~ /has_[a-zA-Z0-9_]+\?/
      #     key = method.to_s.chomp("?").reverse.chomp("_sah").reverse
      #     has = true
      #   elsif method.to_s =~ /hasnt_[a-zA-Z0-9_]+\?/
      #     key = method.to_s.chomp("?").reverse.chomp("_tnsah").reverse
      #     has = false
      #   elsif method.to_s =~ /has_not_[a-zA-Z0-9_]+\?/
      #     key = method.to_s.chomp("?").reverse.chomp("_ton_sah").reverse
      #     has = false
      #   else
      #     return super
      #   end
      #
      #   if has_flag?(method.to_s)
      #     has ? has?(key) : hasnt?(key)
      #   else
      #     puts "*************** NO METHOD!! "
      #     super
      #   end
      # end

      def respond_to?(method)
        has_flag?(method.to_s) || super(method)
      end

      protected

      def on_flag_change(old_val, new_val)
        # Override this method if you want to react to flag changes
      end

      private

      def init_flags
        self.flags = {} unless self.flags.present?
      end

    end
  end
end

ActiveRecord::Base.send :include, ActivemodelFlags::HasFlags
