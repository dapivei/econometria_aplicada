clear
log using DanielaPintoVeizaga_191471_Tarea1RES.log, replace

/*=================================================================

DO-FILE TAREA 01-TALLER DE ECONOMETRÍA

© Daniela Pinto Veizaga, 2020
			
==================================================================*/

* Set up del ambiente
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

/* ++++++++++++++++++++++++++++++++++++++++++
COMENTARIO: 

 Las siguientes variables están registradas como string, 
 cuando en realidad deberían ser numéricas:
 
 Obs, maturity, rate, spread, amt, arbitration
 secured, quorum, paymentvote, acceleration, reverseacc, 
 npexcep.
 
 Además de estos errores en los formatos, existen variables 
 con missing data que no fueron cargados correctamente en
 Stata.

+++++++++++++++++++++++++++++++++++++++++++.*/

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
ds,has (type int double)
tabstat `r(varlist)' , s(mean, median, sd, var, count, range, min, max)

* Descripción por categorías
ds,has (type byte)
foreach var in `r(varlist)' {
	table `var', contents(freq mean spread mean lnamt mean hh_index_ib_ny mean hh_index_ib_eng)
}

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

* Probar asociaciones entre variables de interés

tab num_lawyers2 rep_ic_size, column row nokey chi2 lrchi2 V
tab num_lawyers2 highrate2, column row nokey chi2 lrchi2 V

* Relaciones más específicas

bysort num_lawyers2: tab rep_ic_size highrate2, column row

bysort num_lawyers2: tab years rep_ic_top2, column row

bysort num_lawyers2: tab rep_ic_size highrate2, sum(spread)

bysort num_lawyers2: tab rep_ic_size highrate2, sum(lnamt)

/* ++++++++++++++++++++++++++++++++++++++++++
COMENTARIO: 

 Luego de la limpieza realizada y el filtro aplicado nos quedamos
 con 1482 observaciones y 20 variables, de los cuáles, dos son de 
 tipo string. A continuación, se reportan algunos hallazgos:
 
 ++ 4.51 por ciento de las veces el issuer es México
 ++ 2.35 por ciento de las veces la tasa de interés es de 0.09 por 
    ciento 
 ++ el spread promedio entre el bono soberano y la tasa libre de 
    riesgo es 1.9684
 ++ el promedio del logaritmo del monto de emisión es 6.25
 ++ en promedio, el índice de aglomeración de bonos bajo ley inglesa 
    es menos al índice de aglomeración de bonos bajo ley newyorkina.
 ++ los bonos analizados en esta base de datos fueron emitidos entre
    1947 y 2012.
 ++ en general, el spread promedio entre el bono soberano y la tasa
    libre de riesgo es mayor cuanto menor sea el rating del bono y 
	viceversa. Así, por ejemplo, el spread de un bono con rating b 
	en promedio es 4.17, versus el spread de un bono que cuenta con
	rating aaa, cuyo spread promedio es 0.225; esto mismo se verifica
	observando la variable highrate2 el spread promedio entre tener
	o no un bono de alta caldiad.
 ++ el spread promedio es mayor cuanto más número de firmas de abogados
    involucrados en el contrato; para contratos que contemplan 0 firmas 
	de abogados, el spread promedio es de 0.725, para contratos que 
	contemplan 2 firmas de abogados, el spread promedio es de 3.058.
 ++ además, cuanto mayor es el tamaño de la emisión de bonos,
	mayor es el promedio del spread; esta diferencia es particular 
	de aquellos bonos emitidos bajo la ley de Nueva York (no tanto 
	así de los bonos emitidos bajo la ley inglesa.)
 ++ para probar la relación específica entre el tamaño de la emisión
	y el número de firmas de abogados en el contrato realizamos una
	prueba chi2 y una prueba V de cramer, el resultado de  ambas 
	pruebas es que existe alguna relación entre ambas variables, aunque
	de acuerdo al resultado de la v de cramer, la relación es pequeña:
	0.3912.
 ++ para probar la relación específica entre la calidad del bono
	y el número de firmas de abogados en el contrato realizamos una
	prueba chi2 y una prueba V de cramer, el resultado de  ambas 
	pruebas es que existe alguna relación entre ambas variables, aunque
	de acuerdo al resultado de la v de cramer, la relación es media:
	0.4863.
 ++ considerando aquellos casos en los que no hubo firmas de abogados
    involucrados en el contrato, todos ellos fueron emisiones
    de tamaño pequeño; además, 72.85 por ciento de estos bonos fueron
	calificados como de alta calidad.
 ++ considerando aquellos casos en los que solo una firma de abogados
    estuvo involucrada en el contrato, todos ellos fueron emisiones
    de tamaño pequeño; además, 87.09 por ciento de estos bonos fueron
	calificados como de alta calidad.
 ++ el spread promedio de aquellos bonos calificados como de alta 
    calidad, con emisiones de tamaño pequeño y con ninguna firma de
	abogados en el contrato es de -0.55, con una desviación estándar
	de 2.18.
 ++ el spread promedio de aquellos bonos con baja calidad, de tamaño 
	grande y con dos firmas de abogados en el contrato es de 3.75
	con una desviación estándar de 1.73.	
 ++ no hay cambios significativos entre el promedio del monto del loga-
	ritmo de la emisión, la calidad del bono, tamaño de la emisión y 
	número de firmas de abogados en el contrato.

 En general, parece ser que hay una asociación entre calificación del 
 bono, spread, número de firmas en el contrato y tamaño de la emisión.
 En los ejercicios subsecuentes, exploraremos más a fondo estas rela-
 ciones.

+++++++++++++++++++++++++++++++++++++++++++.*/


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
drop if year < 1947
/*.................................................
2.a. Explorar los datos.¿Qué variables tienen el formato 
incorrecto (i.e. son string cuando deberían ser numéricas)? 
..................................................*/

* Comentario: Las variables que tienen el tipo incorrecto son:
* standarddeviationofexportgrowth, reservesshorttermdebt y obs
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


local nuevasvar issuer_1 issuer                                             ///
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

describe `nuevasvar'

* Descripción de variables numéricas
ds,has (type int double)
tabstat `r(varlist)' , s(mean, median, sd, var, count, range, min, max)

* Descripción por categorías
ds,has (type byte)
foreach var in `r(varlist)' {
	table `var', contents(freq mean gdpgrowth mean debtserviceexports mean ratioofdomesticcredittogdp)
}

ds,has (type int double)
tabstat `r(varlist)' , s(mean, median, sd, var, count, range, min, max) by (debtrescheduledinpreviousyear)

