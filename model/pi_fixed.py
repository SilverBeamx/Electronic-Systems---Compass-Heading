from binary_fractions import TwosComplement, Binary
from math import pi

output_integer_bits = 2  # atan max value is pi/2 ~ 1.57, so 2 bits for integer part
output_decimal_bits = 5  # high precision for decimal part
output_width = 1 + output_integer_bits + output_decimal_bits  # 1 sign bit + integer bits + decimal bits

for pis in [pi, -pi, pi/2, -pi/2]:
    pi_float_repr = TwosComplement(pis)
    sign, pi_float_repr_integer, pi_float_repr_decimal, _ = pi_float_repr.components()
    # Pad integer part if needed
    if len(pi_float_repr_integer) < output_integer_bits:
        pi_float_repr_integer = pi_float_repr_integer[0] * (output_integer_bits - len(pi_float_repr_integer)) + pi_float_repr_integer
    # Pad decimal part if needed
    if len(pi_float_repr_decimal) < output_decimal_bits:
        pi_float_repr_decimal = pi_float_repr_decimal + "0" * (output_decimal_bits - len(pi_float_repr_decimal))
    # Truncate decimal part to the desired number of bits
    pi_float_repr_decimal = pi_float_repr_decimal[:output_decimal_bits]
    pi_truncated_fixed_point_string = (
                                         pi_float_repr_integer +
                                         "." + 
                                         pi_float_repr_decimal)
    pi_truncated_fixed_point_repr = TwosComplement(pi_truncated_fixed_point_string)

    print(f"{pis} fixed-point representation: {pi_float_repr} | {pi_truncated_fixed_point_string} | {pi_truncated_fixed_point_repr}")