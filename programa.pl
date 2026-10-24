% Parte A

% edicion(Expo, Anio)
edicion(feriaDelLibro, 2024).
edicion(feriaDelLibro, 2025).
edicion(feriaDelLibro, 2026).
edicion(comicCon, 2025).
edicion(comicCon, 2026).
edicion(arteBA, 2025).
edicion(arteBA, 2026).
edicion(expoCeliaca, 2026).


% visita(Persona, Expo, Anio)
visita(ana, feriaDelLibro, 2024).
visita(ana, feriaDelLibro, 2025).
visita(ana, feriaDelLibro, 2026).
visita(ana, comicCon, 2026).
visita(beto, comicCon, 2025).
visita(beto, feriaDelLibro, 2025).
visita(caro, arteBA, 2025).
visita(caro, expoCeliaca, 2026).


% asistentes(Expo, Anio, Cantidad)
asistentes(feriaDelLibro, 2025, 1200000).
asistentes(comicCon, 2026, 150000).
asistentes(arteBA, 2026, 90000).
asistentes(expoCeliaca, 2026, 40000).


% invito(QuienInvita, Invitado)
invito(ana, beto).
invito(caro, ana).


/* Error 1: masiva por extensión en vez de comprensión

masiva(feriaDelLibro).
masiva(comicCon).

Si una expo es masiva, que lo es cuando alguna de sus ediciones tuvo más de 100.000 asistentes.

El predicado masiva/1 debería ser una regla que considere los asistentes, de la forma que está ahora mismo
nos obliga a tener que manualmente agregar/quitar un hecho si cambiamos los asistentes de las ediciones
*/


masiva(Expo):-
    asistentes(Expo, _, Asistentes),
    Asistentes >= 100000.

/*
Error 2: Ligar de más

fanatica(Persona, Expo):-
    visita(Persona, Expo, Anio),
    forall(edicion(Expo, Anio), visita(Persona, Expo, Anio)).

Si una persona es fanática de una expo, que es cuando fue a todas sus ediciones. Ej: Ana es fanática de la Feria del Libro, pero no de la Comic Con.

Al ligar todas las variables antes del forall, lo que estamos haciendo es consultar si la persona visito al menos un año la expo.
Ejemplo de beto cuando llega todo ligado, el forall verifica:

forall(edicion(comicCon, 2025), visita(beto, comicCon, 2025)).
             true                          true

Como tanto el antecedente como el consecuente son true, entonces la consulta es verdadera para beto en la comicCon, cuando beto no fue a la de 2026.

Para solucionarlo el año no debería estar ligado.
*/

fanatica(Persona, Expo):-
    visita(Persona, Expo, _),
    forall(edicion(Expo, Anio), visita(Persona, Expo, Anio)).


/*
Error 3: Generar innecesariamente

recomendable(Expo):-
    edicion(Expo, _),
    visita(Persona, _, _),
    masiva(Expo),
    fanatica(Persona, Expo).

Si una expo es recomendable, que es cuando es masiva y tiene algún visitante fanático.

Si tanto masiva/1 como fanatica/2 son inversibles, no es necesario usar edicion/2 y visita/3 para generar, el predicado es inversible sin ellos.
Tampoco nos interesa la persona, que exista al menos una lo podemos chequear usando la variable anónima.
*/

recomendable(Expo):-
    masiva(Expo),
    fanatica(_, Expo).


/*
Error 4: Findall innecesario

habitue(Persona):-
    findall(Anio, visita(Persona, _, Anio), Anios),
    length(Anios, Cantidad),
    Cantidad > 1.

Si una persona es habitué, que es cuando fue a cualquier expo en más de un año distinto. Ej: Ana y Caro son habitués, Beto no.

No es necesario usar findall y listas para consultar esto, tampoco es inversible así como está. Alcanza con consultar si fue en dos años diferentes.
*/

habitue(Persona):-
    visita(Persona, _, Anio),
    visita(Persona, _, OtroAnio),
    Anio \= OtroAnio.

/*
Error 5:

nuncaFue(Persona, Expo):-
    not(visita(Persona, Expo, _)).

Qué personas no fueron a una cierta expo.

No es inversible, hay infinitas personas y expos que no cumplen la condición de haber visitado o sido visitadas (por principio de universo cerrado), falta generar antes del not.
*/

nuncaFue(Persona, Expo):-
    visita(Persona, _, _), %Para generar a la persona, se podría delegar a un predicado persona/1
    edicion(Expo, _), %Para generar a la expo, se podría delegar a un predicado expo/1
    not(visita(Persona, Expo, _)).

/*
Mejora 6: Recursividad infinita

companieros(Persona, OtraPersona):-
    invito(Persona, OtraPersona).
companieros(Persona, OtraPersona):-
    companieros(OtraPersona, Persona).

Si dos personas son compañeras de salida, que es cuando una invitó a la otra (da igual quién a quién).

Como es recursiva, para el caso falso nunca termina de ejecutar. En vez de usar recursividad se puede llamar al mismo hecho con los individuos invertidos en otra clausula, para tener la simetría.

*/

companieros(Persona, OtraPersona):-
    invito(Persona, OtraPersona).