/* ++++++++++++++++++++++++++++++++++++++++++
COMENTARIO: 

 A continuación, algunos comentarios sobre las variables recién incluidas:
 
 ++ el gdpgrowth en promedio es de 0.0071, el debtserviceexports promedio
    es 11.084, el ratioofshorttermdebttototaldebt promedio es 7.77, 
	el reservesshorttermdebt promedio es 46.99, el standarddeviationofexportgrowth2
	promedio es 294.86, el standarddeviationofexportgrowth promedio es 15.04,
	el ratioofreservesgdp promedio es 10.91 y el ratioofdomesticcredittogdp

 ++ separando las observaciones, entre aquellos bonos que fueron reprogramados
    y los que no, vemos, que el mean gdpgrowth y el mean debtserviceexports 
	fueron mayores para los que fueron reprogramados versus los que no fueron
	reprogramados. El promedio del ratioofdomesticcredittogdp fue mayor para 
	los no reprogramados versus los reprogramados.
	
 ++ observando el promedio en debtserviceexports entre los bonos calificados
	con un highrate2 versus los nos calificados con high rate, vemos que 
	la cifra es mayor entre los no calificados con high rate; por el contrario
	el promedio en ratioofdomesticcredittogdp es mayor de los bonos califica-
	dos como high rate.

 ++ controlando el debtserviceexports por tamaño de la emisión,
    vemos que el promedio del debtserviceexports fue mayor cuando cuando las 
	emisiones tuvieron mayor tamaño (25 versus 8.46); mientras que contro-
	lando el ratioofdomesticcredittogdp por tamaño de emisión,
	vemos que el promedio del ratioofdomesticcredittogdp fue mayor
	cuando la emisión tuvo menor tamaño (72 verus 44).

 ++ el promedio de debtserviceexports más alto observado, controlado por
    número de firmas que intervenieron en el contrato, fue cuando fueron
	dos las firmas involucradas (17.39)
	
 ++ no hay diferencias significativas en los promedios de spread, lnamt
    y hh_index_ib, cuando se controla por la variable 
	debtrescheduledinpreviousyear
 
 Lo antes comentado son observaciones iniciales que serán exploradas a 
 mayor detalle en los siguientes apartados.
+++++++++++++++++++++++++++++++++++++++++++.*/



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
ds,has (type int double)
foreach x in `r(varlist)' {
    local i = `i' + 1
    hist `x' , name(jar`i', replace) frequency normal
    local jar  `jar'  jar`i' 
}
graph combine `jar'

ds,has (type int byte)
foreach x in `r(varlist)' {
    local i = `i' + 1
    hist `x' , name(jar`i', replace) frequency
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
 
twoway scatter spread lnamt, by(num_lawyers2, total)
twoway scatter spread lnamt, by(highrate2, total)
twoway scatter spread lnamt, by(law, total)

* Box plots
graph box spread, by(highrate2)
graph box lnamt, over(highrate2)
graph hbox lnamt, over(law)
graph hbox spread, by(law)
graph hbox spread, by(curr)


* Matrix

graph matrix spread gdpgrowth lnamt 



/* ++++++++++++++++++++++++++++++++++++++++++
COMENTARIO Y CONCLUSIONES: 
 Histogramas ---------------------------------------------------
 La mayoría de nuestras observaciones (relacionadas con los bonos)
 son de años recientes (1990-2010). El gdpgrowth, lnamt y spread, 
 exhiben una forma de distribución normal.
 La mayoría de las observaciones son relacionas a bonos de alta 
 calidad, tamaño pequeño de emisión y sin recalendarización de 
 la deuda en el año previo.

 Scatterplots---------------------------------------------------
 Al observar las relaciones entre número de firmas en el contrato, 
 spread y logartimo del monto de emisión, vemos que el monto de 
 emisión no es muy variante ante cambios en el número de firmas en 
 el contrato o spread; sin embargo, observamos que parece ser que
 existe una relación entre número de firmas en el contrato y spread
 del bono soberano y la tasa libre de riesgo.
 Al observar las relaciones entre el spread, el lnamt y calidad 
 del bono en cuestión, parece ser que existe una relación entre 
 la calidad del bono y el spread. Si el bono es de alta calidad,
 parece ser que el spread es menor.
 Finalmente, en relación a la ley para promover juicios en caso
 de default y el spread, parece ser que el spread bajo ley inglesa
 es más variante que el spread ante ley en Nueva York.
 
 Boxplots------------------------------------------------------
 Observando los spreads por ley para promover juicios en un boxplot,
 podemos observar que los bonos cuya ley para promover juicios
 es la ley de Nueva York o la de Inglaterra, exhiben mayores 
 outliers. Mientras tanto, el spread más bajo, en promedio, se
 encuentra en aquellos bonos cuya ley para promover juicios es
 la austriaca; el spread más alto, en promedio, se observa en
 Japón. 
 Matrix ------------------------------------------------------
 Finalmente, de acuedo a la matriz graficada, no hay una relación
 lineal entre gdpgrowth, spread y lnamt.
+++++++++++++++++++++++++++++++++++++++++++.*/


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

gen num_lawyers_2=num_lawyers2==2
gen num_lawyers_0=num_lawyers2==0
replace rep_ic_size = 0 if num_lawyers2==0

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
rvfplot, yline(0)
xi: regress spread aaa aa a bb                                              ///
		    num_lawyers_2 num_lawyers_0
estat hettest

** Variables Omitidas

xi: regress spread aaa aa a bb                                              ///
		    num_lawyers_2 num_lawyers_0
ovtest

** Especificaciones
xi: regress spread aaa aa a bb                                              ///
		    num_lawyers_2 num_lawyers_0
linktest

** Multicolinealidad

xi: regress spread aaa aa a bb                                              ///
		    num_lawyers_2 num_lawyers_0
vif

** Outliers
avplot aaa
avplot a
avplot bb
avplot num_lawyers_2
avplots


** Normalidad

xi: regress spread aaa aa a bb                                              ///
		    num_lawyers_2 num_lawyers_0
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
*xi: regress spread num_lawyers_2 num_lawyers_0, robust
*ovtest

** Especificaciones
xi: regress spread num_lawyers_2 num_lawyers_0
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


