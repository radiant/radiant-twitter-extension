You can have updates to your site automatically send details to your 
Twitter account. All you'll need to do is provide your account information 
in the Radiant::Config settings.

The required keys are `twitter.password`, `twitter.username` and `twitter.url_host`.

The `username` and `password` are the same for your login details of your Twitter
account. The `url_host` will be used when generating links back to your site, this 
should be your domain name.

On the edit screen of each page, you can select the option to notify Twitter
of all of the updates to the children of that page. You can create a blog page,
for example, and have each new post linked in your Twitter account.

_Built with version `0.6.6` of the `twitter` gem._