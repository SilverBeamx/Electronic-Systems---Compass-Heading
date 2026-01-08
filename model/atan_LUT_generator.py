from binary_fractions import TwosComplement, Binary
from fractions import Fraction
from math import atan, pi

# The address width for the LUT is 8 bits
# It has been decided for it ot be a signed fixed point decimal
# where 1 bit for the sign, 4 for the integer part, 3 for the decimal part.
# This means a min value of -16 to a max of 15.875, in 0.125 increments.

integer_bits = 5
decimal_bits = 6
input_width = 1 + integer_bits + decimal_bits  # 1 sign bit + integer bits + decimal bits

output_integer_bits = 2  # atan max value is pi/2 ~ 1.57, so 2 bits for integer part
output_decimal_bits = 5  # high precision for decimal part
output_width = 1 + output_integer_bits + output_decimal_bits  # 1 sign bit + integer bits + decimal bits

start = -2**(integer_bits+decimal_bits)
num_entries = 2**(integer_bits+decimal_bits+1)

mname = "atan_lut_" + str(num_entries) + "_" + str(output_width) + "bit"
fname = mname + ".vhd"

out_file = open(fname, "w")

out_file.write("library IEEE;\n")
out_file.write("  use IEEE.std_logic_1164.all;\n")
out_file.write("  use IEEE.numeric_std.all;\n")
out_file.write("\n")
out_file.write("entity " + mname + " is\n")
out_file.write("  port (\n")
out_file.write("    address  : in  std_logic_vector(" + str(input_width-1) + " downto 0);\n")
out_file.write("    atan_out : out std_logic_vector(" + str(output_width-1) + " downto 0)\n")
out_file.write("  );\n")
out_file.write("end entity;\n")
out_file.write("\n")
out_file.write("architecture rtl of " + mname + " is\n")
out_file.write("\n")
out_file.write("  type LUT_t is array (natural range 0 to " + str(num_entries-1) + ") of natural;\n")
out_file.write("  constant LUT: LUT_t := (\n")

for entry in range(0, num_entries):
    # Convert entry to binary and twos complement fixed-point representation
    binary_repr = Binary(entry).no_prefix()
    binary_repr = str(binary_repr).zfill(input_width)
    fixed_point_repr = binary_repr[:-decimal_bits] + "." + binary_repr[-decimal_bits:]
    # Convert fixed-point representation to float and compute atan
    float_repr = TwosComplement(fixed_point_repr).to_float()
    atan_value = atan(float_repr)
    print(f"Index {entry}: {float_repr} | {binary_repr} | {fixed_point_repr} | {atan(float_repr)}")
    # Convert atan result to fixed-point representation for output truncating it to the desired number of decimal bits
    atan_fixed_point_repr = TwosComplement(atan_value)
    sign, atan_fixed_point_repr_integer, atan_fixed_point_repr_decimal, _ = atan_fixed_point_repr.components()
    # Pad integer part if needed
    if len(atan_fixed_point_repr_integer) < output_integer_bits:
        atan_fixed_point_repr_integer = atan_fixed_point_repr_integer[0] * (output_integer_bits - len(atan_fixed_point_repr_integer)) + atan_fixed_point_repr_integer
    # Pad decimal part if needed
    if len(atan_fixed_point_repr_decimal) < output_decimal_bits:
        atan_fixed_point_repr_decimal = atan_fixed_point_repr_decimal + "0" * (output_decimal_bits - len(atan_fixed_point_repr_decimal))
    # Truncate decimal part to the desired number of bits
    atan_fixed_point_repr_decimal = atan_fixed_point_repr_decimal[:output_decimal_bits]
    atan_fixed_point_equivalent_natural = Binary().to_float(str(sign) + 
                                         atan_fixed_point_repr_integer + 
                                         atan_fixed_point_repr_decimal)
    atan_truncated_fixed_point_string = (str(sign) + 
                                         atan_fixed_point_repr_integer + 
                                         "." + 
                                         atan_fixed_point_repr_decimal)
    atan_truncated_fixed_point_repr = TwosComplement(atan_truncated_fixed_point_string)
    print(f"    -> {atan_fixed_point_repr} | {atan_truncated_fixed_point_string} | {atan_truncated_fixed_point_repr}")
    print(f"    -> {atan_value} | {atan_truncated_fixed_point_repr.to_float()} | {atan_fixed_point_equivalent_natural}")
    # Create LUT line entry
    lut_line = "    " + str(entry) + " => " + str(int(atan_fixed_point_equivalent_natural))
    if entry != (num_entries-1):
        lut_line = lut_line +","
    # Format line with comments
    input_comment_formatted = f"({fixed_point_repr} | {float_repr})"
    output_comment_formatted = f"({atan_truncated_fixed_point_string} | {atan_truncated_fixed_point_repr.to_float()})"
    lut_line = f"{lut_line:<25} -- {input_comment_formatted:<30} => {output_comment_formatted:<30}\n"
    # Add line to file
    out_file.write(lut_line)

out_file.write("  );\n")
out_file.write("\n")
out_file.write("begin\n")

out_file.write("  atan_out <= std_logic_vector(to_unsigned(LUT(to_integer(unsigned(address)))," + str(output_width) + "));\n")

out_file.write("end architecture;\n")

out_file.close()