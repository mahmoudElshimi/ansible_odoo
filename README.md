# Ansible Odoo Automation

**Ansible-based automation toolkit** to initialize linux servers for Odoo+Docker running under [odoer](https://github.com/mahmoudElshimi/odoer). It includes full support for installation, backup, deployment, and maintenance tasks in both development and production environments.

Designed with automation, clarity, and minimal assumptions in mind.

---
## Features

- Automates Odoo Docker setup and provisioning
- Full system backups (database, filestore, extra addons)
- Local and remote backup syncing with timestamped archives
- Odoo initialization and update tasks
- Environment-specific inventory management
- Enforces consistent user permissions and dotfile configuration
- Supports remote provisioning with SSH and rsync
- Cron-ready structure for scheduled tasks

---

## Structure

```

ansible_odoo/
├── ansible.cfg
├── inventory.ini
├── init_playbook.yml
├── deploy_playbook.yml
├── maintain_playbook.yml
├── files/
│   ├── extra-addons.zip
│   ├── odoer.service
│   └── dotfiles/
│       ├── .zshrc
│       ├── .tmux.conf
│       └── .zprofile
├── backups/
│   └── backups.zip

```

---

## Playbooks

### `init_playbook.yml`
Sets up a fresh Linux Server with Odoo+Docker environment. Installs dependencies, copies dotfiles, unzips addons, and runs `odoer init`.

### `deploy_playbook.yml`
Used for production deployment with NGINX configuration and proper service setup iff domain.

### `maintain_playbook.yml`
Performs:
- Backup creation via `odoer`
- Zipping and syncing the backup to the Ansible control machine
- Timestamped naming of backups
- Security upgrade 

---

## Backup Strategy

Backups include:
- PostgreSQL database
- Odoo filestore
- Extra addons

Backups are zipped and saved on the remote server at:
```

/home/admin/backups.zip

```

They are then pulled to the control machine in:
```

ansible_odoo/backups/<host>/backups_YYYYMMDDTHHMMSS.zip

````

---

## Usage

### Running a playbook to init the server
```bash
ansible-playbook init_playbook.yml -e "odoer_password='Odoer_PASS' backup_file='backup_file'"
````

To deploy Nginx+SSL:

```bash
ansible-playbook deploy_playbook.yml
```

To backup and update:

```bash
ansible-playbook maintain_playbook.yml
```

### Setting up your inventory

```ini
[init]
odoo ansible_host=1.2.3.4

[deploy]
custS_domain ansible_host=1.2.3.4

[production]
test.example.com ansible_host=5.6.7.8
```

## License

Released under the MIT/X License.

> RTFM,  KISS

---

## Author

**Mahmoud Elshimi**
Email: [mahmoudelshimi@protonmail.ch](mailto:mahmoudelshimi@protonmail.ch)
Phone: +20 100 312 3253

```
