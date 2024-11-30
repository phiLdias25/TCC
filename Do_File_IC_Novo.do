** Definir o Diretório e o tema dos gráfico
cd "C:\Users\phili\Documents\Importante\Iniciação_Científica\Dados"
set scheme white_tableau

** Abrir a base de dados
insheet using Mortes_Completa_2.0.csv

** Colocando labels nas variáveis

label variable ano "Ano da Morte"
label variable cod_condado "Código do Condado"
label variable cod_estado "Código do Estado"
label variable cod_condado2 "Código Alternativo do Condado"
label variable pop_condado "Índice da População - 1 a 9"
label variable mes "Mês da Morte"
label variable dia "Dia da Morte"
label variable sexo "Gênero do Indivíduo"
label variable raca "Raça do Indivíduo"
label variable racar3 "Raça do Indivíduo - Branco, Negro ou Outra"
label variable idade "Idade do Indivíduo"
label variable estado_civil "Estado Civil do Indivíduo"
label variable causa_morte "Causa da Morte, segundo CID-9"
label variable populacao_total "População Total dos Condados"

** Excluindo v1, v2 e v3 e a variável de população (será adicionada mais para frente)
drop v1 v2 populacao_total cod_condado2

** Mudar ordenamento das variáveis

order ano cod_condado cod_estado pop_condado mes dia sexo raca racar3 idade estado_civil causa_morte

** Salvar a tabela intermediária
save Mortes_Completa_CORRIGIDA_Stata.dta, replace

** Abrindo a tabela intermediária
use Mortes_Completa_CORRIGIDA_Stata.dta, clear

** Ordenando os dados corretamente
sort cod_condado
sort causa_morte
sort ano

** Criando a dummy para os casos relevantes do CID-9 e as dummies de mortes por causas externas, intervenção legal e homicídos, separadas por raça
gen dummy_raca = (racar3 == 3)

	** População Negra
gen dummy_morte_int_leg_negro = (causa_morte >= 970 & causa_morte <= 978) & dummy_raca == 1
tab dummy_morte_int_leg_negro

gen dummy_morte_homi_negro = (causa_morte >= 960 & causa_morte <= 969) & dummy_raca == 1
tab dummy_morte_homi_negro

gen dummy_morte_causa_ext_negro = (causa_morte >= 800 & causa_morte <= 999) & dummy_raca == 1
tab dummy_morte_causa_ext_negro
	
	**População Branca
gen dummy_morte_int_leg_branco = (causa_morte >= 970 & causa_morte <= 978) & dummy_raca == 0
tab dummy_morte_int_leg_branco

gen dummy_morte_homi_branco = (causa_morte >= 960 & causa_morte <= 969) & dummy_raca == 0
tab dummy_morte_homi_branco

gen dummy_morte_causa_ext_branco = (causa_morte >= 800 & causa_morte <= 999) & dummy_raca == 0
tab dummy_morte_causa_ext_branco

** Estatística Descritiva de Raças

label define raca_label 0 "Ásia ou Ilhas do Pacífico" 1 "Branco" 2 "Negro" 3 "Indígena Americano" 4 "Chinês" 5 "Japonês" 6 "Havaiano" 7 "Outras" 8 "Filipino"
label values raca raca_label
label define racar3_label 1 "Branco" 2 "Outra" 3 "Negro"
label values racar3 racar3_label
label define ano_label 86 "1986" 87 "1987" 88 "1988"
label values ano ano_label
tabulate raca ano

** Estatística Descritiva de Mortes por Causas Externas do CID-9
tab causa_morte ano if causa_morte >= 800 & causa_morte <= 999
tab causa_morte racar3 if causa_morte >= 800 & causa_morte <= 999

** Estatística Descritiva de Mortes por Intervenção Legal do CID-9
tab causa_morte ano if causa_morte >= 970 & causa_morte <= 978
tab causa_morte racar3 if causa_morte >= 970 & causa_morte <= 978

** Estatística Descritiva de Mortes por Homicídio do CID-9
tab causa_morte ano if causa_morte >= 960 & causa_morte <= 969
tab causa_morte racar3 if causa_morte >= 960 & causa_morte <= 969


** Criando a coluna de semana
tostring ano, replace force
replace ano = "1986" if ano == "86"
replace ano = "1987" if ano == "87"
replace ano = "1988" if ano == "88"

tostring mes, replace force
replace mes = "01" if mes == "1"
replace mes = "02" if mes == "2"
replace mes = "03" if mes == "3"
replace mes = "04" if mes == "4"
replace mes = "05" if mes == "5"
replace mes = "06" if mes == "6"
replace mes = "07" if mes == "7"
replace mes = "08" if mes == "8"
replace mes = "09" if mes == "9"

tostring dia, replace force
replace dia = "01" if dia == "1"
replace dia = "02" if dia == "2"
replace dia = "03" if dia == "3"
replace dia = "04" if dia == "4"
replace dia = "05" if dia == "5"
replace dia = "06" if dia == "6"
replace dia = "07" if dia == "7"
replace dia = "08" if dia == "8"
replace dia = "09" if dia == "9"

gen data = ano+mes+dia
gen data_obito = date(data, "YMD")
gen week = week(data_obito)

sort data_obito
sort week

gen um = 1
* um = Número de óbitos totais naquela semana, naquele condado

** Salvar a tabela intermediária
save Mortes_Completa_CORRIGIDA_Stata.dta, replace

** Abrindo a tabela intermediária
use Mortes_Completa_CORRIGIDA_Stata.dta, clear

** Gráficos de mortes totais por raça ao longo do tempo

collapse (sum) um, by(ano week racar3)

* Negros

destring ano, replace

twoway (line um week if ano == 1986 & racar3 == 3, lwidth(medium) lcolor(black)) (line um week if ano == 1987 & racar3 == 3, lwidth(medium) lcolor(red) lpattern(dash)) (line um week if ano == 1988 & racar3 == 3, lwidth(thick) lcolor(gray) lpattern(dot)), xtitle("Semanas") ytitle("Número de Óbitos") legend(order(1 "1986" 2 "1987" 3 "1988")) xlabel(, nogrid) xline(32, lcolor(red) lpattern(dot) lwidth(thick))

* 10 semanas antes do lançamento - 10 semanas depois do lançamento do álbum
twoway line um week if week >= 22 & week <= 38 & ano == 1988 & racar3 == 3, lcolor(black) lpattern(solid) lwidth(thin) xlabel(22(2)40) xlabel(, nogrid) xline(32, lcolor(red) lpattern(dot) lwidth(thick)) xtitle("Semana do ano") ytitle("Número de óbitos")

* Não Negros

use Mortes_Completa_CORRIGIDA_Stata.dta, clear

keep if racar3 == 1 | racar3 == 2

collapse (sum) um, by(week ano)

destring ano, replace

twoway (line um week if ano == 1986, lwidth(medium) lcolor(black)) (line um week if ano == 1987, lwidth(medium) lcolor(red) lpattern(dash)) (line um week if ano == 1988, lwidth(thick) lcolor(gray) lpattern(dot)), xtitle("Semanas") ytitle("Número de Óbitos") legend(order(1 "1986" 2 "1987" 3 "1988")) xlabel(, nogrid) xline(32, lcolor(red) lpattern(dot) lwidth(thick))

* 10 semanas antes do lançamento - 5 semanas depois do lançamento do álbum
twoway line um week if week >= 22 & week <= 38 & ano == 1988, lcolor(black) lpattern(solid) lwidth(thin) xlabel(22(2)40) xlabel(, nogrid) xline(32, lcolor(red) lpattern(dot) lwidth(thick)) xtitle("Semana do ano") ytitle("Número de óbitos")

** Colapsando as bases para a população morta por intervenções legais (separando entre negros e brancos)

use Mortes_Completa_CORRIGIDA_Stata.dta, clear

	** População Negra
collapse (sum) dummy_morte_int_leg_negro um, by(ano week cod_condado)
rename dummy_morte_int_leg_negro morte_int_leg_negro
save Morte_int_leg_negro.dta, replace

* Abrindo a base intermediária de novo
use Mortes_Completa_CORRIGIDA_Stata.dta, clear
	** População Branca
collapse (sum) dummy_morte_int_leg_branco um, by(ano week cod_condado)
rename dummy_morte_int_leg_branco morte_int_leg_branco
save Morte_int_leg_branco.dta, replace

** Trazendo a base balanceada e juntando-a com a base de mortes anuais por intervenção legal, separadas por raça

	** População Negra
