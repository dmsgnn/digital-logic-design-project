# __Digital logic design project__

This project has been developed as part of the BSc thesis and represents the final exam of the course "Reti Logiche" ("Logic Networks") attended during my Bachelor's Degree (A.Y. 2020/21) at the Polytechnic University of Milan. The highest possible final grade has been achieved: 30 cum Laude.

## __Description__
Aim of this project was to design, test and syntethize, using the VHDL hardware description language, an hardware component capable of equalizing an image. The component had to interface with a memory, taking the original version of the image from it and writing the final computed one on it.

The grade was assigned using test cases and on the basis of the final [report](report.pdf).

## __Functionalities__
The implemented equalizer takes an input represented by the following format: the first byte is the image width, the second byte is the image height and the next bytes represent pixels color information.

The maximum image size is 128x128 pixels. Further details can be found in the [project specification](project_specification_20_21.pdf).

## __Tests__
An example test can be found in the [testbench](/testbench) folder. Test cases used fot the evaluation were unknown during the development.