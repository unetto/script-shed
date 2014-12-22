#!/usr/bin/env python
# -*- coding: utf-8 -*-

# REF: http://momijiame.tumblr.com/post/45560105945/python-http-requests

import requests

if __name__ == '__main__':
    query = {
        'q': 'momijiame',
        'rpp': '5',
        'include_entities': 'true'
    }
    r = requests.get('http://search.twitter.com/search.json', params=query)
    print r.status_code
    print r.encoding
    print r.headers
    print r.text
    print r.json()