/* ++++++++++++++++++++++++++++++++++++++++++
COMENTARIO: 


Previamente corrimos dos regresiones para estimar el efecto
desconocido de cambiar una variable sobre otra.

Con la primera regresión, estamos interesados en conocer la 
relación entre dos características asociadas a los bonos (la
calificación de los bonos y el número de firmas de abogados 
en el contrato) con el spread del bono soberano y la tasa li-
bre de riesgo. De ahora en adelante, denominaremos este inten-
to como la regresión A.

En la segunda regresión, estamos interesados en conocer la 
relación únicamente entre el número de firmas y el spread aso-
ciado a los bonos. De ajpra en adelante, denominaremos esta
regresión como regresión B.

***Procedemos a analizar primero el resultado de la regresión A.

El 23 por ciento de la varianza del spread está explicada 
por las variables dependientes especificadas en el modelo.
Es deseable que la raíz cuadrada del error cuadrático medio, 
entendida como la desviación estándar de la regresión, sea cer-
cana cero; en este caso, toma un valor de 2.84

Analizando las relaciones especificadas por el modelo, tenemos que:
-- El spread promedio es de 2.90 si el bono es no tiene un rating de 
   aaa; si tiene un rating aaa, el spread promedio es 2.90-2.4796.
-- El spread promedio es de 2.90 si el bono no tiene un rating aa;
   si tiene un rating aa, el spread promedio es 2.90-2.672.
-- El spread promedio de un bono con rating "a" es 2.90-1.90; el 
   spread promedio de un bono sin rating "a" es de 2.90.
-- El spread promedio de un bono con rating bb es 2.90+0.60.
-- El spread promedio de un bono, cuando el número de firmas de 
   abogados en el contrato es 2, es 2.90 + 0.30.
-- El spread promedio de un bono, cuando no hay firmas de abogados en el
   contrato es de 2.90-1.04.
   
   
Observando el valor p, asociado a cada uno de los regresores, identifica-
mos que los regresores aaa, aa, a, bb, num_lawyers_0 son estadísticamente 
significativos para explicar el spread.

Tests:

Homocedasticidad:

Una suposición importante es que la varianza de los residuos debe ser 
homocedástica o constante. De acuerdo con la prueba gráfica, no observamos
patrón alguno entre los residuos y a los valores predichos (Yhat).

Otra forma no gráfica de detectar heterocedasticidad es con la prueba de 
Breusch-Pagan. La hipótesis nula es que los residuos son homocedásticos. 
En el siguiente ejemplo, el valor-p asociado a estadístico chi-cuadrado es
0.0000. Como el valor es menor que 0.05, rechazamos la hipótesis nula y 
concluimos que hay heterocedasticidad.

Variables omitidas:

Con el comando ovtest, revisamos la hipótesis nula: que el modelo no 
tiene sesgo de variables omitidas, el valor p es menor que el umbral
habitual de de 0.05 (95% de significancia), por lo que no rechazamos
el nulo y concluimos que necesitamos más variables.

Especificación:

Lo que hay que buscar aquí es verificar si _hatsq (Yhat al cuadrado) es
estadísticamente significativa. La hipótesis nula es que no hay error
de especificación. Como el valor p de _hatsq es significativo (0.68), 
rechazamos la hipótesis nula y concluimos que nuestro modelo no está
correctamente especificado.

Multicolinealidad:

El comando en Stata para verificar la multicolinealidad es vif.
Un vif> 10 o un 1 / vif <0.10 indica un problema. Como todos nuestros
valores de vif se encuentran entre 1 y 2, no hay problemas de multicoli-
nealidad.

Outliers:

Usamos el comando avplots (usar después de correr la regresión). En todos
los casos observamos valores atípicos.

Normalidad:

Finalmente, nos interesa probar que los residuos se comportan "normales".
Los residuos, indicados con letra m, son la diferencia entre los valores 
observados (Y) y los valores predichos (Yhat): e = Y –Yhat. Con la prueba 
de swilks tenemos la hipótesis nula es que la distribución de los residuales
es normal, aquí el valor p es 0.00, entonces rechazamos el nulo, concluimos 
entonces que los residuos no están distribuidos normalmente.

***Procedemos a analizar el resultado de la regresión B.

El 12 por ciento de la varianza del spread está explicada 
por las variables dependientes especificadas en el modelo.
Es deseable que la raíz cuadrada del error cuadrático medio, 
entendida como la desviación estándar de la regresión, sea cer-
cana cero; en este caso, toma un valor de 3.01

Analizando las relaciones especificadas por el modelo, tenemos que:
-- El spread promedio es de 1.15+1.90, cuando el número de firmas de 
   abogados en el contrato es 2; por el contrario, el spread promedio
   es de 1.15-0.97 si ninguna firma intervino en el contrato. 

   
Observando el valor p, asociado a cada uno de los regresores, identifica-
mos que ambos regresores son estadísticamente significativos para explicar 
el spread.

Tests:

Homocedasticidad:

Una suposición importante es que la varianza de los residuos debe ser 
homocedástica o constante. De acuerdo con la prueba gráfica, no observamos
patrón alguno entre los residuos y a los valores predichos (Yhat).

Otra forma no gráfica de detectar heterocedasticidad es con la prueba de 
Breusch-Pagan. La hipótesis nula es que los residuos son homocedásticos. 
En el siguiente ejemplo, el valor-p asociado a estadístico chi-cuadrado es
0.0000. Como el valor es menor que 0.05, rechazamos la hipótesis nula y 
concluimos que hay heterocedasticidad.

Como en esta regresión y en la anterior, nuestras regresiones no pasan
la prueba de la homocedasticidad, en el siguiente apartado empleareamos
errores estándar robustos.  

Con el comando ovtest, revisamos la hipótesis nula: que el modelo no 
tiene sesgo de variables omitidas, el valor p es menor que el umbral
habitual de de 0.05 (95% de significancia), por lo que no rechazamos
el nulo y concluimos que necesitamos más variables.


Variables omitidas:

No es posible realizar el test. Marca un error. 

Especificación:

Lo que hay que buscar aquí es verificar si _hatsq (Yhat al cuadrado) es
estadísticamente significativa. La hipótesis nula es que no hay error
de especificación. Como el valor p de _hatsq es significativo (0.68), 
rechazamos la hipótesis nula y concluimos que nuestro modelo no está
correctamente especificado.

Multicolinealidad:

El comando en Stata para verificar la multicolinealidad es vif.
Un vif> 10 o un 1 / vif <0.10 indica un problema. Como ambos de nuestros
valores de vif son 1.19, no hay problemas de multicolinealidad.

Outliers:

Usamos el comando avplots (usar después de correr la regresión). En todos
los casos observamos valores atípicos.

Normalidad:

Finalmente, nos interesa probar que los residuos se comportan "normales".
Los residuos, indicados con letra m, son la diferencia entre los valores 
observados (Y) y los valores predichos (Yhat): e = Y –Yhat. Con la prueba 
de swilks tenemos la hipótesis nula es que la distribución de los residuales
es normal, aquí el valor p es 0.00, entonces rechazamos el nulo; concluimos 
entonces que los residuos no están distribuidos normalmente.


+++++++++++++++++++++++++++++++++++++++++++.*/

