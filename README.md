# Moment of inertia

The program calculates the moments of inertia of the molecules Ix, Iy and Iz relative to the x, y and z axes (the axis of rotation with the minimum moment of inertia is taken as the x axis, the y and z axes are perpendicular to it and to each other). The coordinates for the atoms from the [XYZ file](https://en.wikipedia.org/wiki/XYZ_file_format) are used as data for the calculation.

## Software requirements

To run the program, you need a Perl interpreter of version not lower than 5.10 and a shell to start the program. The program can run as a Unix command shell on the Linux operating system, in which the Perl interpreter is usually present with the system, and on the Microsoft Windows operating system using the Windows Power Shell and the installed Perl interpreter, for example, [Strawberry Perl](http://strawberryperl.com/).

## System requirements

For normal operation of the program (especially for large molecules), at least 2 GB of RAM is required.

## Usage

To use the program, run it in the shell with the location of the XYZ file, for example:

```
$ ./moments_of_inertia.pl filename.xyz
```

The program will create a text file *filename.txt* with the results of the calculation in the directory where the file *filename.xyz* is located. Examples of source XYZ files can be found in the *Examples* folder.

You can set the parameters of the program using the following startup keys:

```-v (--version)``` Show program version and exit.

```-h (--help)``` Show short help and exit.

```-a[1-3]``` Accuracy counting. Sets the interval of movement of the directing vector for the axis of rotation in space. The smaller the interval, the more accurate and longer the calculation takes place: **-a1** – 0.1; **-a2** – 0.05; **-a3** – 0.01; **-a4** – 0.005;**-a5** – 0.001. The default key is **-a3**.

| Key | Movement of the directing vector (step 1) | Movement of the directing vector (step 2) |
|:----:|:----:|:----------:|
| ````-a1```` | 0.1 | 0.05 |
| ````-a2```` | 0.05 | 0.005 |
| ````-a3```` | 0.01 | 0.0005 |

*Note!*

* Usually, 3D-visualization programs of molecules store XYZ files with a coordinate grid, in which 1 Å is taken as a unit of length. If this condition is not met, the program will calculate the moments of inertia incorrectly in absolute value, but in the correct ratios.
* Calculation is available for molecules consisting of the following atoms: H, B, C, N, O, F, Na, Mg, Al, Si, P, S, Cl, Br, I.

## Contacts

With corrections, questions, comments and suggestions, please email:

* Mikhail N. Koverda m.kov@pm.me
* Anna A. Koverda a.koverda@pm.me
* Eugene N. Ofitserov ofitser@mail.ru

## License

This program is licensed under the GNU General Public License v3.0.