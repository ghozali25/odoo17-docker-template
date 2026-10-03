# Odoo 17 Docker Template

Template deploy Odoo 17 (rakitan sendiri di atas `python:3.10-slim-bookworm`,
source Odoo di-clone dari branch `17.0`) dengan library tambahan yang biasa
dibutuhkan modul custom, siap dibakukan sekali dan dipakai berulang untuk
setiap client.

Sudah termasuk di image:

- Dependency resmi Odoo 17 dari `requirements.txt`
- `pandas`, `sqlparse`, `xlsxwriter`, `requests` (izi_data)
- `odoorpc`, `openupgradelib` (upgrade_analysis)
- `openpyxl` (sql_export_excel)
- `paramiko`, `boto3`, `dropbox`, `pyncclient`, `nextcloud-api-wrapper`
  (auto_database_backup)

Setelan default dibuat hemat untuk VPS kecil (mulai 1 GB RAM,
`workers = 0`). Naikkan `workers` dan batas memori di `config/odoo.conf`
bila servernya lebih besar.

## Cara pakai

```bash
git clone <repo-ini> odoo17
cd odoo17
cp .env.example .env
# edit .env  -> isi POSTGRES_PASSWORD
# edit config/odoo.conf -> samakan db_password dengan .env,
#                          ganti admin_passwd
mkdir -p data/postgres data/odoo addons custom_addons
docker compose up -d --build
```

Odoo bisa dibuka di `http://<ip-server>:8069`.

Folder penting (semua di host, aman dari `docker compose up -d` berulang):

| Folder host        | Isi                                   |
|--------------------|---------------------------------------|
| `data/postgres/`   | File database PostgreSQL              |
| `data/odoo/`       | Filestore & attachment Odoo           |
| `addons/`          | Addons tambahan (extra)               |
| `custom_addons/`   | Modul custom client                   |

## Catatan

- Jangan commit file `.env` asli; repo hanya menyimpan `.env.example`.
- Setelah mengubah `Dockerfile` (mis. tambah library), jalankan
  `docker compose build odoo && docker compose up -d`.
- Untuk di belakang reverse proxy / Cloudflare Tunnel, set
  `proxy_mode = True` di `config/odoo.conf`.