/* ++++++++++++++++++++++++++++++++++++++++++
			EJERCICIO 5: Regresion con
			Cambios
++++++++++++++++++++++++++++++++++++++++++ */

/*.................................................
5.a. Añadir errores estándar robustos y variables 
dummy para year y curr
..................................................*/

*********PRIMERA REGRESIÓN

encode curr, gen(n_curr)
save merge_db_regress, replace
regress spread aaa aa a bb                                                  ///
		num_lawyers_2 num_lawyers_0                                         ///
		i.n_curr i.year, robust

***--> Tests

** Homocedasticidad

xi: regress spread aaa aa a bb                                              ///
		    num_lawyers_2 num_lawyers_0                                     ///
		    i.n_curr i.year
estat hettest

** Variables omitidas
xi: regress spread aaa aa a bb                                              ///
		    num_lawyers_2 num_lawyers_0                                     ///
		    i.n_curr i.year, robust
ovtest

** Especificaciones
xi: regress spread aaa aa a bb                                              ///
		    num_lawyers_2 num_lawyers_0                                     ///
		    i.n_curr i.year, robust
linktest

** Multicolinealidad
xi: regress spread aaa aa a bb                                              ///
		    num_lawyers_2 num_lawyers_0                                     ///
		    i.n_curr i.year, robust
vif

** Outliers
avplot num_lawyers_2
avplot num_lawyers_0
avplots


** Normalidad

xi: regress spread aaa aa a bb                                              ///
		    num_lawyers_2 num_lawyers_0                                     ///
		    i.n_curr i.year, robust
predict n, resid
kdensity n, normal
histogram n, kdensity normal
pnorm n
qnorm n
swilk n
		
		
*********SEGUNDA REGRESIÓN	
regress spread num_lawyers_2 num_lawyers_0 i.n_curr i.year, robust

***--> Tests

** Homocedasticidad

xi: regress spread num_lawyers_2 num_lawyers_0 i.n_curr i.year
estat hettest

** Variables omitidas: 
xi: regress spread num_lawyers_2 num_lawyers_0 i.n_curr i.year
ovtest

** Especificaciones
xi: regress spread num_lawyers_2 num_lawyers_0 i.n_curr i.year, robust
linktest

** Multicolinealidad
xi: regress spread num_lawyers_2 num_lawyers_0 i.n_curr i.year, robust
vif

** Outliers
avplot num_lawyers_2
avplot num_lawyers_0
avplots


** Normalidad

xi: regress spread num_lawyers_2 num_lawyers_0 i.n_curr i.year, robust
predict t, resid
kdensity t, normal
histogram t, kdensity normal
pnorm t
qnorm t
swilk t
		
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
		
***--> Tests

** Homocedasticidad

xi: regress spread aaa aa a bb                                              ///
		    num_lawyers_2 num_lawyers_0                                     ///
		    i.n_curr i.year
estat hettest

** Variables omitidas
xi: regress spread aaa aa a bb                                              ///
		    num_lawyers_2 num_lawyers_0                                     ///
		    i.n_curr i.year, robust
ovtest

** Especificaciones
xi: regress spread aaa aa a bb                                              ///
		    num_lawyers_2 num_lawyers_0                                     ///
		    i.n_curr i.year, robust
linktest

** Multicolinealidad
xi: regress spread aaa aa a bb                                              ///
		    num_lawyers_2 num_lawyers_0                                     ///
		    i.n_curr i.year, robust
vif

** Outliers
avplot num_lawyers_2
avplot num_lawyers_0
avplots


** Normalidad

xi: regress spread aaa aa a bb                                              ///
		    num_lawyers_2 num_lawyers_0                                     ///
		    i.n_curr i.year, robust
predict b, resid
kdensity b, normal
histogram b, kdensity normal
pnorm b
qnorm b
swilk b



* segunda regresión
regress spread num_lawyers_2 num_lawyers_0 i.n_curr i.year, robust

***--> Tests

** Homocedasticidad

xi: regress spread num_lawyers_2 num_lawyers_0 i.n_curr i.year
estat hettest

** Variables omitidas: 
xi: regress spread num_lawyers_2 num_lawyers_0 i.n_curr i.year
ovtest

** Especificaciones
xi: regress spread num_lawyers_2 num_lawyers_0 i.n_curr i.year, robust
linktest

** Multicolinealidad
xi: regress spread num_lawyers_2 num_lawyers_0 i.n_curr i.year, robust
vif

** Outliers
avplot num_lawyers_2
avplot num_lawyers_0
avplots


** Normalidad

xi: regress spread num_lawyers_2 num_lawyers_0 i.n_curr i.year, robust
predict c, resid
kdensity c, normal
histogram c, kdensity normal
pnorm c
qnorm c
swilk c

** For law ENGLISH
clear
use merge_db_regress
keep if law=="English"

* primera regresión
regress spread aaa aa a bb                                                  ///
		num_lawyers_2 num_lawyers_0                                         ///
		i.n_curr i.year, robust
		
*---> Test		
** Homocedasticidad

xi: regress spread aaa aa a bb                                              ///
		    num_lawyers_2 num_lawyers_0                                     ///
		    i.n_curr i.year
estat hettest

** Variables omitidas
xi: regress spread aaa aa a bb                                              ///
		    num_lawyers_2 num_lawyers_0                                     ///
		    i.n_curr i.year, robust
ovtest

** Especificaciones
xi: regress spread aaa aa a bb                                              ///
		    num_lawyers_2 num_lawyers_0                                     ///
		    i.n_curr i.year, robust
linktest

** Multicolinealidad
xi: regress spread aaa aa a bb                                              ///
		    num_lawyers_2 num_lawyers_0                                     ///
		    i.n_curr i.year, robust
vif

