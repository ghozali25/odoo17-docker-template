FROM python:3.12-slim-bookworm

ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg \
        git \
        build-essential \
        gcc \
        g++ \
        wkhtmltopdf \
        make \
        libpq-dev \
        libldap2-dev \
        libsasl2-dev \
        libxml2-dev \
        libxslt1-dev \
        libjpeg62-turbo-dev \
        zlib1g-dev \
        libffi-dev \
        libssl-dev \
        libfreetype6-dev \
        liblcms2-dev \
        libopenjp2-7-dev \
        libtiff5-dev \
        libwebp-dev \
        libharfbuzz-dev \
        libfribidi-dev \
        libxcb1 \
        libx11-6 \
        libxext6 \
        libxrender1 \
        xfonts-75dpi \
        xfonts-base \
        fonts-dejavu \
        node-less \
        npm \
        && rm -rf /var/lib/apt/lists/*

RUN echo "deb [signed-by=/usr/share/keyrings/postgresql-archive-keyring.gpg] http://apt.postgresql.org/pub/repos/apt bookworm-pgdg main" \
    > /etc/apt/sources.list.d/pgdg.list && \
    curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc \
    | gpg --dearmor -o /usr/share/keyrings/postgresql-archive-keyring.gpg && \
    apt-get update && \
    apt-get install -y --no-install-recommends postgresql-client-15 && \
    rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 --branch 17.0 https://github.com/odoo/odoo.git /opt/odoo

WORKDIR /opt/odoo

RUN python -m pip install --no-cache-dir --upgrade \
        pip \
        setuptools \
        wheel

RUN pip install --no-cache-dir -r requirements.txt

# --- Library tambahan untuk modul-modul custom ---
# izi_data (port):         pandas, sqlparse, xlsxwriter, requests
# upgrade_analysis:        odoorpc, openupgradelib
# sql_export_excel:        openpyxl
# auto_database_backup:    paramiko, boto3, dropbox, pyncclient, nextcloud-api-wrapper
RUN pip install --no-cache-dir \
        pandas \
        "sqlparse>=0.4.2" \
        xlsxwriter \
        requests \
        odoorpc \
        openupgradelib \
        openpyxl \
        paramiko \
        boto3 \
        dropbox \
        pyncclient \
        nextcloud-api-wrapper

RUN npm install -g rtlcss

RUN mkdir -p \
        /var/lib/odoo \
        /mnt/extra-addons \
        /mnt/custom-addons \
        /etc/odoo

RUN useradd \
        --system \
        --home /var/lib/odoo \
        --shell /bin/bash \
        odoo

RUN chown -R odoo:odoo \
        /var/lib/odoo \
        /opt/odoo \
        /mnt/extra-addons \
        /mnt/custom-addons

COPY config/odoo.conf /etc/odoo/odoo.conf

RUN chown odoo:odoo /etc/odoo/odoo.conf

USER odoo

EXPOSE 8069 8072

CMD ["python3", "/opt/odoo/odoo-bin", "-c", "/etc/odoo/odoo.conf"]
