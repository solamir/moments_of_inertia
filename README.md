# Moment of inertia

The program calculates the minimum (*Ix*) and maximum (*Iz*) moments of inertia of the molecule using atomic coordinates from the [XYZ file](https://en.wikipedia.org/wiki/XYZ_file_format).

## System requirements

For normal operation of the program, at least 2 Gb of RAM is required. However, when calculating large molecules (more than 30 atoms), the recommended amount of RAM is 4 Gb.

## Software requirements

To run the program, you need a Perl interpreter of version not lower than 5.10 and a shell to start the program. The program can run as a Unix command shell on the Linux operating system, in which the Perl interpreter is usually present with the system, and on the Microsoft Windows operating system using the Windows Power Shell and the installed Perl interpreter, for example, [Strawberry Perl](http://strawberryperl.com/).

## Usage

To use the program, run it in the shell with the location of the XYZ file, for example:

```
$ ./moments_of_inertia.pl filename.xyz
```

The program will create a text file *filename.txt* with the results of the calculation in the directory where the file *filename.xyz* is located. Examples of source XYZ files can be found in the *Examples* folder. For example, launching the program with the file *Pentane.xyz* will create the file *Pentane.txt* with the results of the calculation:

```
This is Moment of inertia version 1.1
System date is Mon Feb 25 20:18:04 2019
Calculation for data from file /mnt/e/Pentane.xyz

The calculation with step of the directing vector is 0.05

-------------------------------------------------
|Coordinates of the center of gravity           |
-------------------------------------------------
|x              |y              |z              |
-------------------------------------------------
|3.13712        |0.78884        |-0.90687       |
-------------------------------------------------

-------------------------------------------------
|Moments of inertia, Da*A^2                     |
-------------------------------------------------
|Ix                     |Iz                     |
-------------------------------------------------
|29.989                 |269.277                |
-------------------------------------------------
-------------------------------------------------------
```

You can set the parameters of the program using the following startup keys:

**-v** - Show program version and exit.

**-a[1-5]** - Accuracy counting. Sets the interval of movement of the directing vector of the axis of rotation in space. The smaller the interval, the more accurate and longer the calculation takes place (see the principle of operation): **-a1** – 0.1; **-a2** – 0.05; **-a3** – 0.01; **-a4** – 0.005;**-a5** – 0.001. The default key is **-a3**.

**-o[1-5]** - The number of significant figures to which the value of the moments of inertia will be rounded (in units of Da * Å2). The default key is **-o3**.

**-d** - Display coordinates of axis directing vectors with minimum and maximum inertia moments.

**-i** - Display the initial information for the calculation.

For example, the result of the calculation for the pentane molecule using the XYZ file from the *Examples* folder with the keys **-a2** **-o4** **-d** will look like this:

```
$ ./moments_of_inertia.pl -a2 -o4 -d ./Pentane.xyz
$ cat ./Pentane.txt
This is Moment of inertia version 1.1
System date is Mon Feb 25 20:24:44 2019
Calculation for data from file /mnt/e/Pentane.xyz

The calculation with step of the directing vector is 0.05

-------------------------------------------------
|Coordinates of the center of gravity           |
-------------------------------------------------
|x              |y              |z              |
-------------------------------------------------
|3.13712        |0.78884        |-0.90687       |
-------------------------------------------------

-------------------------------------------------
|Moments of inertia, Da*A^2                     |
-------------------------------------------------
|Ix                     |Iz                     |
-------------------------------------------------
|29.9888                |269.2769               |
-------------------------------------------------

-------------------------------------------------
|Coordinates of the directing vectors           |
-------------------------------------------------
|           |i          |j          |k          |
-------------------------------------------------
|a_x        |0.55       |0.25       |-0.3       |
-------------------------------------------------
|a_z        |0          |-0.85      |-0.7       |
-------------------------------------------------
-------------------------------------------------------
```

*Note!*

* Usually, 3D-visualization programs of molecules store XYZ files with a coordinate grid, in which 1 Å is taken as a unit of length. If this condition is not met, the program will calculate the moments of inertia incorrectly in absolute value, but in the correct ratios.
* Calculation is available for molecules consisting of the following atoms: H, B, C, N, O, F, Na, Mg, Al, Si, P, S, Cl, Br, I.

## Contacts

With corrections, questions, comments and suggestions, please email:

* Mikhail Koverda m.kov@pm.me
* Eugene N. Ofitserov ofitser@mail.ru

## License

This program is licensed under the GNU General Public License v3.0.

## Principle of operation

The XYZ file is a text file in which for each atom of the molecule its coordinates are indicated in the Cartesian system, for example, the XYZ file for pentane contains the following information:

```
17

C      0.88843      0.03444      0.00635
C      2.40855      0.05283     -0.01558
C      2.94163      0.96482     -1.12020
C      4.46987      0.98077     -1.13892
C      5.00405      1.88707     -2.23658
H      0.52876     -0.62374      0.80344
H      0.48677     -0.33185     -0.94384
H      0.48652      1.03669      0.18608
H      2.77834     -0.96831     -0.16472
H      2.77808      0.39277      0.95890
H      2.56526      1.98395     -0.96898
H      2.56572      0.62305     -2.09233
H      4.85117     -0.03520     -1.29421
H      4.85071      1.32591     -0.17064
H      4.66744      1.54992     -3.22215
H      6.09853      1.88355     -2.23189
H      4.66701      2.91854     -2.09234
```

The program works according to the following algorithm:

1. Data from the file is read and the symbol of the element is replaced with the value of its atomic mass in Daltons.
2. Calculate the coordinates of the center of gravity of the molecule.
3. A straight line is set that passes through the center of gravity of the molecule and has an arbitrary direction vector, for example ***a*** = (0, -1, -1).
4. The coordinates of the direction vector iteratively change with a certain interval of movement (by specifying the **–a** key) so that the direction of the vector corresponds to all possible directions of the axis of rotation in space, for example, ***ax*** =[0,1], ***ay*** = [-1,1], ***az*** = [-1,1].
5. For each position of the axis in space, the moment of inertia is calculated relative to this axis, considering the distance of each atom to this axis and stored in memory.
6. After the calculation of the moments of inertia for all positions of the axis, the program selects the largest and smallest moments of inertia and returns their values in units Da*Å^2, as well as the coordinates of the direction vectors ***a*** and ***b*** for these axes.
7. The resulting axes are always perpendicular to each other, as can be easily seen by calculating the scalar product of the directing vectors for these axes.