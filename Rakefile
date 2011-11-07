#!/usr/bin/env rake

require File.expand_path('lib/cstrike/jp_server', File.dirname(__FILE__))

desc "Heroku task, cache MasterServerRespons"
task :cron do
    CStrike::JPServer::cache
end
