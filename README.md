# Twitter

An extension to Radiant that will automatically tweet the publication of new pages in selected parts of your site, and which provides a set of radius tags that allow you to feature twitter feeds of different kinds on your site.

## Installation

	sudo gem install radiant-twitter-extension

add this to your environment.rb

	config.gem 'radiant-twitter-extension', :version => '~> 2.0.0.rc1'

and then:

	rake radiant:extensions:update_all
	rake radiant:extensions:twitter:migrate
	
You can also vendor the extension in the old-fashioned way:

	git submodule add git://github.com/radiant/radiant-twitter-extension.git vendor/extensions/twitter
	rake radiant:extensions:twitter:update
	rake radiant:extensions:twitter:migrate

## Status

Nearly stable. I've just made some quite sweeping changes to bring this up to date, so small bugs are likely. Please file issues.

## Configuration

You can present twitter searches and feeds without authenticating, but if you want to post automatically to twitter you need to provide login information. The extension adds a 'twitter' block to the main radiant configuration interface: enter your screen name and password. Future versions may integrate with Twitter as an application but for now all we need is the ability to tweet.

## Tweet on publication

To post a tweet every time you publish a blog entry, check the 'Notify Twitter of newly published child pages?' box on the parent blog page. The tweet will contain the title of the page and its url.

## Display a twitter feed

If radiant is configured to tweet for you, all you need is this radius tag:

	<r:twitter:tweets [max="10"] />
	
If it's not configured, or you want to display another user:

	<r:twitter:tweets user="screen_name" />

To display a hashtag, or any other search:

	<r:twitter:tweets search="#radiant" />

To display tweets from someone's list:

	<r:twitter:tweets user="screen_name" list="list_name" />

The default presentation of tweets is exactly as [suggested by Twitter](https://dev.twitter.com/terms/display-guidelines) and if you include their widget script and the provided css it should all just work. If you want to present tweets differently, a range of more detailed radius tags is available. This is a slightly more compact format:

	<r:twitter:tweets user="screen_name" />
	  <li class="tweet">
	    <r:tweet:avatar class="avatar" />
		<r:tweet:user:screen_name />
		<span class="block">
		  <r:tweet:text />
		</span>
		<span class="hidden">
		  <r:tweet:reply_link />
		  <r:tweet:retweet_link />
		</span>
	  </li>
	</r:twitter:tweets>
		
## Scripts and styles 

The quick way to format tweets nicely is to include the supplied sass in your site stylesheet. If you're using radiant's built-in stylesheet manager and working in Sass, you can keep everything in one file (and selectively override it) by including this line near the top:

	@import 'twitter.sass'
	
You can also link to `/stylesheets/twitter.css` in the usual way.

The links created by radius tags here are all compatible with twitter's widgeting. To enable basic intent-based popups, just include this line in the head or at the foot of your layout:

	<script type="text/javascript" src="http://platform.twitter.com/widgets.js"></script>

## Todo

* More gratifying twitter integration of admin
* Page field to edit tweet text before publication
* URL-shortener

## Copyright and license

Originally created by Sean Cribbs and now the work of many hands, including:

* Jim Gay
* Edmund Haselwanter
* Anna Billstrom
* William Ross

Currently maintained by Will at spanner.org. Issues and comments on github, please:

	https://github.com/radiant/radiant-twitter-extension/issues

Released under the same terms as Rails and/or Radiant.



