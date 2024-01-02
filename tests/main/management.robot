*** Settings ***
Resource    ../resources/common.robot
Library    Cumulocity

Suite Setup    Set Main Device

*** Test Cases ***

Install package via file
    # Note: The tedge package was downloaded using: snap download hello-world
    ${binary_url}=    Cumulocity.Create Inventory Binary    hello-world    binary    file=${CURDIR}/../testdata/hello-world_29.snap
    ${operation}=    Cumulocity.Install Software    hello-world,latest::snap,${binary_url}
    Operation Should Be SUCCESSFUL    ${operation}
    Cumulocity.Device Should Have Installed Software    hello-world,6.4

Install/Uninstall package via Cumulocity
    # install
    ${operation}=    Cumulocity.Install Software    hello-world,latest::snap    timeout=180
    Operation Should Be SUCCESSFUL    ${operation}
    Cumulocity.Device Should Have Installed Software    hello-world

    # remove
    ${operation}=    Cumulocity.Uninstall Software    hello-world,latest::snap    timeout=180
    Operation Should Be SUCCESSFUL    ${operation}
    ${mo}=    Cumulocity.Device Should Have Fragments    c8y_SoftwareList
    Log    ${mo}
    Should Not Contain    ${mo}    hello-world
