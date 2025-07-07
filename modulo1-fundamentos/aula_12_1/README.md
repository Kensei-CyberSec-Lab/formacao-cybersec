# Lab 01 – Scan no Metasploitable com GVM

## Passo 1: Deploy do Metasploitable
- Execute a VM Metasploitable em bridge/network local.
- Anote seu IP (ex: 192.168.56.101).

## Passo 2: Levantar o GVM
- `docker compose build`
- `docker compose up -d`
- Aguarde ~5 minutos.

## Passo 3: Acessar a UI
- Abra `http://localhost:9392`
- Login: `admin` / `admin`

## Passo 4: Criar Target
- Vá em **Configuration → Targets**
- New Target: nome `Metasploitable`, host = IP da VM

## Passo 5: Executar Scan
- Vá em **Scans → Tasks**
- New Task: nome `Scan MSB01`, selecione Target, configuração “Full and fast”
- Start Task

## Passo 6: Analisar e Exportar
- Veja findings como VSFTPD backdoor, Apache antigo etc.
- Exporte relatório em PDF para análise

