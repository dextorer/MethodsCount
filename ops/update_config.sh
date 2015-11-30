#!/bin/sh
LMC_PROD_CONFIG=lmc-production-$(date +%s)
LMC_WORKER_PROD_CONFIG=lmc-workers-production-$(date +%s)
eb config save --cfg $LMC_PROD_CONFIG lmc-production
eb config save --cfg $LMC_WORKER_PROD_CONFIG lmc-workers-production
eb config put $LMC_PROD_CONFIG
eb config put $LMC_WORKER_PROD_CONFIG
