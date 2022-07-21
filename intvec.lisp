(defpackage #:intvec
  (:use :cl)
  (:export
   ;; walking
   :do-intvec
   ;; basic API
   :make-full-intvec
   :intvec-insert
   :intvec-remove
   :intvec-member
   :intvec-length
   :intvec-singleton-value
   :intvec-empty-p
   ;; sequence conversion
   :intvec->sequence
   :sequence->intvec
   :intvec-filled-indices))

(in-package :intvec)

;; intvec walking
(defmacro do-intvec ((var intvec &optional result) &body body)
  "Iterate over all values in the intvec"
  (let* ((v (gensym "intvec"))
         (index (gensym "index"))
         (val (gensym "val")))
    `(let* ((,v ,intvec)
            (,var NIL))
       (do ((,index 0 (1+ ,index)))
           ((zerop ,v) ,result)
         (symbol-macrolet ((,val (mod ,v 2)))
           (when (plusp ,val)
             (setf ,var ,index)
             ,@body))
         (setf ,v (floor ,v 2))))))

;;; Integer bitvector API
(declaim (inline INTVEC-INSERT INTVEC-REMOVE INTVEC-MEMBER
                 INTVEC-SIZE INTVEC-LENGTH
                 INTVEC-EMPTY-P
                 MAKE-FULL-INTVEC))

(defun intvec-insert (intvec value)
  "Returns new intvec with value inserted"
  (logior intvec
          (ash 1 value)))

(defun intvec-remove (intvec value)
  "Returns new intvec with value removed"
  (logxor intvec
          (logand intvec
                  (ash 1 value))))

(defun intvec-member (intvec value)
  "Returns boolean denoting whether or not value is in intvec"
  (logbitp value intvec))

(defun intvec-size (intvec)
  "Return number of non-zero bits in the intvec, i.e. its size as a set."
  (logcount intvec))

(defun intvec-length (intvec)
  "Returns length of intvec if it were a sequence"
  (integer-length intvec))

(defun intvec-empty-p (intvec)
  "Returns T if intvec has no items, NIL otherwise"
  (zerop (logcount intvec)))

(defun intvec-filled-indices (intvec)
  "Convert intvec to list of indices where 1 bits are located."
  (let* ((result nil))
    (do-intvec (i intvec result)
      (push i result))))

(defun intvec->sequence (type intvec)
  "Returns sequence filled with 0s and 1s from intvec 1-bit indices"
  (let* ((result (make-sequence type
                                (integer-length intvec)
                                :initial-element 0)))
    (do-intvec (i intvec result)
      (setf (elt result i) 1))))

(defun sequence->intvec (sequence)
  "Return integer when supplied a list of indices for 1 bits."
  (reduce (let* ((index 0))
            (lambda (vec val)
              (logior vec
                      (ash val (1- (incf index))))))
          sequence
          :initial-value 0))

(defun make-full-intvec (length)
  "Returns completely filled intvec of given length"
  (1- (ash 1 length)))
