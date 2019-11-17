{% set grafana_init = False %}
{% if salt['grains.get']('grafana_init', False) == True %}
    {% set grafana_init = True %}
{% endif %}

{% if grafana_init == False %}
grafana-init-script:
    cmd.script:
        - source: salt://grafana/init_script.sh

grafana_init:
    grains:
        - present
        - value: True
        - require:
            - cmd: grafana-init-script 
{% endif %}

grafana-server:
    service:
        - enable: True
        - running
