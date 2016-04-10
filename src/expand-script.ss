;;; expand-script.ss
;;;
;;; Copyright (c) 1998-2016 R. Kent Dybvig and Oscar Waddell
;;;
;;; Permission is hereby granted, free of charge, to any person obtaining a
;;; copy of this software and associated documentation files (the "Software"),
;;; to deal in the Software without restriction, including without limitation
;;; the rights to use, copy, modify, merge, publish, distribute, sublicense,
;;; and/or sell copies of the Software, and to permit persons to whom the
;;; Software is furnished to do so, subject to the following conditions:
;;;
;;; The above copyright notice and this permission notice shall be included in
;;; all copies or substantial portions of the Software.
;;;
;;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
;;; THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
;;; FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
;;; DEALINGS IN THE SOFTWARE.

(define expand-script
  (lambda (in out)
    (define noexpand "noexpand")
    (unless (string? in)
      (errorf 'expand-script "~s is not a string" in))
    (unless (string? out)
      (errorf 'expand-script "~s is not a string" out))
    (printf "expanding ~a with output to ~a\n" in out)
    (let ([sin (open-input-file in '(buffered))])
      (let ([sout (open-output-file out '(buffered replace mode #o755))])
        (if (and (eqv? (read-char sin) #\#)
                 (eqv? (read-char sin) #\!)
                 (memv (peek-char sin) '(#\space #\/)))
            (begin
              (fprintf sout "#!~c" (read-char sin))
              (let loop ()
                (let ([c (read-char sin)])
                  (unless (eof-object? c)
                    (write-char c sout)
                    (unless (eqv? c #\newline) (loop))))))
            (file-position sin 0))
        (let loop ()
          (let ([x (read sin)])
            (unless (eof-object? x)
              (let ([x (expand x)])
                (fasl-write x sout))
              (loop))))
        (close-input-port sin)
        (close-output-port sout)))))
