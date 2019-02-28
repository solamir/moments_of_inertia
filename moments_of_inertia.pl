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
    H => 1.008,
    B => 10.810,
    C => 12.011,
    N => 14.007,
    O => 15.999,
    F => 18.998,
    Na => 22.990,
    Mg => 24.305,
    Al => 26.982,
    Si => 28.085,
    P => 30.974,
    S => 32.060,
    Cl => 35.450,
    Br => 79.904,
    I => 126.900,
);

# Checking keys and setting appropriate values:
# -v - display the program version
# -a[1-5] - accuracy of the calculation of the moments of inertia (default is -a3)
# -o[1-5] - number of significant figures in the output result
# -d - display the coordinates of the directing vectors
# -i key is checked below
my $version = "1.1_git_11";
my ($accuracy, $s_f_moment, $s_f_vector, $direct_vector_output);

foreach (@ARGV) {
   if ($_ eq "-v") {print "This is program version $version\n"; exit} 
}

foreach (@ARGV) {
    # Accuracy of the calculation
    if ($_ eq "-a1") {$accuracy = 0.1; $s_f_vector = 1; last}
    elsif ($_ eq "-a2") {$accuracy = 0.05; $s_f_vector = 2; last}
    elsif ($_ eq "-a3") {$accuracy = 0.01; $s_f_vector = 2; last}
    elsif ($_ eq "-a4") {$accuracy = 0.005; $s_f_vector = 3; last}
    elsif ($_ eq "-a5") {$accuracy = 0.001; $s_f_vector = 3; last}
    else {$accuracy = 0.01}
}

foreach (@ARGV) {
    # Number of significant figures in the output result
    if ($_ eq "-o1") {$s_f_moment = 1; last}
    elsif ($_ eq "-o2") {$s_f_moment = 2; last}
    elsif ($_ eq "-o3") {$s_f_moment = 3; last}
    elsif ($_ eq "-o4") {$s_f_moment = 4; last}
    elsif ($_ eq "-o5") {$s_f_moment = 5; last}
    else {$s_f_moment = 3}
}

foreach (@ARGV) {
    if ($_ eq "-d") {$direct_vector_output = "true"; last}
}

# Opening a file and reading information
my $filename = $ARGV[-1];
open(DATA, $filename) or die "Could not open file $filename $!";
chomp(my @xyz = <DATA>);
close DATA;

# The number of atoms in a molecule
my $total_number_of_atoms = shift @xyz;

# Delete comments
shift @xyz;

# Displays preliminary information about the calculation
$filename =~ s/...$/txt/; # Replacing file name extension with .txt
open OUTPUT, ">>", ${filename};
print OUTPUT "This is Moment of inertia version $version\n";

my $time = localtime;
print OUTPUT "System date is $time\n";
print OUTPUT "Calculation for data from file $ARGV[-1]\n";
print OUTPUT "\n";
print OUTPUT "The calculation with step of the directing vector is $accuracy\n";