use Morte_int_leg_negro.dta, clear
merge 1:1 ano week cod_condado using "C:\Users\phili\Documents\Importante\Iniciação_Científica\Dados\Bases de semana\Mortes_anual_completa.dta"
drop if _merge == 1
replace morte_int_leg_negro = 0 if _merge == 2
replace um = 0 if _merge == 2
rename um um_int_leg_negro
rename _merge _merge_inicial
merge m:m ano cod_condado using Base_populacao_completa
* Base de população não possui informação dos condados 30037, 31005, 31009, 38007, 46021 e 48269 para o ano de 1986, dos condados 31085, 31115 e 51685 para o ano de 1987 e dos condados 8111, 31183, 48301 e 48393 para o ano de 1988.
* Para corrigir isso, fazer uma interpolação com base na média entre as populações de cada condado dos outros anos da base
replace populacao_total = 997 if cod_condado == 30037 & ano == "1986"
replace populacao_total = 453 if cod_condado == 31005 & ano == "1986"
replace populacao_total = 705 if cod_condado == 31009 & ano == "1986"
replace populacao_total = 1178 if cod_condado == 38007 & ano == "1986"
replace populacao_total = 2060 if cod_condado == 46021 & ano == "1986"
replace populacao_total = 378 if cod_condado == 48269 & ano == "1986"
replace populacao_total = 1248 if cod_condado == 31085 & ano == "1987"
replace populacao_total = 732 if cod_condado == 31115 & ano == "1987"
replace populacao_total = 6738 if cod_condado == 51685 & ano == "1987"
replace populacao_total = 825 if cod_condado == 8111 & ano == "1988"
replace populacao_total = 951 if cod_condado == 31183 & ano == "1988"
replace populacao_total = 95 if cod_condado == 48301 & ano == "1988"
replace populacao_total = 1094 if cod_condado == 48393 & ano == "1988"
drop _merge_inicial _merge
save Morte_int_leg_negro.dta, replace
	
	** População Branca
use Morte_int_leg_branco.dta, clear
merge 1:1 ano week cod_condado using "C:\Users\phili\Documents\Importante\Iniciação_Científica\Dados\Bases de semana\Mortes_anual_completa.dta"
drop if _merge == 1
replace morte_int_leg_branco = 0 if _merge == 2
replace um = 0 if _merge == 2
rename um um_int_leg_branco
rename _merge _merge_inicial
merge m:m ano cod_condado using Base_populacao_completa
* Base de população não possui informação dos condados 30037, 31005, 31009, 38007, 46021 e 48269 para o ano de 1986, dos condados 31085, 31115 e 51685 para o ano de 1987 e dos condados 8111, 31183, 48301 e 48393 para o ano de 1988.
* Para corrigir isso, fazer uma interpolação com base na média entre as populações de cada condado dos outros anos da base
replace populacao_total = 997 if cod_condado == 30037 & ano == "1986"
replace populacao_total = 453 if cod_condado == 31005 & ano == "1986"
replace populacao_total = 705 if cod_condado == 31009 & ano == "1986"
replace populacao_total = 1178 if cod_condado == 38007 & ano == "1986"
replace populacao_total = 2060 if cod_condado == 46021 & ano == "1986"
replace populacao_total = 378 if cod_condado == 48269 & ano == "1986"
replace populacao_total = 1248 if cod_condado == 31085 & ano == "1987"
replace populacao_total = 732 if cod_condado == 31115 & ano == "1987"
replace populacao_total = 6738 if cod_condado == 51685 & ano == "1987"
replace populacao_total = 825 if cod_condado == 8111 & ano == "1988"
replace populacao_total = 951 if cod_condado == 31183 & ano == "1988"
replace populacao_total = 95 if cod_condado == 48301 & ano == "1988"
replace populacao_total = 1094 if cod_condado == 48393 & ano == "1988"
drop _merge_inicial _merge
save Morte_int_leg_branco.dta, replace

** Realizando um procedimento semelhante, só que agora para a base de mortes anuais por homicídios

*Abrindo a base intermediária de novo
use Mortes_Completa_CORRIGIDA_Stata.dta, clear

	** População Negra
collapse (sum) dummy_morte_homi_negro um, by(ano week cod_condado)
rename dummy_morte_homi_negro morte_homi_negro
save Morte_homi_negro.dta, replace

use Morte_homi_negro.dta, clear
merge 1:1 ano week cod_condado using "C:\Users\phili\Documents\Importante\Iniciação_Científica\Dados\Bases de semana\Mortes_anual_completa.dta"
drop if _merge == 1
replace morte_homi_negro = 0 if _merge == 2
replace um = 0 if _merge == 2
rename um um_homi_negro
rename _merge _merge_inicial
merge m:m ano cod_condado using Base_populacao_completa
* Base de população não possui informação dos condados 30037, 31005, 31009, 38007, 46021 e 48269 para o ano de 1986, dos condados 31085, 31115 e 51685 para o ano de 1987 e dos condados 8111, 31183, 48301 e 48393 para o ano de 1988.
* Para corrigir isso, fazer uma interpolação com base na média entre as populações de cada condado dos outros anos da base
replace populacao_total = 997 if cod_condado == 30037 & ano == "1986"
replace populacao_total = 453 if cod_condado == 31005 & ano == "1986"
replace populacao_total = 705 if cod_condado == 31009 & ano == "1986"
replace populacao_total = 1178 if cod_condado == 38007 & ano == "1986"
replace populacao_total = 2060 if cod_condado == 46021 & ano == "1986"
replace populacao_total = 378 if cod_condado == 48269 & ano == "1986"
replace populacao_total = 1248 if cod_condado == 31085 & ano == "1987"
replace populacao_total = 732 if cod_condado == 31115 & ano == "1987"
replace populacao_total = 6738 if cod_condado == 51685 & ano == "1987"
replace populacao_total = 825 if cod_condado == 8111 & ano == "1988"
replace populacao_total = 951 if cod_condado == 31183 & ano == "1988"
replace populacao_total = 95 if cod_condado == 48301 & ano == "1988"
replace populacao_total = 1094 if cod_condado == 48393 & ano == "1988"
drop _merge_inicial _merge
save Morte_homi_negro.dta, replace

*Abrindo a base intermediária
use Mortes_Completa_CORRIGIDA_Stata.dta, clear

	** População Branca
collapse (sum) dummy_morte_homi_branco um, by(ano week cod_condado)
rename dummy_morte_homi_branco morte_homi_branco
save Morte_homi_branco.dta, replace

use Morte_homi_branco.dta, clear
merge 1:1 ano week cod_condado using "C:\Users\phili\Documents\Importante\Iniciação_Científica\Dados\Bases de semana\Mortes_anual_completa.dta"
drop if _merge == 1
replace morte_homi_branco = 0 if _merge == 2
replace um = 0 if _merge == 2
rename um um_homi_branco
rename _merge _merge_inicial
merge m:m ano cod_condado using Base_populacao_completa
* Base de população não possui informação dos condados 30037, 31005, 31009, 38007, 46021 e 48269 para o ano de 1986, dos condados 31085, 31115 e 51685 para o ano de 1987 e dos condados 8111, 31183, 48301 e 48393 para o ano de 1988.
* Para corrigir isso, fazer uma interpolação com base na média entre as populações de cada condado dos outros anos da base
replace populacao_total = 997 if cod_condado == 30037 & ano == "1986"
replace populacao_total = 453 if cod_condado == 31005 & ano == "1986"
replace populacao_total = 705 if cod_condado == 31009 & ano == "1986"
replace populacao_total = 1178 if cod_condado == 38007 & ano == "1986"
replace populacao_total = 2060 if cod_condado == 46021 & ano == "1986"
replace populacao_total = 378 if cod_condado == 48269 & ano == "1986"
replace populacao_total = 1248 if cod_condado == 31085 & ano == "1987"
replace populacao_total = 732 if cod_condado == 31115 & ano == "1987"
replace populacao_total = 6738 if cod_condado == 51685 & ano == "1987"
replace populacao_total = 825 if cod_condado == 8111 & ano == "1988"
replace populacao_total = 951 if cod_condado == 31183 & ano == "1988"
replace populacao_total = 95 if cod_condado == 48301 & ano == "1988"
replace populacao_total = 1094 if cod_condado == 48393 & ano == "1988"
drop _merge_inicial _merge
save Morte_homi_branco.dta, replace

** Agora, para mortes por causas externas

*Abrindo a base intermediária de novo
use Mortes_Completa_CORRIGIDA_Stata.dta, clear

	** População Negra
collapse (sum) dummy_morte_causa_ext_negro um, by(ano week cod_condado)
rename dummy_morte_causa_ext_negro morte_causa_ext_negro
save Morte_causa_ext_negro.dta, replace

use Morte_causa_ext_negro.dta, clear
merge 1:1 ano week cod_condado using "C:\Users\phili\Documents\Importante\Iniciação_Científica\Dados\Bases de semana\Mortes_anual_completa.dta"
drop if _merge == 1
replace morte_causa_ext_negro = 0 if _merge == 2
replace um = 0 if _merge == 2
rename um um_causa_ext_negro
rename _merge _merge_inicial
merge m:m ano cod_condado using Base_populacao_completa
* Base de população não possui informação dos condados 30037, 31005, 31009, 38007, 46021 e 48269 para o ano de 1986, dos condados 31085, 31115 e 51685 para o ano de 1987 e dos condados 8111, 31183, 48301 e 48393 para o ano de 1988.
* Para corrigir isso, fazer uma interpolação com base na média entre as populações de cada condado dos outros anos da base
replace populacao_total = 997 if cod_condado == 30037 & ano == "1986"
replace populacao_total = 453 if cod_condado == 31005 & ano == "1986"
replace populacao_total = 705 if cod_condado == 31009 & ano == "1986"
replace populacao_total = 1178 if cod_condado == 38007 & ano == "1986"
replace populacao_total = 2060 if cod_condado == 46021 & ano == "1986"
replace populacao_total = 378 if cod_condado == 48269 & ano == "1986"
replace populacao_total = 1248 if cod_condado == 31085 & ano == "1987"
replace populacao_total = 732 if cod_condado == 31115 & ano == "1987"
replace populacao_total = 6738 if cod_condado == 51685 & ano == "1987"
replace populacao_total = 825 if cod_condado == 8111 & ano == "1988"
replace populacao_total = 951 if cod_condado == 31183 & ano == "1988"
replace populacao_total = 95 if cod_condado == 48301 & ano == "1988"
replace populacao_total = 1094 if cod_condado == 48393 & ano == "1988"
drop _merge_inicial _merge
save Morte_causa_ext_negro.dta, replace

