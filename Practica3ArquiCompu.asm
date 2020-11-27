.data
file_in: .asciiz "source.txt"
file_out: .asciiz "output.txt"
buffer: .space 10000
bufferCadena: .space 128
cadena: 	.space 2000
mensajeDeEntrada:  .asciiz "Ingrese la cadena a buscar "
cadena1: .asciiz "La cantidad de repeticiones de la cadena 1 es "
cadena2: .asciiz "\nLa cantidad de repeticiones de la cadena 2 es  \n"
cadena3: .asciiz "\nLa cantidad de repeticiones de la cadena 3 es  \n"
 

.text

manejoDeArchivo:

#Abrir el archivo a leer

	li $v0, 13	 #Llamada del sistema al servicio 13 para abrir archivos
	la $a0, file_in  #Nombre del archivo de entrada, en este caso, siguiendo la convencion de clase, source.txt
	li $a1, 0	 #Declaración para solamente lectura
	li $a2, 0	 #El modo es ignorado
	syscall		 #Llamada syscall para abrir el archivo
	move $s0, $v0    #Se almacena el descriptor del archivo

#Abrir el archivo a escribir
	li $v0, 13 	#Llamada del sistema al servicio 13 para abrir archivos
	la $a0, file_out #Nombre del archivo de entrada, en este caso, siguiendo la convencion de clase, output.txt
	li $a1, 1	#Declaración para escritura
	li $a2, 0	#El modo es ignorado
	syscall		#Llamada syscall para abrir el archivo
	move $s1, $v0	#Se guarda el desriptor del archivo a $s1
	
#Leer el archivo que se abrió previamente

	li $v0, 14	#Llamada del sistema al servicio 14 para leer archivos
	move $a0, $s0	#El descriptor del archivo
	la $a1, buffer	#dirección del buffer creado en el .data
	li $a2, 10000	#Cantidad de caracteres a leer
	syscall		#Llamada syscall para leer el archivo
	
	 
manejoDeDatos:
	#Imprimir el mensaje de entrada
	la $a0, mensajeDeEntrada 	#Mensaje que se le imprime en consola al usuario
	la $a1, 30
	la $a2, bufferCadena    	#Aqui se almacena la cadena que ingreso el usuario
	li $v0, 4            		#Llamada del sistema al servicio 4 para imprimir un string
	syscall		     		#Llamada syscall para imprimir el mensaje
	
	#Guardar la entrada del usuario
	move $a0, $a2        	#Mueve la direccion del buffer que contiene la entrada del usuario (en $a2) a $a0
	li $v0, 8	     	#Llamada del sistema al servicio 8 para leer un string
	syscall			#Llamada syscall para leer el string

	
	la $t0, bufferCadena 	#La posicion de memoria del primer dato de lo que ingresa el usuario
	la $t1, buffer 	  	#La posicion de memoria del primer dato del txt
	la $t6, bufferCadena	#La posicion de memoria del primer dato de lo que ingresa el usuario, este es para la bandera para caracter previo
	la $t4 0 	        #Inicializa el contador
	
cicloTxt: 
	lbu $t2, 0($t1) 	#dato del texto en posicion $t1
	beq $t2, $zero, escribirCadena	#Termina el ciclo guarda el numero de apariciones cuando llega al final del archivo
	lbu $t3, 0($t0) 	#dato dela cadena ingresada en la posicion $t0
	lbu $t7, 0($t6)		#dato dela cadena ingresada en la posicion previa
	
	bne $t2, $t3, noEsIgual   #Revisa si el del dato del txt es igual al caracter ingresado
		move $t6, $t0   #Se le ingresa a la bandera lo que tenia el dato de $t0
		addi $t0, $t0, 1 #Si son iguales aumentando los 2 apuntadores
		addi $t1, $t1, 1
		lbu $t3, 0($t0)  #Almacena en $t3 el siguiente dato a analizar 
		bne $t3, 10, cicloTxt   #Determina si se reinicia la cadena
			addi $t4, $t4, 1      #Si hay coinsidencia en la cadena del usuario y en el txt aumenta 1 en el contador
			la $t0, bufferCadena     #Reinicia el apuntador dela cadena del usuario a la primera posicion
		j cicloTxt		      
noEsIgual: 			 #Compara si los caracteres del txt y la cadena ingresada no coinsiden
	beq  $t2, $t7, datoPrevioIgual #Hace la comparacion del caracter actual con el caracter previo (guardado en la bandera)
	addi $t1, $t1, 1	 #mueve el apuntador del texto para continuar con la lectura
	la $t0, bufferCadena	 #Reinicia el aputandor de la cadena ingresada por el usuario a la primera posicion
	j cicloTxt		 #Repetir el proceso

datoPrevioIgual:
	addi $t1, $t1, 1	 #mueve el apuntador del txt para continuar con la lectura
	j cicloTxt		 #continua con la iteracion de busqueda de la cadena ingresada
	
escribirCadena: 
	addiu $t5, $t5, 1	# Obtenemos el registro contador para saber la cantidad de cadenas analizadas

		
	beq $t5, 1, primeraCadena	# Verificamos el valor de $t5 y nos redirigimos a la cadena correspondiente para escribirlo en el archivo de salida
	beq $t5, 2, segundaCadena
	beq $t5, 3, terceraCadena
	