** Outliers
avplot num_lawyers_2
avplot num_lawyers_0
avplots


** Normalidad

xi: regress spread aaa aa a bb                                              ///
		    num_lawyers_2 num_lawyers_0                                     ///
		    i.n_curr i.year, robust
predict g, resid
kdensity g, normal
histogram g, kdensity normal
pnorm g
qnorm g
swilk g	

		
* segunda regresión		

regress spread num_lawyers_2 num_lawyers_0 i.n_curr i.year, robust


*---> Test
** Homocedasticidad

xi: regress spread num_lawyers_2 num_lawyers_0 i.n_curr i.year
estat hettest

** Variables omitidas: 
xi: regress spread num_lawyers_2 num_lawyers_0 i.n_curr i.year
ovtest

** Especificaciones
xi: regress spread num_lawyers_2 num_lawyers_0 i.n_curr i.year, robust
linktest

** Multicolinealidad
xi: regress spread num_lawyers_2 num_lawyers_0 i.n_curr i.year, robust
vif

** Outliers
avplot num_lawyers_2
avplot num_lawyers_0
avplots


** Normalidad

xi: regress spread num_lawyers_2 num_lawyers_0 i.n_curr i.year, robust
predict d, resid
histogram d, kdensity normal
pnorm d
qnorm d
swilk d


/*.................................................
* 5.c. Explicar los principales cambios.
..................................................*/

/* ++++++++++++++++++++++++++++++++++++++++++
COMENTARIO: 

Al añadir las variables (year y curr) a las dos regresiones previamente 
evaluadas en el ejercicio cuatro, obtenemos los siguientes resultados.

Para la especificación de la regresión de la siguiente manera:

---> regress spread aaa aa a bb                                                  
		     num_lawyers_2 num_lawyers_0                                         
		     i.n_curr i.year, robust

Observamos que el 32 por ciento de la varianza del spread está explicada 
por las variables dependientes especificadas en el modelo. Además, observamos
que, en comparación con las otras dos regresiones, la raíz cuadrada del 
error cuadrático medio está más cercana a cero: 2.80.

En términos de la significancia estadística de las variables incluidas, 
resulta que, de las variables originales, ahora únicamente aaa, aa y a
son estadísticamente significativas. En referencia a las dummies incluidas,
todos los años son estadísticamente significativos; por el contrario, no
todos las monedas son estadísticamente significativas para el modelo.

Tests:

Homocedasticidad:

Una suposición importante, en términos de eficiencia, es que la varianza
de los residuos debe ser homocedástica o constante. De acuerdo con la 
prueba gráfica, no observamos patrón alguno entre los residuos y a los
 valores predichos (Yhat).

Otra forma no gráfica de detectar heterocedasticidad es con la prueba de 
Breusch-Pagan. La hipótesis nula es que los residuos son homocedásticos. 
En el siguiente ejemplo, el valor-p asociado a estadístico chi-cuadrado es
0.0000. Como el valor es menor que 0.05, rechazamos la hipótesis nula y 
concluimos que hay heterocedasticidad.

Variables omitidas:

Con el comando ovtest, revisamos la hipótesis nula: que el modelo no 
tiene sesgo de variables omitidas. El valor p es mayor que el umbral
habitual de de 0.05 (95% de significancia), por lo que rechazamos
la hipótesis nula y concluimos que no necesitamos más variables.

Especificación:

Lo que hay que buscar aquí es verificar si _hatsq (Yhat al cuadrado) es
estadísticamente significativa. La hipótesis nula es que no hay error
de especificación. Como el valor p de _hatsq es significativo (0.737), 
rechazamos la hipótesis nula y concluimos que nuestro modelo no está
correctamente especificado.

Multicolinealidad:

El comando en Stata para verificar la multicolinealidad es vif.
Un vif> 10 o un 1 / vif <0.10 indica un problema. El promedio de nuestros
VIF es 17.71, lo cuál quiere decir que muchas de nuestros regresores 
presentan multicolinealidad. De hecho, los vifs grandes corresponden
a algunas de las dummies creadas paras para curr y year. 

Outliers:

Usamos el comando avplots (usar después de correr la regresión). En todos
los casos observamos valores atípicos.

Normalidad:

Finalmente, nos interesa probar que los residuos se comportan "normales".
Los residuos, indicados con letra n, son la diferencia entre los valores 
observados (Y) y los valores predichos (Yhat): e = Y –Yhat. Para probar
la normalidad en el comportamiento de los residuos, podemos emplear la 
prueba de shapiro-wilks, donde se establce que la hipótesis nula es que 
la distribución de los residuales es normal.
Como el p-value (0.0000), asociado a nuestro estadístico W (0.50) es 
menor a 0.05, podemos rechazar la hipótesis nula; concluimos 
entonces que los residuos no están distribuidos normalmente.
de shapiro-wilks tenemos la hipótesis nula es que la distribución de 
los residuales es normal, aquí el valor p es 0.00, entonces rechazamos
el nulo, concluimos entonces que los residuos no están distribuidos 
normalmente.


Para la especificación de la regresión de la siguiente manera:

---> regress spread num_lawyers_2 num_lawyers_0 i.n_curr i.year, robust

Observamos que el 25 por ciento de la varianza del spread está explicada 
por las variables dependientes especificadas en el modelo. Además, observamos
que, en comparación con las otras dos regresiones, la raíz cuadrada del 
error cuadrático medio está 2.90.

En términos de la significancia estadística de las variables incluidas, 
resulta que, de las variables originales, ahora únicamente num_lawyers_2
es estadísticamente significativa. En referencia a las dummies incluidas,
todos los años son estadísticamente significativos; por el contrario, no
todos las monedas son estadísticamente significativas para el modelo.

Tests:

Homocedasticidad:

Una suposición importante es que la varianza de los residuos debe ser 
homocedástica o constante. De acuerdo con la prueba gráfica, no observamos
patrón alguno entre los residuos y a los valores predichos (Yhat).

Otra forma no gráfica de detectar heterocedasticidad es con la prueba de 
Breusch-Pagan. La hipótesis nula es que los residuos son homocedásticos. 
En el siguiente ejemplo, el valor-p asociado a estadístico chi-cuadrado es
0.0097. Como el valor es menor que 0.05, rechazamos la hipótesis nula y 
concluimos que hay heterocedasticidad.

Variables omitidas:

Con el comando ovtest, revisamos la hipótesis nula: que el modelo no 
tiene sesgo de variables omitidas. El valor p es mayor que el umbral
habitual de de 0.05 (95% de significancia), por lo que rechazamos
la hipótesis nula y concluimos que no más variables.

Especificación:

Lo que hay que buscar aquí es verificar si _hatsq (Yhat al cuadrado) es
estadísticamente significativa. La hipótesis nula es que no hay error
de especificación. Como el valor p de _hatsq es significativo (0.893), 
rechazamos la hipótesis nula y concluimos que nuestro modelo no está
correctamente especificado.

Multicolinealidad:

El comando en Stata para verificar la multicolinealidad es vif.
Un vif> 10 o un 1 / vif <0.10 indica un problema. El promedio de nuestros
VIF es 18.85, lo cuál quiere decir que muchas de nuestros regresores 
presentan multicolinealidad. De hecho, los vifs grandes corresponden
a algunas de las dummies creadas paras para curr y year. 

Outliers:

Usamos el comando avplots (usar después de correr la regresión). En todos
los casos observamos valores atípicos.

Normalidad:

Finalmente, nos interesa probar que los residuos se comportan "normales".
Los residuos, indicados con letra t, son la diferencia entre los valores 
observados (Y) y los valores predichos (Yhat): t = Y –Yhat. Para probar
la normalidad en el comportamiento de los residuos, podemos emplear la 
prueba de shapiro-wilks, donde se establce que la hipótesis nula es que 
la distribución de los residuales es normal.
Como el p-value (0.0000), asociado a nuestro estadísitico W (0.55562) es 
menor a 0.05, podemos rechazar la hipótesis nula; concluimos 
entonces que los residuos no están distribuidos normalmente.
de shapiro-wilks tenemos la hipótesis nula es que la distribución de 
los residuales es normal, aquí el valor p es 0.00, entonces rechazamos
el nulo, concluimos entonces que los residuos no están distribuidos 
normalmente.


* Regresión limitada a law = Nueva York

Cuando limitamos la especificación del siguiente modelo 
 
---- > regress spread aaa aa a bb num_lawyers_2 
               num_lawyers_0 i.n_curr i.year, robust
				 
Observamos que 48.12 por ciento de la varianza del spread está
explicada por las variables dependientes especificadas en el modelo. 
Además, observamos que, en comparación con las otras regresiones, 
la raíz cuadrada del error cuadrático medio está más cercana a cero:
1.5602. Los regresores aaa, aa, a y num_lawyers_2 son estadísticamente
significativos para el modelo. La variable num_lawyers_0 es omitida.
 
El resto de las variables dummies (years y curr), son en su mayoría
no estadísticamente significativas para el modelo. 
 
Cuando limitamos la especificación del siguiente modelo 
 
---- > regress spread aaa aa a bb num_lawyers_2 
               num_lawyers_0 i.n_curr i.year, robust
				 
Observamos que 42 por ciento de la varianza del spread está explicada
por las variables dependientes espeficadas en el modelo: num_lawyers_0,
num_lawyers_2, i.curr, i.year. La raíz cuadrada del error cuadrático
medio está más cercana a cero, en comparación con otras regresiones
previamente ejecutadas: 1.6823.
Casi todas las variables son estadísticamente significativas. 

 
* Regresión limitada a law = Inglaterra

Cuando limitamos la especificación del siguiente modelo 
 
---- > regress spread aaa aa a bb num_lawyers_2 
               num_lawyers_0 i.n_curr i.year, robust
				 
Observamos que, en comparación con la submuestra restringida a la ley
en Nueva York, solamente 23.05 por ciento de la varianza del spread está
explicada por las variables dependientes especificadas en el modelo. 
Además, observamos que, en comparación con las otras regresiones, 
la raíz cuadrada del error cuadrático medio es más grande:
4.1325. De los regresores originales, únicamente aaa y aa son
estadísticamente significativos para el modelo. 
 
El resto de las variables dummies (years y curr), son en su mayoría
no estadísticamente significativas para el modelo. 
 
Cuando limitamos la especificación del siguiente modelo 
 
---- > regress spread num_lawyers_2 
               num_lawyers_0 i.n_curr i.year, robust
				 
Quizá este modelo sea la peor especificacion hasta el momento. Solamente
16.90 por ciento de la varianza del spread está explicado por los regresores
incluidos. La raíz del error cuadrático medio es de 4.1732. Además, de las
variables originales, únicamente num_lawyers_2 es estadísticamente 
significativa. 
 
El resto de las variables dummies (years y curr), son en su mayoría
no estadísticamente significativas para el modelo. 

+++++++++++++++++++++++++++++++++++++++++++.*/

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
clear
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

