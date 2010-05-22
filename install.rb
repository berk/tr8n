# Install hook code here

sh "script/plugin install git://github.com/mislav/will_paginate.git"
sh "script/plugin install git://github.com/berk/will_filter.git"
sh "rake will_filter:sync"  
sh "rake tr8n:sync"  
sh "rake db:migrate" 
sh "rake tr8n:init"
