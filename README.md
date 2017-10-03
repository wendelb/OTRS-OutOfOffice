# OTRS Out of Office filter

This module prevents tickets from reopening after receiving an out of office response to the closeing message. It is heavily inspired by [this post on OtterHub](http://forums.otterhub.org/viewtopic.php?p=98057#p98057).

## Installation

Put these 2 files in the following locations (base path is the OTRS root path):

* `OutOfOffice.xml` into the folder `Kernel/Config/Files`
* `OutOfOffice.pm` into the folder `Kernel/System/PostMaster/Filter`

## Configuration

This module can be fully configured via the SysConfig module in OTRS. Please visit `Core::PostMaster` inside the `Ticket` group. After you enabled this module, there is one setting:

* `Match`: This contains an array of substrings. These substrings will be matched case-insensitive against all incoming email subjects.
* `Debug`: 1 = Enable additional debug messages (you need to create this parameter first)


## LICENSE

This project is licensed under the MIT License.