### Prometheus

#### deploy on kubernetes
   ```
    create -f /prometheus

    http://120.27.219.79:31672/metrics    # 验证 node-exporter
    http://120.27.219.79:30091            # prometheus web ui
    http://120.27.219.79:30300            # grafana web ui
   ```

####