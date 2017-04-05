#!/usr/bin/env python
# -*- coding: utf-8 -*-

import FacebookGeoCosts as fgc

if __name__ == '__main__':
  fgc.get_costs_per_ad((datetime.datetime.now() - timedelta(1)).strftime('%Y-%m-%d'))
