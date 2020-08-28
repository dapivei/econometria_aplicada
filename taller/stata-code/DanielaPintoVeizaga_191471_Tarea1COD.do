/*=================================================================

DO-FILE TAREA 01-TALLER DE ECONOMETRÍA

Elaborado por Daniela Pinto Veizaga
			
==================================================================*/

* Set up del ambiente

clear
*log using DanielaPintoVeizaga_191471_Tarea1RES.log, replace
cd "."
import excel "Bonos.xlsx", sheet("Sheet1") firstrow clear
save Bonos, replace
ds
summarize
describe using Bonos

/* ++++++++++++++++++++++++++++++++++++++++++
			EJERCICIO 1
++++++++++++++++++++++++++++++++++++++++++ */


*1.a. Explorar los datos. ¿Qué variables tienen el formato incorrecto (i.e. son string cuando deberían ser numéricas)? 


** rate((string->numérica), 
** spread(string->numérica), 
** amt(string->numérica),
** arbitration(str1-> byte),

* Verificación de los tipos de todas las variables en la bd
ds, has(type string)
*edit `r(varlist)'
summarize `r(varlist)'
ds, has(type 1/100)
ds, has(type byte)
ds, has(type int)
ds, has(type double)

ds
browse
ds, has(type 1/100)

* 1.b. Modificar el formato de las variables para que tengan el formato correcto.

global string_variable obs maturity spread issuerc jur listing law secured quorum reverseacc 


** Cambiar espacios en blanco a missing values
ds,has (type string)
foreach var in `r(varlist)' {
    replace `var' = "." if `var' == ""
}

** Tabular las variables string
ds,has (type string)
foreach var in `r(varlist)' {
    tab `var'
}

** Procedure before changing variable types

tab spread if missing(real(spread))
tab amt if missing(real(amt))
tab arbitration if missing(real(arbitration))


destring arbitration, replace


global wrong_type arbitration

foreach var in `wrong_type' {
	destring `var', replace
}


foreach i of varlist rate spread amt arbitration {
	destring `i', replace
	describe `i'
}

* 1.c. Mantener en la base de datos únicamente las siguientes variables:


keep year spread aaa aa a bb b num_lawyers rep_ic_size curr law rep_ic_top2 //
rep_ic_top2_ny rep_ic_top2_eng lnamt years highrate2 hh_index_ib hh_index_ib_eng //
hh_index_ib_ny 

* 1.d. Mantener las observaciones que son posteriores (incluyendo) al año 1947 (variable year).

keep if year > 1946

* 1.e. Realizar un análisis descriptivo y resumir los principales hallazgos.
ds
describe 


* Creates a list of all vars that match previous criterias
global allvars year spread aaa aa a bb b num_lawyers rep_ic_size curr law rep_ic_top2 rep_ic_top2_ny rep_ic_top2_eng lnamt years highrate2 hh_index_ib hh_index_ib_eng hh_index_ib_ny

foreach var in `allvars' {
	tab `var'
}
describe `allvars'

* Chequeamos las variables string, para excluirlas del anális de tabstat

ds, has(type string)



* Descripción de variables numéricas

ds,has (type int double byte)
tabstat `r(varlist)' , s(mean, median, sd, var, count, range, min, max)

* Estadísticas descriptivas por subgrupos, podemos hacerlo por cada string que tenemos
tabstat year aaa aa a bb b num_lawyers rep_ic_size rep_ic_top2 rep_ic_top2_ny rep_ic_top2_eng lnamt years highrate2 hh_index_ib hh_index_ib_eng hh_index_ib_ny, s(mean, median, sd, var, count, range, min, max) by (curr)
* Estadísticas descriptivas de más variables
bysort var3: tab var1 var2, sum(var4)



/* ++++++++++++++++++++++++++++++++++++++++++
			EJERCICIO 2
++++++++++++++++++++++++++++++++++++++++++ */

* Realizar un merge entre “Bonos.dta” y “Bonos2.xlsx” para tener la información en una única base de datos.
 
import excel "Bonos2.xlsx", sheet("Sheet1") firstrow clear
save Bonos2, replace
ds

