API for using integers as bitvectors/sets.  In practice this is much
faster than bitvectors since they are just integers, but the Common
Lisp sequence API is unavailable as a consequence.  Hence this API
aims to bridge the gap and make working with integers as
bitvectors/sets more convenient.

Examples:

;; Create 8-bit intvec with all bits initialized to 1:
(defvar *vec*
  (make-full-intvec 8))
==> 255

;; Remove the 1 at the 0th bit:
(setf *vec*
  (intvec-remove *vec* 0))
==> 254

;; Insert it again:
(setf *vec*
  (intvec-insert *vec* 0))
==> 255

;; Check if it's there?
(intvec-member *vec* 0)
==> T

;; Remove it again
(setf *vec*
  (intvec-remove *vec* 0))
==> 254

;; Convert to a bit-vector
(intvec->sequence 'bit-vector *vec*)
==> #*01111111

;; Or list
(intvec->sequence 'list *vec*)
==> (0 1 1 1 1 1 1 1)

Note that printing an intvec in binary will result in a reversed bit
sequence as would be seen by any other sequence.

;; Make a string representation with the same bit-ordering as other
;; sequences:
(map 'string
     (lambda (i) (character (princ-to-string i)))
     (intvec->sequence 'list *vec*))
==> "01111111"