** Homocedasticidad

		
xi: regress spread aaa aa a bb                                              ///
		    num_lawyers_2 num_lawyers_0                                     ///
		    n_issuer reservesshorttermdebt n_maturity                       ///
            debtrescheduledinpreviousyear                                   ///            
            debtserviceexports                                              ///
            standarddeviationofexportgrowth                                 ///
		    ratioofdomesticcredittogdp                                      ///
	        standarddeviationofexportgrowth2                                ///
            issuedate ratioofshorttermdebttototaldebt                       ///
	        i.n_curr i.year
estat hettest

** Variables omitidas
xi: regress spread aaa aa a bb                                              ///
		    num_lawyers_2 num_lawyers_0                                     ///
		    n_issuer reservesshorttermdebt n_maturity                       ///
            debtrescheduledinpreviousyear                                   ///            
            debtserviceexports                                              ///
            standarddeviationofexportgrowth                                 ///
		    ratioofdomesticcredittogdp                                      ///
	        standarddeviationofexportgrowth2                                ///
            issuedate ratioofshorttermdebttototaldebt                       ///
	        i.n_curr i.year, robust
ovtest

** Especificaciones
xi: regress spread aaa aa a bb                                              ///
		    num_lawyers_2 num_lawyers_0                                     ///
		    n_issuer reservesshorttermdebt n_maturity                       ///
            debtrescheduledinpreviousyear                                   ///            
            debtserviceexports                                              ///
            standarddeviationofexportgrowth                                 ///
		    ratioofdomesticcredittogdp                                      ///
	        standarddeviationofexportgrowth2                                ///
            issuedate ratioofshorttermdebttototaldebt                       ///
	        i.n_curr i.year, robust
linktest