obs           issuer        maturity      years         gdpgrowth     ratioofsho~t  ratioofdom~p  debtresche~r  standardde~2
issuer_1      issuedate     year          debtservic~s  standardde~h  reservessh~t  ratioofres~s  ratioofres~p


obs           aaa           secured       acceleration  revacc50      cac_change~e  timeindcac~x  ratioofdom~p  english_hi~e  rep_ibc_si~y  spread1       rep_ib~5_eng
issuer_1      aa            othernotes    reverseacc    revacc66      pp_chagela~t  var122        ratioofres~s  dummy_acce~s  rep_ibc_s~y2  spread2       all_two_rep
issuer        a             aggregation   notecommi~ee  revacc75      pp_chagela~1  timeindc~80s  debtresche~r  highrate2     rep_ib_siz~y  spread3       all_one_zero
issuedate     bb            quorum        newunanimit   pp_change     pp_chagela~2  timeindc~90s  ratioofres~p  issuerccha~e  rep_ib_si~y2  spread4       all_option~p
maturity      b             qpost         disenfranch   pp_mandato~e  pp_chage~80s  timeindc~00s  standardde~2  ibcchange     rep_ic_siz~g  changeibank2  ny_two_rep
year          issuerc       paymentvote   disenfexce~s  pp_dateof~ge  pp_chage~90s  change_iss~c  dummy_nylaw   trend_icibc   rep_ic_si~g2  var206        ny_one_zero
years         ibc           lowervotei~g  npledge       pp_currenc~e  pp_chage~00s  change_ibc    dummy_englaw  num_lawyers2  rep_ibc_si~g  var207        ny_options~p
rate          ibank         othervote     npnarrow      npnarrow_c~e  cac_chagel~o  change_ibank  dummy_germ~w  var168        rep_ibc_s~g2  var208        eng_two_rep
curr          reg           sovimm        npexcep       accelerati~e  cac_chagel~1  voice_accon   dummy_othe~w  ratingorder   rep_ib_siz~g  var209        eng_one_zero
bunddm        shelf         siexcept      pp            reverseacc~e  cac_chagel~2  political_~y  dummy_p~2003  ratingorde~m  rep_ib_si~g2  rep_ic_top2   eng_option~p
spreaddm      cac           immexe        pp_mandato~n  notecommi~ge  cac_chag~80s  government~c  dummy_acc_~s  rep_ic_al     hh_index_ic   rep_ic_~2_ny  cleary_sc_~l
var12         v100100       secregexe     pp_dateof~ue  newunanimi~e  cac_chag~90s  regulatory    dummy_reva~s  rep_ibc_al    hh_ind~ic_ny  rep_ic~2_eng  cleary_sc_ny
treasury      v10050        bank          pp_currenc~t  disenfranc~e  cac_chag~00s  rulelaw       dummy_trus~e  rep_ic_size   hh_in~ic_eng  rep_ibc_top2  cleary_sc_~g
spreaddol     v7550         minmodvote    ppnote        minmodvote~e  timeindpp_~o  control_corr  dummy_lawy~s  rep_ic_size2  hh_index_ibc  rep_ibc~2_ny
spread        jur           trustee       splitlaw      trustee_ch~e  timeindpp_~i  debtgnp       dummy_euro    rep_ibc_size  hh_ind~bc_ny  rep_ib~2_eng
amt           listing       agent         pp5           mandmeet_c~e  var116        debtservic~s  dummy_pound   rep_ibc_s~e2  hh_in~bc_eng  rep_ic_top5
lnamt         arbitration   graceprinci   pp1           cac_change    timeindp~80s  gdpgrowth     bbb           rep_ib_size   hh_index_ib   rep_ic_~5_ny
sp            law           graceinter~t  pp10          missppcomp    timeindp~90s  standardde~h  dummy_usdo~r  rep_ib_size2  hh_inde~b_ny  rep_ic~5_eng
highrate      mandmeet      graceother    acc10         misscaccomp   timeindp~00s  ratioofsho~t  chenge_rat~p  rep_ic_siz~y  hh_ind~b_eng  rep_ibc_top5
lowrate       sinkingfund   imf           acc25         pp_chagela~e  timeindcac~i  reservessh~t  ny_highrate   rep_ic_si~y2  multilogit~s  rep_ibc~5_ny

