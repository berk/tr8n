# Goodbye Tr8n Gem, Hello Tr8nHub.com

After years of using Tr8n Rails Gem it became very clear that there must exist a central repository for language rules, translation keys and translations that could be shared across all applications. 

Should we keep translating "Hello World" into every language over and over again? Or should we just translate it once into every possible language and never do it again. How about "Home" link (in a context of home page). Once something is translated in a well defined context, it is translated forever (unless a better translation is provided for the same key). 

Same goes to Language Context Rules and Language Cases. Once those rules are defined, everyone else should be able to use them.

This is why this gem (as good as it is) will no longer be actively supported. 

Please welcome Tr8nHub.com 

# What is Tr8nHub.com?

Tr8nHub.com is a Software as a Service (SaaS) Crowdsourced Translation Platform (CTP) that provides powerful frameworks and tools for rapid translation of web, desktop and mobile applications. The two main features of the platform are Translation Markup Language (TML) and Universal Translation Memory (UTM).

# Translation Markup Language (TML)

TML provides a specific syntax and convention for how translation keys should be defined, including context descriptions and data/decoration tokens labeling. By adhering to those conventions, developers can maximize translations reuse.

For instance, "Home" is a very common word used by nearly all web sites to indicate the main page of the site. But the word "Home", by itself, cannot be translated without a context. By providing a description/context to the word, such as "Main page of the site", developers narrow down the meaning of the word to only mean one thing, and it can now be translated into any language. Any application that uses the word in the same (or similar context) will automatically receive all translations of the key.

Below is an example of how developers would translate the word in a Ruby on Rails application:

```rails
<%= tr("Home", "Main page of the site") %>
```

A Java application might be using it through the Tr8n tag library:

```java
<tr8n:tr label="Home" description="Main page of the site" />
```

And, similarly, an iOS app uses it as well:

```objc
[Tr8n translate:"Home" withDescription:"Main page of the site"]
```

All of the application connected to Tr8nHub will automatically share the same translations.

Since all translation keys in Tr8nHub use the same convention, Tr8nHub can now provide a Universal Translation Memory that shares all translation keys and translation across all applications in all languages.

# Universal Translation Memory (UTM)

Universal Translation Memory is a MASSIVE database of translation keys and translations shared across all applications connected to Tr8nHub.com service.

The translations data uses a smart ranking system that ensures that only top ranked translations are accepted and distributed to the applications. The ranking system is based on the individual translation ranks derived from the voting powers of the translators who provided them or who voted on them - inclding low ranked machine translations, medium ranked crowdsourced user translations and hight ranked professional translator translations. 

Each application connected to Tr8nHub.com provides the rank threshold, the minimal rank of a translation, which the application would accept. The higher the threshold is, the better quality translations the application would accept.

Translation keys in UTM are mapped to the application sources. So application don't actually own copies of translation keys, but are linked to the keys in UTM instead. When application submits new keys, the keys are looked up in UTM and linked back to the application. If the keys don't exist, they will be created in UTM and linked back to the apps.

Application have an option to namespace all translation keys within the app. This would effectively make all application keys unique and not shared in UTM. Application would have a much tighter control of the keys, but it would also loose the ability to link to the global set of keys and get translated 100x faster.


There are many more features you get with UTM and TML. Please view our wiki site to learn more:

http://wiki.tr8nhub.com


# SDKs and Supported Platforms

All SDKs are open sourced and available at:
http://github.com/tr8n

Every SDK comes with at least one sample application to demonstrate its capabilities.

The following platforms are currently supported:

Web:

* Ruby on Rails
* PHP
* PHP Wordpress Extensions
* PHP MediaWiki Extensions
* Java J2EE, Java Struts 2 Extensions
* JavaScript for Dynamic Web Apps
* JavaScript for Static HTML Sites (using Backbone.js and JST templates)

Mobile:

* Java Android
* Objective C for iOS

Desktop:

* Java Swing


# If you are already using Tr8n Gem

You may want to consider upgrading. The Tr8n RoR SDK is a drop-in replacement for this Tr8n Gem. 

All SDKs fully support the old TML syntax, as well as provide powerful enhancements. 

To learn more about Rails integration, visit the wiki page:

http://wiki.tr8nhub.com/index.php?title=Rails_Integration



# Where can i get more information?

* Visit Tr8n's documentation:  http://wiki.tr8nhub.com/

* Follow Tr8nHub on Twitter: https://twitter.com/Tr8nHub

* Connect with Tr8n on Facebook: https://www.facebook.com/pages/tr8nhubcom/138407706218622

* If you have any questions contact: michael@tr8nhub.com






