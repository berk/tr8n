# Install hook code here

sh "rake tr8n:sync"  
sh "rake db:migrate" 
sh "rake tr8n:init"