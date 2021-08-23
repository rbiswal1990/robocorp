*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.
Library           RPA.Browser.Selenium
Library           RPA.Tables
Library           OperatingSystem
Library           RPA.PDF
Library           Telnet
Library           RPA.Archive



*** Keywords ***
Open the robot order website
    Open Available Browser  https://robotsparebinindustries.com/#/robot-order
    
*** Keywords ***
Close the annoying modal
    Wait Until Element Is Visible    xpath:/html/body/div/div/div[2]/div/div/div/div/div/button[1]
    Click Button    OK

*** Keywords ***
Fill the form
    [Arguments]    ${row}
    Click Element    id:head
    Click Element    xpath://*[@id='head']/option[@value='1']
    Click Element    id:id-body-1
    Input Text    css:input[placeholder='Enter the part number for the legs']    ${row}[Legs]
    Input Text    css:input[placeholder='Shipping address']    ${row}[Address]


*** Keywords ***
Preview the robot
    Click Button    preview


*** Keywords ***
Submit the order
    Wait Until Element Is Visible    id:order
    Click Button    order


*** Keywords ***
Store the receipt as a PDF file
    [Arguments]  ${Order number}
    Wait Until Element Is Visible    id:receipt
    ${receipt_html}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${receipt_html}    ${CURDIR}${/}recipts${/}${Order number}.pdf

*** Keywords ***
Take a screenshot of the robot
    [Arguments]  ${Order number}
    Screenshot    css:div#order-completion   ${CURDIR}${/}recipts_images${/}${Order number}.png

*** Keywords ***
Embed the robot screenshot to the receipt PDF file
    [Arguments]  ${screenshot}  ${pdf}  ${Order number}
    Open PDF    ${CURDIR}${/}recipts${/}${Order number}.pdf
    Append To File    ${CURDIR}${/}recipts_images${/}${Order number}.png    ${Order number}.png
    Save Field Values  output_path=${CURDIR}${/}recipts${/}${Order number}.pdf

*** Keywords ***
Go to order another robot
    Click Button    order-another

*** Keywords ***
Create a ZIP file of the receipts
   Archive Folder With ZIP   ${CURDIR}${/}receipts  receipts.zip   recursive=True  include=*.robot  exclude=/.*
   @{files}                  List Archive             receipts.zip
   FOR  ${file}  IN  ${files}
      Log  ${file}
   END
   Add To Archive            .${/}..${/}missing.robot  receipts.zip
   &{info}                   Get Archive Info


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    ${orders}=   Read Table From Csv    ${CURDIR}${/}inputfiles${/}orders.csv
    Write table to CSV    ${orders}    ${OUTPUT_DIR}${/}op1files.csv
    FOR    ${row}    IN    @{orders}
        Close the annoying modal
        Fill the form    ${row}
        Preview the robot
        Submit the order
        ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
        ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}  ${row}[Order number]
        Go to order another robot
    END
    Create a ZIP file of the receipts
