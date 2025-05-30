# ---------------------------------------------------------
# PROJETO: Incidência de Malária no Brasil - Visualização com R
# ---------------------------------------------------------

# Definindo o diretório de trabalho (ajuste conforme seu ambiente)
setwd("")

# Instalação de pacotes necessários (executar apenas uma vez)
install.packages(c("tidyverse", "sf","geobr", "ggspatial","readxl" ))

# ---------------------------------------------------------
# 1. Carregando bibliotecas necessárias
# ---------------------------------------------------------
library(tidyverse)   # Manipulação e visualização de dados
library(sf)          # Manipulação de dados espaciais
library(geobr)       # Geometrias oficiais do Brasil
library(ggspatial)   # Escala e seta de norte
library(readxl)      # Leitura de arquivos Excel

# ---------------------------------------------------------
# 2. Importação da base de casos de Malária
# ---------------------------------------------------------

malaria <- read_excel("malaria_casos.xlsx")

# Ajuste dos nomes de variáveis para facilitar manipulação
colnames(malaria)[3] <- "code_muni"
colnames(malaria)[5] <- "ano"
colnames(malaria)[6] <- "casos"

# Remover colunas desnecessárias
malaria <- malaria %>%
  select(code_muni, ano, casos)

# Garantir que as variáveis estão como texto (padronização)
malaria$code_muni <- as.character(malaria$code_muni)
malaria$ano <- as.character(malaria$ano)

# ---------------------------------------------------------
# 3. Importação da base de população municipal
# ---------------------------------------------------------

populacao <- read_excel("populacao.xlsx")

# Ajuste de variáveis
colnames(populacao)[1] <- "code_muni"
populacao$code_muni <- substr(populacao$code_muni, 1, 6)
populacao <- populacao %>% select(-Município)

# Transformação de wide para long (ano e população)
populacao <- populacao %>%
  mutate(across(-code_muni, as.numeric)) %>%
  pivot_longer(
    cols = -code_muni,
    names_to = "ano",
    values_to = "pop"
  )

# ---------------------------------------------------------
# 4. Junção das bases de casos e população
# ---------------------------------------------------------

base_final <- malaria %>%
  left_join(populacao, by = c("code_muni", "ano"))

# Cálculo da taxa de casos por 1.000 habitantes
base_final <- base_final %>%
  mutate(taxa_casos = (casos / pop) * 1000)

# ---------------------------------------------------------
# 5. Importação da geometria dos municípios (geobr)
# ---------------------------------------------------------

muni <- read_municipality(year = 2020)
muni$code_muni <- substr(muni$code_muni, 1, 6)
muni$code_muni <- as.character(muni$code_muni)

# ---------------------------------------------------------
# 6. Cruzamento de municípios e anos (garante grade completa)
# ---------------------------------------------------------

anos <- sort(unique(base_final$ano))
todos_municipios_anos <- expand_grid(
  code_muni = muni$code_muni,
  ano = anos
)

# Junção das geometrias e indicadores
dados_geo <- left_join(todos_municipios_anos, muni, by = "code_muni") %>%
  left_join(base_final, by = c("code_muni", "ano" = "ano"))

# ---------------------------------------------------------
# 7. Categorização da taxa para visualização
# ---------------------------------------------------------

dados_geo <- dados_geo %>%
  mutate(
    cat_taxa = case_when(
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
    ),
    cat_taxa = factor(
      cat_taxa,
      levels = c("Sem casos", "0 - 1", "1 - 5", "5 - 10", "10 - 20",
                 "20 - 50", "50 - 100", "100 - 300", "> 300"),
      ordered = TRUE
    )
  )

# ---------------------------------------------------------
# 8. Definição da paleta de cores
# ---------------------------------------------------------

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

# Converter em objeto sf
dados_geo <- st_as_sf(dados_geo)

# ---------------------------------------------------------
# 9. Geração dos mapas facetados
# ---------------------------------------------------------

grafico_casos <- ggplot(dados_geo) +
  geom_sf(aes(fill = cat_taxa), color = "black", size = 0.02) +  # Bordas pretas finas
  scale_fill_manual(name = "Casos de malária\npor 1.000 hab.", 
                    values = cores_cat_taxa, drop = FALSE) +
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
  facet_wrap(~ano, ncol = 3) +   # Cria os 3 mapas lado a lado
  labs(title = "")

# ---------------------------------------------------------
# 10. Exportação da figura em alta resolução
# ---------------------------------------------------------

ggsave("malaria_casos.png", grafico_casos, 
       width = 14, height = 6, dpi = 300)
