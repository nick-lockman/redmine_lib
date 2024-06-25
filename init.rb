require File.expand_path('../lib/patches/issue_patch', __FILE__)
require File.expand_path('../lib/patches/user_patch', __FILE__)
require File.expand_path('../lib/patches/watchers_controller_patch', __FILE__)

Redmine::Plugin.register :redmine_lib do
  name 'Redmine Library plugin'
  author 'Nick'
  description 'Library plugin for Redmine'
  version '0.1.0'
  url 'http://172.24.5.159:8080/nick/redmine_lib.git'
  author_url 'http://172.24.5.159:8080/nick'
end

Rails.application.config.after_initialize do
  WatchersController.send(:include, Patches::WatchersControllerPatch)
  Issue.send(:include, Patches::IssuePatch)
  User.send(:include, Patches::UserPatch)
end
