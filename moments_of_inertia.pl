#!/usr/bin/env perl

# ==============================================================================================
# This program is designed to calculate the moments of inertia of a molecule (Ix, Iy and Iz,
# where Ix is a minimum moment and Iz is a maximum moment), given by the coordinates of atoms in
# three-dimensional space as part of the structure-property studies carried out at the
# D. Mendeleev University of Chemical Technology of Russia. For all questions write to
# Mikhail Koverda (m.kov@pm.me)
# ==============================================================================================

use 5.010;
use strict;
#use warnings;

# Displaying version information
my $version = '1.3';

foreach (@ARGV) {
    if ($_ eq '-v' || $_ eq '--version') {
       print "The version of program is $version\n";
       exit;
    } 
}

# Display of brief help
foreach (@ARGV) {
    if ($_ eq '-h' || $_ eq '--help') {
       print "Usage: ./moment_of_inertia [OPTION] <file>\n";
       print "\n";
       print "Use the XYZ file as the input file.\n";
       print "\n";
       printf "%-15s%-15s%-15s\n", "Option", "Long option", "Meaning";
       printf "%-15s%-15s%-15s\n", "-v", "--version", "Show the version number and exit";
       printf "%-15s%-15s%-15s\n", "-h", "--help", "Show short help and exit";
       printf "%-30s%-15s\n", "-a[1-3]", "Set calculation accuracy (the bigger, the better),";
       printf "%30s%-15s\n", "", "default is -a3";
       exit;
    } 
}

# Setting the accuracy of the calculation and output results
my ($accuracy_1, $accuracy_2, $limit, $s_f_moment, $s_f_vector);

foreach (@ARGV) {
    # Accuracy of the calculation
    if ($_ eq '-a1') {
        $accuracy_1 = 0.1;
        $accuracy_2 = 0.05;
        $limit = 0.2;
        $s_f_moment = 3;
        $s_f_vector = 3;
        last;
    }
    elsif ($_ eq '-a2') {
        $accuracy_1 = 0.05;
        $accuracy_2 = 0.005;
        $limit = 0.1;
        $s_f_moment = 4;
        $s_f_vector = 4;
        last;
    }
    elsif ($_ eq '-a3') {
        $accuracy_1 = 0.01;
        $accuracy_2 = 0.0005;
        $limit = 0.02;
        $s_f_moment = 5;
        $s_f_vector = 5;
        last;
    }
    else {
        $accuracy_1 = 0.01;
        $accuracy_2 = 0.0005;
        $limit = 0.02;
        $s_f_moment = 5;
        $s_f_vector = 5;
    }
}

# Opening a file and reading information
# Lines containing the coordinates of the atoms are copied to the array @xyz.
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
open OUTPUT, ">>", $filename;
print OUTPUT "=============================================================\n";
print OUTPUT "Moment of inertia version $version\n";
print OUTPUT "\n";
print OUTPUT "https://github.com/solamir/moments_of_inertia\n";
print OUTPUT "Dmitry Mendeleev University of Chemical Technology of Russia\n";
print OUTPUT "=============================================================\n";
print OUTPUT "\n";

my $small_space = "-" x 49;
my $time = localtime;

print OUTPUT "System date is $time\n";
print OUTPUT "Calculation for data from file $ARGV[-1]\n";
print OUTPUT "\n";
print OUTPUT "Program parameters:\n";
print OUTPUT "Steps of the directing vectors = ${accuracy_1}, $accuracy_2\n";
print OUTPUT "Number of significant figures in the output result = $s_f_moment\n";
print OUTPUT "Total number of atoms = $total_number_of_atoms\n";
print OUTPUT "Output file is \'$filename\'\n";
print OUTPUT "\n";
print OUTPUT "$small_space\n";
print OUTPUT "Input data for calculation:\n";
print OUTPUT "\n";
foreach (@xyz) {print OUTPUT "$_\n"}