*Abrindo a base intermediária
use Mortes_Completa_CORRIGIDA_Stata.dta, clear

	** População Branca
collapse (sum) dummy_morte_causa_ext_branco um, by(ano week cod_condado)
rename dummy_morte_causa_ext_branco morte_causa_ext_branco
save Morte_causa_ext_branco.dta, replace

use Morte_causa_ext_branco.dta, clear
merge 1:1 ano week cod_condado using "C:\Users\phili\Documents\Importante\Iniciação_Científica\Dados\Bases de semana\Mortes_anual_completa.dta"
drop if _merge == 1
replace morte_causa_ext_branco = 0 if _merge == 2
replace um = 0 if _merge == 2
rename um um_causa_ext_branco
rename _merge _merge_inicial
merge m:m ano cod_condado using Base_populacao_completa
* Base de população não possui informação dos condados 30037, 31005, 31009, 38007, 46021 e 48269 para o ano de 1986, dos condados 31085, 31115 e 51685 para o ano de 1987 e dos condados 8111, 31183, 48301 e 48393 para o ano de 1988.
* Para corrigir isso, fazer uma interpolação com base na média entre as populações de cada condado dos outros anos da base
replace populacao_total = 997 if cod_condado == 30037 & ano == "1986"
replace populacao_total = 453 if cod_condado == 31005 & ano == "1986"
replace populacao_total = 705 if cod_condado == 31009 & ano == "1986"
replace populacao_total = 1178 if cod_condado == 38007 & ano == "1986"
replace populacao_total = 2060 if cod_condado == 46021 & ano == "1986"
replace populacao_total = 378 if cod_condado == 48269 & ano == "1986"
replace populacao_total = 1248 if cod_condado == 31085 & ano == "1987"
replace populacao_total = 732 if cod_condado == 31115 & ano == "1987"
replace populacao_total = 6738 if cod_condado == 51685 & ano == "1987"
replace populacao_total = 825 if cod_condado == 8111 & ano == "1988"
replace populacao_total = 951 if cod_condado == 31183 & ano == "1988"
replace populacao_total = 95 if cod_condado == 48301 & ano == "1988"
replace populacao_total = 1094 if cod_condado == 48393 & ano == "1988"
drop _merge_inicial _merge
save Morte_causa_ext_branco.dta, replace

** Juntar as bases já criadas de mortes, separadas por raça e por blocos de código do CID-9

use Morte_int_leg_negro.dta, clear

merge m:1 ano week cod_condado using Morte_int_leg_branco.dta
rename _merge _merge_2
merge m:1 ano week cod_condado using Morte_homi_negro.dta
rename _merge _merge_3
merge m:1 ano week cod_condado using Morte_homi_branco.dta
rename _merge _merge_4
merge m:1 ano week cod_condado using Morte_causa_ext_negro.dta
rename _merge _merge_5
merge m:1 ano week cod_condado using Morte_causa_ext_branco.dta
rename _merge _merge_6

drop um_int_leg_branco um_homi_negro um_homi_branco um_causa_ext_negro um_causa_ext_branco
drop _merge_2 _merge_3 _merge_4 _merge_5 _merge_6
rename um_int_leg_negro obitos_totais

order ano cod_condado week morte_int_leg_negro morte_int_leg_branco morte_homi_negro morte_homi_branco morte_causa_ext_negro morte_causa_ext_negro populacao_total obitos_totais

save Base_mortes_completa_wide.dta, replace

** Transformando a base de wide para long
use Base_mortes_completa_wide.dta, clear

rename morte_int_leg_negro morte_int_leg_1
rename morte_int_leg_branco morte_int_leg_0
rename morte_homi_negro morte_homi_1
rename morte_homi_branco morte_homi_0
rename morte_causa_ext_negro morte_causa_ext_1
rename morte_causa_ext_branco morte_causa_ext_0

reshape long morte_int_leg_ morte_homi_ morte_causa_ext_, i(ano cod_condado week) j(negro)

save Base_completa_long.dta, replace

*ssc install eventdd

** Arrumando a base para realizar o Event Study e o Pooled DIff-N-Diff

use Base_completa_long.dta, clear

* Colocando os anos como numéricos
destring ano, replace

* Criando uma variável contínua de semana
gen week_cont = week if ano == 1986
replace week_cont = 52 + week if ano == 1987
replace week_cont = 104 + week if ano == 1988
	* Semana de lançamento do álbum: Semana 32 de 1988, e 136 na variável week_cont

* Criar uma variável somente com o número 136
gen lanc_album = 136

* Criar a variável que avalia se a semana é pré ou pós tratamento (lançamento do álbum)
gen post = (week_cont >= 136)

* Criar a variável que faz a contagem de tempo até o tratamento ser realizado
gen tempoAteLanc = week_cont - lanc_album

* Criar a variável indicadora se o ano é 1988

gen ano1988 = (ano == 1988)

save Base_completa_long.dta, replace

** Criando gráficos temporais de óbitos ao longo do tempo

* Óbitos gerais ao longo do tempo

use Base_completa_long.dta, clear

collapse (sum) obitos_totais if negro == 1, by(week_cont ano week)

*Gráfico sequencial

	* Período Completo
twoway (line obitos_totais week_cont if week_cont <= 52, lwidth(medium) lcolor(black)) (line obitos_totais week_cont if week_cont > 52 & week_cont <= 105, lwidth(medium) lcolor(red) lpattern(solid)) (line obitos_totais week_cont if week_cont > 105, lwidth(medium) lcolor(gray) lpattern(solid)), xtitle("Semanas de 1986") ytitle("Número de Óbitos") legend(order(1 "1986" 2 "1987" 3 "1988")) xlabel(, nogrid) xline(53, lcolor(black) lwidth(medium) lpattern(dash)) xline(105, lcolor(black) lwidth(medium) lpattern(dash)) xline(136, lcolor(red) lpattern(dot) lwidth(thick))

	* 10 semanas antes do lançamento - 10 semanas depois
twoway line obitos_totais week if week >= 22 & week <= 43 & ano == 1988, lcolor(black) lpattern(solid) lwidth(thin) xlabel(22(2)44) xlabel(, nogrid) xline(32, lcolor(red) lpattern(dot) lwidth(thick)) xtitle("Semana do ano") ytitle("Número de óbitos")


*Gráfico que separa os anos
twoway (line obitos_totais week if ano==1986, lpattern(solid) lcolor(red) lwidth(medium)) (line obitos_totais week if ano==1987, lpattern(dash) lcolor(black) lwidth(medium)) (line obitos_totais week if ano==1988, lpattern(dot) lcolor(black) lwidth(thick)), xlabel(0(2)52) legend(order(1 "1986" 2 "1987" 3 "1988")) xtitle("Semana do ano") ytitle("Número de óbitos") xlabel(, nogrid) xline(32, lcolor(red) lpattern(dot) lwidth(thick)) xline(32, lcolor(red) lpattern(dot) lwidth(thick))

* Óbitos por Causas Externas

use Base_completa_long.dta, clear

collapse (sum) morte_causa_ext_, by(week_cont ano week)

*Gráfico sequencial - Sem separação de raças

	* Período completo
twoway (line morte_causa_ext_ week_cont if week_cont <= 52, lwidth(medium) lcolor(black)) (line morte_causa_ext_ week_cont if week_cont > 52 & week_cont <= 105, lwidth(medium) lcolor(red) lpattern(solid)) (line morte_causa_ext_ week_cont if week_cont > 105, lwidth(medium) lcolor(gray) lpattern(solid)), xtitle("Semanas") ytitle("Número de Óbitos") legend(order(1 "1986" 2 "1987" 3 "1988")) xlabel(, nogrid) xline(53, lcolor(black) lwidth(medium) lpattern(dash)) xline(105, lcolor(black) lwidth(medium) lpattern(dash)) xline(136, lcolor(red) lpattern(dot) lwidth(thick)) 

	* 10 semanas antes do lançamento - 10 semanas depois
twoway line morte_causa_ext_ week if week >= 22 & week <= 43 & ano == 1988, lcolor(black) lpattern(solid) lwidth(thin) xlabel(22(2)44) xlabel(, nogrid) xline(32, lcolor(red) lpattern(dot) lwidth(thick)) xtitle("Semana do ano") ytitle("Número de óbitos")

