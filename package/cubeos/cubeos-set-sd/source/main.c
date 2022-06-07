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
 * This application sets the SD slot which should be used during the next
 * system boot.
 *
 * Usage :  cubeos-set-sd [-h] <SD>
 *
 * <SD> :  Number of SD slot to boot from. Must be 0 or 1
 *   -h :  Print help
 *
 */

#include <errno.h>
#include <fcntl.h>
#include <linux/spi/spidev.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <unistd.h>

#define SPI_ID "spi0.0"
#define SPI_DEVICE "/dev/spidev0.0"

#define WRSR   0x01 /* Write status register */
#define WRITE  0x02 /* Write memory */
#define WREN   0x06 /* Write enable */

#define AT25   0
#define SPIDEV 1

#define UNBIND 0
#define BIND   1

/*
 * bind
 *
 * This function binds and unbinds the SPI device's controlling kernel driver
 */
int8_t bind(uint8_t driver, uint8_t state)
{
    int    fd;
    int8_t ret = 0;

    char file[] = "/sys/bus/spi/drivers/spidev/unbind";

    sprintf(file, "/sys/bus/spi/drivers/%s/%s", driver ? "spidev" : "at25",
            state ? "bind" : "unbind");

    fd = open(file, O_WRONLY);
    if (fd < 0)
    {
        perror("Error opening binding file");
        ret = -1;
    }
    else
    {
        ssize_t status = write(fd, SPI_ID, sizeof(SPI_ID));
        if (status < (ssize_t) sizeof(SPI_ID))
        {
            perror("Unable to bind SPI device");
            ret = -1;
        }

        close(fd);
    }

    return ret;
}

void unmute_printk(int fd, uint8_t * level)
{
    pwrite(fd, level, 1, 0);
    close(fd);
    return;
}

/* Full-duplex SPI messaging */
int8_t spi_comms(uint8_t * tx_buffer, uint32_t tx_length, uint8_t * rx_buffer,
                 uint8_t rx_length)
{

    int fd, ret;

    if ((tx_buffer == NULL) || (rx_buffer == NULL))
    {
        return -1;
    }

    fd = open(SPI_DEVICE, O_RDWR);
    if (fd < 0)
    {
        perror("Error opening generic SPI device");
        return -1;
    }

    struct spi_ioc_transfer tr = {
        .tx_buf        = (unsigned long) tx_buffer,
        .rx_buf        = (unsigned long) rx_buffer,
        .len           = tx_length,
        .speed_hz      = 40000000,
        .bits_per_word = 8,
        .cs_change     = 0,
        .delay_usecs   = 0,
    };

    ret = ioctl(fd, SPI_IOC_MESSAGE(1), &tr);
    if (ret < 1)
    {
        perror("Error sending SPI message");
        return -1;
    }

    close(fd);

    return 0;
}

/* Enable FRAM writes */
int8_t write_enable(void)
{
    uint8_t tx_buf = 0;
    uint8_t rx_buf = 0;

    tx_buf = WREN;

    int8_t status = spi_comms(&tx_buf, 1, &rx_buf, 1);
    if (status != 0)
    {
        fprintf(stderr, "Error: write_enable failed\n");
    }

    return status;
}

/* Set the FRAM status register */
int8_t set_SR(char sr)
{
    /* Enable writes (includes to the status register)*/
    if (write_enable() != 0)
    {
        return -1;
    }

    uint8_t tx_buf[2] = { 0 };
    uint8_t rx_buf[2] = { 0 };

    tx_buf[0] = WRSR; /* Write Status Register */
    tx_buf[1] = sr;

    int8_t status = spi_comms(tx_buf, 2, rx_buf, 2);
    if (status != 0)
    {
        fprintf(stderr, "Error: set_SR failed\n");
    }

    return status;
}

/* Set the sd_byte value in FRAM memory */
int8_t set_SD(uint8_t sd_byte)
{
    /* Enable writes */
    if (write_enable() != 0)
    {
        return -1;
    }

    uint8_t tx_buf[5] = { WRITE, 0x03, 0x00, 0x00, 0x00 };

    tx_buf[4] = sd_byte;

    int8_t status = spi_comms(tx_buf, 5, tx_buf, 5);
    if (status != 0)
    {
        fprintf(stderr, "Error: set_SD failed\n");
    }

    return status;
}

int main(int argc, char * argv[])
{
    uint8_t sd_byte = 0;
    int8_t  status  = 0;

    /* Get and verify command arguments */
    if (argc != 2)
    {
        fprintf(stderr, "Error: Incorrect number of arguments\n");
        status = -1;
    }

    if (!status && !strncmp(argv[1], "-h", 2))
    {
        status = -1;
    }

    if (status == 0)
    {
        sd_byte = atoi(argv[1]);

        if (sd_byte == 1)
        {
            sd_byte = 0xFF;
        }
        else if (sd_byte != 0)
        {
            fprintf(stderr, "Error: Invalid input %s\n", argv[1]);
            status = -1;
        }
    }

    if (status != 0)
    {
        printf("\nUsage :  %s [-h] <SD>\n\n", argv[0]);
        printf(" <SD> :  Number of SD slot to boot from. Must be 0 or 1\n"
               "   -h :  Print this help\n\n");

        return -1;
    }

    /*
     * Mute informational system messages. Binding to the AT25 driver puts out
     * a super irritating/useless message that just gets in the way
     */
    int     fd = open("/proc/sys/kernel/printk", O_RDWR, O_SYNC);
    uint8_t level;
    pread(fd, &level, sizeof(level), 0);
    if (level > 5)
    {
        pwrite(fd, "5", 1, 0);
    }

    /* Bind spi0.0 as spidev (generic SPI) device */
    if (bind(AT25, UNBIND) != 0)
    {
        unmute_printk(fd, &level);
        return -1;
    }

    if (bind(SPIDEV, BIND) != 0)
    {
        bind(AT25, BIND);
        unmute_printk(fd, &level);
        return -1;
    }

    /* Turn off memory-protection */
    status = set_SR(0x00);

    /* Set the new SD byte value */
    if ((status == 0) && (status = set_SD(sd_byte)) == 0)
    {
        printf("Booting SD card slot has been updated. In order for these "
               "changes to take effect, the system must be rebooted.\n");
    }

    /* Reset the memory-protection bits */
    status |= set_SR(0x04);

    /* Rebind spi0.0 as AT25 (EEPROM/FRAM) device */
    if (bind(SPIDEV, UNBIND) != 0 || bind(AT25, BIND) != 0)
    {
        unmute_printk(fd, &level);
        return -1;
    }

    /* Reset printk level */
    unmute_printk(fd, &level);

    return status;
}

