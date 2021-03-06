---
owner_slack: '#2ndline'
review_by: 2017-07-05
title: 'es-rotate'
parent: /manual.html
layout: manual_layout
section: Icinga alerts
---

# es-rotate

This alert triggers when the es-rotate hasn't completed successfully.

es-rotate is part of [es-tools](https://github.com/alphagov/estools).

Its job is to rotate the elasticsearch alias for the current day's logs,
and to delete old indexes.

If it doesn't run, it's fine to rerun manually on the affected host,
using:

    sudo -u nobody /usr/local/bin/es-rotate-passive-check

If there is a problem you can find out more information using the
elasticsearch-head plugin (see "Elasticsearch cluster health" alert for
more details).

