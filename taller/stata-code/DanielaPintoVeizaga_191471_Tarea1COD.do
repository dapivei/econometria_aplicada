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


/*.................................................
1.a. Explorar los datos.¿Qué variables tienen el formato 
incorrecto (i.e. son string cuando deberían ser numéricas)? 
..................................................*/


* Verificación de los tipos de todas las variables en la bd
ds, has(type string)
summarize `r(varlist)'
ds, has(type 1/100)
ds, has(type byte)
ds, has(type int)
ds, has(type double)


/*COMENTARIO: 

 Las siguientes variables están registradas como string, 
 cuando en realidad deberían ser numéricas:
 
 Obs, maturity, rate, spread, amt, arbitration
 secured, quorum, paymentvote, acceleration, reverseacc, 
 npexcep.
 
 Además de estas errores en los formatos, existen variables 
 con missing data que no fueron cargados correctamente en
 Stata.

 */



/*.................................................
1.b. Modificar el formato de las variables para que tengan
el formato correcto.
..................................................*/

* Cambiar espacios en blanco a missing values
ds,has (type string)
foreach var in `r(varlist)' {
    replace `var' = "." if `var' == "" | `var' == "," |`var' == "o" 
}

* Tabular las variables string
ds,has (type string)
foreach var in `r(varlist)' {
    tab `var'
}

* Cambiar tipos de variables
local all_change secured quorum amt paymentvote npexcep                     ///
      spread rate reverseacc acceleration secure arbitration                ///
      obs
foreach var in `all_change' {
	destring `var', replace force

}

* Clean maturity
replace maturity = "."                                                      ///
if maturity == "EX" |                                                       ///
   maturity == "Euro med term note" |                                       ///
   maturity == "Variable" |                                                 ///
   maturity == "med. term notes" |                                          ///
   maturity == "short term notes -- less than nine months"


* Revisar correcto formato de variables
ds, has(type 1/100)
ds, has(type byte)
ds, has(type int)
ds, has(type double)



** Procedure before changing variable types

*tab spread if missing(real(spread))
*tab amt if missing(real(amt))
*tab arbitration if missing(real(arbitration))

/*.................................................
1.c. Mantener en la base de datos únicamente 
las siguientes variables:
..................................................*/

keep year spread aaa aa a bb b num_lawyers2 rep_ic_size curr                ///
     law rep_ic_top2 rep_ic_top2_ny rep_ic_top2_eng lnamt years             ///
     highrate2 hh_index_ib hh_index_ib_eng hh_index_ib_ny                   
save Bonos, replace


/*.................................................
1.d. Mantener las observaciones que son posteriores
(incluyendo) al año 1947 (variable year).
..................................................*/

keep if year > 1946
save Bonos, replace

/*.................................................
1.e. Realizar un análisis descriptivo y resumir 
los principales hallazgos.
..................................................*/

ds
describe 

* Creates a list of all vars that match previous criterias

global allvars year spread aaa aa a bb b num_lawyers2                       ///
       rep_ic_size curr law rep_ic_top2 rep_ic_top2_ny                      ///
       rep_ic_top2_eng lnamt years highrate2 hh_index_ib                    ///
       hh_index_ib_eng hh_index_ib_ny
foreach var in `allvars' {
	tab `var'
}
describe `allvars'


