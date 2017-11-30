# CAYUELAS Martin et MAYEUR Yannick

# Pour des raisons d'optimisation nous avons fait en sorte que la fonction racine renvoit 0,0 pour sqrt(0) car elle renvoyait 0.0078125

# Le calcul devient assez faux a partir du rang 127.

# $s1 contient bn
# $s2 contient b2n
# $s3 contient Bn
# $s4 contient pn
# $s5 contient Pn
# $s6 contient (pn+Pn)/2

.data
b2:	.float 1.0
eps:	.float 0.0001
init:	.float 1.0
two:	.float 2.0
one:	.float 1.0
racine:	.float 0.7071067812
zero:	.float 0.0
texte: 	.asciiz "Entrez un entier x, correspondant au nombre de boucles effectuées\n"
rl:	.asciiz "\n"
espace: .asciiz "        "
affichage: .asciiz "n:       Pi: \n"

.text

main:	# initialisation
	l.s $f1, b2
	mfc1 $s1, $f1
	li $t2, 2 # n = 2 a la premiere iteration
	l.s $f22, two
	
	#affiche texte qui demande n
	li $v0, 4
	la $a0, texte
	syscall
	li $v0, 5
	syscall
	
	
	move $t1, $v0
	li $t0, 0 #cpt
	move $a0, $s1
	jal cb2n
	move $s2, $v0
	move $s1, $s2
	
	
	
	
while:	bge $t0, $t1, end
	li $t3, 2
	l.s $f1, two
	mul $t2, $t2, $t3 # n = 2n
	mul.s $f22, $f22, $f1
	move $a0, $s1
	jal cb2n
	move $s2, $v0
	move $a0, $s2
	move $a1, $s1
	jal cBn
	move $s3, $v0
	move $a0, $s1
	jal cpn
	move $s4, $v0
	move $a0, $s3
	jal cpn
	move $s5, $v0
	move $a0, $s4
	move $a1, $s5
	jal cmoy
	move $s6, $v0
	move $s1, $s2
	addi $t0, $t0, 1
	
	#Affichage de n
	move $a0, $t2
	li $v0, 1
	syscall
	
	li $v0, 4
	la $a0, espace
	syscall
	
	#affichage de Pi
	mtc1 $s6, $f12
	li $v0, 2
	syscall 
	
	li $v0, 4
	la $a0, rl
	syscall
	j while
	
# a0 = bn
cb2n:	subi $sp, $sp, 4
	sw $ra, 0($sp)
	# calcul de bn^2
	mtc1 $a0, $f5
	mul.s $f0, $f5, $f5
	# calcul de sqrt(1 - bn²)
	l.s $f1, one
	sub.s $f2, $f1, $f0
	mfc1 $a0, $f2
	jal sqrt
	# calcul de sqrt(1+sqrt(1-bn²))
	mtc1 $v0, $f0
	l.s $f1, one
	add.s $f2, $f0, $f1
	mfc1 $a0, $f2
	jal sqrt
	# calcul de bn/(lereste)
	mtc1 $v0, $f0
	div.s $f1, $f5, $f0
	# cacul de b2n
	l.s $f0, racine
	mul.s $f2, $f0, $f1
	mfc1 $v0, $f2
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

# a0 = b2n, a1 = bn
cBn:	# calcul de b2n²
	mtc1 $a0, $f1
	mul.s $f3, $f1, $f1
	# calcul de 2b2n²
	l.s $f2, two
	mul.s $f4, $f2, $f3
	# calcul de 1 - 2b2n²
	l.s $f1, one
	sub.s $f2, $f1, $f4
	# calcul bn/reste
	mtc1 $a1, $f1
	div.s $f3, $f1, $f2
	mfc1 $v0, $f3
	jr $ra

# a0 = bn ou Bn, suivant le calcul à effectuer
#Cette fonction est utilisée pour pn et Pn
cpn:	mtc1 $a0, $f0
	mul.s $f2, $f0, $f22
	mfc1 $v0, $f2
	jr $ra

# a0 = pn, a1 = Pn, Calcul de la moyenne
cmoy:	l.s $f2, two
	mtc1 $a0, $f0
	mtc1 $a1, $f1
	add.s $f3, $f0, $f1
	div.s $f1, $f3, $f2
	mfc1 $v0, $f1
	jr $ra
	


# Pour appeller sqrt il faut que la valeur n soit dans $a0 et il faut jal. Le resultat sera dans $v0
sqrt:	subi $sp, $sp, 4
	sw $ra, 0($sp)
	beqz $a0, fzero
	l.s $f0, init
	mtc1 $a0, $f1 
	l.s $f4, eps
	
	
testsqrt:	mul.s $f2, $f0, $f0
		sub.s $f2, $f1, $f2
		abs.s $f2, $f2
		c.le.s $f2, $f4
		bc1t endsqrt
		div.s $f2, $f1, $f0
		add.s $f2, $f0, $f2
		l.s $f3, two
		div.s $f2, $f2, $f3
		mov.s $f0, $f2
		j testsqrt
	
endsqrt:	mfc1 $v0, $f0
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		jr $ra
		
fzero:	l.s $f0, zero
	mfc1 $v0, $f0
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
		
end:	# Exits the program
	li $v0, 10
	syscall
	
