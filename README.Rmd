
---
title: "Visualização da Incidência de Malária no Brasil (2008, 2015 e 2024)"
output: github_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE, message = FALSE, warning = FALSE)
```

## Objetivo

Este projeto tem como objetivo disseminar o conhecimento sobre análise de dados públicos e visualização em R para iniciantes, a partir da incidência de malária no Brasil nos anos de 2008, 2015 e 2024.

## Sobre a Malária

A malária é uma doença infecciosa grave, causada por parasitas do gênero *Plasmodium* e transmitida por mosquitos do gênero *Anopheles*. Embora tratável, representa um grande desafio de saúde pública por diversas razões:

- **Desafio científico**: o mosquito vetor adapta-se a diferentes ambientes.
- **Desafio geográfico**: afeta países tropicais, com condições climáticas e ambientais favoráveis à proliferação do mosquito.
- **Desafio político**: investimentos em controle da malária costumam ser descontinuados quando os casos diminuem, o que favorece o retorno da doença em ciclos ainda mais severos.

## Fontes de Dados

- **Malária**: [Ministério da Saúde - Tableau Público](https://public.tableau.com/app/profile/mal.ria.brasil/viz/Dadosparacidado_201925_03_2020/Ttulo)
- **População**: [Estimativas Populacionais - IBGE/SIDRA](https://sidra.ibge.gov.br/pesquisa/estimapop/tabelas)

## Carregando pacotes

```{r}
library(tidyverse)
library(sf)
library(geobr)
library(ggspatial)
library(readxl)
```

## Importação e tratamento dos dados

### Casos de Malária

```{r}
malaria <- read_excel("data/17- Série Notificados Mun_data.xlsx")

colnames(malaria)[3] <- "code_muni"
colnames(malaria)[5] <- "ano"
colnames(malaria)[6] <- "casos"

malaria <- malaria %>%
  select(code_muni, ano, casos) %>%
  mutate(across(everything(), as.character))
```

### População por município

```{r}
populacao <- read_excel("data/tabela6579.xlsx")
colnames(populacao)[1] <- "code_muni"
populacao$code_muni <- substr(populacao$code_muni, 1, 6)
populacao <- populacao %>% select(-Município)

populacao <- populacao %>%
  mutate(across(-code_muni, as.numeric)) %>%
  pivot_longer(cols = -code_muni, names_to = "ano", values_to = "pop")
```

### Junção das bases

```{r}
base_final <- malaria %>%
  left_join(populacao, by = c("code_muni", "ano")) %>%
  mutate(taxa_casos = (as.numeric(casos) / pop) * 1000)
```

### Geometria dos municípios

```{r}
muni <- read_municipality(year = 2020) %>%
  mutate(code_muni = substr(as.character(code_muni), 1, 6))
```

### Cruzamento dos dados espaciais

```{r}
anos <- sort(unique(base_final$ano))
todos_municipios_anos <- expand_grid(code_muni = muni$code_muni, ano = anos)

dados_geo <- left_join(todos_municipios_anos, muni, by = "code_muni") %>%
  left_join(base_final, by = c("code_muni", "ano")) %>%
  mutate(cat_taxa = case_when(
    is.na(taxa_casos) ~ "Sem casos",
    taxa_casos == 0 ~ "Sem casos",
    taxa_casos > 0 & taxa_casos <= 1 ~ "0 - 1",
    taxa_casos > 1 & taxa_casos <= 5 ~ "1 - 5",
    taxa_casos > 5 & taxa_casos <= 10 ~ "5 - 10",
    taxa_casos > 10 & taxa_casos <= 20 ~ "10 - 20",
    taxa_casos > 20 & taxa_casos <= 50 ~ "20 - 50",
    taxa_casos > 50 & taxa_casos <= 100 ~ "50 - 100",
    taxa_casos > 100 & taxa_casos <= 300 ~ "100 - 300",
    taxa_casos > 300 ~ "> 300",
    TRUE ~ "Sem casos"
  ))

dados_geo$cat_taxa <- factor(dados_geo$cat_taxa, 
                             levels = c("Sem casos", "0 - 1", "1 - 5", "5 - 10", "10 - 20", "20 - 50", "50 - 100", "100 - 300", "> 300"),
                             ordered = TRUE)
dados_geo <- st_as_sf(dados_geo)
```

## Visualização: Mapa da taxa de casos por 1.000 habitantes

```{r fig.width=14, fig.height=6}
cores_cat_taxa <- c(
  "Sem casos" = "white",
  "0 - 1" = "#FFDDCC",
  "1 - 5" = "#FFBB99",
  "5 - 10" = "#FF9966",
  "10 - 20" = "#FF7744",
  "20 - 50" = "#FF5522",
  "50 - 100" = "#FF3300",
  "100 - 300" = "#CC0000",
  "> 300" = "#990000"
)

ggplot(dados_geo) +
  geom_sf(aes(fill = cat_taxa), color = "black", size = 0.02) +
  scale_fill_manual(name = "Casos de malária
por 1.000 hab.", values = cores_cat_taxa, drop = FALSE) +
  annotation_scale(location = "br", width_hint = 0.15, line_width = 0.2) +
  annotation_north_arrow(location = "br", which_north = "true",
                         height = unit(0.7, "cm"), width = unit(0.7, "cm"),
                         pad_x = unit(0.2, "cm"), pad_y = unit(0.5, "cm"),
                         style = north_arrow_fancy_orienteering) +
  theme_minimal() +
  theme(
    legend.text = element_text(size = 10),
    legend.title = element_text(size = 11, face = "bold"), 
    axis.title = element_blank(),
    axis.text = element_blank(),
    axis.ticks = element_blank(),
    panel.grid = element_blank(),
    legend.key.width = unit(1.5, "cm"),
    strip.text = element_text(size = 16, face = "bold"),
    plot.title = element_text(size = 20, face = "bold", hjust = 0.5)
  ) +
  facet_wrap(~ano, ncol = 3)
```

## Interpretação dos Resultados

Os mapas mostram uma redução no número de municípios com alta incidência de malária entre 2008 e 2024. Contudo, ainda persistem áreas críticas, especialmente na Região Norte. Esse padrão cíclico reforça a necessidade de políticas públicas contínuas e sustentáveis de combate à doença.

## Licença

Este projeto está licenciado sob a [MIT License](LICENSE).

## Contribuições

Contribuições são bem-vindas! Sinta-se à vontade para abrir issues ou pull requests.