*Gráfico que separa os anos - Sem separação de raças
twoway (line morte_causa_ext_ week if ano==1986, lpattern(solid) lcolor(red) lwidth(medium)) (line morte_causa_ext_ week if ano==1987, lpattern(dash) lcolor(black) lwidth(medium)) (line morte_causa_ext_ week if ano==1988, lpattern(dot) lcolor(black) lwidth(thick)), xlabel(0(2)52) legend(order(1 "1986" 2 "1987" 3 "1988")) xtitle("Semana do ano") ytitle("Número de óbitos") xlabel(, nogrid) xline(32, lcolor(red) lpattern(dot) lwidth(thick))

*Gráfico sequencial - Com separação de raças
use Base_completa_long.dta, clear

collapse (sum) morte_causa_ext_, by(week_cont ano week negro)

	* Período Completo - Negros
twoway (line morte_causa_ext_ week_cont if week_cont <= 52 & negro == 1, lwidth(medium) lcolor(black)) (line morte_causa_ext_ week_cont if week_cont > 52 & week_cont <= 105 & negro == 1, lwidth(medium) lcolor(red) lpattern(solid)) (line morte_causa_ext_ week_cont if week_cont > 105 & negro == 1, lwidth(medium) lcolor(gray) lpattern(solid)), xtitle("Semanas") ytitle("Número de Óbitos") legend(order(1 "1986" 2 "1987" 3 "1988")) xlabel(, nogrid) xline(53, lcolor(black) lwidth(medium) lpattern(dash)) xline(105, lcolor(black) lwidth(medium) lpattern(dash)) xline(136, lcolor(red) lpattern(dot) lwidth(thick))

	* Período Completo - Não negros
twoway (line morte_causa_ext_ week_cont if week_cont <= 52 & negro == 0, lwidth(medium) lcolor(black)) (line morte_causa_ext_ week_cont if week_cont > 52 & week_cont <= 105 & negro == 0, lwidth(medium) lcolor(red) lpattern(solid)) (line morte_causa_ext_ week_cont if week_cont > 105 & negro == 0, lwidth(medium) lcolor(gray) lpattern(solid)), xtitle("Semanas") ytitle("Número de Óbitos") legend(order(1 "1986" 2 "1987" 3 "1988")) xlabel(, nogrid) xline(53, lcolor(black) lwidth(medium) lpattern(dash)) xline(105, lcolor(black) lwidth(medium) lpattern(dash)) xline(136, lcolor(red) lpattern(dot) lwidth(thick))

	* 10 semanas antes do lançamento - 5 semanas depois - Com separação de raças
		* Negros
twoway line morte_causa_ext_ week if week >= 22 & week <= 38 & ano == 1988 & negro == 1, lcolor(black) lpattern(solid) lwidth(thin) xlabel(22(2)40) xlabel(, nogrid) xline(32, lcolor(red) lpattern(dot) lwidth(thick)) xtitle("Semana do ano") ytitle("Número de óbitos")
		* Não Negros
twoway line morte_causa_ext_ week if week >= 22 & week <= 38 & ano == 1988 & negro == 0, lcolor(black) lpattern(solid) lwidth(thin) xlabel(22(2)40) xlabel(, nogrid) xline(32, lcolor(red) lpattern(dot) lwidth(thick)) xtitle("Semana do ano") ytitle("Número de óbitos")

*Gráfico que separa os anos - Com separação de raças
	* Negros
twoway (line morte_causa_ext_ week if ano==1986 & negro == 1, lpattern(solid) lcolor(red) lwidth(medium)) (line morte_causa_ext_ week if ano==1987 & negro == 1, lpattern(dash) lcolor(black) lwidth(medium)) (line morte_causa_ext_ week if ano==1988 & negro == 1, lpattern(dot) lcolor(black) lwidth(thick)), xlabel(0(2)52) legend(order(1 "1986" 2 "1987" 3 "1988")) xtitle("Semana do ano") ytitle("Número de óbitos") xlabel(, nogrid) xline(32, lcolor(red) lpattern(dot) lwidth(thick))
	* Não negros
twoway (line morte_causa_ext_ week if ano==1986 & negro == 0, lpattern(solid) lcolor(red) lwidth(medium)) (line morte_causa_ext_ week if ano==1987 & negro == 0, lpattern(dash) lcolor(black) lwidth(medium)) (line morte_causa_ext_ week if ano==1988 & negro == 0, lpattern(dot) lcolor(black) lwidth(thick)), xlabel(0(2)52) legend(order(1 "1986" 2 "1987" 3 "1988")) xtitle("Semana do ano") ytitle("Número de óbitos") xlabel(, nogrid) xline(32, lcolor(red) lpattern(dot) lwidth(thick))

* Óbitos por Intervenções Legais

use Base_completa_long.dta, clear

collapse (sum) morte_int_leg_, by(week_cont ano week)

*Gráfico sequencial - Sem separação de raças

	* Período completo
twoway (line morte_int_leg_ week_cont if week_cont <= 52, lwidth(medium) lcolor(black)) (line morte_int_leg_ week_cont if week_cont > 52 & week_cont <= 105, lwidth(medium) lcolor(red) lpattern(solid)) (line morte_int_leg_ week_cont if week_cont > 105, lwidth(medium) lcolor(gray) lpattern(solid)), xtitle("Semanas") ytitle("Número de Óbitos") legend(order(1 "1986" 2 "1987" 3 "1988")) xlabel(, nogrid) xline(53, lcolor(black) lwidth(medium) lpattern(dash)) xline(105, lcolor(black) lwidth(medium) lpattern(dash)) xline(136, lcolor(red) lpattern(dot) lwidth(thick))

	* 10 semanas antes do lançamento - 10 semanas depois
twoway line morte_int_leg_ week if week >= 22 & week <= 43 & ano == 1988, lcolor(black) lpattern(solid) lwidth(thin) xlabel(22(2)44) xlabel(, nogrid) xline(32, lcolor(red) lpattern(dot) lwidth(thick)) xtitle("Semana do ano") ytitle("Número de óbitos")

*Gráfico que separa os anos - Sem separação de raças
twoway (line morte_int_leg_ week if ano==1986, lpattern(solid) lcolor(red) lwidth(medium)) (line morte_int_leg_ week if ano==1987, lpattern(dash) lcolor(black) lwidth(medium)) (line morte_int_leg_ week if ano==1988, lpattern(dot) lcolor(black) lwidth(thick)), xlabel(0(2)52) legend(order(1 "1986" 2 "1987" 3 "1988")) xtitle("Semana do ano") ytitle("Número de óbitos") xlabel(, nogrid) xline(32, lcolor(red) lpattern(dot) lwidth(thick))

*Gráfico sequencial - Com separação de raças
use Base_completa_long.dta, clear

collapse (sum) morte_int_leg_, by(week_cont ano week negro)

	* Período Completo - Negros
twoway (line morte_int_leg_ week_cont if week_cont <= 52 & negro == 1, lwidth(medium) lcolor(black)) (line morte_int_leg_ week_cont if week_cont > 52 & week_cont <= 105 & negro == 1, lwidth(medium) lcolor(red) lpattern(solid)) (line morte_int_leg_ week_cont if week_cont > 105 & negro == 1, lwidth(medium) lcolor(gray) lpattern(solid)), xtitle("Semanas") ytitle("Número de Óbitos") legend(order(1 "1986" 2 "1987" 3 "1988")) xlabel(, nogrid) xline(53, lcolor(black) lwidth(medium) lpattern(dash)) xline(105, lcolor(black) lwidth(medium) lpattern(dash)) xline(136, lcolor(red) lpattern(dot) lwidth(thick))

	* Período Completo - Não negros
twoway (line morte_int_leg_ week_cont if week_cont <= 52 & negro == 0, lwidth(medium) lcolor(black)) (line morte_int_leg_ week_cont if week_cont > 52 & week_cont <= 105 & negro == 0, lwidth(medium) lcolor(red) lpattern(solid)) (line morte_int_leg_ week_cont if week_cont > 105 & negro == 0, lwidth(medium) lcolor(gray) lpattern(solid)), xtitle("Semanas") ytitle("Número de Óbitos") legend(order(1 "1986" 2 "1987" 3 "1988")) xlabel(, nogrid) xline(53, lcolor(black) lwidth(medium) lpattern(dash)) xline(105, lcolor(black) lwidth(medium) lpattern(dash)) xline(136, lcolor(red) lpattern(dot) lwidth(thick))

	* 10 semanas antes do lançamento - 5 semanas depois - Com separação de raças
		* Negros
twoway line morte_int_leg_ week if week >= 22 & week <= 38 & ano == 1988 & negro == 1, lcolor(black) lpattern(solid) lwidth(thin) xlabel(22(2)40) xlabel(, nogrid) xline(32, lcolor(red) lpattern(dot) lwidth(thick)) xtitle("Semana do ano") ytitle("Número de óbitos")
		* Não Negros
twoway line morte_int_leg_ week if week >= 22 & week <= 38 & ano == 1988 & negro == 0, lcolor(black) lpattern(solid) lwidth(thin) xlabel(22(2)40) xlabel(, nogrid) xline(32, lcolor(red) lpattern(dot) lwidth(thick)) xtitle("Semana do ano") ytitle("Número de óbitos")

