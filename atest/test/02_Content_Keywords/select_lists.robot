*** Settings ***
Resource        imports.resource

Test Setup      New Page    ${FORM_URL}
Test Timeout    10s

*** Test Cases ***
Page Should Contain List
    Get Element Count    select[name=interests]    ==    1

Get Select Options
    ${list} =    Get Select Options    select[name=preferred_channel]    validate    len(value) == 3
    Length Should Be    ${list}    3
    Get Select Options    select[name=preferred_channel]    validate
    ...    [v["label"] for v in value] == ["Email", "Telephone", "Direct mail"]
    Get Select Options    select[name=preferred_channel]    validate    value[0]['index'] == 0
    Get Select Options    select[name=preferred_channel]    validate    value[2]['label'] == 'Direct mail'
    ${options} =    Get Select Options    select[name=possible_channels]
    Should be equal    ${options}[0][label]    Email
    Should be equal    ${options}[1][value]    phone

Get Select Options Strict
    Run Keyword And Expect Error
    ...    *strict mode violation*//select*resolved to 3 elements*
    ...    Get Select Options    //select
    Set Strict Mode    False
    ${options} =    Get Select Options    //select
    Length Should Be    ${options}    3
    [Teardown]    Set Strict Mode    True

Get Selected Options
    [Documentation]
    ...    Verifying list 'preferred_channel' has options [Telephone] selected.
    ...    Verifying list 'possible_channels' has options [ Email | Telephone ] selected.
    ...    Verifying list 'interests' has no options selected.
    ...    Verifying list 'possible_channels' fails if assert all options selected.
    ${selection} =    Get Selected Options    select[name=preferred_channel]    label    ==    Telephone
    Should Be Equal    ${selection}    Telephone
    Get Selected Options    select[name=preferred_channel]    value    ==    phone
    Get Selected Options    select[name=possible_channels]    text    ==    Email    Telephone
    Get Selected Options    select[name=possible_channels]    text    validate    len(value) == 2
    Get Selected Options    select[name=possible_channels]    label    ==    Telephone    Email
    ${selection} =    Get Selected Options    select[name=possible_channels]    value    ==    phone    email
    Should Be Equal    ${selection}[0]    email
    Should Be Equal    ${selection}[1]    phone
    Get Selected Options    select[name=interests]    label    ==
    ${selection} =    Get Selected Options    select[name=interests]    label    ==
    Should Be Equal    ${selection}    ${None}
    Run Keyword And Expect Error    *    Get Selected Options    select[name=possible_channels]    label    ==
    ...    Email    Telephone    Direct mail

Get Selected Options With Not Matching Attribute Value
    Run Keyword And Expect Error
    ...    Selected Options: 'phone' (str) should be 'kala' (str)
    ...    Get Selected Options    select[name=preferred_channel]    value    ==    kala

Get Select Options With Not Matching Value
    Run Keyword And Expect Error
    ...    Not Here
    ...    Get Select Options    select[name=preferred_channel]    ==    Email    Not Here

Get Selected Options with xpath
    ${selection} =    Get Selected Options    //html/body/form/table/tbody/tr[8]/td[2]/select    label    ==
    ...    Telephone
    Should Be Equal    ${selection}    Telephone

Get Selected Options With Nonmatching Selector
    Set Browser Timeout    50ms
    Run Keyword And Expect Error    *Timeout 50ms exceeded.*waiting for selector "notamatch"*    Get Selected Options
    ...    notamatch
    [Teardown]    Set Browser Timeout    ${PLAYWRIGHT_TIMEOUT}

Select Option By label
    ${selection} =    Create List    Direct mail
    ${selected} =    Select Option And Verify Selection    label    select[name=preferred_channel]    @{selection}
    Lists Should Be Equal    ${selected}    ${selection}

Select Options By value
    ${selection} =    Create List    males    females    others
    ${selected} =    Select Option And Verify Selection    value    select[name=interests]    @{selection}
    Lists Should Be Equal    ${selected}    ${selection}

Select Options By index
    ${selection} =    Create List    0    2
    ${selected} =    Select Option And Verify Selection    index    select[name=possible_channels]    @{selection}
    Lists Should Be Equal    ${selected}    ${selection}

Select Options By text
    ${selection} =    Create List    Males    Females
    ${selected} =    Select Option And Verify Selection    text    select[name=interests]    @{selection}
    Lists Should Be Equal    ${selected}    ${selection}

Select Options By With Nonmatching Selector
    Set Browser Timeout    50ms
    Run Keyword And Expect Error    *Timeout 50ms exceeded.*waiting for selector "notamatch"*
    ...    Select Options By
    ...    notamatch    label    False    Label
    [Teardown]    Set Browser Timeout    ${PLAYWRIGHT_TIMEOUT}

Deselect Options Implicitly
    Select Option And Verify Selection    text    select[name=possible_channels]

Deselect Options Explicitly
    Deselect Options    select[name=possible_channels]
    Get Selected Options    select[name=possible_channels]    text    ==

Deselect Options With Strict
    Run Keyword And Expect Error
    ...    *strict mode violation*//select*resolved to 3 elements*
    ...    Deselect Options    //select
    Set Strict Mode    False
    Deselect Options    //select
    [Teardown]    Set Strict Mode    True

Deselect Options With Nonmatching Selector
    Set Browser Timeout    50ms
    Run Keyword And Expect Error    *Timeout 50ms exceeded.*waiting for selector "notamatch"*    Deselect Options
    ...    notamatch
    [Teardown]    Set Browser Timeout    ${PLAYWRIGHT_TIMEOUT}

*** Keywords ***
Select Option And Verify Selection
    [Arguments]    ${attribute}    ${list_id}    @{selection}
    ${selected} =    Select Options By    ${list_id}    ${attribute}    @{selection}
    Get Selected Options    ${list_id}    ${attribute}    ==    @{selection}
    [Return]    ${selected}
