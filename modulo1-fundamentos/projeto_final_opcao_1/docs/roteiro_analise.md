# Roteiro de Análise – Mapeamento de Rede

1. **Reconhecimento Inicial**
   - Use `netdiscover` ou `arp-scan` para mapear hosts ativos
   - Identifique o range de IPs e sub-redes

2. **Varredura Detalhada**
   - Utilize `nmap` ou `rustscan` para identificar serviços por host
   - Anote portas abertas e banners

3. **Identificação de Ativos**
   - Categorize os hosts por função (ex: web, fileserver, estação, etc.)

4. **Avaliação de Riscos**
   - Serviços desnecessários?
   - Portas abertas sem autenticação?
   - Ausência de segmentação lógica?

5. **Produção de Relatório**
   - Diagrama da rede
   - Achados + recomendações
   - Plano de ação baseado em impacto e facilidade
