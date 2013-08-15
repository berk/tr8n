# Welcome to Tr8n Translation Engine

Tr8n Translation Engine is a Rails Engine Plugin/Gem that provides a platform for crowd-sourced translations of your Rails application.
The power of the engine comes from its simple and friendly user interface that allows site users as well as professional translators to rapidly 
translate the site into hundreds of languages. 

The rules engine that powers Tr8n allows translators to indicate whether sentences depend on gender rules, numeric rules or combinations of rules configured for each language.
The language specific context rules and language cases can be registered and managed in the administrative user interface. The engine
provides a set of powerful tools that allow admins to configure any aspect of the engine; enabling and disabling its features
and monitoring translation progress.

https://raw.github.com/tr8n/tr8n/master/doc/screenshots/tr8nlogo.png

The Tr8n engine is based on a robust and flexible pluggable architecture where rule types and the syntax of the TML tokens
can be configured or extended for any application deployment.

Tr8n translation engine has been successfully deployed by Geni and Yammer:

Geni Inc, http://www.geni.com

Yammer Inc, http://www.yammer.com 

You can visit their web sites and see how it is being used.


= Documentation

Please look through the following slides to get familiar with Tr8n concepts and features:

http://wiki.tr8n.org/slides

Once you are done, you can try out Tr8n features yourself by following the deployement instructions from one of the examples:

https://github.com/tr8n


Configuration Guide

https://github.com/berk/tr8n/wiki/4.-Configuration-Instructions

Integration Guide

https://github.com/berk/tr8n/wiki/5.-Integration-Instructions

Translation Markup Language (TML)

https://github.com/berk/tr8n/wiki/6.-Tr8n-Syntax-and-Translation-Markup-Language

Rules Engine 

https://github.com/berk/tr8n/wiki/7.-Tr8n-Rules-Engine

Language Context Rules

https://github.com/berk/tr8n/wiki/7.1-Language-Context-Rules

Language Case Rules

https://github.com/berk/tr8n/wiki/7.2-Language-Case-Rules

Supported Languages

https://github.com/berk/tr8n/wiki/9.-Supported-Languages


= Installation Instructions

Add the following gems to your Gemfile: 

  gem 'will_filter', "~> 3.1.2" 
  gem 'tr8n', "~> 3.2.1" 
	
And run:

  $ bundle

At the top of your routes.rb file, add the following lines:

  mount WillFilter::Engine => "/will_filter"
  mount Tr8n::Engine => "/tr8n"

To configure and initialize Tr8n engine, run the following commands: 

  $ rails generate will_filter
  $ rails generate tr8n
  $ rake db:migrate
  $ rake tr8n:init
  $ rails s


Open your browser and point to:

  http://localhost:3000/tr8n


= Integration Instructions

The best way to get going with Tr8n is to run the gem as a stand-alone application and follow the instructions and documentation in the app:

  $ git clone git://github.com/tr8n/tr8n.git
  $ cd tr8n/test/dummy
  $ bundle install
  $ rake db:migrate
  $ rake tr8n:init
  $ rails s

Open your browser and point to:

  http://localhost:3000


= Tr8n Screenshots

Below are a few screenshots of what Tr8n looks like:

== Tr8n Language Selector

https://raw.github.com/tr8n/tr8n/master/doc/screenshots/language_selector.png

== Tr8n Translation Interface

https://raw.github.com/tr8n/tr8n/master/doc/screenshots/submit_translation.png

== Tr8n Translation Votes Interface

https://raw.github.com/tr8n/tr8n/master/doc/screenshots/vote_on_translation.png

== Tr8n Translation Tools

https://raw.github.com/tr8n/tr8n/master/doc/screenshots/translation_tools.png

== Tr8n Translator Dashboard

https://raw.github.com/tr8n/tr8n/master/doc/screenshots/translation_tools.png

== Tr8n Translation Admin Tools

https://raw.github.com/tr8n/tr8n/master/doc/screenshots/admin_tools.png


= External Links

Yammer in Translation

http://bit.ly/g5GQDt 

Yammer Now Available in Dutch, French, German, Japanese, Korean, and Spanish

http://bit.ly/heNIPr 


Geni Goes Global With 20 New Languages And A Crowdsourced Translation Tool 

http://tcrn.ch/f1VLnj 

Quora Discussion - What is the best way to deal with internationlization of text on a large social site?

http://bit.ly/hUU6R9 


LinkedIn Discussion 

http://www.linkedin.com/groups/Internationalizing-your-application-using-Tr8n-4090552?gid=4090552


RailsCasts - If you would like to see a RailsCasts episode on how to get Tr8n configured and running, please visit the RailsCasts suggestion page and vote it up. Thank you!
  
http://bit.ly/gz7lFw 


Tr8n Discussion on Hacker News

http://bit.ly/hB2qmU 


IRC Channel for Discussing Tr8n

irc://irc.freenode.net/#tr8n

