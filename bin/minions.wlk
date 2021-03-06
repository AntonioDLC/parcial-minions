class Empleado{
	var rol
	var estamina
	var tareasRealizadas = []
	method rol(unRol){
		rol = unRol
	}
	method rol(){
		return rol
	}
	method realizarTarea(tarea){
		if(tarea.puedeRealizarla(self).negate()){
			throw new NoPuedeRealizarTareaError()
		}
		rol.realizarPor(self,tarea)
		tareasRealizadas.add(tarea.dificultadPara(self))
		/*Necesito una lista de las realizadas para guardar la dificultad al momento
		 de hacerlas, tambien se podria guardar directamente una lista con las dificultades.*/
	}
	method recuperarEstamina(puntos)
	method comer(fruta){
		self.recuperarEstamina(fruta.estaminaQueAporta())
	}
	method perderEstamina(puntos){
		var enCuantoQueda = estamina - puntos
		if (enCuantoQueda<0){
			throw new EstaminaPorDebajoDe0Error()
		}
		estamina = enCuantoQueda
	}
	method estaminaMayorA(puntos){
		return estamina > puntos
	}
	method tieneEstasHerramientas(listaHerramientas){
		return rol.tieneEstasHerramientas(listaHerramientas)
	}
	method perderMitadDeEstamina(){
		estamina = estamina/2
	}
	method noEsMucama(){
		return rol.noEsMucama()
	}
	method noEsSoldado(){
		return rol.noEsSoldado()
	}
	method esCiclope(){
		return false
	}
	method fuerza(){
		return estamina/2 + 2
	}
	method fuerzaMayorA(puntos){
		return self.fuerza() > puntos
	}
	method fuerzaPorRol(){
		return rol.fuerzaExtra()
	}
	method experiencia(){
		return tareasRealizadas.size() * tareasRealizadas.sum({tarea => tarea.dificultadTarea()})
	}
}

class Ciclope inherits Empleado{
	override method recuperarEstamina(puntos){
		estamina += puntos
	}
	override method esCiclope(){
		return true
	}
	override method fuerza(){
		return (super() + self.fuerzaPorRol())/2
	}
}

class Biclope inherits Empleado{
	override method recuperarEstamina(puntos){
		estamina = 10.min(estamina+puntos)
	}
}

//Roles
class Rol{
	method tieneEstasHerramientas(listaHerr){
		return listaHerr.isEmpty()
	}
	method noEsMucama(){
		return true
	}
	method noEsSoldado(){
		return true
	}
	method fuerzaExtra(){
		return 0
	}
	method realizarPor(emp,tarea){
		tarea.realizarsePor(emp)
	}
	method incrementarDanio(puntos){}
}

class Soldado inherits Rol{
	var danio
	override method incrementarDanio(puntos){
		danio += puntos
	}
	override method fuerzaExtra(){
		return danio
	}
	override method noEsSoldado(){
		return false
	}
}

class Obrero inherits Rol{
	var herramientas
	constructor(listaHerr){
		herramientas = listaHerr
	}
	override method tieneEstasHerramientas(listaHerramientas){
		return herramientas.all({herr => listaHerramientas.contains(herr)})
	}
}

class Mucama inherits Rol{
	override method noEsMucama(){
		return true
	}
}

class Capataz inherits Rol{
	var empleadosACargo
	constructor(listaEmpleados){
		empleadosACargo = listaEmpleados
	}
	override method realizarPor(emp,tarea){
		var empsQuePuedenRealizarla = empleadosACargo.filter({empl => tarea.puedeRealizarla(empl)})
		var empleadoMasExp
		if(empsQuePuedenRealizarla.isEmpty()){
			tarea.realizarsePor(emp)
		}else{
			empleadoMasExp = empsQuePuedenRealizarla.max({empl => empl.experiencia()})
			tarea.realizarsePor(empleadoMasExp)
		}
		
	}
}

//TAREAS

class ArreglarMaquina{
	var maquina
	var herramientasNecesarias = []
	constructor(unaMaqu,herramientasNec){
		maquina = unaMaqu
		herramientasNecesarias = herramientasNec
	}
	method dificultadPara(empleado){
		return maquina.complejidad()*2
	}
	method puedeRealizarla(empleado){
		return empleado.estaminaMayorA(maquina.complejidad()) && empleado.tieneEstasHerramientas(herramientasNecesarias)
	}
	method realizarsePor(empleado){
		empleado.perderEstamina(maquina.complejidad())
	}
}

class DefenderSector{
	var gradoAmenaza
	constructor(gradoAmen){
		gradoAmenaza = gradoAmen
	}
	method dificultadPara(empleado){
		if(empleado.esCiclope()){
			return gradoAmenaza*2
		}else{
			return gradoAmenaza
		}
	}
	method puedeRealizarla(empleado){
		return empleado.noEsMucama() && empleado.fuerzaMayorA(gradoAmenaza)
	}
	method realizarsePor(empleado){
		if(empleado.noEsSoldado()){
			empleado.perderMitadDeEstamina()
		}else{
			empleado.rol().incrementarDanio(2)
		}
	}
}

class LimpiarSector{
	var sector
	var dificultadLimpieza = 10
	constructor(unSector){
		sector = unSector
	}
	method dificultadLimpieza(dificultad){
		dificultadLimpieza = dificultad
	}
	method estaminaRequerida(){
		if(sector.esGrande()){
			return 4
		}
		return 1
	}
	method dificultadPara(empleado){
		return dificultadLimpieza
	}
	method puedeRealizarla(empleado){
		return empleado.estaminaMayorA(self.estaminaRequerida())
	}
	method realizarsePor(empleado){
		if(empleado.noEsMucama()){
			empleado.perderEstamina(self.estaminaRequerida())
		}
	}
}

//CLASES EXTRAS
class Maquina{
	var complejidad
	constructor(complejMaquina){
		complejidad = complejMaquina
	}
	method complejidad(){
		return complejidad
	}
}

class Sector{
	var tamanio
	constructor(tam){
		tamanio = tam
	}
	method esGrande(){
		return tam > 10
	}
}

object banana{
	method estaminaQueAporta(){
		return 10
	}
}

object manzana{
	method estaminaQueAporta(){
		return 5
	}
}

object uvas{
	method estaminaQueAporta(){
		return 1
	}
}

class NoPuedeRealizarTareaError inherits Exception{}
class EstaminaPorDebajoDe0Error inherits Exception{}