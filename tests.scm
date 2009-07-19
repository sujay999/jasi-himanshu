(define cur-section '())
(define errs '())
(define SECTION (lambda args
		  (display "SECTION") (write args) (newline)
		  (set! cur-section args) #t))
(define record-error (lambda (e) (set! errs (cons (list cur-section e) errs))))

(define test
  (lambda (expect fun . args)
    (write (cons fun args))
    (display "  ==> ")
    ((lambda (res)
      (write res)
      (newline)
      (cond ((not (equal? expect res))
	     (record-error (list res expect (cons fun args)))
	     (display " BUT EXPECTED ")
	     (write expect)
	     (newline)
	     #f)
	    (else #t)))
     (if (procedure? fun) (apply fun args) (car args)))))
(define (report-errs)
  (newline)
  (if (null? errs) (display "Passed all tests")
      (begin
	(display "errors were:")
	(newline)
	(display "(SECTION (got expected (call)))")
	(newline)
	(for-each (lambda (l) (write l) (newline))
		  errs)))
  (newline))

(SECTION 2 1);; test that all symbol characters are supported.
'(+ - ... !.. $.+ %.- &.! *.: /:. :+. <-. =. >. ?. ~. _. ^.)

(SECTION 3 4)
(define disjoint-type-functions
  (list boolean? char? null? number? pair? procedure? string? symbol?))
(define type-examples
  (list
   #t #f #\a '() 9739 '(test) record-error "test" "" 'test))
(define i 1)
(for-each (lambda (x) (display (make-string i #\ ))
		  (set! i (+ 3 i))
		  (write x)
		  (newline))
	  disjoint-type-functions)
(define type-matrix
  (map (lambda (x)
	 (let ((t (map (lambda (f) (f x)) disjoint-type-functions)))
	   (write t)
	   (write x)
	   (newline)
	   t))
       type-examples))
(set! i 0)
(define j 0)
(for-each (lambda (x y)
	    (set! j (+ 1 j))
	    (set! i 0)
	    (for-each (lambda (f)
			(set! i (+ 1 i))
			(cond ((and (= i j))
			       (cond ((not (f x)) (test #t f x))))
			      ((f x) (test #f f x)))
			(cond ((and (= i j))
			       (cond ((not (f y)) (test #t f y))))
			      ((f y) (test #f f y))))
		      disjoint-type-functions))
	  (list #t #\a '() 9739 '(test) record-error "test" 'car)
	  (list #f #\newline '() 3252 '(t . t) car "" 'nil))
(SECTION 4 1 2)
(test '(quote a) 'quote (quote 'a))
(test '(quote a) 'quote ''a)
(SECTION 4 1 3)
(test 12 (if #f + *) 3 4)
(SECTION 4 1 4)
(test 8 (lambda (x) (+ x x)) 4)
(define reverse-subtract
  (lambda (x y) (- y x)))
(test 3 reverse-subtract 7 10)
(define add4
  (let ((x 4))
    (lambda (y) (+ x y))))
(test 10 add4 6)
(test '(3 4 5 6) (lambda (x . y) (cons x y)) 3 4 5 6)
(test '(5 6) (lambda (x y . z) z) 3 4 5 6)
(SECTION 4 1 5)
(test 'yes 'if (if (> 3 2) 'yes 'no))
(test 'no 'if (if (> 2 3) 'yes 'no))
(test '1 'if (if (> 3 2) (- 3 2) (+ 3 2)))
(SECTION 4 1 6)
(define x 2)
(test 3 'define (+ x 1))
(set! x 4)
(test 5 'set! (+ x 1))
(SECTION 4 2 1)
(test 'greater 'cond (cond ((> 3 2) 'greater)
			   ((< 3 2) 'less)))
(test 'equal 'cond (cond ((> 3 3) 'greater)
			 ((< 3 3) 'less)
			 (else 'equal)))

(test 2 'cond (cond ((assv 'b '((a 1) (b 2)))
                     (cadr (assv 'b '((a 1) (b 2)))))
		     (else #f)))
(test #t 'and (and (= 2 2) (> 2 1)))
(test #f 'and (and (= 2 2) (< 2 1)))
(test '(f g) 'and (and 1 2 'c '(f g)))
(test #t 'and (and))
(test #t 'or (or (= 2 2) (> 2 1)))
(test #t 'or (or (= 2 2) (< 2 1)))
(test #f 'or (or #f #f #f))
(test #f 'or (or))
(test '(b c) 'or (or (memq 'b '(a b c)) (+ 3 0)))
(SECTION 4 2 2)
(test 6 'let (let ((x 2) (y 3)) (* x y)))
(test 35 'let (let ((x 2) (y 3)) (let ((x 7) (z (+ x y))) (* z x))))
(define x 34)
(test 5 'let (let ((x 3)) (define x 5) x))
(test 34 'let x)
(test 6 'let (let () (define x 6) x))
(test 34 'let x)

(SECTION 4 2 3)
(define x 0)
(test 6 'begin (begin (set! x 5) (+ x 1)))
(SECTION 4 2 4)

(SECTION 4 2 6)

(SECTION 5 2 1)
(define add3 (lambda (x) (+ x 3)))
(test 6 'define (add3 3))
(define first car)
(test 1 'define (first '(1 2)))
(define old-+ +)
(define + (lambda (x y) (list y x)))
(test '(3 6) add3 6)
(set! + old-+)
(test 9 add3 6)
(SECTION 5 2 2)
(test 45 'define
	(let ((x 5))
		(define foo (lambda (y) (bar x y)))
		(define bar (lambda (a b) (+ (* a b) a)))
		(foo (+ x 3))))
(define x 34)
(define (foo) (define x 5) x)
(test 5 foo)
(test 34 'define x)
(define foo (lambda () (define x 5) x))
(test 5 foo)
(test 34 'define x)
(define (foo x) ((lambda () (define x 5) x)) x)
(test 88 foo 88)
(test 4 foo 4)
(test 34 'define x)
(SECTION 6 1)
(test #f not #t)
(test #f not 3)
(test #f not (list 3))
(test #t not #f)
(test #f not '())
(test #f not (list))
(test #f not 'nil)

(test #t boolean? #f)
(test #f boolean? 0)
(test #f boolean? '())
(SECTION 6 2)
(test #t eqv? 'a 'a)
(test #f eqv? 'a 'b)
(test #t eqv? 2 2)
(test #t eqv? '() '())
(test #t eqv? '10000 '10000)
(test #f eqv? (cons 1 2)(cons 1 2))
(test #f eqv? (lambda () 1) (lambda () 2))
(test #f eqv? #f 'nil)
(let ((p (lambda (x) x)))
  (test #t eqv? p p))
(define gen-counter
 (lambda ()
   (let ((n 0))
      (lambda () (set! n (+ n 1)) n))))
(let ((g (gen-counter))) (test #t eqv? g g))
(test #f eqv? (gen-counter) (gen-counter))
(test #t eq? 'a 'a)
(test #f eq? (list 'a) (list 'a))
(test #t eq? '() '())
(test #t eq? car car)
(let ((x '(a))) (test #t eq? x x))
(let ((x (lambda (x) x))) (test #t eq? x x))

(test #t equal? 'a 'a)
(test #t equal? '(a) '(a))
(test #t equal? '(a (b) c) '(a (b) c))
(test #t equal? "abc" "abc")
(test #t equal? 2 2)
(SECTION 6 3)
(test '(a b c d e) 'dot '(a . (b . (c . (d . (e . ()))))))
(define x (list 'a 'b 'c))
(define y x)
(and list? (test #t list? y))
(set-cdr! x 4)
(test '(a . 4) 'set-cdr! x)
(test #t eqv? x y)
(test '(a b c . d) 'dot '(a . (b . (c . d))))
(and list? (test #f list? y))

(and list? (let ((x (list 'a))) (set-cdr! x x) 
                (test #f 'list? (list? x))))

(test #t pair? '(a . b))
(test #t pair? '(a . 1))
(test #t pair? '(a b c))
(test #f pair? '())

(test '(a) cons 'a '())
(test '((a) b c d) cons '(a) '(b c d))
(test '("a" b c) cons "a" '(b c))
(test '(a . 3) cons 'a 3)
(test '((a b) . c) cons '(a b) 'c)

(test 'a car '(a b c))
(test '(a) car '((a) b c d))
(test 1 car '(1 . 2))

(test '(b c d) cdr '((a) b c d))
(test 2 cdr '(1 . 2))

(test '(a 7 c) list 'a (+ 3 4) 'c)
(test '() list)

(test 3 length '(a b c))
(test 3 length '(a (b) (c d e)))
(test 0 length '())

(test '(x y) append '(x) '(y))
(test '(a b c d) append '(a) '(b c d))
(test '(a (b) (c)) append '(a (b)) '((c)))
(test '(a b c . d) append '(a b) '(c . d))
(test 'a append '() 'a)
(test '(x y z) append '(x y z) ()) ; norvig

(test '(c b a) reverse '(a b c))
(test '((e (f)) d (b c) a) reverse '(a (b c) d (e (f))))

(test 'c list-ref '(a b c d) 2)

(test '(a b c) memq 'a '(a b c))
(test '(b c) memq 'b '(a b c))
(test '#f memq 'a '(b c d))
(test '#f memq (list 'a) '(b (a) c))
(test '((a) c) member (list 'a) '(b (a) c))
(test '(101 102) memv 101 '(100 101 102))

(define e '((a 1) (b 2) (c 3)))
(test '(a 1) assq 'a e)
(test '(b 2) assq 'b e)
(test #f assq 'd e)
(test #f assq (list 'a) '(((a)) ((b)) ((c))))
(test '((a)) assoc (list 'a) '(((a)) ((b)) ((c))))
(test '(5 7) assv 5 '((2 3) (5 7) (11 13)))
(SECTION 6 4)
(test #t symbol? 'foo)
(test #t symbol? (car '(a b)))
(test #f symbol? "bar")
(test #t symbol? 'nil)
(test #f symbol? '())
(test #f symbol? #f)
;;; But first, what case are symbols in?  Determine the standard case:
(define char-standard-case char-upcase)
(if (string=? (symbol->string 'A) "a")
    (set! char-standard-case char-downcase))
(test #t 'standard-case
      (string=? (symbol->string 'a) (symbol->string 'A)))
(test #t 'standard-case
      (or (string=? (symbol->string 'a) "A")
	  (string=? (symbol->string 'A) "a")))

(define (str-copy s)
  (define (iter i len result)
    (if (= i len 1) result
        (begin
          (string-set! result i (string-ref s i))
          (iter (+ i 1) len result))))
  (let ((len (string-length s)))
    (iter 0 len (make-string len))))
(define (string-standard-case s)
  (define (iter i len result)
    (if (= i len) result
        (begin
          (string-set! result i (char-standard-case (string-ref s i)))
          (iter (+ i 1) len result))))
  (let ((len (string-length s)))
    (iter 0 len (make-string len))))
(test (string-standard-case "flying-fish") symbol->string 'flying-fish)
(test (string-standard-case "martin") symbol->string 'Martin)
(test #t 'standard-case (eq? 'a 'A))

(define x (string #\a #\b))
(define y (string->symbol x))
(string-set! x 0 #\c)
(test "cb" 'string-set! x)
(test "ab" symbol->string y)
(test y string->symbol "ab")

(test #t eq? 'mISSISSIppi 'mississippi)
(test 'JollyWog string->symbol (symbol->string 'JollyWog))

(SECTION 6 5 5)
(test #t number? 3)

(test #t = 22 22 22)
(test #t = 22 22)
(test #f = 34 34 35)
(test #f = 34 35)
(test #t > 3 -6246)
(test #f > 9 9 -2424)
(test #t >= 3 -4 -6246)
(test #t >= 9 9)
(test #f >= 8 9)
(test #t < -1 2 3 4 5 6 7 8)
(test #f < -1 2 3 4 4 5 6 7)
(test #t <= -1 2 3 4 5 6 7 8)
(test #t <= -1 2 3 4 4 5 6 7)
(test #f < 1 3 2)
(test #f >= 1 3 2)

(test #t zero? 0)
(test #f zero? 1)
(test #f zero? -1)
(test #f zero? -100)
(test #t positive? 4)
(test #f positive? -4)
(test #f positive? 0)
(test #f negative? 4)
(test #t negative? -4)
(test #f negative? 0)
;(test #t odd? 3)
;(test #f odd? 2)
;(test #f odd? -4)
;(test #t odd? -1)
;(test #f even? 3)
;(test #t even? 2)
;(test #t even? -4)
;(test #f even? -1)

(test 38 max 34 5 7 38 6)
(test -24 min 3  5 5 330 4 -24)

(test 7 + 3 4)
(test '3 + 3)
(test 0 +)
(test 4 * 4)
(test 1 *)

(test -1 - 3 4)
(test -3 - 3)
(test 7 abs -7)
(test 7 abs 7)
(test 0 abs 0)

(test 5 quotient 35 7)
(test -5 quotient -35 7)
(test -5 quotient 35 -7)
(test 5 quotient -35 -7)
(test 1 modulo 13 4)
(test 1 remainder 13 4)
(test 3 modulo -13 4)
(test -1 remainder -13 4)
(test -3 modulo 13 -4)
(test 1 remainder 13 -4)
(test -1 modulo -13 -4)
(test -1 remainder -13 -4)
(define (divtest n1 n2)
	(= n1 (+ (* n2 (quotient n1 n2))
		 (remainder n1 n2))))
(test #t divtest 238 9)
(test #t divtest -238 9)
(test #t divtest 238 -9)
(test #t divtest -238 -9)

;(test 4 gcd 0 4)
;(test 4 gcd -4 0)
;(test 4 gcd 32 -36)
;(test 0 gcd)
;(test 288 lcm 32 -36)
;(test 1 lcm)


(SECTION 6 5 6)
(test "0" number->string 0)
(test "100" number->string 100)
(test 100 string->number "100")
(test #f string->number "")
(test #f string->number ".")
(test #f string->number "d")
(test #f string->number "D")
(test #f string->number "i")
(test #f string->number "I")
(test #f string->number "3i")
(test #f string->number "3I")
(test #f string->number "33i")
(test #f string->number "33I")
(test #f string->number "3.3i")
(test #f string->number "3.3I")
(test #f string->number "-")
(test #f string->number "+")

(SECTION 6 6)
(test #t eqv? '#\  #\Space)
(test #t eqv? #\space '#\Space)
(test #t char? #\a)
(test #t char? #\()
(test #t char? #\ )
(test #t char? '#\newline)

(test #f char=? #\A #\B)
(test #f char=? #\a #\b)
(test #f char=? #\9 #\0)
(test #t char=? #\A #\A)

(test #t char<? #\A #\B)
(test #t char<? #\a #\b)
(test #f char<? #\9 #\0)
(test #f char<? #\A #\A)

(test #f char>? #\A #\B)
(test #f char>? #\a #\b)
(test #t char>? #\9 #\0)
(test #f char>? #\A #\A)

(test #t char<=? #\A #\B)
(test #t char<=? #\a #\b)
(test #f char<=? #\9 #\0)
(test #t char<=? #\A #\A)

(test #f char>=? #\A #\B)
(test #f char>=? #\a #\b)
(test #t char>=? #\9 #\0)
(test #t char>=? #\A #\A)

(test #f char-ci=? #\A #\B)
(test #f char-ci=? #\a #\B)
(test #f char-ci=? #\A #\b)
(test #f char-ci=? #\a #\b)
(test #f char-ci=? #\9 #\0)
(test #t char-ci=? #\A #\A)
(test #t char-ci=? #\A #\a)

(test #t char-ci<? #\A #\B)
(test #t char-ci<? #\a #\B)
(test #t char-ci<? #\A #\b)
(test #t char-ci<? #\a #\b)
(test #f char-ci<? #\9 #\0)
(test #f char-ci<? #\A #\A)
(test #f char-ci<? #\A #\a)

(test #f char-ci>? #\A #\B)
(test #f char-ci>? #\a #\B)
(test #f char-ci>? #\A #\b)
(test #f char-ci>? #\a #\b)
(test #t char-ci>? #\9 #\0)
(test #f char-ci>? #\A #\A)
(test #f char-ci>? #\A #\a)

(test #t char-ci<=? #\A #\B)
(test #t char-ci<=? #\a #\B)
(test #t char-ci<=? #\A #\b)
(test #t char-ci<=? #\a #\b)
(test #f char-ci<=? #\9 #\0)
(test #t char-ci<=? #\A #\A)
(test #t char-ci<=? #\A #\a)

(test #f char-ci>=? #\A #\B)
(test #f char-ci>=? #\a #\B)
(test #f char-ci>=? #\A #\b)
(test #f char-ci>=? #\a #\b)
(test #t char-ci>=? #\9 #\0)
(test #t char-ci>=? #\A #\A)
(test #t char-ci>=? #\A #\a)

(test #t char-alphabetic? #\a)
(test #t char-alphabetic? #\A)
(test #t char-alphabetic? #\z)
(test #t char-alphabetic? #\Z)
(test #f char-alphabetic? #\0)
(test #f char-alphabetic? #\9)
(test #f char-alphabetic? #\space)
(test #f char-alphabetic? #\;)

(test #f char-numeric? #\a)
(test #f char-numeric? #\A)
(test #f char-numeric? #\z)
(test #f char-numeric? #\Z)
(test #t char-numeric? #\0)
(test #t char-numeric? #\9)
(test #f char-numeric? #\space)
(test #f char-numeric? #\;)

(test #f char-whitespace? #\a)
(test #f char-whitespace? #\A)
(test #f char-whitespace? #\z)
(test #f char-whitespace? #\Z)
(test #f char-whitespace? #\0)
(test #f char-whitespace? #\9)
(test #t char-whitespace? #\space)
(test #f char-whitespace? #\;)

(test #f char-upper-case? #\0)
(test #f char-upper-case? #\9)
(test #f char-upper-case? #\space)
(test #f char-upper-case? #\;)

(test #f char-lower-case? #\0)
(test #f char-lower-case? #\9)
(test #f char-lower-case? #\space)
(test #f char-lower-case? #\;)

(test #\A char-upcase #\A)
(test #\A char-upcase #\a)
(test #\a char-downcase #\A)
(test #\a char-downcase #\a)
(SECTION 6 7)
;(test #t string? "The word \"recursion\\\" has many meanings.")
(test #t string? "")
(define f (make-string 3 #\*))
(test "?**" 'string-set! (begin (string-set! f 0 #\?) f))
(test "abc" string #\a #\b #\c)
(test "" string)
(test 3 string-length "abc")
(test #\a string-ref "abc" 0)
(test #\c string-ref "abc" 2)
(test 0 string-length "")

(SECTION 6 8)
(SECTION 6 9)
(test #t procedure? car)
(test #f procedure? 'car)
(test #t procedure? (lambda (x) (* x x)))
(test #f procedure? '(lambda (x) (* x x)))
(test 7 apply + (list 3 4))
(test 7 apply (lambda (a b) (+ a b)) (list 3 4))
(test '() apply list '())

(test '(b e h) map cadr '((a b) (d e) (g h)))
(test '(5 7 9) map + '(1 2 3) '(4 5 6))
(test '() map cadr '())
(newline)
"last item in file"