*Gráfico que separa os anos - Com separação de raças
	* Negros
twoway (line morte_int_leg_ week if ano==1986 & negro == 1, lpattern(solid) lcolor(red) lwidth(medium)) (line morte_int_leg_ week if ano==1987 & negro == 1, lpattern(dash) lcolor(black) lwidth(medium)) (line morte_int_leg_ week if ano==1988 & negro == 1, lpattern(dot) lcolor(black) lwidth(thick)), xlabel(0(2)52) legend(order(1 "1986" 2 "1987" 3 "1988")) xtitle("Semana do ano") ytitle("Número de óbitos") xlabel(, nogrid) xline(32, lcolor(red) lpattern(dot) lwidth(thick))
	* Não negros
twoway (line morte_int_leg_ week if ano==1986 & negro == 0, lpattern(solid) lcolor(red) lwidth(medium)) (line morte_int_leg_ week if ano==1987 & negro == 0, lpattern(dash) lcolor(black) lwidth(medium)) (line morte_int_leg_ week if ano==1988 & negro == 0, lpattern(dot) lcolor(black) lwidth(thick)), xlabel(0(2)52) legend(order(1 "1986" 2 "1987" 3 "1988")) xtitle("Semana do ano") ytitle("Número de óbitos") xlabel(, nogrid) xline(32, lcolor(red) lpattern(dot) lwidth(thick))


* Óbitos por Homicídios

use Base_completa_long.dta, clear

collapse (sum) morte_homi_, by(week_cont ano week)

*Gráfico sequencial - Sem separação de raças

	* Período completo
twoway (line morte_homi_ week_cont if week_cont <= 52, lwidth(medium) lcolor(black)) (line morte_homi_ week_cont if week_cont > 52 & week_cont <= 105, lwidth(medium) lcolor(red) lpattern(solid)) (line morte_homi_ week_cont if week_cont > 105, lwidth(medium) lcolor(gray) lpattern(solid)), ylabel(80(20)160) xtitle("Semanas") ytitle("Número de Óbitos") legend(order(1 "1986" 2 "1987" 3 "1988")) xlabel(, nogrid) xline(53, lcolor(black) lwidth(medium) lpattern(dash)) xline(105, lcolor(black) lwidth(medium) lpattern(dash)) xline(136, lcolor(red) lpattern(dot) lwidth(thick))

	* 10 semanas antes do lançamento - 10 semanas depois
twoway line morte_homi_ week if week >= 22 & week <= 43 & ano == 1988, lcolor(black) lpattern(solid) lwidth(thin) xlabel(22(2)44) xlabel(, nogrid) xline(32, lcolor(red) lpattern(dot) lwidth(thick)) xtitle("Semana do ano") ytitle("Número de óbitos")

*Gráfico que separa os anos - Sem separação de raças
twoway (line morte_homi_ week if ano==1986, lpattern(solid) lcolor(red) lwidth(medium)) (line morte_homi_ week if ano==1987, lpattern(dash) lcolor(black) lwidth(medium)) (line morte_homi_ week if ano==1988, lpattern(dot) lcolor(black) lwidth(thick)), xlabel(0(2)52) legend(order(1 "1986" 2 "1987" 3 "1988")) xtitle("Semana do ano") ytitle("Número de óbitos") xlabel(, nogrid) xline(32, lcolor(red) lpattern(dot) lwidth(thick))

*Gráfico sequencial - Com separação de raças
use Base_completa_long.dta, clear

collapse (sum) morte_homi_, by(week_cont ano week negro)

	* Período Completo - Negros
twoway (line morte_homi_ week_cont if week_cont <= 52 & negro == 1, lwidth(medium) lcolor(black)) (line morte_homi_ week_cont if week_cont > 52 & week_cont <= 105 & negro == 1, lwidth(medium) lcolor(red) lpattern(solid)) (line morte_homi_ week_cont if week_cont > 105 & negro == 1, lwidth(medium) lcolor(gray) lpattern(solid)), xtitle("Semanas") ytitle("Número de Óbitos") legend(order(1 "1986" 2 "1987" 3 "1988")) xlabel(, nogrid) xline(53, lcolor(black) lwidth(medium) lpattern(dash)) xline(105, lcolor(black) lwidth(medium) lpattern(dash)) xline(136, lcolor(red) lpattern(dot) lwidth(thick))
	* Período Completo - Não negros
twoway (line morte_homi_ week_cont if week_cont <= 52 & negro == 0, lwidth(medium) lcolor(black)) (line morte_homi_ week_cont if week_cont > 52 & week_cont <= 105 & negro == 0, lwidth(medium) lcolor(red) lpattern(solid)) (line morte_homi_ week_cont if week_cont > 105 & negro == 0, lwidth(medium) lcolor(gray) lpattern(solid)), xtitle("Semanas") ytitle("Número de Óbitos") legend(order(1 "1986" 2 "1987" 3 "1988")) xlabel(, nogrid) xline(53, lcolor(black) lwidth(medium) lpattern(dash)) xline(105, lcolor(black) lwidth(medium) lpattern(dash)) xline(136, lcolor(red) lpattern(dot) lwidth(thick))

	* 10 semanas antes do lançamento - 5 semanas depois - Negros
twoway line morte_homi_ week if week >= 22 & week <= 38 & ano == 1988 & negro == 1, lcolor(black) lpattern(solid) lwidth(thin) xlabel(22(2)40) xlabel(, nogrid) xline(32, lcolor(red) lpattern(dot) lwidth(thick)) xtitle("Semana do ano") ytitle("Número de óbitos")
	* 10 semanas antes do lançamento - 5 semanas depois - Não Negros
twoway line morte_homi_ week if week >= 22 & week <= 38 & ano == 1988 & negro == 0, lcolor(black) lpattern(solid) lwidth(thin) xlabel(22(2)40) xlabel(, nogrid) xline(32, lcolor(red) lpattern(dot) lwidth(thick)) xtitle("Semana do ano") ytitle("Número de óbitos")

*Gráfico que separa os anos - Com separação de raças
	* Negros
twoway (line morte_homi_ week if ano==1986 & negro == 1, lpattern(solid) lcolor(red) lwidth(medium)) (line morte_homi_ week if ano==1987 & negro == 1, lpattern(dash) lcolor(black) lwidth(medium)) (line morte_homi_ week if ano==1988 & negro == 1, lpattern(dot) lcolor(black) lwidth(thick)), xlabel(0(2)52) legend(order(1 "1986" 2 "1987" 3 "1988")) xtitle("Semana do ano") ytitle("Número de óbitos") xlabel(, nogrid) xline(32, lcolor(red) lpattern(dot) lwidth(thick))
	* Não Negros
twoway (line morte_homi_ week if ano==1986 & negro == 0, lpattern(solid) lcolor(red) lwidth(medium)) (line morte_homi_ week if ano==1987 & negro == 0, lpattern(dash) lcolor(black) lwidth(medium)) (line morte_homi_ week if ano==1988 & negro == 0, lpattern(dot) lcolor(black) lwidth(thick)), xlabel(0(2)52) legend(order(1 "1986" 2 "1987" 3 "1988")) xtitle("Semana do ano") ytitle("Número de óbitos") xlabel(, nogrid) xline(32, lcolor(red) lpattern(dot) lwidth(thick))

** Estimando o Event Study

use Base_completa_long.dta, clear

*ssc install eventdd
*ssc install matsort

gen morte_int_leg_pc = (morte_int_leg_ / populacao_total) * 100000
gen morte_homi_pc = (morte_homi_ / populacao_total) * 100000
gen obitos_totais_pc = (obitos_totais / populacao_total) * 100000
gen morte_causa_ext_pc = (morte_causa_ext_ / populacao_total) * 100000

gen tempoAteLanc2= tempoAteLanc*negro


* Para mortes por Intervenção Legal
eventdd morte_int_leg_pc ib1.negro i.week i.ano, timevar(tempoAteLanc2) method(hdfe, absorb(i.cod_condado) cluster(cod_condado)) leads(10) lags(5) inrange graph_op(ytitle("Mortes por 100 mil habitantes", size(small)) xtitle("Semanas com base no lançamento do álbum") xlabel(, nogrid) ylabel(-0.015(0.005)0.015)) ci(rcap, color(black)) coef_op(mcolor(red))


* Para mortes por Homicídios
eventdd morte_homi_pc ib1.negro i.week i.ano, timevar(tempoAteLanc2) method(hdfe, absorb(i.cod_condado) cluster(cod_condado)) leads(10) lags(5) inrange graph_op(ytitle("Mortes por 100 mil habitantes", size(small)) xtitle("Semanas com base no lançamento do álbum") xlabel(, nogrid) ylabel(-0.1(0.05)0.1)) ci(rcap, color(black)) coef_op(mcolor(red))

