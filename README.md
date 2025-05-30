
# 🦟 Visualização da Incidência de Malária no Brasil (2008, 2015 e 2024)

> 🚀 **Projeto didático de análise e visualização de dados públicos em R**

## 🎯 Objetivo

Este projeto visa **disseminar conhecimento em análise de dados e visualização geoespacial com R**, utilizando como estudo de caso a incidência de malária no Brasil nos anos de 2008, 2015 e 2024. 

🔬 Público-alvo: iniciantes em ciência de dados, saúde pública e análise territorial.

---

## 🧬 Sobre a Malária

A malária é uma doença infecciosa grave, causada por parasitas do gênero *Plasmodium* e transmitida por mosquitos do gênero *Anopheles*. Representa um importante desafio de saúde pública:

- 🧪 **Desafio científico**: o mosquito vetor adapta-se facilmente a diversos ambientes.
- 🌎 **Desafio geográfico**: alta incidência em regiões tropicais, com clima propício à proliferação.
- 🏛 **Desafio político**: políticas de combate muitas vezes são descontinuadas, favorecendo a reincidência cíclica.

---

## 📊 Fontes de Dados

- 🩺 **Casos de Malária**: [Ministério da Saúde - Tableau Público](https://public.tableau.com/app/profile/mal.ria.brasil/viz/Dadosparacidado_201925_03_2020/Ttulo)
- 👥 **População**: [Estimativas Populacionais - IBGE/SIDRA](https://sidra.ibge.gov.br/pesquisa/estimapop/tabelas)

---

## 📦 Pacotes Utilizados

```r
library(tidyverse)
library(sf)
library(geobr)
library(ggspatial)
library(readxl)
```

---

## 🔄 Fluxo de Trabalho

### 📥 Importação e Tratamento de Dados

- **Casos de Malária**  
- **População por Município**  
- **Junção e Cálculo de Taxa de Incidência**

### 🌐 Integração Espacial

- Carregamento da geometria dos municípios com o pacote `geobr`
- União das bases populacionais e epidemiológicas com as geometrias territoriais

### 🎨 Visualização Geoespacial

Os mapas apresentam a **taxa de incidência de casos por 1.000 habitantes**, destacando padrões temporais e territoriais.

```r
# Exemplo simplificado de visualização (vide código completo no script)
ggplot(dados_geo) +
  geom_sf(aes(fill = cat_taxa), color = "black", size = 0.02) +
  scale_fill_manual(values = cores_cat_taxa) +
  facet_wrap(~ano, ncol = 3)
```

---

## 🔎 Interpretação dos Resultados

🗺 Os mapas mostram **redução significativa de municípios com alta incidência entre 2008 e 2024**, porém persistem áreas críticas na Região Norte, indicando a importância de políticas públicas sustentadas e contínuas.

---

## 📝 Licença

📄 Este projeto está licenciado sob a [MIT License](LICENSE).

---

## 🤝 Contribuições

Contribuições são muito bem-vindas!  
Sinta-se à vontade para abrir **issues** ou enviar **pull requests** 🔧.
