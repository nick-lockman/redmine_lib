module Patches
  module UserPatch #< Principal
    def self.included(base)
      base.class_eval do
        has_many :acquaints, :dependent => :destroy, :class_name => "Acquaint"
        has_many :unread_counters, :dependent => :destroy, :class_name => "UnreadCounter"
        has_many :mode_comments, :dependent => :destroy, :class_name => "ModeComment"
      end
    end
    module ClassMethods
    end
    module InstanceMethods
    end
  end
end