     PROGRAM FORMAT
     IMPLICIT NONE
     REAL                         :: X
     CHARACTER (LEN=11)           :: FORM1
     CHARACTER (LEN=*), PARAMETER :: FORM2 = "( F12.3,A )"
     FORM1 = "( F12.3,A )"
     X = 12.0
     PRINT FORM1, X, ' HELLO '
     WRITE (*, FORM2) 2*X, ' HI '
     WRITE (*, "(F12.3,A )") 3*X, ' HI HI '
     END
