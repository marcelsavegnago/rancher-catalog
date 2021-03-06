version: '2'
services:
    odoo:
        tty: true
        stdin_open: true
        image: adhoc/odoo-ar-e:$strImageTag
        labels:
            io.rancher.container.pull_image: always
            io.rancher.scheduler.affinity:container_label_soft_ne: io.rancher.stack_service.name=$${stack_name}/$${service_name}
            io.rancher.scheduler.affinity:host_label: ${host_label}
            traefik.enable: true
            traefik.port: 8069
            traefik.backend.loadbalancer.stickiness: true
            traefik.backend.loadbalancer.method: drr
        {{- if eq .Values.intWorkers "0"}}
            traefik.frontend.rule: Host:$strTraefikDomains
            traefik.frontend.redirect.regex: $strTraefikRedirectRegex
            traefik.frontend.redirect.replacement: $strTraefikRedirectReplacement
            traefik.frontend.redirect.permanent: true
        {{- else}}
            traefik.odoo.port: 8069
            traefik.odoo.frontend.rule: Host:$strTraefikDomains
            traefik.odoo.frontend.redirect.regex: $strTraefikRedirectRegex
            traefik.odoo.frontend.redirect.replacement: $strTraefikRedirectReplacement
            traefik.odoo.frontend.redirect.permanent: true
            traefik.longpolling.port: 8072
            traefik.longpolling.frontend.rule: Host:$strTraefikDomains;PathPrefix:/longpolling/
            traefik.longpolling.frontend.redirect.regex: $strTraefikRedirectRegex
            traefik.longpolling.frontend.redirect.replacement: $strTraefikRedirectReplacement
            traefik.longpolling.frontend.redirect.permanent: true
        {{- end}}
        volumes:
            - odoo_data_filestore:$strOdooDataFilestore
            - odoo_data_sessions:$strOdooDataSessions
        environment:
            # database parameters
            - PGUSER=$strPgUser
            - PGPASSWORD=$strPgPassword
            - PGHOST=$strPgHost
            # TODO, este podria volver a ser un booleano y tmb podriamos
            # re simplificar el entry point, ahora modificamos a odoo para que
            # no cree bd si se manda el db_name, y estamos haciendo eso, mandar
            # db_name
            - FIXDBS=$strFixDbs
            - SMTP_SERVER=$strSmtpServer
            - SMTP_PORT=$intSmtPort
            - SMTP_SSL=$boolSmtpSsl
            - SMTP_USER=$strSmtpUser
            - SMTP_PASSWORD=$strSmtPassword
            - AEROO_DOCS_HOST= aeroo-docs.adhoc-aeroo-docs
            - DATABASE=$strDatabase
            - DBFILTER=$strDbFilter
            - SERVER_MODE=$strServerMode
            - DISABLE_SESSION_GC=$strDisableSessionGC
            - WORKERS=$intWorkers
            - MAX_CRON_THREADS=$intMaxCronThreads
            - ADMIN_PASSWORD=$strAdminPassword
            - MAIL_CATCHALL_DOMAIN=$strMailCatchallDomain
            - FIX_DB_WEB_DISABLED=True
            - LIST_DB=$boolListDb
            - PG_MAX_CONNECTIONS=$intPgMaxConnections
            - LIMIT_MEMORY_HARD=$intLimitMemoryHard
            - LIMIT_MEMORY_SOFT=$intLimitMemorySoft
            - LIMIT_TIME_CPU=$intLimiteTimeCpu
            - LIMIT_TIME_REAL=$intLimiteTimeReal
            - LIMIT_TIME_REAL_CRON=$intLimiteTimeRealCron
            - ODOO_VERSION=$strImageTag
volumes:
  odoo_data_sessions:
    driver: rancher-nfs
    external: true
  odoo_data_filestore:
    driver: rancher-nfs
    external: true
