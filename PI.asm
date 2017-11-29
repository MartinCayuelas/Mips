# $s0 contient sqrt(2)/2
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

texte: 	.asciiz "Entrez un entier n, correspondant au nombre de boucles\n"
rl:	.asciiz "\n"

.text

main:	# initialisation
	l.s $f1, b2
	mfc1 $s1, $f1
	li $t2, 2 # n = 2 a la premiere iteration
	l.s $f22, two
	
	# calcul de la constante sqrt(2)/2
	l.s $f1, two
	mfc1 $a0, $f1
	jal sqrt
	# ici $v0 vaut sqrt(2)
	mtc1 $v0, $f2
	div.s $f1, $f2, $f1
	mfc1 $s0, $f1 # On a sqrt(2)/2
	
	

	#affiche texte qui demande n
	li $v0, 4
	la $a0, texte
	syscall
	li $v0, 5
	syscall
	
	move $t1, $v0
	li $t0, 0 #cpt
	jal cb2n
	move $s1, $s2
	
while:	bge $t0, $t1, end
	li $t3, 2
	l.s $f1, two
	mul $t2, $t2, $t3 # n = 2n
	mul.s $f22, $f22, $f1	
	jal cb2n
	jal cBn
	jal cpn
	jal cPn
	jal cmoy
	move $s1, $s2
	addi $t0, $t0, 1 #Incremente le compteur
	j while
	
		
cb2n:	subi $sp, $sp, 4
	sw $ra, 0($sp)
	# calcul de bn^2
	mtc1 $s1, $f1
	mul.s $f0, $f1, $f1
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
	mtc1 $s1, $f4
	div.s $f1, $f4, $f0
	# cacul de b2n
	mtc1 $s0, $f0
	mul.s $f2, $f0, $f1
	mfc1 $s2, $f2
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
cBn:	# calcul de b2n²
	mtc1 $s2, $f1
	mul.s $f3, $f1, $f1
	# calcul de 2b2n²
	l.s $f2, two
	mul.s $f4, $f2, $f3
	# calcul de 1 - 2b2n²
	l.s $f1, one
	sub.s $f2, $f1, $f4
	# calcul bn/reste
	mtc1 $s1, $f1
	div.s $f3, $f1, $f2
	mfc1 $s3, $f3
	jr $ra

cpn:	mtc1 $s1, $f0
	mul.s $f2, $f0, $f22
	mfc1 $s4, $f2
	jr $ra
	
cPn:	mtc1 $s3, $f0
	mul.s $f2, $f0, $f22
	mfc1 $s5, $f2
	jr $ra


cmoy:	l.s $f2, two
	mtc1 $s4, $f0
	mtc1 $s5, $f1
	add.s $f3, $f0, $f1
	div.s $f1, $f3, $f2
	mfc1 $s6, $f1
	jr $ra
	


# pour appeller sqrt il faut que la valeur n soit dans $a0 et il faut jal le res sera dans $v0
sqrt:	subi $sp, $sp, 4
	sw $ra, 0($sp)
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
		
end:	mtc1 $s6, $f12
	li $v0, 2
	syscall 
	# Exits the program
	li $v0, 10
	syscall
	
