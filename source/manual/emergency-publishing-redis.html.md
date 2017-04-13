---
owner_slack: '#2ndline'
review_by: 2017-08-17
title: Deploy emergency publishing banners with Redis
parent: /manual.html
layout: manual_layout
section: Publishing
important: true
---

# Deploy emergency publishing banners

There are three types of events that would lead GOV.UK to add an emergency banner to
the top of each page on the web site. Each type of event is detailed below.

The GOV.UK on-call escalations contact will tell you when you need to publish an
emergency banner. They will ensure that the event is legitimate and provide you
with the text for the emergency banner.

The GOV.UK on-call escalations contact will tell you what type of event it is; you do
not need to determine the type of event yourself.

If you need to publish the emergency banner out of hours, you will be
instructed to do so either by the GOV.UK on-call escalations contact or the Head of
GOV.UK.

[Contact numbers for those people](https://github.gds/pages/gds/opsmanual/2nd-line/contact-numbers-in-case-of-incident.html) are in the opsmanual on GitHub enterprise.

## Adding emergency publishing banners

Before publishing an emergency banner, you will need the following. The text
required will be supplied by the GOV.UK on-call escalations contact:

### Prerequisites

- Text for the heading
- Text for the 'extra info', which is a sentence displayed under the heading
- A URL for users to find more information (it might not be provided at first)
- The colour for the background of the banner. Each type of emergency has a
  colour - see below.

### Steps to publish the banner

If you've not used them before, you'll need to clone [fabric-scripts](https://github.com/alphagov/fabric-scripts) and follow the setup instructions in the fabric-scripts README.

1) Make sure your copy of fabric-scripts is up to date and on master.

2) Pick your environment, which can be `integration`, `staging`, or `production`. For example, for integration:

```
export environment=integration
```

2) SSH into a `frontend` machine appropriate to the environment you are
deploying the banner on. For example, for integration:

```
ssh frontend-1.frontend.integration
```

3) CD into the directory for `static`:

```
cd /var/apps/static
```

4) Run the rake task to create the emergency banner hash in Redis, substituting
the quoted data for the parameters:

```
sudo -u deploy govuk_setenv static bundle exec rake
emergency_banner:deploy[campaign_class,heading,short_description,link]
```

For example, if you are deploying an emergency banner for which you have the
following information:

* Type: Death
* Heading: Alas poor Yorick
* Short description: I knew him Horatio
* URL: https://www.gov.uk

You would enter the following command:

```
sudo -u deploy govuk_setenv static bundle exec rake
emergency_banner:deploy["black","Alas poor Yorick","I knew him
Horatio","https://www.gov.uk"]
```

Note there are no spaces after the commas between parameters to the rake task.

Exit from the remote machine.

```
exit
```

<a name="purge-cache"></a>5) From your local machine, run the fabric task to clear the application template cache:

```
fab $environment campaigns.clear_cached_templates
```

6) Reload whitehall:

```
fab $environment class:whitehall_frontend app.reload:whitehall
```


7) Test the changes by visiting pages and adding a cache-bust string

You can automate this by using the [emergency publishing scraper](https://github.com/alphagov/emergency-publishing-scraper)

- [https://www.gov.uk/?ae00e491](https://www.gov.uk/?ae00e491)
- [https://www.gov.uk/financial-help-disabled?7f7992eb](https://www.gov.uk/financial-help-disabled?7f7992eb)
- [https://www.gov.uk/government/organisations/hm-revenue-customs?49854527](https://www.gov.uk/government/organisations/hm-revenue-customs?49854527)
- [https://www.gov.uk/search?q=69b197b8](https://www.gov.uk/search?q=69b197b8)

8) Purge our entire origin cache:

```
fab $environment cache.ban_all
```

9) If you are in production environment, once the origin cache is purged, purge
the CDN cache. At the time of writing, this can only be done one item at a time,
and doesn’t work in staging or integration.

You can do so by giving a list of comma separated url paths, the following is a
list of the 10 most used pages:

```
fab $environment
cdn.fastly_purge:/,/search,/state-pension-age,/jobsearch,/vehicle-tax,/government/organisations/hm-revenue-customs,/government/organisations/companies-house,/get-information-about-a-company,/check-uk-visa,/check-vehicle-tax
```

See [these instructions for more details](https://github.gds/pages/gds/opsmanual/2nd-line/cache-flush.html) on
purging the cache.

10) Check that the emergency banner is visible when accessing the same pages as
above but without a cache-bust string.

11) Remember to unset your environment variable:

```
unset environment
```

### Removing emergency publishing banners

1) Make sure your copy of fabric-scripts is up to date and on master.

2) Pick your environment, which can be `integration`, `staging`, or `production`. For example, for integration:

```
export environment=integration
```

2) SSH into a `frontend` machine appropriate to the environment you are
deploying the banner on. For example, for integration:

```
ssh frontend-1.frontend.integration
```

3) CD into the directory for `static`:

```
cd /var/apps/static
```

4) Run the rake task to remove the emergency banner hash from Redis:

```
sudo -u deploy govuk_setenv static bundle exec rake
emergency_banner:remove
```

Exit from the remote machine

```
exit
```

5) Follow from [step 5 through 11](#purge-cache) in the deploy banner instructions above.
