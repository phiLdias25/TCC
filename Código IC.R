#### Abrindo as bibliotecas ####

library(dplyr)
library(readr)
library(tidyverse)
library(readxl)
library(haven)

#### Determinando o diretório ####

setwd('C:/Users/phili/Documents/Importante/Iniciação Científica/Dados')

#### Abrindo as bases de dados ####

mortes_1988 <- read_csv("mort1988.csv")
View(mortes_1988)

mortes_1987 <- read_csv("mort1987.csv")
View(mortes_1987)

mortes_1986 <- read_csv('mort1986.csv')

#### Transferindo as informações importantes para data frames menores ####

mortes_1988_df <- mortes_1988 %>%
  mutate(
    ano = datayear,
    cod_condado = as.numeric(fipsctyo),
    cod_estado = as.numeric(fipssto),
    cod_condado2 = as.numeric(countyoc),
    pop_condado = as.numeric(popsize),
    mes = monthdth,
    dia = daydth,
    sexo = sex,
    raca = race,
    racar3 = racer3,
    idade = ager12,
    estado_civil = marstat,
    causa_morte = as.numeric(ucod)
  ) %>%
  select(ano,cod_condado,cod_estado,cod_condado2, pop_condado,mes,dia,sexo,raca,racar3,idade,estado_civil,causa_morte)

sum(is.na(mortes_1988_df$pop_condado))

mortes_1987_df <- mortes_1987 %>%
  mutate(
    ano = datayear,
    cod_condado = as.numeric(fipsctyo),
    cod_estado = as.numeric(fipssto),
    cod_condado2 = as.numeric(countyoc),
    pop_condado = as.numeric(popsize),
    mes = monthdth,
    dia = daydth,
    sexo = sex,
    raca = race,
    racar3 = racer3,
    idade = ager12,
    estado_civil = marstat,
    causa_morte = as.numeric(ucod)
  ) %>%
  select(ano,cod_condado,cod_estado,cod_condado2, pop_condado,mes,dia,sexo,raca,racar3,idade,estado_civil,causa_morte)

sum(is.na(mortes_1987_df$pop_condado))

mortes_1986_df <- mortes_1986 %>%
  mutate(
    ano = datayear,
    cod_condado = as.numeric(fipsctyo),
    cod_estado = as.numeric(fipssto),
    cod_condado2 = as.numeric(countyoc),
    pop_condado = as.numeric(popsize),
    mes = monthdth,
    dia = daydth,
    sexo = sex,
    raca = race,
    racar3 = racer3,
    idade = ager12,
    estado_civil = marstat,
    causa_morte = as.numeric(ucod)
  ) %>%
  select(ano,cod_condado,cod_estado, cod_condado2, pop_condado,mes,dia,sexo,raca,racar3,idade,estado_civil,causa_morte)


sum(is.na(mortes_1986_df$pop_condado))

#### Juntando as bases de todos os anos e exportando para .csv####

mortes_completa <- bind_rows(mortes_1988_df, mortes_1987_df, mortes_1986_df)



write.csv(mortes_completa, file = 'Mortes_Completa.csv')

##### Unir as bases da mediana do número da população ####

mortes_quase_completas <- read_csv('Mortes_Quase_Completa.csv')

mortes_completa_2 <- mortes_quase_completas %>%
  group_by(cod_condado) %>%
  mutate(pop_condado_mediana = median(pop_condado, na.rm = TRUE))

write.csv(mortes_completa_2, file = 'Mortes_Completa_Nova.csv')

##### Abrir base da população dos EUA por condado ####

pop_por_condado_1986 <- read_excel('Pop_1986_condado.xls')
pop_por_condado_1987 <- read_excel('Pop_1987_condado.xls')
pop_por_condado_1988 <- read_excel('Pop_1988_condado.xls')

##### Arrumar as bases de 86, 87 e 88 ####

