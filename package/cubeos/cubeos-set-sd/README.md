# cubeos-set-sd

This application sets the SD slot which should be used during the next system boot.

## Usage

```

	Usage :  cubeos-set-sd [-h] <SD>
 
	<SD> :  Number of SD slot to boot from. Must be 0 or 1
	-h :  Print help
	
```

## Example
 
```

	$ cubeos-set-sd 1
	Booting SD card slot has been updated. In order for these changes to take effect, the system must be rebooted.

```