companieros(Persona, OtraPersona):-
    invito(OtraPersona, Persona).

% Parte B

/*
1. Justificar si es verdadero o falso la siguiente afirmación: Agregar un hecho a la base de conocimientos nunca va a hacer que una consulta que antes era verdadera ahora resulte ser falsa.

Falso, se puede probar con un contraejemplo. Si yo tengo esta base de conocimientos:

estudiante(ana).

noEsEstudiante(Persona):-
    not(estudiante(Persona)).


Al consultar:
?- noEsEstudiante(beto).
true.

La respuesta es verdadera, sin embargo si agrego este hecho a la base de conocimientos:

estudiante(beto).

Ahora la misma consulta es falsa (dado que beto ahora sí es un estudiante)

?- noEsEstudiante(beto).
false.
*/

contiguo(ocre, azul).
contiguo(azul, verde).
contiguo(verde, amarillo).

llega(Desde, Hasta):-
    llega(Desde, Medio),
    contiguo(Medio, Hasta).
llega(Desde, Hasta):-
    contiguo(Desde, Hasta).

/*
2. ¿Qué pasa con la consulta llega(ocre, verde). ? Justificar.

Si bien desde ocre se puede llegar a verde (ocre -> azul -> verde) consulta nunca puede terminar debido al orden en el que está escrita la clausula recursiva.
La forma en la que el motoo va a chequear esa consulta es por la primera clausula, ligando las variables:

llega(ocre, verde):-
    llega(ocre, Medio),
    contiguo(Medio, verde).

Luego entonces consultará para ligar Medio: llega(ocre, Medio).
Con esto volverá ligar las variables en la primera clausula:

llega(ocre, Medio):-
    llega(ocre, OtroMedio),
    contiguo(OtroMedio, Medio).

Pero ahora con otro pabellon intermedio: OtroMedio. Volverá entonces a validar con llega/2 pero esta vez con otra variable: llega(ocre, OtroMedio).

Y así seguirá infinitamente.

La forma de resolver esto es invertir el orden para que el caso base quede antes que el recursivo:

*/

llega2(Desde, Hasta):-
    contiguo(Desde, Medio),
    llega2(Medio, Hasta).
llega2(Desde, Hasta):-
    contiguo(Desde, Hasta).

/*
De esta forma la misma consulta se resuelve primero chequeando la primera clausula:

llega2(ocre, verde):-
    contiguo(ocre, Medio),
    llega2(Medio, verde).

Pero ahora primero ejecuta la consulta contiguo(ocre, Medio).
Ligando Medio a azul, por lo que la siguiente consulta es: llega2(azul, verde).
Que tiene un camino directo por contiguo(azul, verde).
*/

% Parte C

% premio(Animal, Anio, Premio)
premio(tornado, 2025, granCampeon).
premio(lucero, 2026, mencion(juradoInternacional)).
premio(rayo, 2026, campeonDeRaza(cuartoDeMilla)).
premio(relampago, 2025, campeonDeRaza(criollo)).
premio(nube, 2026, mencion(juradoLocal)).
premio(sultan, 2019, granCampeon).
premio(gaucho, 2018, campeonDeRaza(criollo)).

% animal(Nombre, Cabania, Especie)
animal(tornado, laEsperanza, bovino(angus, 820)).
animal(copito, laEsperanza, ovino(corriedale, 3)).
animal(relampago, donCarlos, equino(criollo, 145, 4)).
animal(rayo, elOmbu, equino(cuartoDeMilla, 150, 5)).
animal(bonita, elOmbu, bovino(angus, 640)).

% Punto 1:

cabania(Cabania):-
    animal(_, Cabania, _).

%elite(Cabania)
elite(Cabania):-
    cabania(Cabania),
    forall(animal(Animal, Cabania, _), aptoJura(Animal)).

%aptoJura(Animal)
aptoJura(Animal):-
    animal(Animal, _, Especie),
    especieApta(Especie).

%especieApta(Especie)
especieApta(bovino(_, Peso)):-
    between(400, 900, Peso).
especieApta(equino(_, Alzada, Edad)):-
    Alzada >= 140,
    Edad >= 3.
especieApta(ovino(_, Lana)):-
    Lana >= 4.

% Punto 2:

%puntos(Premio, Puntos)
puntos(granCampeon, 100).
puntos(campeonDeRaza(criollo), 80).
puntos(campeonDeRaza(Raza), 50):-
    Raza \= criollo.
puntos(mencion(_), 10).

%puntaje(Cabania, Puntaje)
puntaje(Cabania, Puntaje):-
    cabania(Cabania),
    findall(Puntos, puntosPorAnimal(Cabania, Puntos), Lista),
    sum_list(Lista, Puntaje).

%puntosPorAnimal(Cabania, Puntos)
puntosPorAnimal(Cabania, Puntos):-
    animal(Animal, Cabania, _),
    premio(Animal, _, Premio),
    puntos(Premio, Puntos).

%ganadora(Cabania) - La ganadora es aquella que para todo puntaje posible, el de la cabaña es mayor
ganadora(Cabania):-
    puntaje(Cabania, Puntaje),
    forall(puntaje(_, Otro), Puntaje >= Otro).
