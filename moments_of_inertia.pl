#!/usr/bin/env perl

# ===============================================================================================
# This program is designed to calculate the minimum and maximum moments of inertia of a molecule,
# given by the coordinates of atoms in three-dimensional space as part of the structure-property
# studies carried out at the D. Mendeleev University of Chemical Technology of Russia. For all
# questions write to Mikhail Koverda (m.kov@pm.me)
# ===============================================================================================

use 5.010;
use strict;
use warnings;

# Atomic mass table of chemical elements in Daltons
my %atomic_masses = (
    "H" => 1.008,
    "B" => 10.810,
    "C" => 12.011,
    "N" => 14.007,
    "O" => 15.999,
    "F" => 18.998,
    "Na" => 22.990,
    "Mg" => 24.305,
    "Al" => 26.982,
    "Si" => 28.085,
    "P" => 30.974,
    "S" => 32.060,
    "Cl" => 35.450,
    "Br" => 79.904,
    "I" => 126.900,
);

# Checking keys and setting appropriate values:
# -v - display the program version
# -a[1-5] - accuracy of the calculation of the moments of inertia (default is -a3)
# -o[1-5] - number of significant figures in the output result
# -d - display the coordinates of the directing vectors
my $version = "0.1_git_2";
my ($accuracy, $significant_figures, $direct_vector_output);

foreach (@ARGV) {
   if ($_ eq "-v") {
        print "This is program version $version\n";
        exit;
    } 
}

foreach (@ARGV) {
    # Accuracy of the calculation
    if ($_ eq "-a1") {
        $accuracy = 0.1;
        last;
    }
    elsif ($_ eq "-a2") {
        $accuracy = 0.05;
        last;
    }
    elsif ($_ eq "-a3") {
        $accuracy = 0.01;
        last;
    }
    elsif ($_ eq "-a4") {
        $accuracy = 0.005;
        last;
    }
    elsif ($_ eq "-a5") {
        $accuracy = 0.001;
        last;
    }
    else {
        $accuracy = 0.01;
    }
}

foreach (@ARGV) {
    # Number of significant figures in the output result
    if ($_ eq "-o1") {
        $significant_figures = 1;
        last;
    }
    elsif ($_ eq "-o2") {
        $significant_figures = 2;
        last;
    }
    elsif ($_ eq "-o3") {
        $significant_figures = 3;
        last;
    }
    elsif ($_ eq "-o4") {
        $significant_figures = 4;
        last;
    }
    elsif ($_ eq "-o5") {
        $significant_figures = 5;
        last;
    }
    else {
        $significant_figures = 3;
    }
}

foreach (@ARGV) {
    if ($_ eq "-d") {
        $direct_vector_output = "true";
        last;
    }
}

# Opening a file and reading information
my $filename = "$ARGV[-1]";
open(DATA, "$filename") or die "Could not open file '$filename' $!";
chomp(my @xyz = <DATA>);

# The number of atoms in a molecule
my $total_number_of_atoms = shift @xyz;

# Delete comments
shift @xyz;

# Displays preliminary information about the calculation
open OUTPUT, ">>", "${filename}.txt";
print OUTPUT "\n";
print OUTPUT "Calculation for data from file $ARGV[-1]\n";
print OUTPUT "The calculation with step of the directing vector is $accuracy\n";