** Multicolinealidad
xi: regress spread aaa aa a bb                                              ///
		    num_lawyers_2 num_lawyers_0                                     ///
		    n_issuer reservesshorttermdebt n_maturity                       ///
            debtrescheduledinpreviousyear                                   ///            
            debtserviceexports                                              ///
            standarddeviationofexportgrowth                                 ///
		    ratioofdomesticcredittogdp                                      ///
	        standarddeviationofexportgrowth2                                ///
            issuedate ratioofshorttermdebttototaldebt                       ///
	        i.n_curr i.year, robust
vif

** Outliers
avplot num_lawyers_2
avplot num_lawyers_0
avplots


** Normalidad
xi: regress spread aaa aa a bb                                              ///
		    num_lawyers_2 num_lawyers_0                                     ///
		    n_issuer reservesshorttermdebt n_maturity                       ///
            debtrescheduledinpreviousyear                                   ///            
            debtserviceexports                                              ///
            standarddeviationofexportgrowth                                 ///
		    ratioofdomesticcredittogdp                                      ///
	        standarddeviationofexportgrowth2                                ///
            issuedate ratioofshorttermdebttototaldebt                       ///
	        i.n_curr i.year, robust
predict w, resid
kdensity w, normal
histogram w, kdensity normal
pnorm w
qnorm w
swilk w			
		
		
regress spread num_lawyers_2 num_lawyers_0                                  ///
		n_issuer reservesshorttermdebt n_maturity                           ///
        debtrescheduledinpreviousyear                                       ///            
        debtserviceexports                                                  ///
        standarddeviationofexportgrowth                                     ///
		ratioofdomesticcredittogdp                                          ///
	    standarddeviationofexportgrowth2                                    ///
        issuedate ratioofshorttermdebttototaldebt                           ///
	    i.n_curr i.year, robust		

** Homocedasticidad

		
xi:regress spread num_lawyers_2 num_lawyers_0                               ///
		   n_issuer reservesshorttermdebt n_maturity                        ///
           debtrescheduledinpreviousyear                                    ///            
           debtserviceexports                                               ///
           standarddeviationofexportgrowth                                  ///
		   ratioofdomesticcredittogdp                                       ///
	       standarddeviationofexportgrowth2                                 ///
           issuedate ratioofshorttermdebttototaldebt                        ///
	       i.n_curr i.year	
estat hettest

** Variables omitidas
xi:regress spread num_lawyers_2 num_lawyers_0                               ///
		   n_issuer reservesshorttermdebt n_maturity                        ///
           debtrescheduledinpreviousyear                                    ///            
           debtserviceexports                                               ///
           standarddeviationofexportgrowth                                  ///
		   ratioofdomesticcredittogdp                                       ///
	       standarddeviationofexportgrowth2                                 ///
           issuedate ratioofshorttermdebttototaldebt                        ///
	       i.n_curr i.year, robust
ovtest

** Especificaciones
xi:regress spread num_lawyers_2 num_lawyers_0                               ///
		   n_issuer reservesshorttermdebt n_maturity                        ///
           debtrescheduledinpreviousyear                                    ///            
           debtserviceexports                                               ///
           standarddeviationofexportgrowth                                  ///
		   ratioofdomesticcredittogdp                                       ///
	       standarddeviationofexportgrowth2                                 ///
           issuedate ratioofshorttermdebttototaldebt                        ///
	       i.n_curr i.year, robust
linktest

** Multicolinealidad
xi:regress spread num_lawyers_2 num_lawyers_0                               ///
		   n_issuer reservesshorttermdebt n_maturity                        ///
           debtrescheduledinpreviousyear                                    ///            
           debtserviceexports                                               ///
           standarddeviationofexportgrowth                                  ///
		   ratioofdomesticcredittogdp                                       ///
	       standarddeviationofexportgrowth2                                 ///
           issuedate ratioofshorttermdebttototaldebt                        ///
	       i.n_curr i.year, robust
vif

** Outliers
avplot num_lawyers_2
avplot num_lawyers_0
avplots


** Normalidad

xi:regress spread num_lawyers_2 num_lawyers_0                               ///
		   n_issuer reservesshorttermdebt n_maturity                        ///
           debtrescheduledinpreviousyear                                    ///            
           debtserviceexports                                               ///
           standarddeviationofexportgrowth                                  ///
		   ratioofdomesticcredittogdp                                       ///
	       standarddeviationofexportgrowth2                                 ///
           issuedate ratioofshorttermdebttototaldebt                        ///
	       i.n_curr i.year, robust
predict s, resid
kdensity s, normal
histogram s, kdensity normal
pnorm s
qnorm s
swilk s	

/* ++++++++++++++++++++++++++++++++++++++++++
COMENTARIO: 


Cuando corremos la siguiente regresión:

---> regress spread aaa aa a bb                                                  
		     num_lawyers_2 num_lawyers_0                                         
		     n_issuer reservesshorttermdebt n_maturity                           
             debtrescheduledinpreviousyear                                                  
             debtserviceexports                                                  
             standarddeviationofexportgrowth                                     
		     ratioofdomesticcredittogdp                                          
	         standarddeviationofexportgrowth2                                    
             issuedate ratioofshorttermdebttototaldebt                           
	         i.n_curr i.year, robust
			 
En general, el modelo no mejora. De hecho, varias de los regresores incluidos,
resultan ser no significativos para el modelo, como ser: n_issuer, 
reservesshorttermdebt, n_maturity, debtserviceexports, 
standarddeviationofexportgrowth, ratioofdomesticcredittogdp,
standarddeviationofexportgrowth2, issuedate, ratioofshorttermdebttototaldebt.
Además, nuestras variables originalmente significativas (bb, num_lawyers_2,
num_lawyers_0), también dejan de ser significativas. La raiz cuadrada
del error cuadrático medio es de 3.022 y únicamente 30.84 por ciento de la
varianza del spread está explicada por las variables dependientes especificadas
en el modelo.


Cuando corremos la siguiente regresión:

---> regress spread num_lawyers_2 num_lawyers_0                                  
		     n_issuer reservesshorttermdebt n_maturity                          
             debtrescheduledinpreviousyear                                                
             debtserviceexports                                                 
             standarddeviationofexportgrowth                                     
		     ratioofdomesticcredittogdp                                          
	         standarddeviationofexportgrowth2                                   
             issuedate ratioofshorttermdebttototaldebt                           
	         i.n_curr i.year, robust		

En general, el modelo no mejora. De hecho, varias de los regresores incluidos,
resultan ser no significativos para el modelo, como ser: n_issuer, 
reservesshorttermdebt, n_maturity, 
standarddeviationofexportgrowth, ratioofdomesticcredittogdp,
standarddeviationofexportgrowth2, issuedate.
Además,num_lawyers_0, originalmente significativa, deja de ser significativas.
La raiz cuadrada del error cuadrático medio es de 3.03 y únicamente 28.59 por
ciento de la varianza del spread está explicada por las variables dependientes
especificadas en el modelo.

Como las especificaciones no son buenas con estos modelos, debido la no
signicancia 
			 
+++++++++++++++++++++++++++++++++++++++++++.*/