* Para óbitos totais
eventdd obitos_totais_pc ib1.negro i.week i.ano, timevar(tempoAteLanc2) method(hdfe, absorb(i.cod_condado) cluster(cod_condado)) leads(10) lags(5) inrange graph_op(ytitle("Mortes por 100 mil habitantes", size(small)) xtitle("Semanas com base no lançamento do álbum") xlabel(, nogrid)) ci(rcap, color(black)) coef_op(mcolor(red))

* Para mortes por Causas Externas
eventdd morte_causa_ext_pc ib1.negro i.week i.ano, timevar(tempoAteLanc2) method(hdfe, absorb(i.cod_condado) cluster(cod_condado)) leads(10) lags(5) inrange graph_op(ytitle("Mortes por 100 mil habitantes", size(small)) xtitle("Semanas com base no lançamento do álbum") xlabel(, nogrid) ylabel(-0.2(0.1)0.2)) ci(rcap, color(black)) coef_op(mcolor(red))

** Estimando o Pooled Diff-N-Diff

*ssc install reghdfe
*ssc install ftools

* Para mortes por Intervenção Legal


reghdfe morte_int_leg_pc i.negro##i.post if week >= 22 & week <= 43, absorb(cod_condado week_cont ano) vce(cluster cod_condado)

estimates store dnd_int_reg


* Para mortes por homicídio

reghdfe morte_homi_pc i.negro##i.post if week >= 22 & week <= 43, absorb(cod_condado week_cont ano) vce(cluster cod_condado)

estimates store dnd_homi


* Para óbitos totais

reghdfe obitos_totais_pc i.negro##i.post if week >= 22 & week <= 43, absorb(cod_condado week_cont ano) vce(cluster cod_condado)

estimates store dnd_obitos_totais

* Para mortes por causas externas

reghdfe morte_causa_ext_pc i.negro##i.post if week >= 22 & week <= 43, absorb(cod_condado week_cont ano) vce(cluster cod_condado)

estimates store dnd_causas_ext

* Criando tabela de estimação

etable, estimates(dnd_causas_ext dnd_int_reg dnd_homi) showstars showstarsnote export(resultados_dnd.xlsx, replace)


save Base_completa_long.dta, replace

** Fazendo o Event Study e o Pooled Diff-in-Diff para o primeiro single lançado antes do álbum (Lançado em 10 de julho de 1988)

* Criando nova variável para determinar o momento de lançamento do single 

use Base_completa_long.dta, clear

* Semana de lançamento do single: Semana 27 de 1988, e 131 na variável week_cont

* Criar uma variável somente com o número 131
gen lanc_single = 131

* Criar a variável que avalia se a semana é pré ou pós tratamento (lançamento do álbum)
gen post_single = (week_cont >= 131)

* Criar a variável que faz a contagem de tempo até o tratamento ser realizado
gen tempoAteLanc_single = week_cont - lanc_single


save Base_completa_long.dta, replace

** Estimando o Event Study para o single

gen tempoAteLanc_single2= tempoAteLanc_single*negro

* Para mortes por Intervenção Legal
eventdd morte_int_leg_pc ib1.negro i.week i.ano, timevar(tempoAteLanc_single2) method(hdfe, absorb(i.cod_condado) cluster(cod_condado)) leads(10) lags(5) inrange graph_op(ytitle("Mortes por 100 mil habitantes", size(small)) xtitle("Semanas com base no lançamento do single") xlabel(, nogrid) ylabel(-0.015(0.0075)0.015)) ci(rcap, color(black)) coef_op(mcolor(red))


* Para mortes por Homicídios
eventdd morte_homi_pc ib1.negro i.week i.ano, timevar(tempoAteLanc_single2) method(hdfe, absorb(i.cod_condado) cluster(cod_condado)) leads(10) lags(5) inrange graph_op(ytitle("Mortes por 100 mil habitantes", size(small)) xtitle("Semanas com base no lançamento do single") xlabel(, nogrid) ylabel(-0.15(0.075)0.15)) ci(rcap, color(black)) coef_op(mcolor(red))

* Para óbitos totais
eventdd obitos_totais_pc ib1.negro i.week i.ano, timevar(tempoAteLanc_single2) method(hdfe, absorb(i.cod_condado) cluster(cod_condado)) leads(10) lags(5) inrange graph_op(ytitle("Mortes por 100 mil habitantes", size(small)) xtitle("Semanas com base no lançamento do single") xlabel(, nogrid)) ci(rcap, color(black)) coef_op(mcolor(red))

* Para mortes por causas externas
eventdd morte_causa_ext_pc ib1.negro i.week i.ano, timevar(tempoAteLanc_single2) method(hdfe, absorb(i.cod_condado) cluster(cod_condado)) leads(10) lags(5) inrange graph_op(ytitle("Mortes por 100 mil habitantes", size(small)) xtitle("Semanas com base no lançamento do single") xlabel(, nogrid) ylabel(-0.3(0.15)0.3)) ci(rcap, color(black)) coef_op(mcolor(red))

** Estimando o Pooled Diff-N-Diff

* Para mortes por Intervenção Legal
reghdfe morte_int_leg_pc i.negro##i.post_single if week >= 17 & week <= 38, absorb(cod_condado week_cont ano) vce(cluster cod_condado)

estimates store dnd_int_reg_single


* Para mortes por Homicídio
reghdfe morte_homi_pc i.negro##i.post_single if week >= 17 & week <= 38, absorb(cod_condado week_cont ano) vce(cluster cod_condado)

estimates store dnd_homi_single


* Para óbitos totais
reghdfe obitos_totais_pc i.negro##i.post_single if week >= 17 & week <= 38, absorb(cod_condado week_cont ano) vce(cluster cod_condado)

estimates store dnd_obitos_totais_single

* Para mortes por causa externa
reghdfe morte_causa_ext_pc i.negro##i.post_single if week >= 17 & week <= 38, absorb(cod_condado week_cont ano) vce(cluster cod_condado)

estimates store dnd_causas_ext_single

* Criando tabela de estimação
etable, estimates(dnd_causas_ext_single dnd_int_reg_single dnd_homi_single) showstars showstarsnote export(resultados_dnd_single.xlsx, replace)

save Base_completa_long.dta, replace

** Gráficos da progressão do número de mortes em relação ao single

* Óbitos Totais

** Abrindo a tabela intermediária
use Mortes_Completa_CORRIGIDA_Stata.dta, clear

collapse (sum) um, by(ano week racar3)

destring ano, replace

* 10 semanas antes do lançamento - 5 semanas depois do lançamento do single - Negros

twoway line um week if week >= 17 & week <= 31 & ano == 1988 & racar3 == 3, lcolor(black) lpattern(solid) lwidth(thin) xlabel(16(2)32) xlabel(, nogrid) xline(27, lcolor(red) lpattern(dot) lwidth(thick)) xtitle("Semana do ano") ytitle("Número de óbitos")


* 10 semanas antes do lançamento - 5 semanas depois do lançamento do single - Não Negros

use Mortes_Completa_CORRIGIDA_Stata.dta, clear

keep if racar3 == 1 | racar3 == 2

collapse (sum) um, by(week ano)

destring ano, replace

twoway line um week if week >= 17 & week <= 31 & ano == 1988, lcolor(black) lpattern(solid) lwidth(thin) xlabel(16(2)32) xlabel(, nogrid) xline(27, lcolor(red) lpattern(dot) lwidth(thick)) xtitle("Semana do ano") ytitle("Número de óbitos")

* Causas Externas

use Base_completa_long.dta, clear

collapse (sum) morte_causa_ext_, by(week_cont ano week negro)

* 10 semanas antes do lançamento - 5 semanas depois - Com separação de raças
		
		* Negros
twoway line morte_causa_ext_ week if week >= 17 & week <= 31 & ano == 1988 & negro == 1, lcolor(black) lpattern(solid) lwidth(thin) xlabel(16(2)32) xlabel(, nogrid) xline(27, lcolor(red) lpattern(dot) lwidth(thick)) xtitle("Semana do ano") ytitle("Número de óbitos")
		
		* Não Negros
twoway line morte_causa_ext_ week if week >= 17 & week <= 31 & ano == 1988 & negro == 0, lcolor(black) lpattern(solid) lwidth(thin) xlabel(16(2)32) xlabel(, nogrid) xline(27, lcolor(red) lpattern(dot) lwidth(thick)) xtitle("Semana do ano") ytitle("Número de óbitos")

* Intervenção Legal

use Base_completa_long.dta, clear

collapse (sum) morte_int_leg_, by(week_cont ano week negro)

* 10 semanas antes do lançamento - 5 semanas depois - Com separação de raças
		
		* Negros
twoway line morte_int_leg_ week if week >= 17 & week <= 31 & ano == 1988 & negro == 1, lcolor(black) lpattern(solid) lwidth(thin) xlabel(16(2)32) xlabel(, nogrid) xline(27, lcolor(red) lpattern(dot) lwidth(thick)) xtitle("Semana do ano") ytitle("Número de óbitos")
		
		* Não Negros
twoway line morte_int_leg_ week if week >= 17 & week <= 31 & ano == 1988 & negro == 0, lcolor(black) lpattern(solid) lwidth(thin) xlabel(16(2)32) xlabel(, nogrid) xline(27, lcolor(red) lpattern(dot) lwidth(thick)) xtitle("Semana do ano") ytitle("Número de óbitos")

