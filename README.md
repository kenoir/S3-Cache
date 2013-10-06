s3-jruby-stale-cache
====================

Example application using JRuby threading demonstrating using s3 as a serve-while-revalidate cache.

Comparison of threaded and unthreaded versions, time to return content (in ms):

With `CACHE_EXPIRE_AFTER_MS = 1000` and `num_tests = 50`:

    AVG time for threaded 395.98ms
    AVG time for unthreaded 718.54ms

There are thread safety issues with the aws-sdk ...