pop_por_condado_1986 <- pop_por_condado_1986 |>
  mutate(ano = ifelse(ano == '1986', '86', ano)) |> 
  rowwise() |> 
  mutate(total_por_raca_sexo = sum(c_across(a:r), na.rm = TRUE)) |> 
  ungroup() |> 
  group_by(ano, cod_condado, total_por_raca_sexo) |> 
  select(-a:-r) |> 
  pivot_wider(names_from = 'raça/sexo',
              values_from = 'total_por_raca_sexo') |> 
  mutate(populacao_total = sum(c_across('White male':'Other races female'), na.rm = TRUE)) |> 
  mutate(prop_white_male = round(`White male` / populacao_total, 4),
         prop_white_female = round(`White female` / populacao_total, 4),
         prop_black_male = round(`Black male` / populacao_total, 4),
         prop_black_female = round(`Black female` / populacao_total, 4))
  

pop_por_condado_1987 <- pop_por_condado_1987 |>
  mutate(ano = ifelse(ano == '1987', '87', ano)) |> 
  rowwise() |> 
  mutate(total_por_raca_sexo = sum(c_across(a:r), na.rm = TRUE)) |> 
  ungroup() |> 
  group_by(ano, cod_condado, total_por_raca_sexo) |> 
  select(-a:-r) |> 
  pivot_wider(names_from = 'raca/sexo',
              values_from = 'total_por_raca_sexo') |> 
  mutate(populacao_total = sum(c_across('White male':'Other races female'), na.rm = TRUE)) |> 
  mutate(prop_white_male = round(`White male` / populacao_total, 4),
         prop_white_female = round(`White female` / populacao_total, 4),
         prop_black_male = round(`Black male` / populacao_total, 4),
         prop_black_female = round(`Black female` / populacao_total, 4))

pop_por_condado_1988 <- pop_por_condado_1988 |>
  mutate(ano = ifelse(ano == '1988', '88', ano)) |> 
  rowwise() |> 
  mutate(total_por_raca_sexo = sum(c_across(a:r), na.rm = TRUE)) |> 
  ungroup() |> 
  group_by(ano, cod_condado, total_por_raca_sexo) |> 
  select(-a:-r) |> 
  pivot_wider(names_from = 'raca/sexo',
              values_from = 'total_por_raca_sexo') |> 
  mutate(populacao_total = sum(c_across('White male':'Other races female'), na.rm = TRUE)) |> 
  mutate(prop_white_male = round(`White male` / populacao_total, 4),
         prop_white_female = round(`White female` / populacao_total, 4),
         prop_black_male = round(`Black male` / populacao_total, 4),
         prop_black_female = round(`Black female` / populacao_total, 4))

##### Baixar novamente a Mortes_Completa_Nova.csv ####

base_antiga <- read_csv('Mortes_Completa.csv')

##### Juntar as bases, colocando a população por extenso de cada condado na base completa ####

?full_join

pop_86_87 <- full_join(pop_por_condado_1986, pop_por_condado_1987, by = c('ano', 'cod_condado', 'populacao_total', 'White male', 'White female', 'Black male', 'Black female', 'Other races male', 'Other races female', 'prop_white_male', 'prop_white_female', 'prop_black_male', 'prop_black_female'))

pop_completo <- full_join(pop_86_87, pop_por_condado_1988, by = c('ano', 'cod_condado', 'populacao_total', 'White male', 'White female', 'Black male', 'Black female', 'Other races male', 'Other races female', 'prop_white_male', 'prop_white_female', 'prop_black_male', 'prop_black_female')) |>
  rename(
    White_male = `White male`,
    White_female = `White female`,
    Black_male = `Black male`,
    Black_female = `Black female`,
    Other_races_male = `Other races male`,
    Other_races_female = `Other races female`
  ) |> 
  mutate(ano = paste0("19", ano))

write_dta(pop_completo, 'Base_populacao_completa.dta')

class(pop_completo$ano)

pop_completo <- pop_completo |>
  mutate(ano = str_sub(ano, -2)) |> 
  mutate(ano = as.numeric(ano))

class(pop_completo$ano)

basenova_full <- full_join(base_antiga, pop_completo, by = c('ano', 'cod_condado'))
basenova_inner <- inner_join(base_antiga, pop_completo, by = c('ano', 'cod_condado'))

cond_sem_pop <- anti_join(basenova_full, basenova_inner, by = "cod_condado")

write.csv(basenova_inner, file = 'Mortes_Completa_2.0.csv')

codigos_unicos <- cond_sem_pop%>%
  select(cod_condado) %>%
  distinct()


