(define generic-on-key '("zenkaku-hankaku" "<Shift> " "<Alt> "))
(define generic-on-key? (make-key-predicate '("zenkaku-hankaku" "<Shift> " "<Alt> ")))
(define generic-off-key '("zenkaku-hankaku" "<Shift> " "<IgnoreShift><Control>/" "<IgnoreShift><Control>["))
(define generic-off-key? (make-key-predicate '("zenkaku-hankaku" "<Shift> " "<IgnoreShift><Control>/" "<IgnoreShift><Control>[")))
(define generic-begin-conv-key '(" "))
(define generic-begin-conv-key? (make-key-predicate '(" ")))
(define generic-commit-key '("<IgnoreCase><Control>j" "return" "<IgnoreCase><Control>m" "<IgnoreCase><Control>y"))
(define generic-commit-key? (make-key-predicate '("<IgnoreCase><Control>j" "return" "<IgnoreCase><Control>m" "<IgnoreCase><Control>y")))
(define generic-cancel-key '("escape" "<Control>[" "<IgnoreCase><Control>g"))
(define generic-cancel-key? (make-key-predicate '("escape" "<Control>[" "<IgnoreCase><Control>g")))
(define generic-next-candidate-key '(" " "down" "<IgnoreCase><Control>n"))
(define generic-next-candidate-key? (make-key-predicate '(" " "down" "<IgnoreCase><Control>n")))
(define generic-prev-candidate-key '("up" "<IgnoreCase><Control>p"))
(define generic-prev-candidate-key? (make-key-predicate '("up" "<IgnoreCase><Control>p")))
(define generic-next-page-key '("next"))
(define generic-next-page-key? (make-key-predicate '("next")))
(define generic-prev-page-key '("prior"))
(define generic-prev-page-key? (make-key-predicate '("prior")))
