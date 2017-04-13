---
owner_slack: '#2ndline'
review_by: 2017-04-26
title: Monitor your app during deployment
section: Deployment
layout: manual_layout
parent: "/manual.html"
---

# Monitor your app during deployment

## Deployment Dashboards

There are a number of applications with a dashboard showing useful information for the deployment process.

The existing deployment dashboards are written by puppet every 30 minutes and loaded when Grafana starts. Don’t change them directly.

## Panels

### Deployment and restart lines

These show/hide vertical lines on the other panels that show when events happened.

![Deployment restart lines](images/deployment_dashboards/deploys_restarts_checkboxes.png)

![Deployment lines](images/deployment_dashboards/deployment_lines.png)

### Processes - Last hour

![Processes](images/deployment_dashboards/processes.png)

This shows the number of processes running on each server. During a deployment, you should expect the number of processes to double and then return to normal (the number depends on the server).

You should only test your code when this has settled back to normal.

Implementation note:

We have converted nulls to 0 so that we can see when a server dies. Data is available for all ruby/rack services, but not python ones. YMMV with other languages.

### 500 Rate over time

![500s over time](images/deployment_dashboards/500s_over_time.png)

Shows average error rate per one second bucket over the dashboard selected time range. This currently defaults to 24 hours but the you can change it.

Implementation note:

The Y-Axis on this graph depends on how the data is collected and sampled by graphite, and is not meaningful to users. It’s only showing you relative spikes in errors.

### Deploys and Errors

![Errors and deploys](images/deployment_dashboards/errors_and_deploys.png)

These show you the total number of errors and deploys over the last 5 minutes and the last 24 hours respectively.

Implementation note:

The reason for the long titles is we can’t alter the table column headings in Grafana.

### 500 count last 5 min

![500s in last 5 minutes](images/deployment_dashboards/500s_5_mins.png)

Total number of 500s in the last 5 minutes.

### 500 count full time range

![500s over full time range](images/deployment_dashboards/500s_full_range.png)

Total number 500s in the across the dashboard's given time range.

### Links

Any additional links to monitoring services that we have not been able to add to the dashboard. Errbit currently links to the page showing all the applications for a given environment. Unfortunately we are not able to link to the application specific Errbit.

Icinga for general errors for a given environment. This should be checked prior to any deployments and also after once all processes count have returned to normal.

### Worker Failures

![Worker failures](images/deployment_dashboards/worker_failures.png)

Shows the total number of errors across all the workers related to an application for 5 minute period and the total time range of the dashboard.

Note: If an application has no workers then this row is not displayed for that application’s dashboard.

### Worker Success

![Worker successes](images/deployment_dashboards/worker_successes.png)

Shows the total number of successes across all the workers related to an application for 5 minute period and the total time range of the dashboard.

Note: If an application has no workers then this row is not displayed for that application’s dashboard.

### 5xx by Controller and Action

![Top 10 5xx by controller](images/deployment_dashboards/top_10_controller_5xx.png)

Graph showing the number of errors for a given controller and action over the dashboard time range.

### 90th Percentile Response by Controller

![90th percentile response by controller](images/deployment_dashboards/response_by_controller.png)

Graph showing the response time by controller over the dashboard time range.

## Update and Add Panels to Existing Dashboards

Dashboards are configured in `govuk-puppet`. Each dashboard panel is configured by a .json.erb template in `modules/grafana/templates/dashboards/deployment_partials` and these are combined to generate the JSON config for each application dashboard.

It’s best to duplicate an existing dashboard in Grafana to test your changes.

![Duplicate dashboard](images/deployment_dashboards/duplicate_dashboard.png)

Then, either add the panel to an existing row, or create a new row with your panel in.

![Panel rows](images/deployment_dashboards/panel_rows.png)

Once you are happy with your changes, export the JSON partial of what you want to add in order to add it to `govuk-puppet`.

You can export the entire dashboard by clicking on the cog:

![Dashboard JSON](images/deployment_dashboards/view_json.png)

Or you can export a single panel by clicking on the panel title to add it to a partial:

![Panel JSON](images/deployment_dashboards/panel_json.png)

Please delete any temporary dashboards after you’ve finished!

### If you’re changing an existing panel…

Find the partial in puppet and replace the contents with the exported JSON. Replace any application specific text/urls/queries in the partial with template variables.

TOP TIP: use `git add -p` to avoid unnecessary changes being committed

### If you’re adding a new panel

Create a new partial in puppet with the exported JSON
Replace any application specific text/urls/queries in the partial with template variables.