* Descripción de variables numéricas
ds,has (type int double byte)
tabstat `r(varlist)' , s(mean, median, sd, var, count, range, min, max)

* Estadísticas descriptivas por subgrupos
local ratings aaa aa a bb b
foreach var in `ratings' {
	tabstat year num_lawyers2 rep_ic_size                                   ///      
			rep_ic_top2 rep_ic_top2_ny rep_ic_top2_eng                      /// 
			lnamt years highrate2 hh_index_ib hh_index_ib_eng               ///
			hh_index_ib_ny,                                                 ///
			s(mean, median, sd, var, count, range, min, max)                ///
		    by (`var')
}

		
*COMENTARIO: 

*Bonds are similar to a loan. An entity issues a bond, which an investor buys with the expectation of being paid back in the future—plus interest. 

*A Triple-A (AAA) bond rating is the highest rating bond agencies award to an investment considered to have a low risk of default, thereby making it the most creditworthy. 

*The issue date is simply the date on which a bond is issued and begins to accrue interest.
*The maturity date is the date on which an investor can expect to have their principal repaid

* Estadísticas descriptivas de más variables
*bysort var3: tab var1 var2, sum(var4)


/* ++++++++++++++++++++++++++++++++++++++++++
			EJERCICIO 2
++++++++++++++++++++++++++++++++++++++++++ */

/*.................................................
Realizar un merge entre “Bonos.dta” y “Bonos2.xlsx”
para tener la información en una única base de datos.
..................................................*/


* Importamos de nuevo de  base de datos Bonos y generamos id
use Bonos
gen id = _n
save Bonos, replace

* Importamos la base de datos Bonos2 y generamos id
import excel "Bonos2.xlsx", sheet("Sheet1") firstrow clear
save Bonos2, replace
gen id = _n
save Bonos2, replace


* Merge usando el id
merge 1:1 id using Bonos, force
drop if _merge==1

/*.................................................
2.a. Explorar los datos.¿Qué variables tienen el formato 
incorrecto (i.e. son string cuando deberían ser numéricas)? 
..................................................*/


* Verificación de los tipos de todas las variables en la bd
ds, has(type string)
ds, has(type 1/100)
ds, has(type byte)
ds, has(type int)
ds, has(type double)


/*.................................................
2.b. Modificar el formato de las variables para que tengan
el formato correcto.
..................................................*/

* Cambiar espacios en caracteres especiales por a missing values
ds,has (type string)
foreach var in `r(varlist)' {
    replace `var' = "." if `var' == "" | `var' == "," |`var' == "o" 
}


* Cambiar tipos de variables
local changes standarddeviationofexportgrowth reservesshorttermdebt         ///
      obs
foreach var in `changes' {
	destring `var', replace force

}

* Clean maturity
replace maturity = "."                                                      ///
if maturity == "EX" |                                                       ///
maturity == "Euro med term note" |                                          ///
maturity == "Variable" |                                                    ///
maturity == "med. term notes" |                                             ///
maturity == "short term notes -- less than nine months"

save merge_db, replace

/*.................................................
2.c. Realizar un análisis descriptivo y resumir los 
principales hallazgos de las nuevas variables.
..................................................*/


local nuevasvar obs issuer_1 issuer                                         ///
      debtrescheduledinpreviousyear                                         ///
      debtserviceexports gdpgrowth                                          ///
      standarddeviationofexportgrowth                                       ///  
      standarddeviationofexportgrowth2                                      ///            
      issuedate ratioofshorttermdebttototaldebt                             ///                         
      maturity reservesshorttermdebt                                        ///                
      ratioofdomesticcredittogdp                                            ///
      ratioofreservesgdp 
foreach var in `nuevasvar' {
	tab `var'
}

*COMENTARIO: 

/* ++++++++++++++++++++++++++++++++++++++++++
			EJERCICIO 3
++++++++++++++++++++++++++++++++++++++++++ */

/*.................................................
A través de gráficos (a elección, al menos 3
distintos tipos) realizar un análisis descriptivo,
que nos permita determinar relaciones. Contestar:
¿Cuáles son las principales conclusiones?
..................................................*/


* Histograms de variables numéricas
use merge_db
ds,has (type int double byte)
foreach x in `r(varlist)' {
    local i = `i' + 1
    hist `x' , name(jar`i', replace) frequency nodraw
    local jar  `jar'  jar`i' 
}
graph combine `jar'


* Revisando el tipo de variables
ds, has (type int)
ds, has(type string)
ds, has(type 1/100)
ds, has(type byte)
ds, has(type double)


* Scatterplots
foreach var in `r(varlist)' {
   twoway scatter `var' grade || ///
           lfit `var' grade,      ///
           name(gr`var', replace)
 }
 
 
* Otras gráficas

twoway scatter sat age, mlabel(lastname) || lfit sat age, yline(1800) xline(30)

catplot major agegroups, percent(major gender) blabel(bar) by(gender) recast(hbar)

graph hbar (mean) age averagescoregrade newspaperreadershiptimeswk, ///
over(gender) over(studentstatus, label(labsize(small))) blabel(bar) title(Student indicators) ///
legend(label(1 "Age") label(2 "Score") label(3 "Newsp read"))


*COMENTARIO: 

/* ++++++++++++++++++++++++++++++++++++++++++
			EJERCICIO 4: Regresion Simple
++++++++++++++++++++++++++++++++++++++++++ */


/*.................................................
4.a. Generar las siguientes variables: 
i. num_lawyers_2: es 1 si num_lawyers2==2 
y es 0 cuando num_lawyers2==1 (el resto de
los casos es cero. HINT: cuidado con las
variables omitidas).
ii. num_lawyers_0: es 1 si num_lawyers2==0
y es 0 cuando num_lawyers2==1 o num_lawyers2=2
(el resto de los casos es cero. HINT: cuidado
 con las variables omitidas).
**iii. Reemplazar rep_ic_size con cero si 
num_lawyers2=0.
..................................................*/

use merge_db
gen num_lawyers_2=num_lawyers2==2
replace num_lawyers_2 = 0 if num_lawyers2==1
replace num_lawyers_2 = . if num_lawyers2== 0


gen num_lawyers_0=num_lawyers2==0
replace num_lawyers_0 = 0 if (num_lawyers2==1 | num_lawyers2==2)

replace rep_ic_size = 0 if num_lawyers_2==0

save merge_db_regress, replace
/*.................................................
4.b. Resultados: correr las siguientes 
regresiones
i. Variable dependiente: spread; 
Variables independientes: aaa aa a bb b 
num_lawyers_2 num_lawyers_0
ii. Variable dependiente: spread; 
Variables independientes: num_lawyers_2
num_lawyers_0
..................................................*/


regress spread aaa aa a bb                                                  ///
		num_lawyers_2 num_lawyers_0

regress spread num_lawyers_2 num_lawyers_0


/*.................................................
4.c. Tests: realizar las siguientes pruebas:
i. Linealidad; ii. Homocedasticidad
iii. Variables omitidas; iv. Especificación
v. Multicolinealidad; vi. Outliers
vii. Normalidad en los errores
..................................................*/

/*.................................................
Primera regresion
..................................................*/

** Homocedasticidad

xi: regress spread aaa aa a bb                                              ///
		    num_lawyers_2 num_lawyers_0
estat hettest

** Variables Omitidas

xi: regress spread aaa aa a bb                                              ///
		    num_lawyers_2 num_lawyers_0, robust
ovtest

** Especificaciones
xi: regress spread aaa aa a bb                                              ///
		    num_lawyers_2 num_lawyers_0, robust
linktest

** Multicolinealidad

xi: regress spread aaa aa a bb                                              ///
		    num_lawyers_2 num_lawyers_0, robust
vif

** Outliers
avplot aaa
avplot a
avplot bb
avplot num_lawyers_2
avplots


** Normalidad

xi: regress spread aaa aa a bb                                              ///
		    num_lawyers_2 num_lawyers_0, robust
predict e, resid
kdensity e, normal
histogram e, kdensity normal
pnorm e
qnorm e
swilk e

/*.................................................
Segunda regresion
..................................................*/

** Homocedasticidad

xi: regress spread num_lawyers_2 num_lawyers_0
estat hettest

** Variables omitidas: NOT POSSIBLE!
**xi: regress spread num_lawyers_2 num_lawyers_0, robust
**ovtest

** Especificaciones
xi: regress spread num_lawyers_2 num_lawyers_0, robust
linktest

** Multicolinealidad
xi: regress spread num_lawyers_2 num_lawyers_0, robust
vif

** Outliers
avplot num_lawyers_2
avplot num_lawyers_0
avplots


** Normalidad

xi: regress spread num_lawyers_2 num_lawyers_0, robust
predict m, resid
kdensity m, normal
histogram m, kdensity normal
pnorm m
qnorm m
swilk m

/*.................................................
4.d. Describir lo siguiente (se debe incorporar
la significancia y distintos aspectos vistos en clase):
i. Resultados intuitivos de las regresiones
ii. Resultados intuitivos de las pruebas
..................................................*/


*COMENTARIO: 


/* ++++++++++++++++++++++++++++++++++++++++++
			EJERCICIO 5: Regresion con
			Cambios
++++++++++++++++++++++++++++++++++++++++++ */

/*.................................................
5.a. Añadir errores estándar robustos y variables 
dummy para year y curr
..................................................*/

encode curr, gen(n_curr)

* primera regresión
regress spread aaa aa a bb                                                  ///
		num_lawyers_2 num_lawyers_0                                         ///
		i.year, robust

* segunda regresión		
regress spread num_lawyers_2 num_lawyers_0 i.n_curr i.year, robust


/*.................................................
5.b. Considerando el punto (a), correr la regresión
para dos submuestras: law==NY y law==English, 
respectivamente.
..................................................*/

** For law NY
keep if law=="NY"

* primera regresión
regress spread aaa aa a bb                                                  ///
		num_lawyers_2 num_lawyers_0                                         ///
		i.n_curr i.year, robust
		
* segunda regresión
regress spread num_lawyers_2 num_lawyers_0 i.n_curr i.year, robust


** For law ENGLISH
use merge_db_regress
encode curr, gen(n_curr)
keep if law=="English"

* primera regresión
regress spread aaa aa a bb                                                  ///
		num_lawyers_2 num_lawyers_0                                         ///
		i.n_curr i.year, robust
		
* segunda regresión		

regress spread num_lawyers_2 num_lawyers_0 i.n_curr i.year, robust

/*.................................................
* 5.c. Explicar los principales cambios.
..................................................*/

*COMENTARIO: 


/* ++++++++++++++++++++++++++++++++++++++++++
			 EJERCICIO 6
++++++++++++++++++++++++++++++++++++++++++ */

/*................................................. 
Añadir información: Replicar 5a, incluyendo las 
variables extras de archivo Bonos2 (previamente 
incluidas en el ejercicio 2) como regresores. 
Explicar la principal conclusión al añadir estas 
variables.
..................................................*/

use merge_db_regress
encode issuer, gen(n_issuer)
encode maturity, gen (n_maturity)
	  
regress spread aaa aa a bb                                                  ///
		num_lawyers_2 num_lawyers_0                                         ///
		n_issuer reservesshorttermdebt n_maturity                           ///
        debtrescheduledinpreviousyear                                       ///            
        debtserviceexports                                                  ///
        standarddeviationofexportgrowth                                     ///
		ratioofdomesticcredittogdp                                          ///
	    standarddeviationofexportgrowth2                                    ///
        issuedate ratioofshorttermdebttototaldebt                           ///
	    i.n_curr i.year, robust
		
		
		
* COMENTARIO:


/* ++++++++++++++++++++++++++++++++++++++++++
			 EJERCICIO 7: PROBIT
++++++++++++++++++++++++++++++++++++++++++ */


/*.................................................
Correr un Probit con Variable dependiente: 
rep_ibc_top2; Variables independientes: 
lnamt years highrate2 hh_index_ib num_lawyers2 
(incluir dummies para la variable year)
..................................................*/
use merge_db
probit rep_ic_top2 lnamt years highrate2 hh_index_ib num_lawyers2 i.years
predict r
kdensity r, normal
histogram r, kdensity normal
pnorm r
qnorm r
swilk r


/*.................................................
7.a. Generar la variable lambda con la siguiente
forma: normalden(xb)/normal(xb) (HINT: ver predict).
..................................................*/
drawnorm x, n(100) means(0.5) sds(2)
kdensity x
rnorm(0.5,2)
gen l = rnormal(0.5,0.5)
drawnorm x
/*.................................................
7.b. Replicar 5a con la variable lambda como regresor,
explicar la intuición de incluir esta variable y los 
cambios en los resultados.
..................................................*/
ds
browse

quietly describe, varlist
describe, varlist
local estab `r(varlist)'
	
 
