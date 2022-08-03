// For lab4 https://cs50.harvard.edu/x/2022/labs/4/
// Modifies the volume of an audio file

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

// Number of bytes in .wav header
const int HEADER_SIZE = 44;

int main(int argc, char *argv[])
{
    // Check command-line arguments
    if (argc != 4)
    {
        printf("Usage: ./volume input.wav output.wav factor\n");
        return 1;
    }

    // Open files and determine scaling factor
    FILE *input = fopen(argv[1], "r");
    if (input == NULL)
    {
        printf("Could not open file.\n");
        return 1;
    }

    FILE *output = fopen(argv[2], "w");
    if (output == NULL)
    {
        printf("Could not open file.\n");
        return 1;
    }

    float factor = atof(argv[3]);

    // array of bytes to store the WAV file header
    uint8_t header[HEADER_SIZE];

    // read header from input and write to output file
    fread(&header, sizeof(header), 1, input);
    fwrite(&header, sizeof(header), 1, output);

    // 2 byte buffer for wav samples
    int16_t buffer;

    // loop until the EOF
    while (fread(&buffer, sizeof(buffer), 1, input))
    {
        // multiply the sample by the volume factor
        buffer = buffer * factor;
        // write the new value to the output file
        fwrite(&buffer, sizeof(buffer), 1, output);
    }

    // Close files
    fclose(input);
    fclose(output);
}
