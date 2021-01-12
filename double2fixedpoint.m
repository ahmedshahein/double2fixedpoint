function x_fxp = double2fixedpoint(x, S, WL, FL, OF)
% -------------------------------------------------------------------
%  x_fxp = double2fixedpoint(x, S, WL, FL, OF)
%
%  The double2fixedpoint function is developed to convert double or
%  float numbers to fixed-point representation.
%  The function output is a struct data-type
%  The input to the function can be struct or double/float number.
%  The function operates in single values. A wrapper is required for
%  arrays.
%  The function output is 2's complement for signed numbers.
%
%  Function Inputs:
%   S: Sign-bit       0-> Unsigned, 1-> Signed
%   WL: Word length
%   FL: Fraction length
%   OF: Overflow      "Wrap" "Saturate"
%
%  Function Output:
%   fxp = struct(
%               'S', Sign digit
%               'WL', Word-length
%               'FL', Fraction-length
%               'int', Integer representation of fixed-point number
%               'bin', Binary representation of fixed-point number
%               'sgn', Sign bit
%               'dec', Decimal part of fixed-point number (LHS of decimal point)
%               'frac', Fraction part of fixed-point (RHS of decimal point)
%               'fxp', Fixed-point number (quantized)
%               'float', Float/Double representation of number (copy of input)
%               'max', Maximum (uppoer bound) of fixed-point number based
%                      on specified range by (S/WL/FL) positive number
%               'min', Maximum (uppoer bound) of fixed-point number based
%                      on specified range by (S/WL/FL) negative number for
%                      signed and zero for unsigned
%               'DR_dB', Dynamic range based on specified range by
%                        (S/WL/FL) equivelent to ratio between Maximum
%                        and 1
%               'res', Resolution based on specified range by (S/WL/FL)
%                      determined by reciprocal of 2^FL
%               'of_flag', Flag indicating that overflow has been occured
%               );
%
%  Intermediate Parameters:
%   IL: Integer length = WL - FL
%   Resolution: 1/2^FL
%   Maximum = 2^(IL-S) - Resolution
%   Minimum = 0 [Unsigned], -2^(IL-S) [Signed]
%
%  Fixed-point Representation:
%   Unsigned:                  2^(IL-1) + 2^(IL-2) ... 2^(1) + 2^(0) [.] 2^(-1) + 2^(-2) ... 2^-(FL-1) + 2^-(FL)
%   Signed:   2^(SxIL) -1^S x {2^(IL-1) + 2^(IL-2) ... 2^(1) + 2^(0) [.] 2^(-1) + 2^(-2) ... 2^-(FL-1) + 2^-(FL)}
%   Fixed-point number = Decimal Part[.]Fraction Part
%   where [.] is the decimal point 
%  Example:
%   x_fxp = double2fixedpoint(5.65236589,0,10,6,'Wrap'); 5.65625 [362]
%   x_fxp = double2fixedpoint(5.65236589,1,10,6,'Wrap'); 5.65625 [362]
%   x_fxp = double2fixedpoint(5.65236589,1,12,6,'Wrap'); 5.65625 [362]
%   x_fxp = double2fixedpoint(5.65236589,1,12,8,'Wrap'); 5.65234375 [1447]
%
%
% -------------------------------------------------------------------
% Copyright (C) 2021 Ahmed Shahein
% ahmed.shahein@vlsi-design.org
% -------------------------------------------------------------------
% Check if function has 5 input parameters
if nargin < 5,
    disp('### Error: Missing input parameter');
    x_fxp = [];
    return
