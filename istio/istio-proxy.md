### config

```
{
  "node": {
    "id": "sidecar~10.244.1.156~productpage-v1-697f57cdfd-gm7g5.default~default.svc.cluster.local",
    "cluster": "productpage",

    "metadata": {"INTERCEPTION_MODE":"REDIRECT","ISTIO_PROXY_SHA":"istio-proxy:930841ca88b15365737acb7eddeea6733d4f98b9","ISTIO_PROXY_VERSION":"1.0.2","ISTIO_VERSION":"1.0.4","POD_NAME":"productpage-v1-697f57cdfd-gm7g5","app":"productpage","istio":"sidecar","pod-template-hash":"697f57cdfd","sidecar.istio.io/status":"{\"version\":\"ebf16d3ea0236e4b5cb4d3fc0f01da62e2e6265d005e58f8f6bd43a4fb672fdd\",\"initContainers\":[\"istio-init\"],\"containers\":[\"istio-proxy\"],\"volumes\":[\"istio-envoy\",\"istio-certs\"],\"imagePullSecrets\":null}","version":"v1"}
    },
    "stats_config": {
    "use_all_default_tags": false,
    "stats_tags": [{
        "tag_name": "cluster_name",
        "regex": "^cluster\\.((.+?(\\..+?\\.svc\\.cluster\\.local)?)\\.)"
      },
      {
        "tag_name": "tcp_prefix",
        "regex": "^tcp\\.((.*?)\\.)\\w+?$"
      },
      {
        "tag_name": "response_code",
        "regex": "_rq(_(\\d{3}))$"
      },
      {
        "tag_name": "response_code_class",
        "regex": "_rq(_(\\dxx))$"
      },
      {
        "tag_name": "http_conn_manager_listener_prefix",
        "regex": "^listener(?=\\.).*?\\.http\\.(((?:[_.[:digit:]]*|[_\\[\\]aAbBcCdDeEfF[:digit:]]*))\\.)"
      },
      {
        "tag_name": "http_conn_manager_prefix",
        "regex": "^http\\.(((?:[_.[:digit:]]*|[_\\[\\]aAbBcCdDeEfF[:digit:]]*))\\.)"
      },
      {
        "tag_name": "listener_address",
        "regex": "^listener\\.(((?:[_.[:digit:]]*|[_\\[\\]aAbBcCdDeEfF[:digit:]]*))\\.)"
      }
    ]
  },
  "admin": {
    "access_log_path": "/dev/null",
    "address": {
      "socket_address": {
        "address": "127.0.0.1",
        "port_value": 15000
      }
    }
  },
  "dynamic_resources": {
    "lds_config": {
        "ads": {}
    },
    "cds_config": {
        "ads": {}
    },
    "ads_config": {
      "api_type": "GRPC",
      "refresh_delay": "1s",
      "grpc_services": [
        {
          "envoy_grpc": {
            "cluster_name": "xds-grpc"
          }
        }
      ]
    }
  },
  "static_resources": {
    "clusters": [
    {
      "name": "prometheus_stats",
      "type": "STATIC",
      "connect_timeout": "0.250s",
      "lb_policy": "ROUND_ROBIN",
      "hosts": [{
        "socket_address": {
          "protocol": "TCP",
          "address": "127.0.0.1",
          "port_value": 15000,
        }
      }],
    },
    {
    "name": "xds-grpc",
    "type": "STRICT_DNS",
    "connect_timeout": "10s",
    "lb_policy": "ROUND_ROBIN",

    "hosts": [
    {
    "socket_address": {"address": "istio-pilot.istio-system", "port_value": 15010}
    }
    ],
    "circuit_breakers": {
        "thresholds": [
      {
        "priority": "DEFAULT",
        "max_connections": 100000,
        "max_pending_requests": 100000,
        "max_requests": 100000
      },
      {
        "priority": "HIGH",
        "max_connections": 100000,
        "max_pending_requests": 100000,
        "max_requests": 100000
      }]
    },
    "upstream_connection_options": {
      "tcp_keepalive": {
        "keepalive_time": 300
      }
    },
    "http2_protocol_options": { }
    }


    ,
      {
        "name": "zipkin",
        "type": "STRICT_DNS",
        "connect_timeout": "1s",
        "lb_policy": "ROUND_ROBIN",
        "hosts": [
          {
            "socket_address": {"address": "zipkin.istio-system", "port_value": 9411}
          }
        ]
      }

    ],
    "listeners":[
      {
        "address": {
          "socket_address": {
            "protocol": "TCP",
            "address": "0.0.0.0",
            "port_value": 15090,
          }
        },
        "filter_chains": [{
          "filters": [{
            "name": "envoy.http_connection_manager",
            "config": {
              "codec_type": "AUTO",
              "stat_prefix": "stats",
              "route_config": {
                "virtual_hosts": [{
                  "name": "backend",
                  "domains": [
                    "*"
                  ],
                  "routes": [{
                    "match": {
                      "prefix": "/stats/prometheus"
                    },
                    "route": {
                      "cluster": "prometheus_stats"
                    }
                  }]
                }]
              },
              "http_filters": {
                "name": "envoy.router"
              }
            }
          }]
        }],
      },
    ],
  },

  "tracing": {
    "http": {
      "name": "envoy.zipkin",
      "config": {
        "collector_cluster": "zipkin"
      }
    }
  },


}
```