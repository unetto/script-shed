#!/usr/bin/env python
# -*- coding: utf-8 -*-

# REF: http://momijiame.tumblr.com/post/20004851868/python-rest-api

import sys
import httplib2
import json

class HttpClient(object):

    def __init__(self):
        # Endpoint of REST-API
        self._endpoint = "http://wikipedia.simpleapi.net/api"
        # Expression format
        self._format = "json"

    def search(self, keyword):
        # Request query parameter
        request_query = {"keyword": keyword, "output": self._format}
        return self._search(request_query)
    
    def _search(self, query):
        # Convert a dict type query parameter to a string type
        query_str = reduce(lambda s, (k, v): \
                           "%s&%s=%s" % (s, k, v), query.iteritems(), "")
        # Create request URI
        request_uri = "%s?%s" % (self._endpoint, query_str[1:])
        return self._request(request_uri)

    def _request(self, uri):
        # Get HTTP client
        http_client = httplib2.Http(".cache")
        # Call REST-API
        resp, content = http_client.request(uri, "GET")
        return self._parse(content)

    def _parse(self, content):
        # Convert a response JSON object to a python object
        return json.loads(content)

if __name__ == '__main__':
    client = HttpClient()
    response_entity = client.search(sys.argv[1])
    print response_entity