/* ++++++++++++++++++++++++++++++++++++++++++
			 EJERCICIO 7: PROBIT
++++++++++++++++++++++++++++++++++++++++++ */


/*.................................................
Correr un Probit con Variable dependiente: 
rep_ibc_top2; Variables independientes: 
lnamt years highrate2 hh_index_ib num_lawyers2 
(incluir dummies para la variable year)
..................................................*/
clear
use merge_db_regress
probit rep_ic_top2 lnamt highrate2 hh_index_ib num_lawyers2 years i.year

gen p = _b[_cons] + _b[lnamt]*lnamt + _b[hh_index_ib]*hh_index_ib +  ///
        _b[highrate2]*highrate2 + _b[num_lawyers2]*num_lawyers2 + ///
		_b[1965.year]*1965.year + _b[1976.year]*1976.year + ///
		_b[1977.year]*1977.year + _b[1993.year]*1993.year + ///
		_b[1994.year]*1994.year + _b[1995.year]*1995.year + ///
		_b[1996.year]*1996.year + _b[1978.year]*1978.year + ///
		_b[1979.year]*1979.year + _b[1981.year]*1981.year + ///
		_b[1985.year]*1985.year + _b[1989.year]*1989.year + ///
		_b[1990.year]*1990.year + _b[1991.year]*1991.year + ///
		_b[1992.year]*1992.year + _b[1993.year]*1993.year +  ///
		_b[1994.year]*1994.year + _b[1995.year]*1995.year + ///
		_b[1996.year]*1996.year + _b[1997.year]*1995.year + ///
		_b[1998.year]*1998.year + _b[1999.year]*1999.year + ///
		_b[2000.year]*2000.year + _b[2001.year]*2001.year + ///
		_b[2002.year]*2002.year + _b[2003.year]*2003.year + ///
		_b[2004.year]*2004.year + _b[2005.year]*2005.year + ///
		_b[2006.year]*2006.year + _b[2007.year]*2007.year + ///
		_b[2008.year]*2008.year + _b[2009.year]*2009.year + ///
		_b[2010.year]*2010.year + _b[years]*years	


/*.................................................
7.a. Generar la variable lambda con la siguiente
forma: normalden(xb)/normal(xb) (HINT: ver predict).
..................................................*/

gen lambda = normalden(p)/normal(p)

/*.................................................
7.b. Replicar 5a con la variable lambda como regresor,
explicar la intuición de incluir esta variable y los 
cambios en los resultados.
..................................................*/


* primera regresión
regress spread aaa aa a bb                                                  ///
		num_lawyers_2 num_lawyers_0                                         ///
		i.n_curr i.year lambda, robust

		
** Homocedasticidad

xi: regress spread aaa aa a bb                                              ///
		    num_lawyers_2 num_lawyers_0                                     ///
		   i.n_curr i.year lambda
estat hettest

** Variables omitidas
xi: regress spread aaa aa a bb                                              ///
		    num_lawyers_2 num_lawyers_0                                     ///
		    i.n_curr i.year lambda, robust
ovtest

** Especificaciones
xi: regress spread aaa aa a bb                                              ///
		    num_lawyers_2 num_lawyers_0                                     ///
		    i.n_curr i.year lambda, robust
linktest

** Multicolinealidad
xi: regress spread aaa aa a bb                                              ///
		    num_lawyers_2 num_lawyers_0                                     ///
		    i.n_curr i.year lambda, robust
vif

** Outliers
avplot num_lawyers_2
avplot num_lawyers_0
avplots


** Normalidad

xi: regress spread aaa aa a bb                                              ///
		    num_lawyers_2 num_lawyers_0                                     ///
		    i.n_curr i.year lambda, robust
predict j, resid
kdensity j, normal
histogram j, kdensity normal
pnorm j
qnorm j
swilk j
* segunda regresión		
regress spread num_lawyers_2 num_lawyers_0 i.n_curr i.year lambda, robust
** Homocedasticidad

xi: regress spread num_lawyers_2 num_lawyers_0 i.n_curr i.year lambda
estat hettest

** Variables omitidas
xi: regress spread num_lawyers_2 num_lawyers_0 i.n_curr i.year lambda,robust
ovtest

** Especificaciones
xi: regress spread num_lawyers_2 num_lawyers_0 i.n_curr i.year lambda,robust
linktest

** Multicolinealidad
xi: regress spread num_lawyers_2 num_lawyers_0 i.n_curr i.year lambda,robust
vif

** Outliers
avplot num_lawyers_2
avplot num_lawyers_0
avplots


** Normalidad

xi: regress spread num_lawyers_2 num_lawyers_0 i.n_curr i.year lambda,robust
predict q, resid
kdensity q, normal
histogram q, kdensity normal
pnorm q
qnorm q
swilk q

/* ++++++++++++++++++++++++++++++++++++++++++
COMENTARIO: 


Mediante el procedimiento previo, calculamos la razón de la inversa
de Mill, misma que no es nada más que la probabilidad de la occurrencia 
de los regresores sobre la probabilidad acumulada. Utilizamos esta forma 
para controlar la endogeneidad: parte del término de error provocado por 
variables no observadas. Entonces, una vez que insertamos lambda en el 
modelo de regresión lineal normal y ejecutamos la regresión, la beta 
asociada a la lambda es la fracción de la covarianza entre las variables 
no observadas y el spread del bono, relativo a la variación de las variables
no observadas.

En específico, la beta asociada al lambda de la primera regresión fue de
-1.032278; la beta asociada al lambda en la segunda regresión fue de 
-1.843948.  
En términos de los resultados del modelo, no hay mejoras significativas en
el porcentaje de varianza de la variable dependiente explicada por la 
las variables independientes. En ambas las dos regresiones en las que se
incluye lambda como regresor, la variable num_lawyers_2 deja de ser 
significativa. 

+++++++++++++++++++++++++++++++++++++++++++.*/


log close
