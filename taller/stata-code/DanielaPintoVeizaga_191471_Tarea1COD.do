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
spread rate reverseacc acceleration secure arbitration                      ///
obs
foreach var in `all_change' {
	destring `var', replace force

}

* Clean maturity
replace maturity = "."                                                      ///
if maturity == "EX" |                                                       ///
maturity == "Euro med term note" |                                          ///
maturity == "Variable" |                                                    ///
maturity == "med. term notes" |                                             ///
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

keep year spread aaa aa a bb b num_lawyers rep_ic_size curr                 ///
law rep_ic_top2 rep_ic_top2_ny rep_ic_top2_eng lnamt years                  ///
highrate2 hh_index_ib hh_index_ib_eng hh_index_ib_ny 

/*.................................................
1.d. Mantener las observaciones que son posteriores
(incluyendo) al año 1947 (variable year).
..................................................*/

keep if year > 1946

/*.................................................
1.e. Realizar un análisis descriptivo y resumir 
los principales hallazgos.
..................................................*/

ds
describe 

* Creates a list of all vars that match previous criterias

global allvars year spread aaa aa a bb b num_lawyers                        ///
rep_ic_size curr law rep_ic_top2 rep_ic_top2_ny                             ///
rep_ic_top2_eng lnamt years highrate2 hh_index_ib                           ///
hh_index_ib_eng hh_index_ib_ny

foreach var in `allvars' {
	tab `var'
}
describe `allvars'

* Descripción de variables numéricas
ds,has (type int double byte)
tabstat `r(varlist)' , s(mean, median, sd, var, count, range, min, max)

* Estadísticas descriptivas por subgrupos
tabstat year aaa aa a bb b num_lawyers rep_ic_size                          
rep_ic_top2 rep_ic_top2_ny rep_ic_top2_eng lnamt 
years highrate2 hh_index_ib hh_index_ib_eng 
hh_index_ib_ny,
s(mean, median, sd, var, count, range, min, max) 
by (curr)

* Estadísticas descriptivas de más variables
bysort var3: tab var1 var2, sum(var4)



/* ++++++++++++++++++++++++++++++++++++++++++
			EJERCICIO 2
++++++++++++++++++++++++++++++++++++++++++ */

/*.................................................
Realizar un merge entre “Bonos.dta” y “Bonos2.xlsx”
para tener la información en una única base de datos.
..................................................*/


* Importamos de nuevo de  base de datos Bonos y generamos id
import excel "Bonos.xlsx", sheet("Sheet1") firstrow clear
save Bonos, replace
gen id = _n
save Bonos, replace

* Importamos la base de datos Bonos2 y generamos id
import excel "Bonos2.xlsx", sheet("Sheet1") firstrow clear
save Bonos2, replace
gen id = _n
save Bonos2, replace


* Merge usando el id
merge 1:1 id using Bonos, force


* Verificación de los tipos de todas las variables en la bd
ds, has(type string)
ds, has(type 1/100)
ds, has(type byte)
ds, has(type int)
ds, has(type double)


* Cambiar espacios en caracteres especiales por a missing values
ds,has (type string)
foreach var in `r(varlist)' {
    replace `var' = "." if `var' == "" | `var' == "," |`var' == "o" 
}


destring reservesshorttermdebt, replace force
destring standarddeviationofexportgrowth, replace force

* Clean maturity
replace maturity = "."                                                      ///
if maturity == "EX" |                                                       ///
maturity == "Euro med term note" |                                          ///
maturity == "Variable" |                                                    ///
maturity == "med. term notes" |                                             ///
maturity == "short term notes -- less than nine months"

save Bonos2, replace
use Bonos2
merge 1:1 id using Bonos

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



/* ++++++++++++++++++++++++++++++++++++++++++
			EJERCICIO 3
++++++++++++++++++++++++++++++++++++++++++ */

/*.................................................
A través de gráficos (a elección, al menos 3
distintos tipos) realizar un análisis descriptivo,
que nos permita determinar relaciones. Contestar:
¿Cuáles son las principales conclusiones?



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


replace rep_ic_size = 0 if num_lawyers_2==0


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




/*.................................................
4.c. Tests: realizar las siguientes pruebas:
i. Linealidad; ii. Homocedasticidad
iii. Variables omitidas; iv. Especificación
v. Multicolinealidad; vi. Outliers
vii. Normalidad en los errores
..................................................*/



/*.................................................
4.d. Describir lo siguiente (se debe incorporar
la significancia y distintos aspectos vistos en clase):
i. Resultados intuitivos de las regresiones
ii. Resultados intuitivos de las pruebas
..................................................*/





/* ++++++++++++++++++++++++++++++++++++++++++
			EJERCICIO 5: Regresion con
			Cambios
++++++++++++++++++++++++++++++++++++++++++ */

/*.................................................
5.a. Añadir errores estándar robustos y variables 
dummy para year y curr
..................................................*/

/*.................................................
5.b. Considerando el punto (a), correr la regresión
para dos submuestras: law==NY y law==English, 
respectivamente.
..................................................*/

/*.................................................
* 5.c. Explicar los principales cambios.
..................................................*/


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



/* ++++++++++++++++++++++++++++++++++++++++++
			 EJERCICIO 7: PROBIT
++++++++++++++++++++++++++++++++++++++++++ */


/*.................................................
Correr un Probit con Variable dependiente: 
rep_ibc_top2; Variables independientes: 
lnamt years highrate2 hh_index_ib num_lawyers2 
(incluir dummies para la variable year)
..................................................*/


/*.................................................
7.a. Generar la variable lambda con la siguiente
forma: normalden(xb)/normal(xb) (HINT: ver predict).
..................................................*/

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
	
 