else
    % Input is double/float
    if ~isstruct(x),
        % Compute integer-length (IL)
        IL = WL - FL;
        % Compute fixed-point resolution
        Resolution = 2^-FL;
        % Determine Signed/Unsigned data-type, and compute upper and lower
        % bounds
        if S == 1
            Minimum = -2^(IL-S);
            Maximum =  2^(IL-S) - Resolution;
        else
            Minimum =  0;
            Maximum =  2^(IL-S) - Resolution;
            if x < 0,
                disp('### ERROR: Negative number for unsigned data-type.');
                return
            end
        end
        % Compute dynamic range in dB
        DR      = 20*log10(Maximum-1);
        % Check if input is Power-Of-Two (POT) number
        if mod(sqrt(abs(x)),2) == 0
            pot_size = floor(abs(x)/2^IL)-1;
        else
            pot_size = floor(abs(x)/2^IL);
        end
        % Overflow action setting
        if strcmp(OF, 'Wrap'),
            if x > Maximum,
                x = x - pot_size*2^IL;
                of_flag = 1;
            elseif x < Minimum,
                x = x + pot_size*2^IL;
                of_flag = 1;
            else
                of_flag = 0;
            end
        elseif strcmp(OF, 'Saturate'),
            if x > Maximum,
                x = Maximum;
                of_flag = 1;
            elseif x < Minimum,
                x = Minimum;
                of_flag = 1;
            else
                of_flag = 0;
            end
        end
        % Sign-bit extraction, prepare for rounding        
        if S == 1
            if x < 0,
                sgn = -1;
                sel_ceil = 1;
            else
                sgn = 1;
                sel_ceil = 0;
            end
            x = abs(x);
        else
            sgn = 1;
            sel_ceil = 0;
        end
        % Integer representation of fixed-point number
        if sel_ceil,
            x_tmp = 2^IL - x;
            x_int_fxp = round(x_tmp*2^FL);            
        else
            x_int_fxp = round(x*2^FL);
        end        
        x_int = round(x*2^FL);
        % Binary representation of fixed-point number
        x_bin = de2bi(x_int,WL,'left-msb');
        % Fixed-point representation as decimal and fraction parts
        p = 1:FL;
        frac = 2.^-p;
        x_frac = sum(x_bin(WL-FL+1:end).*frac);
        p = 0:IL-1;
        dec = fliplr(2.^p);
        x_dec =  sum(x_bin(1:IL).*dec);
        % Fixed-point number == dec[.]fraction
        x_fix = x_dec + x_frac;
        % Fixed-point struct output assignment
        x_fxp.S         = S;
        x_fxp.WL        = WL;
        x_fxp.FL        = FL;
        x_fxp.int       = x_int_fxp;
        x_fxp.bin       = de2bi(x_int_fxp,WL,'left-msb');
        x_fxp.sgn       = sgn;
        x_fxp.dec       = x_dec;
        x_fxp.frac      = x_frac;
        x_fxp.fxp       = sgn*x_fix;
        x_fxp.float     = sgn*x;
        x_fxp.max       = Maximum;
        x_fxp.min       = Minimum;
        x_fxp.DR_dB     = DR;
        x_fxp.res       = Resolution;
        x_fxp.err       = abs(x - x_fix);
        x_fxp.of_flag   = of_flag;
    % Input is struct of fxp data-type
    else
        if ( isfield(x, 'float') || isfield(x, 'int') || isfield(x, 'bin') || (isfield(x, 'dec') && isfield(x, 'frac')) ),
            if isfield(x, 'S') && ~isempty(S) && (x.S ~= S),
                disp('### ERROR: Incorrect sign assignment');
                x_fxp = [];
                return
            elseif isfield(x, 'S') && x.S == S && x.WL == WL && x.FL == FL,
                disp('### INFO: No conversion is required, both in & out are identical');
                x_fxp = [];
                return
            else
                x_tmp = x.float;
                % Recursive call of double2fixedpoint function
                % This case is used to type casting, or changing the
                % fixed-point configuration such as; bit-width extenstion
                % or shrinking
                x_fxp = double2fixedpoint(x_tmp, S, WL, FL, OF);
            end
        else
            disp('### ERROR: Input struct is missing param(s) float|int|bin|dec/frac');
            x_fxp = [];
            return
        end
    end
end
% EOF