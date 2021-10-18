# ReMap-Printers
Collection of scripts to ReMap existing networkprinters 

## Description 
As the "PrintNightmare" ball is still rolling, Microsoft keeps making the job as a Printer administrator a troublesome task.
This script "ReMapNetworkPrinters.ps1" I created as an "implementation specialist" at one of Europe larges IT companies. 
The task was to reinstall the printqueues on client computers after having move the existing printservices from the customers own environment to a hosted environment, without having to both the users with old installed printerqueues not working, and then given the Helpdesk an unbelievable amount of extra calls from unhappy users.

But as the new October 2021 security patch seems to force the printerqueues to be reinstalled on the printservers, then the queues on the client is likewice having to be reinstalled.


INPUT:        TYPE   NOTE
--------------------------------------------
Old_servers   Array  Name of the existing printservers (can be multiple)
New_server    string Name of the new printserver


Following steps within the script
1. START transscript
2. Controlling access to the share "PRINT$" on the new printserver
3. Get all installed printers on the client, that are connected to the old printservers
4. BEGIN LOOP - ForEach found printerqueue
4. Foreach printer from the "old_servers" the printername is replaced by a new value based on the "new_server" 
5. Control if the printerqueue exists on the new printserver
6. Control if the printerqueue is "shared", if so, install the printqueue on the client
7. If the printerqueue is existing "Default printer", then set the new as it
8. Old printerqueues is uninstalled from the client
9. END LOOP - ForEach found printerqueue
10. END Transcript