* Homicídios

use Base_completa_long.dta, clear

collapse (sum) morte_homi_, by(week_cont ano week negro)

* 10 semanas antes do lançamento - 5 semanas depois - Negros
twoway line morte_homi_ week if week >= 17 & week <= 31 & ano == 1988 & negro == 1, lcolor(black) lpattern(solid) lwidth(thin) xlabel(16(2)32) xlabel(, nogrid) xline(27, lcolor(red) lpattern(dot) lwidth(thick)) xtitle("Semana do ano") ytitle("Número de óbitos")
	
* 10 semanas antes do lançamento - 5 semanas depois - Não Negros
twoway line morte_homi_ week if week >= 17 & week <= 31 & ano == 1988 & negro == 0, lcolor(black) lpattern(solid) lwidth(thin) xlabel(16(2)32) xlabel(, nogrid) xline(27, lcolor(red) lpattern(dot) lwidth(thick)) xtitle("Semana do ano") ytitle("Número de óbitos")

** Fazendo o Event Study e o Pooled Diff-in-Diff para o segundo single lançado antes do álbum (Lançado em 10 de julho de 1988)

* Criando nova variável para determinar o momento de lançamento do single 

use Base_completa_long.dta, clear

* Semana de lançamento do álbum: Semana 36 de 1988, e 140 na variável week_cont

* Criar uma variável somente com o número 140
gen lanc_single_2 = 140

* Criar a variável que avalia se a semana é pré ou pós tratamento (lançamento do álbum)
gen post_single_2 = (week_cont >= 140)

* Criar a variável que faz a contagem de tempo até o tratamento ser realizado
gen tempoAteLanc_single_2 = week_cont - lanc_single_2


save Base_completa_long.dta, replace

** Estimando o Event Study para o single

gen tempoAteLanc_single2_2= tempoAteLanc_single_2*negro

* Para mortes por Intervenção Legal
eventdd morte_int_leg_pc ib1.negro i.week i.ano, timevar(tempoAteLanc_single2_2) method(hdfe, absorb(i.cod_condado) cluster(cod_condado)) leads(10) lags(5) inrange graph_op(ytitle("Mortes por 100 mil habitantes", size(small)) xtitle("Semanas com base no lançamento do single") xlabel(, nogrid) ylabel(-0.02(0.01)0.02)) ci(rcap, color(black)) coef_op(mcolor(red))


* Para mortes por Homicídios
eventdd morte_homi_pc ib1.negro i.week i.ano, timevar(tempoAteLanc_single2_2) method(hdfe, absorb(i.cod_condado) cluster(cod_condado)) leads(10) lags(5) inrange graph_op(ytitle("Mortes por 100 mil habitantes", size(small)) xtitle("Semanas com base no lançamento do single") xlabel(, nogrid) ylabel(-0.15(0.075)0.15)) ci(rcap, color(black)) coef_op(mcolor(red))

* Para óbitos totais
eventdd obitos_totais_pc ib1.negro i.week i.ano, timevar(tempoAteLanc_single2_2) method(hdfe, absorb(i.cod_condado) cluster(cod_condado)) leads(10) lags(5) inrange graph_op(ytitle("Mortes por 100 mil habitantes", size(small)) xtitle("Semanas com base no lançamento do single") xlabel(, nogrid)) ci(rcap, color(black)) coef_op(mcolor(red))

* Para causas externas
eventdd morte_causa_ext_pc ib1.negro i.week i.ano, timevar(tempoAteLanc_single2_2) method(hdfe, absorb(i.cod_condado) cluster(cod_condado)) leads(10) lags(5) inrange graph_op(ytitle("Mortes por 100 mil habitantes", size(small)) xtitle("Semanas com base no lançamento do single") xlabel(, nogrid) ylabel(-0.3(0.15)0.3)) ci(rcap, color(black)) coef_op(mcolor(red))

** Estimando o Pooled Diff-N-Diff

* Para mortes por Intervenção Legal
reghdfe morte_int_leg_pc i.negro##i.post_single_2 if week >= 26 & week <= 47, absorb(cod_condado week_cont ano) vce(cluster cod_condado)

estimates store dnd_int_reg_single_2


* Para mortes por homicídio
reghdfe morte_homi_pc i.negro##i.post_single_2 if week >= 26 & week <= 47, absorb(cod_condado week_cont ano) vce(cluster cod_condado)

estimates store dnd_homi_single_2


* Para óbitos totais
reghdfe obitos_totais_pc i.negro##i.post_single_2 if week >= 26 & week <= 47, absorb(cod_condado week_cont ano) vce(cluster cod_condado)

* Para causas externas
reghdfe morte_causa_ext_pc i.negro##i.post_single_2 if week >= 26 & week <= 47, absorb(cod_condado week_cont ano) vce(cluster cod_condado)

estimates store dnd_causa_ext_single_2

* Criando tabela de estimação
etable, estimates(dnd_causa_ext_single_2 dnd_int_reg_single_2 dnd_homi_single_2) showstars showstarsnote export(resultados_dnd_single_2.xlsx, replace)

save Base_completa_long.dta, replace

** Gráficos da progressão do número de mortes em relação ao single

* Óbitos Totais

** Abrindo a tabela intermediária
use Mortes_Completa_CORRIGIDA_Stata.dta, clear

collapse (sum) um, by(ano week racar3)

destring ano, replace

* 10 semanas antes do lançamento - 5 semanas depois do lançamento do single - Negros

twoway line um week if week >= 26 & week <= 42 & ano == 1988 & racar3 == 3, lcolor(black) lpattern(solid) lwidth(thin) xlabel(24(2)44) xlabel(, nogrid) xline(36, lcolor(red) lpattern(dot) lwidth(thick)) xtitle("Semana do ano") ytitle("Número de óbitos")


* 10 semanas antes do lançamento - 5 semanas depois do lançamento do single - Não Negros

use Mortes_Completa_CORRIGIDA_Stata.dta, clear

keep if racar3 == 1 | racar3 == 2

collapse (sum) um, by(week ano)

destring ano, replace

twoway line um week if week >= 26 & week <= 42 & ano == 1988, lcolor(black) lpattern(solid) lwidth(thin) xlabel(24(2)44) xlabel(, nogrid) xline(36, lcolor(red) lpattern(dot) lwidth(thick)) xtitle("Semana do ano") ytitle("Número de óbitos")

* Causas Externas

use Base_completa_long.dta, clear

collapse (sum) morte_causa_ext_, by(week_cont ano week negro)

* 10 semanas antes do lançamento - 5 semanas depois - Com separação de raças
		
		* Negros
twoway line morte_causa_ext_ week if week >= 26 & week <= 42 & ano == 1988 & negro == 1, lcolor(black) lpattern(solid) lwidth(thin) xlabel(24(2)44) xlabel(, nogrid) xline(36, lcolor(red) lpattern(dot) lwidth(thick)) xtitle("Semana do ano") ytitle("Número de óbitos")
		
		* Não Negros
twoway line morte_causa_ext_ week if week >= 26 & week <= 42 & ano == 1988 & negro == 0, lcolor(black) lpattern(solid) lwidth(thin) xlabel(24(2)44) xlabel(, nogrid) xline(36, lcolor(red) lpattern(dot) lwidth(thick)) xtitle("Semana do ano") ytitle("Número de óbitos")

* Intervenção Legal

use Base_completa_long.dta, clear

collapse (sum) morte_int_leg_, by(week_cont ano week negro)

* 10 semanas antes do lançamento - 5 semanas depois - Com separação de raças
		
		* Negros
twoway line morte_int_leg_ week if week >= 26 & week <= 42 & ano == 1988 & negro == 1, lcolor(black) lpattern(solid) lwidth(thin) xlabel(24(2)44) xlabel(, nogrid) xline(36, lcolor(red) lpattern(dot) lwidth(thick)) xtitle("Semana do ano") ytitle("Número de óbitos")
		
		* Não Negros
twoway line morte_int_leg_ week if week >= 26 & week <= 42 & ano == 1988 & negro == 0, lcolor(black) lpattern(solid) lwidth(thin) xlabel(24(2)44) xlabel(, nogrid) xline(36, lcolor(red) lpattern(dot) lwidth(thick)) xtitle("Semana do ano") ytitle("Número de óbitos")

* Homicídios

use Base_completa_long.dta, clear

collapse (sum) morte_homi_, by(week_cont ano week negro)

* 10 semanas antes do lançamento - 5 semanas depois - Negros
twoway line morte_homi_ week if week >= 26 & week <= 42 & ano == 1988 & negro == 1, lcolor(black) lpattern(solid) lwidth(thin) xlabel(24(2)44) xlabel(, nogrid) xline(36, lcolor(red) lpattern(dot) lwidth(thick)) xtitle("Semana do ano") ytitle("Número de óbitos")
	
* 10 semanas antes do lançamento - 5 semanas depois - Não Negros
twoway line morte_homi_ week if week >= 26 & week <= 42 & ano == 1988 & negro == 0, lcolor(black) lpattern(solid) lwidth(thin) xlabel(24(2)44) xlabel(, nogrid) xline(36, lcolor(red) lpattern(dot) lwidth(thick)) xtitle("Semana do ano") ytitle("Número de óbitos")