# Delete first and last whitespace
foreach (@xyz) {s/^\s+|\s+$//g}

# Replacing the character of an element in a string with the value of its atomic mass
foreach (@xyz) {
    my @atom_data = split;
    if ($atom_data[0] =~ /H$/) {$atom_data[0] = $atomic_masses{"H"}}
    if ($atom_data[0] =~ /B$/) {$atom_data[0] = $atomic_masses{"B"}}
    if ($atom_data[0] =~ /C$/) {$atom_data[0] = $atomic_masses{"C"}}
    if ($atom_data[0] =~ /N$/) {$atom_data[0] = $atomic_masses{"N"}}
    if ($atom_data[0] =~ /O$/) {$atom_data[0] = $atomic_masses{"O"}}
    if ($atom_data[0] =~ /F$/) {$atom_data[0] = $atomic_masses{"F"}}
    if ($atom_data[0] =~ /Na$/) {$atom_data[0] = $atomic_masses{"Na"}}
    if ($atom_data[0] =~ /Mg$/) {$atom_data[0] = $atomic_masses{"Mg"}}
    if ($atom_data[0] =~ /Al$/) {$atom_data[0] = $atomic_masses{"Al"}}
    if ($atom_data[0] =~ /Si$/) {$atom_data[0] = $atomic_masses{"Si"}}
    if ($atom_data[0] =~ /P$/) {$atom_data[0] = $atomic_masses{"P"}}
    if ($atom_data[0] =~ /S$/) {$atom_data[0] = $atomic_masses{"S"}}
    if ($atom_data[0] =~ /Cl$/) {$atom_data[0] = $atomic_masses{"Cl"}}
    if ($atom_data[0] =~ /Br$/) {$atom_data[0] = $atomic_masses{"Br"}}
    if ($atom_data[0] =~ /I$/) {$atom_data[0] = $atomic_masses{"I"}}                        
    $_ = "@atom_data";
}

# Сreating masses and coordinates arrays
my (@masses, @X, @Y, @Z);
foreach (@xyz) {push @masses, (split)[0]}
foreach (@xyz) {push @X, (split)[1]}
foreach (@xyz) {push @Y, (split)[2]}
foreach (@xyz) {push @Z, (split)[3]}

# Finding the coordinates of the center of mass
my ($sum_Xm, $sum_Ym, $sum_Zm, $sum_m);

for (my $n = 0; $n <= $total_number_of_atoms - 1; $n++) {
    $sum_Xm += $masses[$n] * $X[$n];
    $sum_Ym += $masses[$n] * $Y[$n];
    $sum_Zm += $masses[$n] * $Z[$n];
    $sum_m += $masses[$n];
}

my $X_c = $sum_Xm / $sum_m;
my $Y_c = $sum_Ym / $sum_m;
my $Z_c = $sum_Zm / $sum_m;

my $small_space = "-" x 49;
print OUTPUT "\n";
print OUTPUT "$small_space\n";
printf OUTPUT "|%-47s|\n", "Coordinates of the center of gravity";
print OUTPUT "$small_space\n";
printf OUTPUT "|%-15s|%-15s|%-15s|\n", "x", "y", "z";
print OUTPUT "$small_space\n";
printf OUTPUT "|%-15.5f|%-15.5f|%-15.5f|\n", $X_c, $Y_c, $Z_c;
print OUTPUT "$small_space\n";

# The search of the moments of inertia with relative to the various lines passing through the center of masses
# @I is array of inertia moments, and @XaYaZa is array of coordinates of the directing vectors of the lines
# corresponding to this moment of inertia. The lines take all the spatial directions and for each straight line
# the moment of inertia of the molecule is calculated relative to this line.
my (@I, @X_a, @Y_a, @Z_a);

for (my $X_a = 0; $X_a <= 1; $X_a = $X_a + $accuracy) {
    for (my $Y_a = -1; $Y_a <= 1; $Y_a = $Y_a + $accuracy) {
        for (my $Z_a = -1; $Z_a <= 1; $Z_a = $Z_a + $accuracy) {
            my $I = 0;
            for (my $n = 0; $n <= $total_number_of_atoms - 1; $n++) {
                my $Ii = $masses[$n] * (&distance($X[$n], $Y[$n], $Z[$n], $X_a, $Y_a, $Z_a)) ** 2;
                $I += $Ii;
            }
            push @I, $I;
            push @X_a, $X_a;
            push @Y_a, $Y_a;
            push @Z_a, $Z_a;
        }
    }
}

# Find Ix, Iz and its directing vector сoordinates
my @I_sort = sort { $a <=> $b } @I;
my $I_min = $I_sort[0];
my $I_max = $I_sort[-1];

print OUTPUT "\n";
print OUTPUT "$small_space\n";
printf OUTPUT "|%-47s|\n", "Moments of inertia, Da*A^2";
print OUTPUT "$small_space\n";
printf OUTPUT "|%-23s|%-23s|\n", "Ix", "Iz";
print OUTPUT "$small_space\n";
printf OUTPUT "|%-23.${s_f_moment}f|%-23.${s_f_moment}f|\n", $I_min, $I_max;
print OUTPUT "$small_space\n";

my @XaYaZa_MIN = &return_XaYaZa_MIN($I_min);
my @XaYaZa_MAX = &return_XaYaZa_MAX($I_max);

if ($direct_vector_output) {
    print OUTPUT "\n";
    print OUTPUT "$small_space\n";
    printf OUTPUT "|%-47s|\n", "Coordinates of the directing vectors";
    print OUTPUT "$small_space\n";
    printf OUTPUT "|%11s|%-11s|%-11s|%-11s|\n", "", "i", "j", "k";
    print OUTPUT "$small_space\n";
    printf OUTPUT "|%-11s|%-11.${s_f_vector}f|%-11.${s_f_vector}f|%-11.${s_f_vector}f|\n", "a_x", $XaYaZa_MIN[0], $XaYaZa_MIN[1], $XaYaZa_MIN[2];
    print OUTPUT "$small_space\n";
    printf OUTPUT "|%-11s|%-11.${s_f_vector}f|%-11.${s_f_vector}f|%-11.${s_f_vector}f|\n", "a_z", $XaYaZa_MAX[0], $XaYaZa_MAX[1], $XaYaZa_MAX[2];
    print OUTPUT "$small_space\n";
}

# Displaying initial data
foreach (@ARGV) {
    if ($_ eq "-i") {
        my @initial_data = map $_ . "\n", @xyz;
        print OUTPUT "\n";
        print OUTPUT "Initial data:\n";
        foreach (@initial_data) {printf OUTPUT "%-6s %8s %8s %8s\n", (split)[0], (split)[1], (split)[2], (split)[3]}
        print OUTPUT "\n";
    }
}

my $space = "-" x 55;
print OUTPUT "$space\n";

close OUTPUT;

# ======================================================================
# =========================== Functions ================================
# ======================================================================

# The function returns the distance between the atom and the line defined by the directing vector a = (X_a; Y_a; Z_a):
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

# The functions returns the value of the coordinates of the directing vector according to
# the number of minimum or maximum moment of inertia in the corresponding array:
# &return_XaYaZa_MIN($I_min)
# &return_XaYaZa_MAX($I_max)
sub return_XaYaZa_MIN {
    my @coord_MIN;
    my $count = 0;
    foreach (@I) {
        if ($_ =~ /$I_min/) {
            @coord_MIN = ($X_a[$count], $Y_a[$count], $Z_a[$count]);
            return @coord_MIN;
        }
        $count++;
    }
}

sub return_XaYaZa_MAX {
    my @coord_MAX;
    my $count = 0;
    foreach (@I) {
        if ($_ =~ /$I_max/) {
            @coord_MAX = ($X_a[$count], $Y_a[$count], $Z_a[$count]);
            return @coord_MAX;
        }
        $count++;
    }
}