# Delete first and last whitespace in array @xyz
foreach (@xyz) {s/^\s+|\s+$//g}

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

# Checking the correctness of chemical elements in the input file
foreach (@xyz) {
    if ($_ =~ /^\D/) {
        die "Error! Unknown atom in source file!\n";
    }
}

print OUTPUT "\n";
print OUTPUT "$small_space\n";
print OUTPUT "Data after replacing characters with their atomic masses:\n";
print OUTPUT "\n";
foreach (@xyz) {printf OUTPUT "%-8s %8s %8s %8s\n", (split)[0], (split)[1], (split)[2], (split)[3]}

# Сreating masses and coordinates arrays
my (@masses, @X, @Y, @Z);
foreach (@xyz) {push @masses, (split)[0]}
foreach (@xyz) {push @X, (split)[1]}
foreach (@xyz) {push @Y, (split)[2]}
foreach (@xyz) {push @Z, (split)[3]}

# Finding the coordinates of the center of mass
# The coordinates of the center of mass are found as the weighted average coordinates of the atom,
# taking into account their mass
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

# Displays the coordinates of the center of mass
# Coordinates have the same accuracy as the coordinates in the source file
print OUTPUT "\n";
print OUTPUT "$small_space\n";
print OUTPUT "Finding the coordinates of the center of mass:\n";
print OUTPUT "\n";
print OUTPUT "\$sum_Xm = $sum_Xm\n";
print OUTPUT "\$sum_Ym = $sum_Ym\n";
print OUTPUT "\$sum_Zm = $sum_Zm\n";
print OUTPUT "\$sum_m = $sum_m\n";
print OUTPUT "\n";
print OUTPUT "$small_space\n";
printf OUTPUT "|%-47s|\n", "Coordinates of the center of gravity";
print OUTPUT "$small_space\n";
printf OUTPUT "|%-15s|%-15s|%-15s|\n", "x", "y", "z";
print OUTPUT "$small_space\n";
printf OUTPUT "|%-15.5f|%-15.5f|%-15.5f|\n", $X_c, $Y_c, $Z_c;
print OUTPUT "$small_space\n";

# The search of the moments of inertia with relative to the various lines passing through the center of masses
# @I is array of inertia moments, and @X_a, @Y_a and @Z_a is arrays of coordinates of the directing vectors of the lines
# corresponding to this moment of inertia. The lines take all the spatial directions and for each straight line
# the moment of inertia of the molecule is calculated relative to this line.
my (@I, @X_a, @Y_a, @Z_a);

for (my $X_a = 0; $X_a <= 1; $X_a = $X_a + $accuracy_1) {
    for (my $Y_a = -1; $Y_a <= 1; $Y_a = $Y_a + $accuracy_1) {
        for (my $Z_a = -1; $Z_a <= 1; $Z_a = $Z_a + $accuracy_1) {
            my $I;
            for (my $n = 0; $n <= $total_number_of_atoms - 1; $n++) {
                $I += $masses[$n] * (&distance($X[$n], $Y[$n], $Z[$n], $X_a, $Y_a, $Z_a)) ** 2;
            }
            push @I, $I;
            push @X_a, $X_a;
            push @Y_a, $Y_a;
            push @Z_a, $Z_a;
        }
    }
}

print OUTPUT "\n";
print OUTPUT "$small_space\n";
print OUTPUT "Search of the moments of inertia with relative to the various\n";
print OUTPUT "lines passing through the center of masses\n";

# Find Ix, Iz and its directing vector сoordinates
my @I_sort = sort { $a <=> $b } @I;
my $I_x = $I_sort[0];
my $I_z = $I_sort[-1];

print OUTPUT "\n";
print OUTPUT "I_x and I_z values found! (step 1):\n";
print OUTPUT "I_x = $I_x\n";
print OUTPUT "I_z = $I_z\n";

# Finding the coordinates of the directing vectors
my (@XaYaZa_Ix, @XaYaZa_Iz);

my $count;
foreach (@I) {
    if ($_ =~ /$I_x/) {@XaYaZa_Ix = ($X_a[$count], $Y_a[$count], $Z_a[$count])}
    $count++;
}

$count = 0;
foreach (@I) {
    if ($_ =~ /$I_z/) {@XaYaZa_Iz = ($X_a[$count], $Y_a[$count], $Z_a[$count])}
    $count++;
}

print OUTPUT "\n";
print OUTPUT "$small_space\n";
printf OUTPUT "|%-47s|\n", "Coordinates of the directing vectors (step 1)";
print OUTPUT "$small_space\n";
printf OUTPUT "|%11s|%-11s|%-11s|%-11s|\n", "", "i", "j", "k";
print OUTPUT "$small_space\n";
printf OUTPUT "|%-11s|%-11.${s_f_vector}f|%-11.${s_f_vector}f|%-11.${s_f_vector}f|\n", "a_x", $XaYaZa_Ix[0], $XaYaZa_Ix[1], $XaYaZa_Ix[2];
print OUTPUT "$small_space\n";
printf OUTPUT "|%-11s|%-11.${s_f_vector}f|%-11.${s_f_vector}f|%-11.${s_f_vector}f|\n", "a_z", $XaYaZa_Iz[0], $XaYaZa_Iz[1], $XaYaZa_Iz[2];
print OUTPUT "$small_space\n";

@I = ();
@X_a = ();
@Y_a = ();
@Z_a = ();

for (my $X_a = $XaYaZa_Ix[0] - $limit; $X_a <= $XaYaZa_Ix[0] + $limit; $X_a = $X_a + $accuracy_2) {
    for (my $Y_a = $XaYaZa_Ix[1] - $limit; $Y_a <= $XaYaZa_Ix[1] + $limit; $Y_a = $Y_a + $accuracy_2) {
        for (my $Z_a = $XaYaZa_Ix[2] - $limit; $Z_a <= $XaYaZa_Ix[2] + $limit; $Z_a = $Z_a + $accuracy_2) {
            my $I;
            for (my $n = 0; $n <= $total_number_of_atoms - 1; $n++) {
                $I += $masses[$n] * (&distance($X[$n], $Y[$n], $Z[$n], $X_a, $Y_a, $Z_a)) ** 2;
            }
            push @I, $I;
            push @X_a, $X_a;
            push @Y_a, $Y_a;
            push @Z_a, $Z_a;
        }
    }
}

@I_sort = sort { $a <=> $b } @I;
$I_x = $I_sort[0];

$count = 0;
foreach (@I) {
    if ($_ =~ /$I_x/) {@XaYaZa_Ix = ($X_a[$count], $Y_a[$count], $Z_a[$count])}
    $count++;
}

@I = ();
@X_a = ();
@Y_a = ();
@Z_a = ();

for (my $X_a = $XaYaZa_Iz[0] - $limit; $X_a <= $XaYaZa_Iz[0] + $limit; $X_a = $X_a + $accuracy_2) {
    for (my $Y_a = $XaYaZa_Iz[1] - $limit; $Y_a <= $XaYaZa_Iz[1] + $limit; $Y_a = $Y_a + $accuracy_2) {
        for (my $Z_a = $XaYaZa_Iz[2] - $limit; $Z_a <= $XaYaZa_Iz[2] + $limit; $Z_a = $Z_a + $accuracy_2) {
            my $I;
            for (my $n = 0; $n <= $total_number_of_atoms - 1; $n++) {
                $I += $masses[$n] * (&distance($X[$n], $Y[$n], $Z[$n], $X_a, $Y_a, $Z_a)) ** 2;
            }
            push @I, $I;
            push @X_a, $X_a;
            push @Y_a, $Y_a;
            push @Z_a, $Z_a;
        }
    }
}

@I_sort = sort { $a <=> $b } @I;
$I_z = $I_sort[-1];

print OUTPUT "\n";
print OUTPUT "I_x and I_z values found! (step 2):\n";

$count = 0;
foreach (@I) {
    if ($_ =~ /$I_z/) {@XaYaZa_Iz = ($X_a[$count], $Y_a[$count], $Z_a[$count])}
    $count++;
}

@I = ();
@X_a = ();
@Y_a = ();
@Z_a = ();

# Calculation of the directing vector for the y axis
# Axis y is perpendicular at the same time axis x and axis z
# The equations of two planes plane1 and plane2 are calculated,
# the intersection of which gives the equation for the axis of rotation y.

# Сoordinates of the direction vectors of the axes x and z
my $a_x = $XaYaZa_Ix[0];
my $a_y = $XaYaZa_Ix[1];
my $a_z = $XaYaZa_Ix[2];

my $c_x = $XaYaZa_Iz[0];
my $c_y = $XaYaZa_Iz[1];
my $c_z = $XaYaZa_Iz[2];

my $i = $a_y * $c_z - $a_z * $c_y;
my $j = -1 * ($a_x * $c_z - $a_z * $c_x);
my $k = $a_x * $c_y - $a_y * $c_x;

my $plane1_x = $a_y * $k - $a_z * $j;
my $plane1_y = $a_z * $i - $a_x * $k;
my $plane1_z = $a_x * $j - $a_y * $i;
# Free term in the plane 1 equation
#my $plane1_l = $a_z * $j * $X_c - $a_x * $k * $X_c + $a_x * $k * $Y_c - 
#$a_z * $i * $Y_c + $a_x * $j * $Z_c - $a_y * $i * $Z_c;

my $plane2_x = $c_y * $k - $c_z * $j;
my $plane2_y = $c_z * $i - $c_x * $k;
my $plane2_z = $c_x * $j - $c_y * $i;
# Free term in the plane 1 equation
#my $plane2_l = $b_z * $j * $X_c - $b_x * $k * $X_c + $b_x * $k * $Y_c - 
#$b_z * $i * $Y_c + $b_x * $j * $Z_c - $b_y * $i * $Z_c;

my $b_x = $plane1_y * $plane2_z - $plane1_z * $plane2_y;
my $b_y = $plane1_z * $plane2_x - $plane1_x * $plane2_z;
my $b_z = $plane1_x * $plane2_y - $plane1_y * $plane2_x;

# Find Iy
my $I_y;
for (my $n = 0; $n <= $total_number_of_atoms - 1; $n++) {
    $I_y += $masses[$n] * (&distance($X[$n], $Y[$n], $Z[$n], $b_x, $b_y, $b_z)) ** 2;
}

# Output all moments of inertia
print OUTPUT "\n";
print OUTPUT "$small_space\n";
printf OUTPUT "|%-47s|\n", "Moments of inertia, Da*A^2 (step 2)";
print OUTPUT "$small_space\n";
printf OUTPUT "|%-15s|%-15s|%-15s|\n", "Ix", "Iy", "Iz";
print OUTPUT "$small_space\n";
printf OUTPUT "|%-15.${s_f_moment}f|%-15.${s_f_moment}f|%-15.${s_f_moment}f|\n", $I_x, $I_y, $I_z;
print OUTPUT "$small_space\n";

# Displaying direct vectors coordinates
print OUTPUT "\n";
print OUTPUT "$small_space\n";
printf OUTPUT "|%-47s|\n", "Coordinates of the directing vectors (step 2)";
print OUTPUT "$small_space\n";
printf OUTPUT "|%11s|%-11s|%-11s|%-11s|\n", "", "i", "j", "k";
print OUTPUT "$small_space\n";
printf OUTPUT "|%-11s|%-11.${s_f_vector}f|%-11.${s_f_vector}f|%-11.${s_f_vector}f|\n", "a_x", $a_x, $a_y, $a_z;
print OUTPUT "$small_space\n";
printf OUTPUT "|%-11s|%-11.${s_f_vector}f|%-11.${s_f_vector}f|%-11.${s_f_vector}f|\n", "a_y", $b_x, $b_y, $b_z;
print OUTPUT "$small_space\n";
printf OUTPUT "|%-11s|%-11.${s_f_vector}f|%-11.${s_f_vector}f|%-11.${s_f_vector}f|\n", "a_z", $c_x, $c_y, $c_z;
print OUTPUT "$small_space\n";
print OUTPUT "\n";

close OUTPUT;

# ======================================================================
# =========================== Functions ================================
# ======================================================================

# The function returns the distance between the atom and 
# the line defined by the directing vector a = (X_a; Y_a; Z_a):
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