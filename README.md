# double2fixedpoint
Convert double data-taype to fixed-point data-type
The double2fixedpoint function is developed to convert double or float numbers to fixed-point representation.
The function output is a struct data-type The input to the function can be struct or double/float number.
The function operates in single values. A wrapper is required for arrays.
The function output is 2's complement for signed numbers.
The output is in struct format and has the following fields:
               'S', Sign digit
               'WL', Word-length
               'FL', Fraction-length
               'int', Integer representation of fixed-point number
               'bin', Binary representation of fixed-point number
               'sgn', Sign bit
               'dec', Decimal part of fixed-point number (LHS of decimal point)
               'frac', Fraction part of fixed-point (RHS of decimal point)
               'fxp', Fixed-point number (quantized)
               'float', Float/Double representation of number (copy of input)
               'max', Maximum (uppoer bound) of fixed-point number based
                      on specified range by (S/WL/FL) positive number
               'min', Maximum (uppoer bound) of fixed-point number based
                      on specified range by (S/WL/FL) negative number for
                      signed and zero for unsigned
               'DR_dB', Dynamic range based on specified range by
                        (S/WL/FL) equivelent to ratio between Maximum
                        and 1
               'res', Resolution based on specified range by (S/WL/FL)
                      determined by reciprocal of 2^FL
               'of_flag', Flag indicating that overflow has been occured
The usage is as follow:
x_fxp = double2fixedpoint(x, S, WL, FL, OF)
It is developed and tested on Ocave 5.2.0
