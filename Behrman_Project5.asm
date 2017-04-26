TITLE Programming Assingment #5    (Behrman_Project5.asm)

; Author: Alexandra Behrman
; Course / Project ID    CS271_400             Date: 2/28/16
; Description: Write a program that performs the following tasks:
	;1. Introduce the program.
	;2. Get a user request in the range [min = 10 .. max = 200].
	;3. Generate request random integers in the range [lo = 100 .. hi = 999], storing them in consecutive elements of an array.
	;4. Display the list of integers before sorting, 10 numbers per line.
	;5. Sort the list in descending order (i.e., largest first).
	;6. Calculate and display the median value, rounded to the nearest integer.
	;7. Display the sorted list, 10 numbers per line.

INCLUDE Irvine32.inc

MIN = 10
MAX = 200
LO = 100
HI = 999

.data

myName			BYTE	"Name: Alexandra Behrman", 0
myProgram		BYTE	"Title: Programming Assignment #5", 0
goodbye			BYTE	"Thanks for playing! Goodbye.", 0
intro1			BYTE	"This program will generate and display a series of random integers in the range [100 ... 999], ", 0
intro2			BYTE	"sort the list, calculate and display the median value, and end by displaying the newly sorted list.", 0
prompt1			BYTE	"How many integers would you like to generate?", 0
prompt2			BYTE	"Please enter a number between [10 ... 200]: ", 0
low_err			BYTE	"That number is too low. Try again.", 0
high_err		BYTE	"That number is too high. Try again.", 0
medianString	BYTE	"The median is: ", 0
unsortedArray	BYTE	"This is the unsorted array: ", 0
sortedArray		BYTE	"This is the sorted array: ", 0
spaces			BYTE	"     ", 0

request			DWORD	? ;number of random integers to be generated - entered by user

list			DWORD MAX DUP(?) ;array

.code
main PROC

;------------ introduction procedure -------------
	push	OFFSET myName
	push	OFFSET myProgram
	push	OFFSET intro1
	push	OFFSET intro2
	call	introduction

;--------------- getData procedure ---------------
	push	OFFSET request
	push	OFFSET prompt1
	push	OFFSET prompt2
	push	OFFSET low_err
	push	OFFSET high_err
	call	getData

;-------------- fillArray procedure --------------
	call	Randomize
	push	OFFSET list
	push	request
	call	fillArray
	
;------------- displayList procedure -------------
	push	OFFSET list
	push	request
	push	OFFSET spaces
	push	OFFSET unsortedArray
	call	displayList

;-------------- sortList procedure ---------------
	push	OFFSET list
	push	request
	call	sortList

;------------ displayMedian procedure ------------
	push	OFFSET list
	push	request
	push	OFFSET medianString
	call	displayMedian

;------------- displayList procedure -------------
	push	OFFSET list
	push	request
	push	OFFSET spaces
	push	OFFSET sortedArray
	call	displayList

;-------------- farewell procedure ---------------
	push	OFFSET goodbye
	call	farewell

	exit	; exit to operating system
main ENDP


;---------------------------------------------------------------------------------
;INTRODUCTION PROCEDURE
;Description:			Introduces the program and programmer
;Receives:				myName, myProgram, intro1, intro2
;Returns:				N/A
;Preconditions:			N/A
;Registers Changed:		edx
;---------------------------------------------------------------------------------
introduction PROC
	push	ebp
	mov		ebp, esp

	mov		edx, [ebp+20]			;edx = myName
	call	WriteString
	call	CrLf
	mov		edx, [ebp+16]			;edx = myProgram
	call	WriteString
	call	CrLf
	call	CrLf
	mov		edx, [ebp+12]			;edx = intro1
	call	WriteString
	call	CrLf
	mov		edx, [ebp+8]			;edx = intro2
	call	WriteString
	call	Crlf
	call	CrLf

	pop		ebp
	ret		16
introduction ENDP


