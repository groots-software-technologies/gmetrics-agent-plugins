# To add gmetrics-agent binary plugins to remote host 

### These plugins are depends only Gmetrics Monitoring not applicable for other monitoring tool.

### Help Usage & get plugin list to copy

```bash <(curl -Ls https://raw.githubusercontent.com/grootsadmin/gmetrics-agent-setup/[branch]/v5/bin/gmetrics_agent_plugin_add.sh) -h ```

### To add plugins

```$ bash <(curl -Ls https://raw.githubusercontent.com/grootsadmin/gmetrics-agent-setup/[branch]/v5/bin/gmetrics_agent_plugin_add.sh) -p <Pluginname> ```

Ex:

```$ bash <(curl -Ls https://raw.githubusercontent.com/grootsadmin/gmetrics-agent-setup/alpha/v5/bin/gmetrics_agent_plugin_add.sh) -p <Pluginname>```

- Plugins will get copied to groots/metrics/libexec directory

### Refer log

```cat /var/log/groots/metrics/gmetrics_agent_plugin_add.sh.log ```
