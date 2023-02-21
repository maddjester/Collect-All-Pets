from clicknium import clicknium as cc, ui, locator

tab = cc.edge.open("https://www.pockettactics.com/collect-all-pets/codes", is_maximize=False, is_wait_complete=False)

codes = tab.find_elements(locator.pockettactics.strong_itsalwaysadesert)

for code in codes:
    print(f'"{code.get_text()}",')