;---------------------------------------------------------------------------------
;GETDATA PROCEDURE
;Description:			Prompts user for integer and validates integer is within range
;Receives:				request, prompt1, prompt2, low_err, high_err
;Returns:				user value put in request variable
;Preconditions:			request declared as DWORD
;Registers Changed:		eax, ebx, edx
;---------------------------------------------------------------------------------
getData PROC
	push	ebp
	mov		ebp, esp
	mov		ebx, [ebp+24]			;ebx = request
	
	mov		edx, [ebp+20]			;edx = prompt1
	call	WriteString
	call	CrLf

	Top:
		mov		edx, [ebp+16]		;edx = prompt2
		call	WriteString
		call	ReadInt

		cmp		eax, MIN			;user input validation
		jl		TooLow
		cmp		eax, MAX
		ja		TooHigh

		mov		[ebx], eax			;request = user input
		pop		ebp
		ret		20

	TooLow:							;user input is below MIN
		call	CrLf
		mov		edx, [ebp+12]		;edx = low_err
		call	WriteString
		call	CrLf
		jmp		Top

	TooHigh:						;user input is above MAX
		call	CrLf
		mov		edx, [ebp+8]		;edx = high_err
		call	WriteString
		call	CrLf
		jmp		Top
getData ENDP


;---------------------------------------------------------------------------------
;FILLARRAY PROCEDURE
;Description:			fills array with random integers in [100...999]
;Receives:				list, request
;Returns:				(request)# values in array
;Preconditions:			request contains an integer
;Registers Changed:		eax, ecx, esi
;---------------------------------------------------------------------------------
fillArray PROC
	push	ebp
	mov		ebp, esp
	mov		esi, [ebp+12]			;esi = list
	mov		ecx, [ebp+8]			;ecx = request (loop counter)

	L1:								;code taken from Lecture #20 slides
		mov		eax, HI
		sub		eax, LO
		inc		eax

		call	RandomRange

		add		eax, LO
		mov		[esi], eax			;put random integer in current @list position in esi
		add		esi, 4				;move esi to next array element
		loop	L1

	pop		ebp
	ret		8
fillArray ENDP


;---------------------------------------------------------------------------------
;DISPLAYLIST PROCEDURE
;Description:			display the list
;Receives:				list, request, spaces, unsorted/sortedArray
;Returns:				N/A
;Preconditions:			request contains integer value, 
;Registers Changed:		eax, ebx, ecx, edx, esi
;---------------------------------------------------------------------------------
displayList	PROC
	push	ebp
	mov		ebp, esp
	mov		ebx, 0					;ebx = counting # of values displayed in line
	mov		esi, [ebp+20]			;esi = list
	mov		ecx, [ebp+16]			;ecx = request (loop counter)

	call	CrLf
	mov		edx, [ebp+8]			;edx = unsorted/sortedArray (depending on 1st or 2nd time calling)
	call	WriteString
	call	CrLf
	call	CrLf

	L1:
		mov		eax, [esi]			;eax = value in current @list position in esi
		call	WriteDec
		mov		edx, [ebp+12]		;edx = spaces between columns
		call	WriteString
		inc		ebx
		cmp		ebx, 10				;if ebx = 10, move to a new line
		jl		NextNum				;jump if ebx is not 10 yet
		call	CrLf
		mov		ebx, 0				;reset ebx for new line

	NextNum:
		add		esi, 4				;move to next element in array
		loop	L1

	pop		ebp
	ret		16
displayList	ENDP


;---------------------------------------------------------------------------------
;SORTLIST PROCEDURE
;Description:			sorts list in descending order
;Receives:				list, request
;Returns:				sorted list
;Preconditions:			request contains an integer
;Registers Changed:		eax, ebx, ecx, edx, esi
;---------------------------------------------------------------------------------
sortList PROC						;code adapted from BubbleSort code in textbook
	push	ebp
	mov		ebp, esp
	mov		esi, [ebp+12]			;esi = list
	mov		ecx, [ebp+8]			;ecx = request (loop counter)
	dec		ecx

	L1:
		mov		eax, [esi]			;move value in current @list position in esi into eax
		mov		edx, esi			;move current list position into edx
		push	ecx

		L2:
			mov		ebx, [esi+4]	;move value in next @list position into ebx
			mov		eax, [edx]		;move current list value into eax
			cmp		eax, ebx		
			jge		NoExchange		;if eax is larger, do not need to exchange values
			add		esi, 4			;move esi to next list position
			push	esi
			push	edx
			push	ecx
			call	exchange
			sub		esi, 4			;move esi back to original position (so position is not jumped by NoExchange)
	
		NoExchange:
			add		esi, 4			;move esi to next list position
			loop	L2

		pop		ecx
		mov		esi, edx			;move original list position back to esi
		add		esi, 4				;move esi to next list position
		loop	L1

	pop		ebp
	ret		8
