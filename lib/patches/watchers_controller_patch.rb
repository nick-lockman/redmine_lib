module Patches
  module WatchersControllerPatch
    def self.included(base)
      base.extend(ClassMethods)
      base.send(:include, InstanceMethods)

      base.class_eval do
        alias_method :create_without_journal, :create
        alias_method :create, :create_with_journal
        alias_method :destroy_without_journal, :destroy
        alias_method :destroy, :destroy_with_journal
        alias_method :watch_without_journal, :watch
        alias_method :watch, :watch_with_journal
        alias_method :unwatch_without_journal, :unwatch
        alias_method :unwatch, :unwatch_with_journal
        alias_method :set_watcher_without_journal, :set_watcher
        alias_method :set_watcher, :set_watcher_with_journal
      end
    end

    module ClassMethods
    end

    module InstanceMethods
      def create_with_journal
        user_ids = []
        if params[:watcher]
          user_ids << (params[:watcher][:user_ids] || params[:watcher][:user_id])
        else
          user_ids << params[:user_id]
        end
        users = User.active.visible.where(:id => user_ids.flatten.compact.uniq)
        users.each do |user|
          @watchables.each do |watchable|
            Watcher.create(:watchable => watchable, :user => user)
          end
        end
        call_hook(:controller_watchers_create_after_save, { :params => params, :users => users, :watchables => @watchables })
        call_hook(:controller_watchers_create_notification_after_save, { :params => params, :users => users, :watchables => @watchables })
        respond_to do |format|
          format.html { redirect_to_referer_or {render :html => 'Watcher added.', :status => 200, :layout => true}}
          format.js { @users = users_for_new_watcher }
          format.api { render_api_ok }
        end
      end

      def destroy_with_journal
        user = User.find(params[:user_id])
        @watchables.each do |watchable|
          watchable.set_watcher(user, false)
        end
        call_hook(:controller_watchers_destroy_after_save, { :params => params, :user => user, :watchables => @watchables })
        call_hook(:controller_watchers_destroy_notification_after_save, { :params => params, :user => user, :watchables => @watchables })
        respond_to do |format|
          format.html { redirect_to_referer_or {render :html => 'Watcher removed.', :status => 200, :layout => true} }
          format.js
          format.api { render_api_ok }
        end
      rescue ActiveRecord::RecordNotFound
        render_404
      end

      def watch_with_journal
        set_watcher(@watchables, User.current, true)
        call_hook(:controller_watchers_watch_after_save, { :params => params, :user => User.current, :watchables => @watchables })
        call_hook(:controller_watchers_watch_notification_after_save, { :params => params, :user => User.current, :watchables => @watchables })
      end

      def unwatch_with_journal
        set_watcher(@watchables, User.current, false)
        call_hook(:controller_watchers_unwatch_after_save, { :params => params, :user => User.current, :watchables => @watchables })
        call_hook(:controller_watchers_unwatch_notification_after_save, { :params => params, :user => User.current, :watchables => @watchables })
      end


      def set_watcher_with_journal(watchables, user, watching)
        watchables.each do |watchable|
          watchable.set_watcher(user, watching)
        end
        respond_to do |format|
          format.html {
            text = watching ? 'Watcher added.' : 'Watcher removed.'
            redirect_to_referer_or {render :html => text, :status => 200, :layout => true}
          }
          format.js { render inline: "location.reload();" }
        end
      end

    end
  end

end
