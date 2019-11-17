base:
    'roles:influxdb':
        - match: grain
        - influxdb

    'roles:kapacitor':
        - match: grain
        - kapacitor

    'roles:grafana':
        - match: grain
        - grafana
