# Boutiques descriptor

This directory contains a
[Boutiques](https://github.com/boutiques/boutiques) descriptor for the BIDS app and an example of invocation.

## How to use

* Install Boutiques: `pip install boutiques`
* Run the example:

```bash
bosh exec launch --no-container  boutiques/bidspm_3.1.1.json boutiques/invocation_smooth.json
bosh exec launch --no-container  boutiques/bidspm_3.1.1.json boutiques/invocation_stats.json
```
