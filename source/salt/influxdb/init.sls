{% set influx_init = False %}
{% if salt['grains.get']('influx_init', False) == True %}
    {% set influx_init = True %}
{% endif %}

{% if influx_init == False %}
include:
    - influx_init
{% endif %}

influxdb:
    pkg:
        - installed

    service:
        - enable: True
        - running
        - require:
            - pkg: influxdb
