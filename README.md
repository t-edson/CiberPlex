CiberPlex 1.0.0b
================

CiberPlex es un programa de control avanzado de cabinas de Internet, desarrollado en Lazarus y FreePascal. Incluye todas las funcionalidades comunes a este tipo de programas, así como funciones de control avanzadas de las computadoras cliente.

IMPORTANTE: Actualmente, Ciberplex se encuentra en fase de  desarrollo, por lo que no es del todo funcional.

==CIBERPLEX - Introducción
CiberPlex, es un software de control de ingresos. Permite realizar ventas, llevando el registro exacto de los elementos vendidos.

Una de sus característica más llamativas es que usa una interfaz gráfica elaborada, más allá de los simples controles y formularios que usan la mayoría de apliaciones de este tipo. Por ejemplo las PC cliente se representan como objetos gráficos con efectos llamativos, para indicar los estado de cuenta o espera.

Para realizar esta labor, CiberPlex define 3 conceptos principales:
* Boleta. 
* Objeto Facturable (OF).
* Grupo de Objetos Facturables (GOF).

Las boletas son elementos que puede recibir artículos del almacén para la venta. Cuando una boleta se paga, se genera, un ingreso de efectivo, que es registrado por el sistema. Las boletas no aparecen en pantalla, de forma independiente.

Los OF son  elementos que pueden generar consumo, porque incluyen siempre una boleta. Por lo general tienen una representación gráfica en la pantalla. Y pueden ser de diversos tipos tanto visual como funcionalmente. Se enuentran siempre agrupados en un GOF. Se les identifica por un nombre, que debe ser único dentro de su GOF.

Los GOF son elementos que agrupan a los OF. Pueden contener muchos o ningún OF. Pueden tener o no, representación gráfica en pantalla. Manejan propiedades independientes quepro lo geenral afectan a todos los OF que contienen.Se les identifica por un nombre, que debe ser único dentro de la aplicación.


==CIBERPLEX - Server

Esta es la aplicación principal donde se encuentran los contenedores de los datos el modelo. CiberPlex, no usa base de datos (al igual que NILOTER-m) sino que guarda toda su información en archivos de texto, INI y XML.

CiberPlex-Server permite configurar a todos los elementos visuales, y no visuales. También incluye a una interfaz visual para trabajar de la misma forma a como lo hace CiberPlex-Visor.


==Diseño

Ciberplex, es una versión mejorada de la serie de programas NILOTER-m.

Se compone de 3 módulos:

* CiberPlex-Server.- Es el servidor principal e incluye también un ainterfaz gráfica de control.
* CiberPlex-Cliente.- Es el programa que reside en las PC cliente. Actualmente se usa el mismo cliente del NILOTER-m.
* CiberPlex-Visor.- Permite mostrar la pantalla prinicpal, desde cualquier PC en la misma red.

La arquitectura de CiberPlex es similar al de un sistema distribuido y separa claramente lo que es el modelo de datos, de la interfaz gráfica.

Incluye también el control de locutorios para los enrutadores para llamadas de la serie NILO-mB, NILO-mC, NILO-mD y NILO-mE.

En principio, CiberPlex realiza las mismas funciones que el programa NILOTER-m, pero ha sido diseñado con una arquitectura más abierta, y flexible, logrando importantes mejoras:

* Se definen claramente los elementos (objetos) de la aplicación, de modo que se tienen Objetos Facturables (que pueden generar consumo) y Grupos de objetos facturables (agrupa a varios Objetos facturables), de modo que se facilita el diseño interno, el soporte y la evolución de la aplicación.
* Se separa la capa del modelo, de la capa vista, facilitando la implementación de "Visores" adicionales que usan las mismas rutinas del Visor local, que se incluye en el servidor.
* El código fuente se diseña de modo que pueda integrar fácilmente elementos nuevos (Grupos de facturables y Objetos facturables), a su interfaz. Por ejemplo, si se deseara incluir el control de otro tipo de negocio, como lavadoras, se puede crear los módulos necesarios y luego integrarlos a la interfaz de CiberPlex.