sortList ENDP


;---------------------------------------------------------------------------------
;EXCHANGE PROCEDURE
;Description:			swaps variables in two array addresses
;Receives:				esi, edx, ecx
;Returns:				swapped array elements
;Preconditions:			esi and edx contain integers
;Registers Changed:		eax, ebx, edx, esi
;---------------------------------------------------------------------------------
exchange PROC
	push	ebp
	mov		ebp, esp
	pushad

	mov		ebx, [ebp+16]			;ebx = first @list position to be swapped
	mov		eax, [ebp+12]			;eax = second @list position to be swapped
	mov		edx, ebx				;edx = position held in ebx

	mov		esi, eax				;esi = position held in eax
	mov		eax, [eax]
	mov		ebx, [ebx]
	mov		[esi], ebx				;value from ebx now in new position in list
	mov		esi, edx				;esi = position held in ebx
	mov		[esi], eax				;value from eax now in new position in list

	popad
	pop		ebp
	ret		12
exchange ENDP


;---------------------------------------------------------------------------------
;DISPLAYMEDIAN PROCEDURE
;Description:			calculates and displays the median
;Receives:				list, request, medianString
;Returns:				N/A
;Preconditions:			request holds an integer
;Registers Changed:		eax, ebx, edx, esi
;---------------------------------------------------------------------------------
displayMedian PROC
	push	ebp
	mov		ebp, esp
	mov		esi, [ebp+16]			;esi = list
	mov		eax, [ebp+12]			;eax = request
	mov		ebx, 2
	mov		edx, 0

	div		ebx
	cmp		edx, 0
	je		EvenList				;if edx = 0, list has even number of integers
	jmp		OddList					;else list has odd number of integers

	EvenList:
		mov		edx, 0
		mov		eax, [ebp+12]
		mov		ebx, 2
		div		ebx					;determine the halfway point in request
		mov		ebx, 4
		mul		ebx					;multiply by 4 to increment esi
		add		esi, eax
		mov		ebx, [esi]
		mov		eax, [esi-4]
		add		eax, ebx
		mov		ebx, 2
		div		ebx					;divide sum of middle two integers by 2
		cmp		edx, 0
		je		WriteMedian			;if edx = 0, no remainder to eax = median
		inc		eax					;else increment eax (round up)

		WriteMedian:
				mov		edx, [ebp+8]	;edx = medianString
				call	CrLf
				call	CrLf
				call	WriteString
				call	WriteDec
				call	CrLf
				call	CrLf
				pop		ebp
				ret		12

	OddList:
		mov		eax, [ebp+12]
		mov		ebx, 2
		div		ebx					;determine the halfway point in request
		mov		ebx, 4
		mul		ebx					;multiply by 4 to increment esi
		add		esi, eax
		mov		eax, [esi]			;eax = median
		mov		edx, [ebp+8]		;edx = medianString
		call	CrLf
		call	CrLf
		call	WriteString
		call	WriteDec
		call	CrLf
		call	CrLf
		pop		ebp
		ret		12

displayMedian ENDP


;---------------------------------------------------------------------------------
;FAREWELL PROCEDURE
;Description:			Says goodbye
;Receives:				goodbye
;Returns:				N/A
;Preconditions:			N/A
;Registers Changed:		edx
;---------------------------------------------------------------------------------
farewell PROC
	push	ebp
	mov		ebp, esp

	call	CrLf
	call	CrLf
	mov		edx, [ebp+8]		;edx = goodbye
	call	WriteString
	call	CrLf
	call	CrLf
	
	pop		ebp
	ret		4
farewell ENDP

END main
