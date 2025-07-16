# Proposta Técnica – Estrutura de Rede para Cliente Fictício S/A

**Autor:** [Seu Nome]  
**Data:** [Data do Documento]  
**Versão:** 1.0

## Sumário Executivo

[Resumo da proposta de forma clara, estratégica e focada no valor para o cliente.]

## Objetivo

Desenhar uma arquitetura de rede corporativa segura, escalável e segmentada para a empresa Fictício S/A, com base no briefing recebido.

## Escopo

Inclui matriz e filiais com acesso remoto, servidores internos e conectividade com sistemas em nuvem.

## Proposta de Arquitetura

- Sub-redes por departamento (Financeiro, TI, etc.)
- VLAN para visitantes separada da rede interna
- VPN entre matriz e filiais
- Firewall com controle de acesso e logs

## Diagrama da Rede

[Inserir diagrama lógico com fluxos e segmentação]

## Justificativas Técnicas

- Segmentação para limitar propagação de ataques
- VPN para comunicação segura entre unidades
- Isolamento de visitantes e IoT

## Plano de Implementação (80/20)

| Ação                          | Impacto | Facilidade | Prioridade |
|-------------------------------|---------|------------|------------|
| Implementar VLANs por setor   | Alto    | Média      | Alta       |
| Configurar VPN site-to-site   | Alto    | Alta       | Alta       |
| Criar política de acesso Wi-Fi| Médio   | Alta       | Média      |

## Conclusão

A proposta atende aos requisitos do cliente com foco em segurança, escalabilidade e controle.

## Anexos

- Diagrama da rede
- Lista de equipamentos sugeridos (opcional)
