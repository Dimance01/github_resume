#!/usr/bin/python2.7
# -*- coding: utf-8 -*-

import PiwikVisits as pv
import datetime
from datetime import timedelta


if __name__ == '__main__':                                              # If you run this file, it will run the following script
    
    pv.api_request((datetime.datetime.now() - timedelta(1)).strftime('%Y-%m-%d'))