primeraCadena:			   #Escribimos la primera cadena, este proceso es igual para todas las cadenas
	move $a0, $s1		#Enviamos como parametro el descriptor del archivo donde escribiremos
	li $v0, 15		#15 para especificar que deseamos escribir
	la $a1, cadena1		#Le pasamos a $a1 la direccion del buffer
	li $a2, 46		#Especificamos cuantos caracteres queremos escribir
	syscall			#Hacemos la llamada al sistema
	j imprimirContador		#Redirigimos a el procedimiento que nos ayuda a escribir el numero de aparariciones

segundaCadena:			#Escribimos la segunda cadena, con el procedimiento de la primera		
	move $a0, $s1	   
	li $v0, 15
	la $a1, cadena2
	li $a2, 47
	syscall
	j imprimirContador

terceraCadena:			#Escribimos la tercera cadena, con el procedimiento de la primera	
	move $a0, $s1	   
	li $v0, 15
	la $a1, cadena3
	li $a2, 47
	syscall
	j imprimirContador
		
imprimirContador:
	move $a0, $t4     #Cargamos la cadena leida
	la $a1, cadena	  #Lo enviamos al buffer	
	jal int2str    #Llamamos al procedimiento que nos cambia de integer a String
    
    
	li $v0, 15	 #Con el dato convertido se escribe en el archivo
	move $a0, $s1	 #Indicamos el archivo
	la $a1, cadena	 #cargamos el buffer
	li $a2, 10	 #Indicamos cuantos caracteres escrbiremos
	syscall		 #La llamada al sistema escribe en el archivo
    
    bne $t5, 3, manejoDeDatos	#Evaluamos si ya si ingresaron las 3 cadenas, si no volvemos a realizar el llamda a manejoDeDatos
    
    
        #Cerramos y terminamos la ejecucion
 
	li   $v0, 16       # Llamada al sistema para cerrar el archivo
	move $a0, $s0      # Enviamos el descriptor del archivo de lectura
	syscall            # Cerramos el archivo de lectura
	
	li   $v0, 16       # Llamada al sistema para cerrar el archivo
	move $a0, $s1      # Enviamos el descriptor del archivo de salida
	syscall            # Cerramos el archivo de escritura
			
Exit:	li   $v0, 10	   #Finalizamos el programa para evitar que se haga un ciclo infinito por el procedimiento de abajo
	syscall
	

#Proceso por el cual convertimos de integer a su codificacion en ascii sacado de https://stackoverflow.com/questions/46917337/simple-mips-function-to-convert-integer-to-string?rq=1	
int2str:
addi $sp, $sp, -4	#Se guardan los datos de $t en pila 
sw $t0, ($sp)		# para que los valores no cambien. Usamos solo $t0 aquí, así que se guarde eso.
bltz $a0, neg_num	#Si es num < 0
j next0			#De lo contrario nos vamos a 'next0'

neg_num:		#Cuerpo para lo condicion de < 0
li $t0, '-'
sb $t0, ($a1)		#str = ASCII de "-"
addi $a1, $a1, 1	#str++
li $t0, -1		
mul $a0, $a0, $t0	#num *= -1

next0:
li $t0, -1
addi $sp, $sp, -4	#Hacemos espacio en la pila
sw $t0, ($sp)		#guardamos -1(marcador del final de la pila) en la pila de MIPS

push_digits:
blez $a0, next1		#num < 0? Si es así, finaliza el bucle (pasa a 'next1')
li $t0, 10		#Si no, iniciamo el bucle while acá
div $a0, $t0
mfhi $t0		#$t0 = num % 10
mflo $a0		#num = num // 10  
addi $sp, $sp, -4	#Hacemos espacio en la pila
sw $t0, ($sp)		#Almacenamos el modulo 10 calculado arriba
j push_digits

next1:			
lw $t0, ($sp)		#$t0 = pop "El digito" de la pila
addi $sp, $sp, 4	#Y "Restauramos" la pila

bltz $t0, neg_digit	#si el dígito <= 0, pasa a neg_digit
j pop_digits		#Saltamos  pop_digits

neg_digit:
li $t0, '0'		
sb $t0,($a1)		#*str = ASCII of '0'
addi $a1, $a1, 1	#str++
j next2			#Saltamos a next2

pop_digits:
bltz $t0, next2		#Si el num <= 0 saltamos a next2 y finalizamos el loop
addi $t0, $t0, '0'	#de lo contrario $t0 = ASCII of digit
sb $t0, ($a1)		#*str = ASCII del digito
addi $a1, $a1, 1	#str++
lw $t0, ($sp)		#digit = pop de la pila
addi $sp, $sp, 4	#restauramos la pila
j pop_digits		#Saltamos a pop_digits

next2:
sb $zero, ($a1)		#*str = 0 marcador final del String

lw $t0, ($sp)		#restaurar el valor $t0 antes de que se llamara a la función
addi $sp, $sp, 4	#restauramos la pila
jr $ra			#saltamos a la llamada