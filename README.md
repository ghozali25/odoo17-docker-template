# Odoo 17 Docker Template

Template deploy Odoo 17 (rakitan sendiri di atas `python:3.12-slim-bookworm`,
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

## Opsi: data di /mnt/storage

Bila server punya mount storage besar (mis. `/mnt/storage`), dua cara
supaya database & filestore tinggal di sana, bukan di disk sistem:

**Cara 1 — clone langsung di storage (paling sederhana):**

```bash
cd /mnt/storage
sudo git clone <repo-ini> odoo17
cd odoo17
```

Sisa langkahnya sama seperti di atas; semua folder `data/`, `addons/`,
`custom_addons/` otomatis berada di `/mnt/storage/odoo17/`.

**Cara 2 — repo di tempat lain, volume diarahkan manual:**

Edit `docker-compose.yml`, ubah volume menjadi path absolut:

```yaml
    volumes:
      - /mnt/storage/odoo17/data/postgres:/var/lib/postgresql/data
```

dan untuk service `odoo`:

```yaml
    volumes:
      - /mnt/storage/odoo17/data/odoo:/var/lib/odoo
      - ./config:/etc/odoo
      - /mnt/storage/odoo17/addons:/mnt/extra-addons
      - /mnt/storage/odoo17/custom_addons:/mnt/custom-addons
```

Buat dulu foldernya: `sudo mkdir -p /mnt/storage/odoo17/{data/postgres,data/odoo,addons,custom_addons}`.

## Catatan

- Jangan commit file `.env` asli; repo hanya menyimpan `.env.example`.
- Setelah mengubah `Dockerfile` (mis. tambah library), jalankan
  `docker compose build odoo && docker compose up -d`.
- Untuk di belakang reverse proxy / Cloudflare Tunnel, set
  `proxy_mode = True` di `config/odoo.conf`.
