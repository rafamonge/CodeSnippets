### To install

Note: the spaces after binpath= etc. are relevant.

    sc create "awesomeService" binpath= "C:\WindowsService\DEV\WindowsService\WindowsService\bin\Debug\WindowsService.exe" displayname= "awesomeService"

### To start stop delete

	sc start awesomeService
	sc stop awesomeService
	sc delete awesomeService
