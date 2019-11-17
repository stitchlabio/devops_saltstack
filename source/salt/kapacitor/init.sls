{% set influx_init = False %}
{% if salt['grains.get']('influx_init', False) == True %}
    {% set influx_init = True %}
{% endif %}

{% if influx_init == False %}
include:
    - influx_init
{% endif %}

kapacitor:
    pkg:
        - installed

    service:
        - enable: True
        - running
        - require:
            - pkg: kapacitor
        - watch:
            - file: /etc/kapacitor/kapacitor.conf 

/etc/kapacitor/kapacitor.conf:
    file.managed:
        - source: salt://kapacitor/kapacitor.conf.tmpl
        - makedirs: True
        - template: mako
        - context:
            channel: {{ pillar['channel'] }}


/data/kapacitor/cpu_idle_alert.tick:
    file.managed:
        - source: salt://kapacitor/cpu_idle_alert.tick
        - makedirs: True

/data/kapacitor/nginx_waiting_alert.tick:
    file.managed:
        - source: salt://kapacitor/nginx_waiting_alert.tick
        - makedirs: True
