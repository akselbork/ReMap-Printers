
[CmdletBinding()]
Param(
    [parameter(mandatory=$true)]
    [array[]]$old_servers, # = "SRVDC01", # = "SRVDC01","test"
    [parameter(mandatory=$true)]
    [string]$new_server #= "SRVPRT02" # = "SRVPRT02"
)


## START LOGGING
Start-Transcript "C:\Data\Set_Network_Printers_transcript.txt"

IF (test-path "\\$new_server\PRINT$") {

    $count = 0
    $count_added = 0
    $count_deleted = 0
    $defaultprint = $null
    # GENERATE A LOGFILE BASE ON THE DATE AND TIME IT IS CREATED




    ### GET INSTALLED PRINTERS
    Write-host "START checking if any networkprinter is installed on $($env:computername)"
    TRY {
        $Networkprinters = Get-WmiObject win32_printer | Where-Object network
    } CATCH {
    }

    write-host "OLD Servers: $($old_servers -join ", ")
    Write-host "OLD Servers Count: $($old_servers.count)"

    ### GET PRINTERS ON NEW PRINTSERVER
    #$NewPrinterObject = Get-Printer -ComputerName $new_server
    Write-host "LOOPING through all installed printers"
    foreach ($printer in $Networkprinters) {
        
        $new_printerconnectionname = $null
        $NewPrinterObject = $null
        foreach ($old_server in $old_servers) {
        
            SWITCH -Regex ($printer.ServerName) {
                $old_server { $new_printerconnectionname = ($printer.name) -replace ($Matches.Values,"$new_server") }
                default { }
            }
        }

        IF (-not [string]::IsNullOrEmpty($new_printerconnectionname)) {
            write-host $new_printerconnectionname -ForegroundColor Green
            ### GET PRINTER ON NEW PRINTSERVER
            $count ++
            TRY {
                Write-host "TESTING: Does printerqueu $new_printerconnectionname exists..."
                $NewPrinterObject = Get-Printer $printer.ShareName -ComputerName $new_server -ErrorAction Stop
            } CATCH {
                Write-host "TESTING: Printerqueu $new_printerconnectionname DOES NOT exists..."
            }

            IF ($NewPrinterObject.Shared -eq $true) {
                TRY {
                    Write-host "ADDING: $new_printerconnectionname"
                    Add-Printer -ConnectionName $new_printerconnectionname -ErrorAction Stop
                    $count_added ++
                    IF ($printer.Default) {
                        $defaultprint = $new_printerconnectionname
                        (new-object -ComObject WScript.Network).SetDefaultPrinter( (Get-WmiObject win32_printer | Where-Object name -EQ $new_printerconnectionname ).name)
                    }
                } CATCH {
                }
            } ELSE {
                Write-Warning "$new_printerconnectionname does not exist.. old printer is going to be deleted..."
            }# END IF
            
            TRY {
                Write-host "$($printer.name) is being deleted...." -ForegroundColor Yellow
                $printer.Delete()
                $count_deleted ++
            } CATCH {
            }

        } ELSE {
        
        }# END IF
    }

    Write-host "TOTAL:           Installed Network printers - $($Networkprinters.count)"
    Write-host "NEW:             Added new network printers - $($count_added)"
    Write-host "REMOVED:         Deleted network printers   - $($count_deleted)"

    IF (-not [string]::IsNullOrEmpty($defaultprint)) {
        Write-host "DEFAULT PRINTER: $defaultprint"
    } 
} ELSE {
    Write-Warning "Not connection to New Printserver - $new_server..."

}
## END LOGGING
Stop-Transcript




## SHOW AFTER RECONFIGURATION
#Get-WmiObject win32_printer | Where-Object network | select name, sharename, systemname, default
