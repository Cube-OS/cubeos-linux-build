/*
 * KubOS Linux
 * Copyright (C) 2017 Kubos Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * cubeos-get-sd
 *
 * This application fetches and displays:
 *   - The current SD slot in use
 *   - The current setting of sd_byte, which determines which SD slot is
 *     selected during boot
 *
 */

#include <errno.h>
#include <fcntl.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

/*
 * Count the number of bits in a byte that are ones
 * Ex. count_ones(0xFF) = 8
 */
uint8_t count_ones(uint8_t byte)
{
    static const uint8_t NIBBLE_LOOKUP[16]
        = { 0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4 };

    return NIBBLE_LOOKUP[byte & 0x0F] + NIBBLE_LOOKUP[byte >> 4];
}

int main(int argc, char * argv[])
{

    char * device = "/sys/class/spi_master/spi0/spi0.0/eeprom";

    ssize_t ret;
    int     fd;

    uint8_t sd_byte = 0;
    char    sd_sel;

    /* Get SD card in use */
    fd = open("/sys/class/gpio/export", O_WRONLY);
    write(fd, "48", 2);
    close(fd);

    fd  = open("/sys/class/gpio/pioB16/value", O_RDONLY);
    ret = read(fd, &sd_sel, sizeof(sd_sel));
    close(fd);

    fd = open("/sys/class/gpio/unexport", O_WRONLY);
    write(fd, "48", 2);
    close(fd);

    if (sd_sel == '0')
    {
        sd_byte = 1;
    }
    else
    {
        sd_byte = 0;
    }

    printf("Current SD card in use: %x\n", sd_byte);

    /* Get current sd_byte value */
    fd = open(device, O_RDWR | O_SYNC);
    if (fd < 0)
    {
        perror("Error opening FRAM");
        return -1;
    }

    /* Read current sd_byte value */
    pread(fd, &sd_byte, sizeof(sd_byte), 0x30000);
    if (ret < (int) sizeof(sd_byte))
    {
        perror("Protected read failed");
        close(fd);
        return -1;
    }

    /* Convert the value into valid user inputs (either 0 or 1) */
    uint8_t ones = count_ones(sd_byte);

    if (ones > 4)
    {
        sd_byte = 1;
    }
    else if (ones < 4)
    {
        sd_byte = 0;
    }

    if (ones != 4)
    {
        printf("Current sd_byte value:  %x\n", sd_byte);
    }
    else
    {
        fprintf(stderr, "Error: sd_byte has become corrupted. Please reset "
                        "with cubeos_set_sd command\n");
    }

    close(fd);

    return 0;
}

