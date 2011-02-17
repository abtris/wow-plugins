-- TradeSkillMaster_AuctionDB Locale - ruRU
-- Please use the localization app on CurseForge to update this
-- http://wow.curseforge.com/addons/TradeSkillMaster_AuctionDB/localization/

local L = LibStub("AceLocale-3.0"):NewLocale("TradeSkillMaster_AuctionDB", "ruRU")
if not L then return end

L["%s has a market value of %s and was seen %s times last scan and %s times total. The stdDev is %s."] = "Рыночная стоймость %s равна %s, %s лотов было замечено во время последнего сканирования, всего замечено лотов %s."
L["Alchemy"] = "Алхимия"
L["Auction house must be open in order to scan."] = "Сканирование невозможно, если окно аукциона закрыто."
L["AuctionDB"] = "AuctionDB"
L["AuctionDB - Auction House Scanning"] = "AuctionDB - сканирование аукциона"
L["AuctionDB - Run Scan"] = "AuctionDB - запустить сканирование"
L["AuctionDB - Scanning"] = "AuctionDB - сканирование"
L["AuctionDB Market Value:"] = "AuctionDB рыночная цена:"
L["AuctionDB Min Buyout:"] = "AuctionDB минимальный выкуп:"
L["AuctionDB Seen Count:"] = "Сколько раз появлялся на ауке (данные AuctionDB):"
L["Blacksmithing"] = "Кузнечное дело"
L["Complete AH Scan"] = "Полное сканирование аукциона"
L["Cooking"] = "Кулинария"
L["Enable display of AuctionDB data in tooltip."] = "Включить отображение данных AuctionDB в подсказке."
L["Enchanting"] = "Наложение чар"
L["Engineering"] = "Инженерия"
L["Error: AuctionHouse window busy."] = "Ошибка: Окно аукциона занято."
L["GetAll Scan:"] = "GetAll сканирование:"
L[ [=[If checked, a GetAll scan will be used whenever possible.

WARNING: With any GetAll scan there is a risk you may get disconnected from the game.]=] ] = [=[Отметьте для использования GetAll сканирования при первой возможности.
Внимание: при GetAll сканировании ест риск разрыва соединения с сервером.]=]
L["If checked, a regular scan will scan for this profession."] = "Отметьте, чтобы провести обычное сканирования для этой профессии."
L["Inscription"] = "Начертание"
L["Item Lookup:"] = "Поиск предмета:"
L["Jewelcrafting"] = "Ювелирное дело"
L["Leatherworking"] = "Кожевничество"
L["No data for that item"] = "Нет данных об этом предмете."
L["Not Ready"] = "Не готово"
L["Nothing to scan."] = "Нечего сканировать."
L["Professions to scan for:"] = "Для каких профессий просканировать:"
L["Ready"] = "Готово"
L["Ready in %s min and %s sec"] = "Готовность через %s  мин %s  сек."
L["Run GetAll Scan"] = "Запустить GetAll сканирование"
L["Run GetAll Scan if Possible"] = "Запустить GetAll сканирование, если можно."
L["Run Regular Scan"] = "Запустить обычное сканирование."
L["Run Scan"] = "Запустить сканирование"
L["Scan complete!"] = "Сканирование завершено!"
L["Scan interupted due to auction house being closed."] = "Сканирование прекращено, так как окно аукциона было закрыто."
L[ [=[Starts scanning the auction house based on the below settings.

If you are running a GetAll scan, your game client may temporarily lock up.]=] ] = [=[Начать сканирование аукциона с заданными настройками.
Если вы запустите GetAll сканирование, клиент игры может на какое-то время "повиснуть".]=]
L["Tailoring"] = "Портняжное дело."
L["resets the data"] = "Очистить данные"
L["|cffff0000WARNING:|r As of 4.0.1 there is a bug with GetAll scans only scanning a maximum of 42554 auctions from the AH which is less than your auction house currently contains. As a result, thousands of items may have been missed. Please use regular scans until blizzard fixes this bug."] = "|cffff0000Внимание: с патча 4.0.1 из-за бага GetAll сканирует только 42554 лота, что меньше общего количества лотов сейчас на вашем аукционе. Тысячи лотов могут быть не учтены. До тех пор, пока Blizzard не исправит эту ошибку, пользуйтесь обычным способом сканирования. "
