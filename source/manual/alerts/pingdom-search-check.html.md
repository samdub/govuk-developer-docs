---
owner_slack: '#2ndline'
review_by: 2017-09-04
title: 'Pingdom search check'
parent: /manual.html
layout: manual_layout
section: Icinga alerts
---

# Pingdom search check

If Pingdom can't retrieve the search results page it means that while
GOV.UK may be available (see check above), it is not possible to
retrieve dynamic content. Assuming that the homepage check has not
failed, the CDN is probably OK. It is possible for our main provider
(Carrenza) to be down and for us to serve static content from a
secondary mirror at a second supplier (Skyscape).

This is not such a critical problem as you might assume, because a large
amount of traffic comes direct to static content from external searches
and can be served from the mirror. Debug as normal by walking backwards
from the users perspective through the stack to find out where the
failure is.