In `govuk-puppet` we are using an [array structure](https://github.com/alphagov/govuk-puppet/blob/master/modules/grafana/manifests/dashboards.pp) to dynamically control which partials are rendered.

Adding your partial name to this structure will result in it being rendered in Grafana.

### Test the dashboard

Any new partials or dashboards should be tested on Integration with multiple applications.

It is also possible to test that the puppet generates the dashboard JSON you expect by spinning up a `graphite-1.management` vm.

`vagrant up graphite-1.management` from inside the `govuk-puppet` repo.

Deployed dashboards live in `/etc/grafana/dashboards` on the `graphite-1.management` machine.

## Add a new application

The list of applications that have dashboards generated is stored in the [hiera](https://github.com/alphagov/govuk-puppet/blob/master/hieradata/common.yaml) data inside puppet under `grafana::dashboards::deployment_applications`.

Each dashboard can have parameters associated with it which effect how the dashboard is generated.

Params:

- show_workers: This adds a row with workers failure and success panels, this is required for applications that have sidekiq workers.

- docs_name: This is the name of the application used in the developer documentation. Often the same as the repository name on Github.

## Graphite

Graphite is a data storage application for time stream data that is used to store data performance data, error counts and other statistics about gov.uk servers.

All data is stored with a key which is made up of multiple nodes which each node in the key representing a particular aspect of the data item - i.e. server name or metric type.

We are currently locked at version 0.9.13.

In addition to data storage is it possible to use graphite functions to manipulate the data streams, the below is a list of the most use functions/combinations of functions use in the dashboards. Full Graphite documentation can be found [here](http://graphite.readthedocs.io/en/0.9.13-pre1)

### [hitcount](http://graphite.readthedocs.io/en/0.9.13-pre1/functions.html#graphite.render.functions.hitcount)

This is helpful when trying to get actual volumes out of graphite as data is events per second for the time interval (usually but not always 5 seconds). This means that a value of 0.2 represents a single event in a 5 second interval, and means that summing the data in Grafana results in not integer values.  Wrapping the data in `hitcount` will convert it back to the expected count value.

The second parameter is the interval size that is summed together. Care must be taken with this value as data can be lost when a large time period is queried with a small interval, increasing the number of data points returned can ensure accurate data at the cost of performance.

### [integral](http://graphite.readthedocs.io/en/0.9.13-pre1/functions.html#graphite.render.functions.integral) + hitcount

Integral creates returns the sum of values for the time period, or if graphing the sum of values up until that point in time. Used with `hitcount` it can help by ensuring no data is lost as a result of using a small interval with a large time period.

The resulting data should not be graphed as in most cases, unless it is to compare to similar data with a time offset.

### [aliasByNode](http://graphite.readthedocs.io/en/0.9.13-pre1/functions.html#graphite.render.functions.aliasByNode)

Used to extract one node out of the key and then use that as the name of the data column. This is particularly helpful when needing to group summaries data.

### [sumSeries](http://graphite.readthedocs.io/en/0.9.13-pre1/functions.html?#graphite.render.functions.sumSeries)

Sum series data together, can be used by itself to return a single stream of data or with `aliasByNode` to return grouped sets of data.

## Deploy the Dashboards

Deploy puppet and then either wait for convergence or use fabric to force a puppet run on the graphite box. Currently you will need to restart the Grafana service after deploying new dashboards.

`sudo service grafana-server restart` if you’re on the `graphite-1.management` machine. Otherwise use the fabric scripts.

## New features and improvements

These are features that we didn't have time to add in the two-week blitz.

### Add and improve links to dashboards

- Only link from the release app to an application's dashboard if the dashboard
  exists
  - This involves reverting [alphagov/release#131](https://github.com/alphagov/release/pull/131)
    and changing the Grafana API call so that it only makes one
    environment-specific call to Grafana, because cross-environment calls are
    not possible.
- Only link from the developer docs to an application's dashboard if the
  dashboard exists.
  - For example, the [govuk_content_api page](https://docs.publishing.service.gov.uk/apps/govuk_content_api.html)
    should not link to a dashboard because the app does not have one.
- Add a link from the badger (a Capistrano task in govuk-app-deployment) when
  the badger announces a deployment
  - This involves reopening [alphagov/govuk-app-deployment#122](alphagov/govuk-app-deployment/pull/122)
    and making the API call environment-specific, as for the release app.

These changes require the applications to be able to access the Grafana API, for
example, https://grafana.publishing.service.gov.uk/api/dashboards/file/deployment_whitehall.json.
The Grafana hostname was originally not accessible from the app servers, but it
now been configured so these updates can now be made.

### Errbit links

A dashboard's Errbit link currently goes to the main Errbit page for that
environment. It would be better to link to an application's own Errbit page, but
we would need to configure each link individually or work out how to generate
or look up an app-specific link.

### Hide empty controller-specific graphs

The two graphs which are powered by ElasticSearch (5xx responses by controller
action, and slow responses by controller) do not have data on every dashboard.
It would be better to hide these graphs if there is no data, in the same way
that the worker failures and successes are hidden if an app has no workers.
