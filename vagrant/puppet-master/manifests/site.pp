import "classes/roles/*"

import "modules"

# comentado pois nao precisa mais aplicar o arquivo de nodes dependendo do ambiente
#$site_pp_imports

# The filebucket option allows for file backups to the server
#filebucket { main: server => 'puppet' }

# Set global defaults - including backing up all files to the main filebucket and adds a global path
#File { backup => main }

Exec { path => "/usr/bin:/usr/sbin/:/bin:/sbin:/usr/local/bin:/opt/local/bin:/opt/local/sbin" }

