CiberPlex 1.3
=============

CiberPlex es un sistema de ventas, con interfaz gráfica, aplicado al control de alquiler de cabinas de Internet y de llamadas para locutorios, desarrollado en Lazarus y FreePascal. 

Como controlador de cabinas de internet, incluye todas las funcionalidades comunes a este tipo de programas, así como funciones de control avanzadas de las computadoras cliente, como visualización de tiempo, bloqueo de pantalla, o apagado remoto.

![Tito's Terminal](http://blog.pucp.edu.pe/blog/tito/wp-content/uploads/sites/610/2017/01/cp.png "Título de la imagen")

== Dependencias

El programa se compila con Lazarus. En esta etapa solo es compilable para Windows.

El código fuente utiliza diversas librerías. Estas son:
 
* MisUtils
* ogEditGraf
* MiConfig
* UtilsGrilla
* SynFacilUtils
* Xpres-1.2
* Synapse

== CIBERPLEX - Introducción
CiberPlex, es en general, un software de control de ventas, que puede aplicarse a diversos rubros de negocio, pero que en la versión actual, solo incluye control de alquiler de cabinas de internet y control de llamadas usando enrutadores NILO-m.

Sus principales características son:

	1. Aplicación para Windows-x64. 
	2. Aplicación portable, sin dependencias de librerías externas.
	3. Incluye una interfaz gráfica donde puede mostrar objetos, con formas y colores, más que simples ventanas.
	4. Diseñado con arquitectura modelo-vista. Permite administrar diversos puntos de ventas, mostrando la misma interfaz gráfica en cada uno de ellos.
	5. Base de datos propietaria, embebida.
	6. Incluye control para alquiler de cabinas de Internet.
	7. Incluye control para llamadas usando enrutadores NILO-m.


Una de sus característica particulares de CIBERPLEX, es que usa una interfaz gráfica elaborada, más allá de los simples controles y formularios que usan la mayoría de aplicaciones de este tipo. Por ejemplo las PC cliente se representan como objetos gráficos con efectos llamativos, para indicar los estado de cuenta o espera.

El control de llamadas, se usa en negocios de Locutorios o Centros de llamadas. Trabaja solamente cuando se usan los equipos enrutadores NILO-m, de la serie NILO-mB, NILO-mC, NILO-mD y NILO-mE.

== CIBERPLEX - Facturación

Las ventas dentro de CIBERPLEX, se realizan siempre en objetos especiales llamados Facturables. Un objeto facturable es un objeto que puede generar consumo. Todo consumo se escribe en una boleta.

Dentro de la terminología de CIBERPLEX, se manejan 3 conceptos principales:

* Boleta. 
* Objeto Facturable (FAC).
* Grupo Facturables (GFAC).

Las boletas son elementos que puede recibir artículos del almacén para la venta. Cuando una boleta se paga, se genera, un ingreso de efectivo, que es registrado por el sistema. Las boletas no aparecen en pantalla, de forma independiente.

Los objetos facturables o FAC son elementos que pueden generar consumo, porque incluyen siempre una boleta. Por lo general, tienen una representación gráfica en la pantalla, y pueden ser de diversos tipos, tanto visual como funcionalmente. Se enuentran siempre agrupados en un GFAC. Se les identifica por un nombre, que debe ser único dentro de su GFAC.

Los GFAC o Grupo Facturables son elementos que agrupan a los FAC. Pueden contener muchos o ningún FAC. Pueden tener o no, representación gráfica en pantalla. Manejan propiedades independientes que por lo general afectan a todos los FAC que contienen.Se les identifica por un nombre, que debe ser único dentro de la aplicación.


== CIBERPLEX - Server

Esta es la aplicación principal donde se encuentran los contenedores de los datos. CiberPlex, no usa base de datos (al igual que NILOTER-m) sino que guarda toda su información en archivos de texto, INI y XML.

CiberPlex-Server permite configurar a todos los elementos visuales, y no visuales. También incluye a una interfaz visual para trabajar de la misma forma a como lo hace CiberPlex-Visor.


== Diseño

Ciberplex, es una versión mejorada de la serie de programas NILOTER-m.

Se compone de 3 módulos:

* CiberPlex-Server.- Es el servidor principal e incluye también un ainterfaz gráfica de control.
* CiberPlex-Cliente.- Es el programa que reside en las PC cliente. Actualmente se usa el mismo cliente del NILOTER-m.
* CiberPlex-Visor.- Permite mostrar la pantalla prinicpal, desde cualquier PC en la misma red.

La arquitectura de CiberPlex es similar al de un sistema distribuido y separa claramente lo que es el modelo de datos, de la interfaz gráfica.

En principio, CiberPlex realiza las mismas funciones que el programa NILOTER-m, pero ha sido diseñado con una arquitectura más abierta, y flexible, logrando importantes mejoras:

* Se definen claramente los elementos (objetos) de la aplicación, de modo que se tienen Objetos Facturables (que pueden generar consumo) y Grupos de objetos facturables (agrupa a varios Objetos facturables), facilitando así el diseño interno, el soporte y la evolución de la aplicación.
* Se separa la capa del modelo, de la capa vista, facilitando la implementación de "Visores" adicionales que usan las mismas rutinas del Visor local, que se incluye en el servidor.
* El código fuente se diseña de modo que pueda integrar fácilmente elementos nuevos (Grupos de facturables y Objetos facturables), a su interfaz. Por ejemplo, si se deseara incluir el control de otro tipo de negocio, como lavadoras, se puede crear los módulos necesarios y luego integrarlos a la interfaz de CiberPlex.