** Fazer um mapa de calor sobre os condados e as proporções de indivíduos negros sobre a população total do condado

grmap, activate

* Criando uma base para cada ano com ano, código do condado e as proporções de tipos de indivíduos

use Base_completa_long.dta, clear

gen um = 1

collapse (sum) um, by(ano cod_condado prop_white_male prop_white_female prop_black_male prop_black_female)

drop um

save Base_prop.dta, replace

	* 1986

use Base_prop.dta, clear

keep if ano == 1986

merge 1:1 cod_condado using Intermediária_86.dta

drop if _merge == 1

drop _merge

save Base_prop_1986.dta, replace

	* 1987

use Base_prop.dta, clear

keep if ano == 1987

merge 1:1 cod_condado using Intermediária_87.dta

drop if _merge == 1

drop _merge

save Base_prop_1987.dta, replace

	* 1988

use Base_prop.dta, clear

keep if ano == 1988

merge 1:1 cod_condado using Intermediária_88.dta

drop if _merge == 1

drop _merge

save Base_prop_1988.dta, replace

* Renomear coluna da base com as informações dos condados
	*use condados.dta, clear
	*rename cod_condado cod_condado2
	*save condados.dta, replace

* Fazer o merge da base com as infos e as bases com as proporções, e fazer o mapa

	* 1986
	
use Base_prop_1986.dta, clear

merge 1:1 cod_condado2 using condados.dta

drop if _ID == .

grmap prop_black_male, clmethod(custom) clbreaks(0 0.05 0.1 0.15 0.20 0.25 0.30 0.35 0.40) fcolor(red*0.1 red*0.2 red*0.3 red*0.4 red*0.5 red*0.6 red*0.7 red*0.8)

	* 1987

use Base_prop_1987.dta, clear

merge 1:1 cod_condado2 using condados.dta

drop if _ID == .

grmap prop_black_male, clmethod(custom) clbreaks(0 0.05 0.1 0.15 0.20 0.25 0.30 0.35 0.40) fcolor(red*0.1 red*0.2 red*0.3 red*0.4 red*0.5 red*0.6 red*0.7 red*0.8)

	* 1988

use Base_prop_1988.dta, clear

merge 1:1 cod_condado2 using condados.dta

drop if _ID == .

grmap prop_black_male, clmethod(custom) clbreaks(0 0.05 0.1 0.15 0.20 0.25 0.30 0.35 0.40) fcolor(red*0.1 red*0.2 red*0.3 red*0.4 red*0.5 red*0.6 red*0.7 red*0.8)


** Achar a mediana da proporção de indivíduos negros em relação à população de condados, e realizar o event study para os indivíduos em condados ACIMA da mediana

use Base_completa_long, clear

summarize prop_black_male, detail
* Mediana da proporção: 0.0081

gen acima_mediana_prop = prop_black_male > 0.0081

keep if acima_mediana_prop == 1

save Base_completa_long_mediana, replace

** Event Study para o álbum

use Base_completa_long_mediana, clear

* Para mortes por Intervenção Legal
eventdd morte_int_leg_pc ib1.negro i.week i.ano, timevar(tempoAteLanc2) method(hdfe, absorb(i.cod_condado) cluster(cod_condado)) leads(10) lags(5) inrange graph_op(ytitle("Mortes por 100 mil habitantes", size(small)) xtitle("Semanas com base no lançamento do álbum") xlabel(, nogrid) ylabel(-0.03(0.015)0.03)) ci(rcap, color(black)) coef_op(mcolor(red))


* Para mortes por Homicídios
eventdd morte_homi_pc ib1.negro i.week i.ano, timevar(tempoAteLanc2) method(hdfe, absorb(i.cod_condado) cluster(cod_condado)) leads(10) lags(5) inrange graph_op(ytitle("Mortes por 100 mil habitantes", size(small)) xtitle("Semanas com base no lançamento do álbum") xlabel(, nogrid) ylabel(-0.2(0.1)0.2)) ci(rcap, color(black)) coef_op(mcolor(red))

* Para óbitos totais
eventdd obitos_totais_pc ib1.negro i.week i.ano, timevar(tempoAteLanc2) method(hdfe, absorb(i.cod_condado) cluster(cod_condado)) leads(10) lags(5) inrange graph_op(ytitle("Mortes por 100 mil habitantes", size(small)) xtitle("Semanas com base no lançamento do álbum") xlabel(, nogrid)) ci(rcap, color(black)) coef_op(mcolor(red))

* Para causas externas
eventdd morte_causa_ext_pc ib1.negro i.week i.ano, timevar(tempoAteLanc2) method(hdfe, absorb(i.cod_condado) cluster(cod_condado)) leads(10) lags(5) inrange graph_op(ytitle("Mortes por 100 mil habitantes", size(small)) xtitle("Semanas com base no lançamento do álbum") xlabel(, nogrid) ylabel(-0.3(0.15)0.3)) ci(rcap, color(black)) coef_op(mcolor(red))


** Event Study para o primeiro single

* Para mortes por Intervenção Legal
eventdd morte_int_leg_pc ib1.negro i.week i.ano, timevar(tempoAteLanc_single2) method(hdfe, absorb(i.cod_condado) cluster(cod_condado)) leads(10) lags(5) inrange graph_op(ytitle("Mortes por 100 mil habitantes", size(small)) xtitle("Semanas com base no lançamento do single") xlabel(, nogrid) ylabel(-0.02(0.01)0.02)) ci(rcap, color(black)) coef_op(mcolor(red))


* Para mortes por Homicídios
eventdd morte_homi_pc ib1.negro i.week i.ano, timevar(tempoAteLanc_single2) method(hdfe, absorb(i.cod_condado) cluster(cod_condado)) leads(10) lags(5) inrange graph_op(ytitle("Mortes por 100 mil habitantes", size(small)) xtitle("Semanas com base no lançamento do single") xlabel(, nogrid) ylabel(-0.2(0.1)0.2)) ci(rcap, color(black)) coef_op(mcolor(red))

* Para óbitos totais
eventdd obitos_totais_pc ib1.negro i.week i.ano, timevar(tempoAteLanc_single2) method(hdfe, absorb(i.cod_condado) cluster(cod_condado)) leads(10) lags(5) inrange graph_op(ytitle("Mortes por 100 mil habitantes", size(small)) xtitle("Semanas com base no lançamento do single") xlabel(, nogrid)) ci(rcap, color(black)) coef_op(mcolor(red))

* Para Causas Externas
eventdd morte_causa_ext_pc ib1.negro i.week i.ano, timevar(tempoAteLanc_single2) method(hdfe, absorb(i.cod_condado) cluster(cod_condado)) leads(10) lags(5) inrange graph_op(ytitle("Mortes por 100 mil habitantes", size(small)) xtitle("Semanas com base no lançamento do single") xlabel(, nogrid) ylabel(-0.3(0.15)0.3)) ci(rcap, color(black)) coef_op(mcolor(red))

** Event Study para o segundo single

* Para mortes por Intervenção Legal
eventdd morte_int_leg_pc ib1.negro i.week i.ano, timevar(tempoAteLanc_single2_2) method(hdfe, absorb(i.cod_condado) cluster(cod_condado)) leads(10) lags(5) inrange graph_op(ytitle("Mortes por 100 mil habitantes", size(small)) xtitle("Semanas com base no lançamento do single") xlabel(, nogrid) ylabel(-0.03(0.015)0.03)) ci(rcap, color(black)) coef_op(mcolor(red))


* Para mortes por Homicídios
eventdd morte_homi_pc ib1.negro i.week i.ano, timevar(tempoAteLanc_single2_2) method(hdfe, absorb(i.cod_condado) cluster(cod_condado)) leads(10) lags(5) inrange graph_op(ytitle("Mortes por 100 mil habitantes", size(small)) xtitle("Semanas com base no lançamento do single") xlabel(, nogrid) ylabel(-0.2(0.1)0.2)) ci(rcap, color(black)) coef_op(mcolor(red))

* Para óbitos totais
eventdd obitos_totais_pc ib1.negro i.week i.ano, timevar(tempoAteLanc_single2_2) method(hdfe, absorb(i.cod_condado) cluster(cod_condado)) leads(10) lags(5) inrange graph_op(ytitle("Mortes por 100 mil habitantes", size(small)) xtitle("Semanas com base no lançamento do single") xlabel(, nogrid)) ci(rcap, color(black)) coef_op(mcolor(red))

* Para causas externas
eventdd morte_causa_ext_ ib1.negro i.week i.ano, timevar(tempoAteLanc_single2_2) method(hdfe, absorb(i.cod_condado) cluster(cod_condado)) leads(10) lags(5) inrange graph_op(ytitle("Mortes por 100 mil habitantes", size(small)) xtitle("Semanas com base no lançamento do single") xlabel(, nogrid) ylabel(-0.2(0.1)0.2)) ci(rcap, color(black)) coef_op(mcolor(red))

** Número de condados: 3135
** Número de semanas: 52
** Número de anos: 3
** Número de observações: 489060
