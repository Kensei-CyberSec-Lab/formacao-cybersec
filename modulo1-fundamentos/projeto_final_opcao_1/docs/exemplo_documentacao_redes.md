# Exemplo de Documentação de Redes Descobertas

**Autor:** Aluno Exemplo  
**Data:** 12/07/2025  
**Versão:** 1.0

## Redes Identificadas

| Nome Estimado | Subnet Descoberta | Finalidade Suposta              |
|---------------|--------------------|---------------------------------|
| rede1         | 10.10.10.0/24      | Rede principal dos dispositivos|
| rede2         | 172.16.20.0/24     | Rede de visitantes              |
| rede3         | 192.168.50.0/24    | Infraestrutura / servidores     |

---

## Dispositivos por Rede

### rede1
| IP               | Função             | Evidência                |
|------------------|--------------------|--------------------------|
| 10.10.10.5        | Estação de trabalho | Responde ping, porta 22  |
| 10.10.10.20       | Impressora         | Serviço web na porta 631 |
| 10.10.10.100      | Servidor Web       | Porta 80 com nginx       |

### rede2
| IP               | Função             | Evidência                |
|------------------|--------------------|--------------------------|
| 172.16.20.10      | Dispositivo guest  | Poucos serviços ativos   |

### rede3
| IP               | Função             | Evidência                |
|------------------|--------------------|--------------------------|
| 192.168.50.50     | Servidor de arquivos | Porta 80 ativa (HTTPD)   |

---

## Observações de Risco

- A `rede2` aparenta estar isolada, mas precisa ser testada quanto ao roteamento com `rede1`.
- `rede3` deveria estar isolada de estações de trabalho comuns.
- Impressoras expostas na mesma rede de usuários pode ser risco de movimentação lateral.