##### Fazer mapa de calor para a proporção de homens negros em relação a pop total de cada condado ####

library(ggplot2)
library(sf)
library(tigris)
library(dplyr)
library(haven)
library(stringr)

## Para 1986

counties <- counties(cb = TRUE, resolution = "20m")

prop1986 <- read_dta('Base_prop_1986.dta')

prop1986$cod_condado <- as.character(prop1986$cod_condado)

prop1986 <- prop1986 |> 
  filter(!str_detect(cod_condado, '^5[2-6]'))

prop1986_conv <- prop1986 |> 
  mutate(cod_conv = case_when(nchar(cod_condado) == 4 & str_detect(cod_condado, '^3') ~ str_c('4', str_sub(cod_condado, 2, 4)),
             nchar(cod_condado) == 4 & str_detect(cod_condado, '^4') ~ str_c('5', str_sub(cod_condado, 2, 4)),
             nchar(cod_condado) == 4 & str_detect(cod_condado, '^5') ~ str_c('6', str_sub(cod_condado, 2, 4)),
             nchar(cod_condado) == 4 & str_detect(cod_condado, '^6') ~ str_c('8', str_sub(cod_condado, 2, 4)),
             nchar(cod_condado) == 4 & str_detect(cod_condado, '^7') ~ str_c('6', str_sub(cod_condado, 2, 4)),
             nchar(cod_condado) == 4 & str_detect(cod_condado, '^8') ~ str_c('10', str_sub(cod_condado, 2, 4)),
             nchar(cod_condado) == 4 & str_detect(cod_condado, '^9') ~ str_c('11', str_sub(cod_condado, 2, 4)),
             nchar(cod_condado) == 5 & str_detect(cod_condado, '^10') ~ str_c('12', str_sub(cod_condado, 2, 4)),
             nchar(cod_condado) == 5 & str_detect(cod_condado, '^11') ~ str_c('13', str_sub(cod_condado, 2, 4)),
             nchar(cod_condado) == 5 & as.numeric(str_sub(cod_condado, 1, 2)) >= 12 & as.numeric(str_sub(cod_condado, 1, 2)) <= 39 ~ str_c(as.numeric(str_sub(cod_condado, 1, 2)) + 3, str_sub(cod_condado, 3, 5)),
             nchar(cod_condado) == 5 & as.numeric(str_sub(cod_condado, 1, 2)) >= 40 & as.numeric(str_sub(cod_condado, 1, 2)) <= 47 ~ str_c(as.numeric(str_sub(cod_condado, 1, 2)) + 4, str_sub(cod_condado, 3, 5)),
             nchar(cod_condado) == 5 & as.numeric(str_sub(cod_condado, 1, 2)) >= 48 & as.numeric(str_sub(cod_condado, 1, 2)) <= 51 ~ str_c(as.numeric(str_sub(cod_condado, 1, 2)) + 5, str_sub(cod_condado, 3, 5)),
             TRUE ~ cod_condado))
             
             

prop1986_merge <- counties |> 
  left_join(prop1986_conv, by = c('GEOID' = 'cod_conv')) # 398 condados NA

sum(is.na(prop1986_merge$prop_black_male))

# Supondo que 'counties' seja o shapefile dos condados e que 'proporcao' seja a variável de interesse
# Ajustar a projeção para Albers Equal Area
counties <- st_transform(counties, crs = "+proj=aea +lat_1=29.5 +lat_2=45.5 +lat_0=37.5 +lon_0=-96")

counties |> 
  distinct(STATEFP, STATE_NAME) |> 
  arrange(STATEFP)

# Plotar o mapa com os ajustes

ggplot() +
  geom_sf(data = prop1986_merge, aes(fill = prop_black_male), color = NA) +
  coord_sf(xlim = c(-125, -66), ylim = c(24, 50)) +
  scale_fill_gradient(low = "grey", high = "darkred", name = "Proporção", 
                      limits = c(0, max(prop1986_merge$prop_black_male, na.rm = TRUE)), 
                      oob = scales::squish,
                      na.value = 'darkgrey') +
  labs(title = "Distribuição de Indivíduos Negros pelos Condados dos EUA (1986)",
       subtitle = "Representação proporcional com base na população total") +
  theme_void() +
  theme(legend.position = "right")



