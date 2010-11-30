namespace :will_filter do

  desc "Sync extra files from will_filter plugin."
  task :sync do
    system "rsync -ruv vendor/plugins/will_filter/config/wf ./config"
    system "rsync -ruv vendor/plugins/will_filter/db/migrate ./db"
  end
  
end