# Delete first and last whitespace
foreach (@xyz) {s/^\s+|\s+$//g}

# Replacing the character of an element in a string with the value of its atomic mass
foreach (@xyz) {
    my @atom_data = split;
    if ($atom_data[0] =~ /^H$/) {$atom_data[0] = $atomic_masses{"H"}}
    if ($atom_data[0] =~ /^B$/) {$atom_data[0] = $atomic_masses{"B"}}
    if ($atom_data[0] =~ /^C$/) {$atom_data[0] = $atomic_masses{"C"}}
    if ($atom_data[0] =~ /^N$/) {$atom_data[0] = $atomic_masses{"N"}}
    if ($atom_data[0] =~ /^O$/) {$atom_data[0] = $atomic_masses{"O"}}
    if ($atom_data[0] =~ /^F$/) {$atom_data[0] = $atomic_masses{"F"}}
    if ($atom_data[0] =~ /^Na$/) {$atom_data[0] = $atomic_masses{"Na"}}
    if ($atom_data[0] =~ /^Mg$/) {$atom_data[0] = $atomic_masses{"Mg"}}
    if ($atom_data[0] =~ /^Al$/) {$atom_data[0] = $atomic_masses{"Al"}}
    if ($atom_data[0] =~ /^Si$/) {$atom_data[0] = $atomic_masses{"Si"}}
    if ($atom_data[0] =~ /^P$/) {$atom_data[0] = $atomic_masses{"P"}}
    if ($atom_data[0] =~ /^S$/) {$atom_data[0] = $atomic_masses{"S"}}
    if ($atom_data[0] =~ /^Cl$/) {$atom_data[0] = $atomic_masses{"Cl"}}
    if ($atom_data[0] =~ /^Br$/) {$atom_data[0] = $atomic_masses{"Br"}}
    if ($atom_data[0] =~ /^I$/) {$atom_data[0] = $atomic_masses{"I"}}                        
    $_ = "@atom_data";
}

# Finding the coordinates of the center of mass
my ($sum_Xm, $sum_Ym, $sum_Zm, $sum_m);

foreach (@xyz) {
    $sum_Xm += (split)[0] * (split)[1];
    $sum_Ym += (split)[0] * (split)[2];
    $sum_Zm += (split)[0] * (split)[3];
    $sum_m += (split)[0];
}

my $X_c = $sum_Xm / $sum_m;
my $Y_c = $sum_Ym / $sum_m;
my $Z_c = $sum_Zm / $sum_m;

# Rounding the coordinates of the center of masses and their output
my $X_c_rounded = sprintf("%.5f", $X_c);
my $Y_c_rounded = sprintf("%.5f", $Y_c);
my $Z_c_rounded = sprintf("%.5f", $Z_c);

print OUTPUT "Coordinates of the center of gravity: ($X_c_rounded; $Y_c_rounded; $Z_c_rounded)\n";

# The search of the moments of inertia with relative to the various lines passing through the center of masses
# @I is array of inertia moments, and @XaYaZa is array of coordinates of the directing vectors of the lines
# corresponding to this moment of inertia. The lines take all the spatial directions and for each straight line
# the moment of inertia of the molecule is calculated relative to this line.
my (@I, @XaYaZa);

for (my $X_a = 0; $X_a <= 1; $X_a = $X_a + $accuracy) {
    for (my $Y_a = -1; $Y_a <= 1; $Y_a = $Y_a + $accuracy) {
        for (my $Z_a = -1; $Z_a <= 1; $Z_a = $Z_a + $accuracy) {
            my $I = 0;
            for (my $n = 1; $n <= $total_number_of_atoms; $n++) {
                my $Ii = &mass($n) * (&distance(&coordinates($n, "x"), &coordinates($n, "y"), &coordinates($n, "z"), $X_a, $Y_a, $Z_a)) ** 2;
                $I += $Ii;
            }
            push @I, $I;
            push @XaYaZa, ($X_a . ' ' . $Y_a . ' ' . $Z_a);
        }
    }
}

# Remove the first undef value from the arrays @I and @XaYaZa and find Ix, Iz and its directing vector сoordinates 
shift @I;
shift @XaYaZa;

my $I_min = &min(@I);
my $I_max = &max(@I);
my $I_min_rounded = sprintf("%.${significant_figures}f", $I_min);
my $I_max_rounded = sprintf("%.${significant_figures}f", $I_max);

print OUTPUT "Moment of inertia Ix is: $I_min_rounded Da*(Å^2)\n";
print OUTPUT "Moment of inertia Iz is: $I_max_rounded Da*(Å^2)\n";

if ($direct_vector_output) {
    my $XaYaZa_MIN = &return_XaYaZa_MIN($I_min);
    my $XaYaZa_MAX = &return_XaYaZa_MAX($I_max);
    print OUTPUT "Coordinates of the directing vector a_x = {i, j, k} is: $XaYaZa_MIN\n";
    print OUTPUT "Coordinates of the directing vector a_z = {i, j, k} is: $XaYaZa_MAX\n";
}

close OUTPUT;

# ======================================================================
# =========================== Functions ================================
# ======================================================================

# The function returns the atomic mass of the element with the number n:
# &mass(n)
sub mass {
    my @atom_data = split /\s+/, $xyz[$_[0] - 1];
    return $atom_data[0];
}

# The function returns the coordinates of the atom with the number n:
# &coordinates(n, ["x", "y", "z"])
sub coordinates {
    my @atom_data = split /\s+/, $xyz[$_[0] - 1];
    if ($_[1] =~ /x/) {return $atom_data[1]}
    if ($_[1] =~ /y/) {return $atom_data[2]}
    if ($_[1] =~ /z/) {return $atom_data[3]}
}

# The function returns the distance between the atom and the line defined by the directing vector c = (X_a; Y_a; Z_a):
# &distance(x, y, z, X_a, Y_a, Z_a)
sub distance {
    my $u_x = $X_c - $_[0];
    my $u_y = $Y_c - $_[1];
    my $u_z = $Z_c - $_[2];

    my $i = $_[5] * $u_y - $_[4] * $u_z;
    my $j = -1 * ($_[5] * $u_x - $_[3] * $u_z);
    my $k = $_[4] * $u_x - $_[3] * $u_y;

    my $distance = sqrt($i ** 2 + $j ** 2 + $k ** 2) / sqrt($_[3] ** 2 + $_[4] ** 2 + $_[5] ** 2);
    return $distance;
}

# Functions to find the minimum or maximum value:
# &min(@array)
sub min {
    my ($min, @vars) = @_;
    for (@vars) {$min = $_ if $_ < $min}
    return $min;
}

sub max {
    my ($max, @vars) = @_;
    for (@vars) {$max = $_ if $_ > $max}
    return $max;
}

# The functions returns the value of the coordinates of the directing vector according to
# the number of minimum or maximum moment of inertia in the corresponding array:
# &return_XaYaZa_MIN($I_min)
# &return_XaYaZa_MAX($I_max)
sub return_XaYaZa_MIN {
    my $count = 0;
    foreach (@I) {
        if ($_ =~ /$I_min/) {return $XaYaZa[$count]}
        $count++;
    }
}

sub return_XaYaZa_MAX {
    my $count = 0;
    foreach (@I) {
        if ($_ =~ /$I_max/) {return $XaYaZa[$count]}
        $count++;
    }
}