# Initialize & Partition Windows Disks

## Summary

If you have ever added a substantial amount of disks to a Windows VM at once you might know the pain involved in intializing and partitioning them. This script will automatically detect all unintialized disks and prepare them for you. It will select MBR or GPT depending on the size of the disk, allow you configure the Drive Letter and Disk Label, and will print a summary at the end of a run.