* Clean Bonos2
use Bonos2, clear
ds,has (type string)
foreach var in `r(varlist)' {
    replace `var' = "." if `var' == ""
	replace `var'  = lower(`var' )

}



ds,has (type 1/100)
foreach var in `r(varlist)' {
    replace `var' = "." if `var' == "&&"
}



* Change strings to numeric
destring reservessh~t standardde~h, replace

* Change to date format
use http://www.ssc.wisc.edu/sscc/pubs/files/dates.dta
*ssc install todate
todate maturity,generate(maturity_date) p(mmddyy) c(2000) f(%dd_m_cy)

 todate d1 d2 d3, gen(ndate1-ndate3) p(yyyymmdd) f(%dd_m_cy)




cf _all using Bonos, verbose

merge 1:1  obs issuer issuer_1 issuedate maturity year years gdpgrowth using Bonos

merge 1:1  obs issuer issuer_1 issuedate year years gdpgrowth ratioofsho~t ratioofdom~p ratioofres~p standardde~2 debtresche~r ratioofres~s reservessh~t debtservic~s standardde~h using Bonos

/* ++++++++++++++++++++++++++++++++++++++++++
			EJERCICIO 3
++++++++++++++++++++++++++++++++++++++++++ */


* A través de gráficos (a elección, al menos 3 distintos tipos) realizar un análisis descriptivo, que nos permita determinar relaciones. Contestar: ¿Cuáles son las principales conclusiones?


* EJERCICIO 4: Regresión simple

* 4.a. Generar las siguientes variables: 

i. num_lawyers_2: es 1 si num_lawyers2==2 y es 0 cuando num_lawyers2==1 (el resto de los casos es cero. HINT: cuidado con las variables omitidas).

ii. num_lawyers_0: es 1 si num_lawyers2==0 y es 0 cuando num_lawyers2==1 o num_lawyers2=2 (el resto de los casos es cero. HINT: cuidado con las variables omitidas).
**iii. Reemplazar rep_ic_size con cero si num_lawyers2=0.
replace rep_ic_size = 0 if num_lawyers_2==0

* 4.b. Resultados: correr las siguientes regresiones
i. Variable dependiente: spread; Variables independientes: aaa aa a bb b num_lawyers_2 num_lawyers_0
ii. Variable dependiente: spread; Variables independientes: num_lawyers_2 num_lawyers_0
* 4.c. Tests: realizar las siguientes pruebas:
i. Linealidad
ii. Homocedasticidad
iii. Variables omitidas
iv. Especificación
v. Multicolinealidad
vi. Outliers
vii. Normalidad en los errores
* 4.d. Describir lo siguiente (se debe incorporar la significancia y distintos aspectos vistos en clase):
i. Resultados intuitivos de las regresiones
ii. Resultados intuitivos de las pruebas


* EJERCICIO 5: Regresión con cambios: Replicar el ejercicio 4 pero añadir lo siguiente y explicar los principales cambios (se debe incorporar la significancia y distintos aspectos vistos en clase):

* 5.a. Añadir errores estándar robustos y variables dummy para year y curr
* 5.b. Considerando el punto (a), correr la regresión para dos submuestras: law==NY y law==English, respectivamente.
* 5.c. Explicar los principales cambios.


* EJERCICIO 6: Añadir información: Replicar 5a, incluyendo las variables extras de archivo Bonos2 (previamente incluidas en el ejercicio 2) como regresores. Explicar la principal conclusión al añadir estas variables.


* EJERCICIO 7: Correr un Probit con Variable dependiente: rep_ibc_top2; Variables independientes: lnamt years highrate2 hh_index_ib num_lawyers2 (incluir dummies para la variable year)

* 7.a. Generar la variable lambda con la siguiente forma: normalden(xb)/normal(xb) (HINT: ver predict).
* 7.b. Replicar 5a con la variable lambda como regresor, explicar la intuición de incluir esta variable y los cambios en los resultados.
ds
browse

quietly describe, varlist
describe, varlist
local estab `r(varlist)'
	
 
