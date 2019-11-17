influx-init-script:
    cmd.script:
        - source: salt://influx_init/init_script.sh

influx_init:
    grains:
        - present
        - value: True
        - require:
            - cmd: influx-init-script 
